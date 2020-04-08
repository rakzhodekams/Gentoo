ffmpeg \
 -f pulse -ac 2 -ar 48000 -i alsa_output.pci-0000_00_1b.0.analog-stereo.monitor \
 -f pulse -ac 2 -ar 44100 -i alsa_input.pci-0000_00_1b.0.analog-stereo \
 -filter_complex amix=inputs=2 \
 -f x11grab -r 60 -s 1600x900 -i :0.0+0,0 -vcodec libx264 -preset veryfast -crf 18 -acodec aac -ar 44100 -q:a 1 -pix_fmt yuv420p /home/i00nsu/ffmpeg/testing.mkv
