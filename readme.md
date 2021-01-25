# Simple Pianoroll for Renoise [ALPHA-0.1]
* still work in progress *
![Pianoroll in action](https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/pianorollanim.gif?raw=true "Pianoroll in Renoise")

## Important

Adding note logic is not fully done yet. Dragging currently not possible.

## Video on Youtube

Showing the tool in action:

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/5qJCNvbco7M/0.jpg)](https://www.youtube.com/watch?v=5qJCNvbco7M)

## Install

Download the latest build here and drop onto Renoise: https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/raw/master/out/com.dufte.SimplePianoroll.xrnx

## How to use it

* right click on a track in pattern editor and select "Edit with Pianoroll ..."
* note drawing with double click, will also play the note
* note deletion with double click on note, or when selected "DEL"-key  
* click on notes to set note length and velocity for drawing notes, will also select this note
* multiple select notes by click each notes while holding "Left-CTRL"
* transpose notes by select one or more and use arrow keys, when you hold "Left-SHIFT" or "Right-SHIFT" it will transpose by one octave
* for note preview, enable OSC server in Renoise settings, port 8000 UDP (currently hardcoded)
* for polyphony, just add note columns for the current track
* when a track is empty, the current selected instrument will be used