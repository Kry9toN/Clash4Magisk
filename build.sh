# Env
VERSION=v1.12.6
OUTDIR=out

# Create output folder
if [[ ! -d ${OUTDIR} ]] ; then
  mkdir -p ${OUTDIR}
fi

# Initial build dashboard yach
cd yacd-meta
git submodule update --remote

# Install npm i -g pnpm
pnpm i
pnpm build
cp -r public ..
cd ..

# Zipping clash
zip Clash4Magisk-${VERSION}.zip -r META-INF/ \
    clash/ \
    public/ \
    changelog.md \
    module.prop \
    uninstall.sh \
    customize.sh \
    clash_service.sh

mv Clash4Magisk-${VERSION}.zip out
rm -rf public

echo "Output saved in 'out' folder"
