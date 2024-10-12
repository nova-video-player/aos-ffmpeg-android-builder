# disable--protocols does not work
CONFIG_LIBAV="\
	--disable-ffmpeg \
	--disable-ffplay \
	--disable-ffprobe \
	--disable-doc \
	--disable-htmlpages \
	--disable-manpages \
	--disable-podpages \
	--disable-txtpages \
	--disable-programs \
	--disable-swresample \
	--enable-swscale \
	--disable-postproc \
	--disable-bzlib \
	--disable-muxers \
	--disable-bsfs \
	--disable-avdevice \
	--disable-devices \
	--enable-demuxers \
	--enable-parsers \
	--enable-muxer=spdif \
	--disable-encoders \
	--enable-decoders \
	--disable-v4l2-m2m \
	--enable-libdav1d \
	--enable-libopus \
	--disable-vulkan \
	--enable-openssl \
	"
