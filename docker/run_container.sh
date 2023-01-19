#!/bin/sh
docker run -it --volume="$PWD/..:/workdir/rpi" rpi:imx-1
