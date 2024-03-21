Stems are audio files that break down a track into mixes. Obtaining them provides a myriad of use cases, such as learning music production, dubbing, and adjusting relative instrument volumes. While we could hard-code which stems are playing at a particular time, an interactive stem splitter tool provides a more ‘playful’ way of manipulating audio (and visual) output.

![workflow (1)](https://github.com/shreyadsouza/stem-splitter/assets/55857093/1a512e0c-667e-482c-bcdd-be338463cc4f)

Setup:
1. Add .mov file to video-inputs folder
2. Run scripts/run_pipeline.sh to automatically create stems (this will take some time)
3. Open Wekinator project, wek/WekinatorProject/WekinatorProject.wekproj and run the model
4. Open stem-splitter-video/stem_splitter_video.pde
5. Run chuck stem-synth-mult.ck

Further details provided here: https://medium.com/@shreyadsouza/interactive-stem-player-9dde80fe16c3
