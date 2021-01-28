# Simple Pianoroll for Renoise [alpha] [WIP]
![Pianoroll in action](https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/pianorollanim.gif?raw=true "Pianoroll in Renoise")

## Video on Youtube

Showing the tool v0.1 in action:

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/5qJCNvbco7M/0.jpg)](https://www.youtube.com/watch?v=5qJCNvbco7M)

## Thread on official Renoise forum
https://forum.renoise.com/t/another-piano-roll-com-dufte-simplepianoroll-xrnx/63034

## Features

* Piano roll workflow, inspired by FL piano roll
* Native HDPI support
* Polyphony support (automatically adds note column, if needed)
* Note preview via Renoise inbuild OSC Server (UDP, Port 8000 currently hardcoded)

## Important

* Adding note logic is not fully done yet
* Dragging notes currently not possible, use arrow keys
* Overlapped notes will currently break the piano roll grid
* Its using always the instrument, which is used in the pattern. In an empty pattern, its using the current active instrument

## Install

Download the latest build here and drop it onto Renoise: https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/raw/master/out/com.dufte.SimplePianoroll.xrnx
 
## Mouse actions

|Actions||
|---|---|
|Add notes|Double click on a free spot in the grid|
|Remove notes|Double click on a note|
|Select a note|Click on a note<br><br>*It also reads out note length and velocity of the selected note and set these values for new notes.*|
|Preview a note|Click on a note|
|Select multiple individual notes|While holding <kbd>ctrl</kbd>, click on a note|
|Deselect notes|Click on a free spot in the grid|
|Rectangle select notes|First click on a free spot in the grid to set the first corner, then hold <kbd>shift</kbd> and click another free spot and it will select all notes inside this rectangle

## Keyboard actions

Info: Non handled keyboard events will be send back to the host. So renoise default keyboard shortcuts should work.

|Keys|Context|Description|
|---|---|---|
|<kbd>up</kbd>|Nothing selected|Move in the grid upwards|
|<kbd>down</kbd>|Nothing selected|Move in the grid downwards|
|<kbd>shift + up</kbd>|Nothing selected|Move in the grid 12 steps upwards|
|<kbd>shift + down</kbd>|Nothing selected|Move in the grid 12 steps downwards|
|<kbd>up</kbd>|One or more notes selected|Transpose note 1 semitone up|
|<kbd>down</kbd>|One or more notes selected|Transpose note 1 semitone down|
|<kbd>shift + up</kbd>|One or more notes selected|Transpose note 12 semitone up|
|<kbd>shift + down</kbd>|One or more notes selected|Transpose note 12 semitone up|
|<kbd>ctrl + up</kbd>|One or more notes selected|Transpose note 1 semitone up but stay in scale|
|<kbd>ctrl + down</kbd>|One or more notes selected|Transpose note 1 semitone down but stay in scale|
|<kbd>ctrl + shift + up</kbd>|One or more notes selected|Transpose note 12 semitone up but stay in scale|
|<kbd>ctrl + shift + down</kbd>|One or more notes selected|Transpose note 12 semitone up but stay in scale|
|<kbd>del</kbd>|One or more notes selected|Remove selected notes|
|<kbd>esc</kbd>|One or more notes selected|Deselect all notes|
|<kbd>ctrl + a</kbd>|-|Select all visible notes|
