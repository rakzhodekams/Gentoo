#!/bin/sh
ffmpeg -y -video_size 1600x900 -framerate 30 -f x11grab -i :0.0+0.0 -vsync 0 -c:v prores -f pulse -ac 2 -i default out.mkv

