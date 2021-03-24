#!/bin/sh

# NOTE:
# Download, Build and place binaries (crunch, astcenc, PVRTexToolCLI) in THIS folder before run!
# crunch: https://github.com/BinomialLLC/crunch
# astcenc: https://github.com/ARM-software/astc-encoder
# PVRTexToolCLI: https://www.imaginationtech.com/developers/powervr-sdk-tools/pvrtextool/


export PATH=.:$PATH

# DXT
./crunch -file ./src/dxt_bc1.png  -yflip -fileformat ktx -dxt1  -out compressed_dxt_bc1.ktx
./crunch -file ./src/dxt_bc1a.png -yflip -fileformat ktx -dxt1a -out compressed_dxt_bc1a.ktx
./crunch -file ./src/dxt_bc2.png -mipMode None -yflip -fileformat ktx -dxt2  -out compressed_dxt_bc2.ktx
./crunch -file ./src/dxt_bc2.png -yflip -fileformat ktx -dxt2  -out compressed_dxt_bc2.ktx
./crunch -file ./src/dxt_bc3.png  -yflip -fileformat ktx -dxt3  -out compressed_dxt_bc3.ktx

# ASTC
#block_footprint=(4x4)
block_footprint=(4x4 5x4 5x5 6x5 6x6 8x5 8x6 8x8 10x5 10x6 10x8 10x10 12x10 12x12)
for i in ${!block_footprint[*]}
do
  bfp=${block_footprint[$i]}
  ./PVRTexToolCLI -i ./src/astc_${bfp}.png -l -m -flip y,flag -f ASTC_${bfp} -o compressed_astc_${bfp}.ktx
done


# ETC
./PVRTexToolCLI -i ./src/etc1.png -l -m -flip y,flag -f ETC1,UBN,lRGB -o compressed_etc1.ktx
./PVRTexToolCLI -i ./src/etc2.png -l -m -flip y,flag -f ETC2_RGBA,UBN,lRGB -o compressed_etc2.ktx
