#!/bin/bash

for ARCH in arm arm64 x86 x86_64
do
  case "${ARCH}" in
    'arm')
      ABI=armeabi-v7a ;;
    'arm64')
      ABI=arm64-v8a ;;
    *)
      ABI=${ARCH} ;;
    esac
  if [ ! -d dist-full-${ABI} ]
  then
   ./build.sh -a ${ARCH} -c config_full.sh
  fi
done
