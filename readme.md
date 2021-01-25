# Simple Pianoroll for Renoise [alpha] [WIP]
![Pianoroll in action](https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/pianorollanim.gif?raw=true "Pianoroll in Renoise")

## Important

* adding note logic is not fully done yet
* dragging notes currently not possible, use arrow keys
* overlapped notes will currently break the piano roll grid

## Video on Youtube

Showing the tool in action:

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/5qJCNvbco7M/0.jpg)](https://www.youtube.com/watch?v=5qJCNvbco7M)

## Install

Download the latest build here and drop it onto Renoise: https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/raw/master/out/com.dufte.SimplePianoroll.xrnx

## How to use it / Features

* HDPI support via Renoise, it should work with any scale value
* right click on a track in pattern editor and select "Edit with Pianoroll ..."
* note drawing with double click, will also play the note
* note deletion with double click on note, or when selected <kbd>del</kbd>-key  
* click on notes to set note length and velocity for drawing notes, will also select this note
* multiple select notes by click each notes while holding <kbd>left ctrl</kbd>
* transpose notes by select one or more and use arrow keys. When you hold <kbd>left shift</kbd> or <kbd>right shift</kbd>, it will transpose by one octave
* for note preview, enable OSC server in Renoise settings, port 8000 UDP (currently hardcoded)
* for polyphony, it automatically enables more note columns if needed and hides the empty right ones
* when a track is empty, the current selected instrument will be used