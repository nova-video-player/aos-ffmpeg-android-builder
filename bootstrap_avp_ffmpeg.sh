#!/bin/bash

if [ `meson --version` == "0.53.2" ] 
then
  echo meson version compatible with x86 build
else
  echo ERROR: meson version not compatible with x86 build, pip3 install meson==0.53.2
  exit 1
fi
for ARCH in arm arm64 x86 x86_64; do
	case "${ARCH}" in
    'arm')
		ABI=armeabi-v7a ;;
    'arm64')
        ABI=arm64-v8a ;;
    *)
        ABI=${ARCH} ;;
    esac
	if [[ ! -d dist-full-${ABI} ]]; then
		( . build.sh -a ${ARCH} -c config_full.sh )
	fi

done
