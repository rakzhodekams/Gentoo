#!/bin/sh
ffmpeg -video_size 1600x900 -framerate 60 -r 60 -f x11grab -i :0.0+0.0 -f pulse -ac 2 -i default out.mkv
