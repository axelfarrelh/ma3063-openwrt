#!/usr/bin/env bash
set -euo pipefail

OWRT_TAG="v25.12.5"
ROOT="${GITHUB_WORKSPACE}"
OWRT="${ROOT}/openwrt"
PORT="${ROOT}/src/25.12.5"

rm -rf "${OWRT}"
git clone --depth 1 --branch "${OWRT_TAG}" https://github.com/openwrt/openwrt.git "${OWRT}"

cp "${PORT}/target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq5018-ruijie-rg-ma3063.dts"    "${OWRT}/target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/"

mkdir -p "${OWRT}/target/linux/qualcommax/patches-6.12"
cp "${PORT}/target/linux/qualcommax/patches-6.12/0914-net-mdio-ipq4019-set-rg-ma3063-div64.patch"    "${OWRT}/target/linux/qualcommax/patches-6.12/"

cat "${PORT}/device-makefile-entry.txt" >> "${OWRT}/target/linux/qualcommax/image/ipq50xx.mk"

./scripts/feeds update -a
./scripts/feeds install -a

cp "${PORT}/config.fragment" "${OWRT}/.config"
cd "${OWRT}"
make defconfig

echo "==== DEVICE CHECK ===="
grep -n "ruijie_rg-ma3063" target/linux/qualcommax/image/ipq50xx.mk
grep -n "rg-ma3063-div64" target/linux/qualcommax/patches-6.12/0914-net-mdio-ipq4019-set-rg-ma3063-div64.patch || true
echo "==== BUILD ===="
make -j"$(nproc)" V=s

echo "==== ARTIFACTS ===="
find bin/targets/qualcommax/ipq50xx -maxdepth 1 -type f -printf '%f\n' | sort
