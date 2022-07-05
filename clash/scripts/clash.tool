#!/system/bin/sh

. /data/adb/clash/scripts/path.sc

monitor_local_ipv4() {
    local_ipv4=$(ip a | awk '$1~/inet$/{print $2}')
    local_ipv4_number=$(ip a | awk '$1~/inet$/{print $2}' | wc -l)
    rules_ipv4=$(${IPTABLES_WAIT} -t mangle -nvL FILTER_LOCAL_IP | grep "ACCEPT" | awk '{print $9}')
    rules_number=$(${IPTABLES_WAIT} -t mangle -L FILTER_LOCAL_IP | grep "ACCEPT" | wc -l)

    if [ ${local_ipv4_number} -ne ${rules_number} ] ; then
        for rules_subnet in ${rules_ipv4[*]} ; do
            wait_count=0
            a_subnet=$(ipcalc -n ${rules_subnet} | awk -F '=' '{print $2}')
            for local_subnet in ${local_ipv4[*]} ; do
                b_subnet=$(ipcalc -n ${local_subnet} | awk -F '=' '{print $2}')

                if [ "${a_subnet}" != "${b_subnet}" ] ; then
                    wait_count=$((${wait_count} + 1))
                    
                    if [ ${wait_count} -ge ${local_ipv4_number} ] ; then
                        ${IPTABLES_WAIT} -t mangle -D FILTER_LOCAL_IP -d ${rules_subnet} -j ACCEPT
                    fi
                fi
            done
        done

        for subnet in ${local_ipv4[*]} ; do
            if ! (${IPTABLES_WAIT} -t mangle -C FILTER_LOCAL_IP -d ${subnet} -j ACCEPT > /dev/null 2>&1) ; then
                ${IPTABLES_WAIT} -t mangle -I FILTER_LOCAL_IP -d ${subnet} -j ACCEPT
            fi
        done

        unset a_subnet
        unset b_subnet
    else
        exit 0
    fi

    unset local_ipv4
    unset local_ipv4_number
    unset rules_ipv4
    unset rules_number
    unset wait_count
}

keep_dns() {
    local_dns=`getprop net.dns1`

    if [[ "${local_dns}" != "${STATIC_DNS}" ]] ; then
        for count in $(seq 1 $(getprop | grep dns | wc -l)); do
            setprop net.dns${count} ${STATIC_DNS}
        done
    fi

    if [[ $(sysctl net.ipv4.ip_forward) != "1" ]] ; then
        sysctl -w net.ipv4.ip_forward=1
    fi

    unset local_dns
}

subscription() {
    if [ "${AUTO_SUBSCRIPTION}" = "true" ] ; then
        mv -f ${CLASH_CONFIG_FILE} ${CLASH_CONFIG_FILE}.backup
        curl -L -A 'clash' ${SUBSCRIPTION_URL} -o ${CLASH_CONFIG_FILE} >> /dev/null 2>&1

        sleep 20

        if [ -f "${CLASH_CONFIG_FILE}" ]; then
            ${SCRIPTS_DIR}/clash.service -k && ${SCRIPTS_DIR}/clash.tproxy -k
            rm -rf ${CLASH_CONFIG_FILE}.backup
            sleep 1
            ${SCRIPTS_DIR}/clash.service -s && ${SCRIPTS_DIR}/clash.tproxy -s
            if [ "$?" = "0" ] ; then
                echo "[info] : subscription renewal is successful, restart cfm." >> ${CFM_LOGS_FILE}
            else
                echo "[error] : subscription renewal was successful, but restarting cfm failed." >> ${CFM_LOGS_FILE}
            fi
        else
            mv ${CLASH_CONFIG_FILE}.backup ${CLASH_CONFIG_FILE}
            echo "[warning] : subscription renewal failed and the configuration file has been restored." >> ${CFM_LOGS_FILE}
        fi
    else
        exit 0
    fi
}

find_packages_uid() {
    echo "" > ${APPUID_FILE}
    for package in `cat ${FILTER_PACKAGES_FILE} | sort -u` ; do
        awk '$1~/'^"${package}"$'/{print $2}' ${SYSTEM_PACKAGES_FILE} >> ${APPUID_FILE}
        if [ "${mode}" = "blacklist" ] ; then
            echo "[info] : ${package} filtered." >> ${CFM_LOGS_FILE}
        elif [ "${mode}" = "whitelist" ] ; then
            echo "[info] : ${package} proxied." >> ${CFM_LOGS_FILE}
        fi
    done
}

port_detection() {
    clash_pid=`cat ${CLASH_PID_FILE}`
    match_count=0

    if ! (${BINARY_DIR}/ss -h > /dev/null 2>&1) ; then
        clash_port=$(netstat -anlp | grep -v p6 | grep "clash" | awk '$6~/'"${clash_pid}"*'/{print $4}' | awk -F ':' '{print $2}' | sort -u)
    else
        clash_port=$(${BINARY_DIR}/ss -antup | grep "clash" | awk '$7~/'pid="${clash_pid}"*'/{print $5}' | awk -F ':' '{print $2}' | sort -u)
    fi
    
    echo -ne "[info] : port active: " >> ${CFM_LOGS_FILE}
    for sub_port in ${clash_port[*]} ; do   
        echo -n "${sub_port} " >> ${CFM_LOGS_FILE}
        if [ "${sub_port}" = ${CLASH_TPROXY_PORT} ] || [ "${sub_port}" = ${CLASH_DNS_PORT} ] ; then
            match_count=$((${match_count} + 1))
        fi
    done
    
    echo "" >> ${CFM_LOGS_FILE}

    if [ ${match_count} -ge 2 ] ; then
        echo "[info] : tproxy port and dns started." >> ${CFM_LOGS_FILE}
        exit 0
    else
        echo "[error] : tproxy port and dns not starting." >> ${CFM_LOGS_FILE}
        exit 1
    fi
}

while getopts ":kfmps" signal ; do
    case ${signal} in
        s)
            if [ -f "${CLASH_PID_FILE}" ] ; then
                subscription
            else
                ${SCRIPTS_DIR}/clash.service -s && ${SCRIPTS_DIR}/clash.tproxy -s \
                && subscription \
                && ${SCRIPTS_DIR}/clash.service -k && ${SCRIPTS_DIR}/clash.tproxy -k
            fi
            ;;
        k)
            keep_dns
            ;;
        f)
            find_packages_uid
            ;;
        m)
            if [ "${mode}" = "blacklist" ] && [ -f "${CLASH_PID_FILE}" ] ; then
                monitor_local_ipv4
            else
                exit 0
            fi
            ;;
        p)
            sleep 
            port_detection
            ;;
        ?)
            echo "Usage: {s|k|f|m|p}"
            ;;
    esac
done