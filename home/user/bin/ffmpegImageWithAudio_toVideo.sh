 ffmpeg -y -loop 1 -framerate 30 -pattern_type glob -i '*.jpg' -i ../../output.wav -shortest -r 30 -pix_fmt yuv420p FinalOutput2.mp4
