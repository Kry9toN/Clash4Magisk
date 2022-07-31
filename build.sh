# Env
VERSION=v1.12.9
OUTDIR=out

# Create output folder
if [ ! -d ${OUTDIR} ]; then
  mkdir -p ${OUTDIR}
fi

# Update sub module
git submodule update --remote

# Initial build dashboard yach
cd yacd-meta

# Install npm i -g pnpm
pnpm i
pnpm build
cp -r public ..
cd ..

# Build core
cd clash-core
make android-arm64
mv bin/Clash* ../clash/core/clash
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
