# Clash for Magisk/Clash for KernelSU
<h1 align="center">
  <img src="https://github.com/Kry9toN/Clash4Magisk/blob/master/docs/logo.png" alt="Clash" width="200">
  <br>Clash<br>
</h1>

<p align="center">Clash for Magisk is module based on shell script to control <a href="https://github.com/Dreamacro/clash">Clash</a> service and manage such like tproxy(Transparent proxy), uid-based black, and white list function, or you just want to start the Clash process alone.</p>

## How to install
  - Download on [release](https://github.com/Kry9toN/Clash4Magisk/releases) and install via Magisk Manager.

## Configure
  Root directory: ```/data/adb/clash/```

  - ```/data/adb/clash/config/``` Location for like config.yaml (edit file <b>account.yaml</b> for proxy
  - ```/data/adb/clash/core/``` Clash binary/core location folder
  - ```/data/adb/clash/run/``` For store log and etc information

  The root directory contains the following files:
  - ```_template``` Template
  - ```_proxies``` Proxy rule config
  - ```account.yaml``` Proxy account
  - ```packages.list``` Black and white list filter list, fill in the package name.

## How to use
  - Start and stop the Clash by disabling and enabling the module, or use the Dashboard software

## Question
  - Apk for manage is comming soon

## Credits
  - [kalasutra/Clash_for_magisk](https://github.com/kalasutra/Clash_For_Magisk)
  - [taamarin](https://github.com/taamarin/ClashforMagisk)
  - [riffchz](https://github.com/riffchz/ClashforMagisk)
  - [MagiskChangeKing](https://t.me/MagiskChangeKing)
  - [e58695](https://t.me/e58695)

## License
  [GNU General Public License v3.0](https://github.com/Kry9toN/Clash4Magisk/blob/master/LICENSE.md)
