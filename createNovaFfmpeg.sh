#!/bin/sh

# this checks out the current ffmpeg.git used by nova

#git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg.git -b n4.4.1
git clone ssh://git@github.com/nova-video-player/FFmpeg ffmpeg.git
cd ffmpeg.git
git remote add dovi https://github.com/quietvoid/FFmpeg
git fetch dovi
git checkout origin/release/4.4
git checkout -b nova
git merge dovi/4.4-MatroskaBlockAdd
# see https://patchwork.ffmpeg.org/project/ffmpeg/patch/DB9PR09MB521251A14DCD46826854BCC6EC749@DB9PR09MB5212.eurprd09.prod.outlook.com/ and http://ffmpeg.org/pipermail/ffmpeg-devel/2021-December/289545.html
wget https://patchwork.ffmpeg.org/project/ffmpeg/patch/DB9PR09MB521251A14DCD46826854BCC6EC749@DB9PR09MB5212.eurprd09.prod.outlook.com/mbox/ -O FFmpeg-devel-lavc-mediacodecdec-set-codec-profile-and-level-from-extradata-for-H264-HEVC.patch
git am FFmpeg-devel-lavc-mediacodecdec-set-codec-profile-and-level-from-extradata-for-H264-HEVC.patch
rm FFmpeg-devel-lavc-mediacodecdec-set-codec-profile-and-level-from-extradata-for-H264-HEVC.patch
#git push origin HEAD:nova
