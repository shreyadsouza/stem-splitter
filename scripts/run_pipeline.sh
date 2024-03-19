# 1. Convert to mp3
echo "Converting to mp3..."
python3 movtomp3.py "../video-inputs/${1}.mov"

# 2. Split files, data gets stored in ./separated/htdemucs/<file name excluding mp3>
echo "Splitting into stems..."
python3 -m demucs -d cpu "../video-inputs/${1}.mp3" --mp3-preset 4

# 3. Move video input to Processing data
mv "../video-inputs/${1}.mov" "../stem-splitter-video/data/${1}.mov"

# 4. Use stems as input for Chuck synthesizer file
chuck ../stem-synth.ck:$1


