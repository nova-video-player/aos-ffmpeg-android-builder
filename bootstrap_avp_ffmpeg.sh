#!/bin/bash

for ARCH in arm x86; do
	if [ ${ARCH} == arm ] ; then
		ABI=armeabi-v7a
	else
		ABI=x86
	fi
	if [[ ! -d dist-base-${ABI} ]]; then
		( . build.sh -a ${ARCH} -c config_base.sh )
	fi
	if [[ ! -d dist-mpeg2-${ABI} ]]; then
		( . build.sh -a ${ARCH} -c config_mpeg2.sh )
	fi
	if [[ ! -d dist-full-${ABI} ]]; then
		( . build.sh -a ${ARCH} -c config_full.sh )
	fi

done
