#!/bin/bash -e

MIRROR='ftp://ftp.jaist.ac.jp/pub/Linux/Gentoo'
ARCH='amd64'

LATEST_STAGE3=$(curl -L ${MIRROR}/releases/${ARCH}/autobuilds/latest-stage3-${ARCH}.txt -s | awk '!/^\s*(#|$)/{print $1}')
STAGE3_FILE_NAME=${LATEST_STAGE3#*?/}
STAGE3_URL=${MIRROR}/releases/${ARCH}/autobuilds/${LATEST_STAGE3}


echo -e "\n======== Download ${STAGE3_FILE_NAME}.DIGESTS ==================================================\n"
curl -LO ${STAGE3_URL}.DIGESTS


echo -e "\n======== Download ${STAGE3_FILE_NAME} ==========================================================\n"
curl -LO ${STAGE3_URL}


echo -e "\n======== Verify ${STAGE3_FILE_NAME} chechsum ===================================================\n"
sha512sum -c <(grep -A1 SHA512 ${STAGE3_FILE_NAME}.DIGESTS | grep -E "${STAGE3_FILE_NAME}$")
