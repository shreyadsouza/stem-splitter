## USES: https://github.com/rostya-codes/mp4-to-mp3-converter/blob/main/converter.py

import moviepy.editor
import sys

file = sys.argv[1]
video = moviepy.editor.VideoFileClip(file) # Initialize video
audio = video.audio # Get audio from file
audio.write_audiofile(str(file[:-4])+'.mp3') # Save mp3 file