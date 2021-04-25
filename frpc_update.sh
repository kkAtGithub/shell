#!/bin/bash

[ -z "${PREFIX}" ] && PREFIX=/usr/local
[ -z "${SUDO}" ] && [ "${NO_SUDO}" != "Y" ] && which sudo >/dev/null 2>&1 && SUDO=sudo

VER=$(${PREFIX}/bin/frpc -v)

RELEASE_URL="https://api.github.com/repos/fatedier/frp/releases/latest"
TMP_NAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
TMP_DIR="/tmp/frp_${TMP_NAME}"

mkdir -p "${TMP_DIR}"
pushd "${TMP_DIR}" >/dev/null

DL_URL=$(curl -s ${RELEASE_URL} | grep linux_amd64 | grep browser_download_url | cut -d '"' -f 4)

if (echo ${DL_URL} | grep ${VER}) >/dev/null 2>&1; then
    echo already latest version!
else
    wget ${DL_URL} -O frp.tar.gz
    tar zxvf frp.tar.gz
    cd frp_*

    $SUDO cp -f "frpc" "${PREFIX}/bin/"
#    $SUDO cp -f "frps" "${PREFIX}/bin/"

    CUR_VER=$(${PREFIX}/bin/frpc -v)
    echo "Update FRP Complete (${VER} -> ${CUR_VER})!"
fi

popd >/dev/null

rm -rf "${TMP_DIR}"

systemctl restart frpc
