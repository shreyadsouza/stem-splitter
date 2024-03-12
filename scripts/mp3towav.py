from pydub import AudioSegment

sound = AudioSegment.from_mp3("apunk.mp3")
sound.export("apunk.wav", format="wav")