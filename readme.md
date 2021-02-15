# Simple Pianoroll for Renoise v0.6

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/pianorollanim.gif?raw=true" width="300">

## Video on Youtube

Showing the tool v0.1 in action:

[<img src="https://img.youtube.com/vi/5qJCNvbco7M/0.jpg" width="300">](https://www.youtube.com/watch?v=5qJCNvbco7M)

## Thread on official Renoise forum

https://forum.renoise.com/t/another-piano-roll-com-dufte-simplepianoroll-xrnx/63034

## Features

* Piano roll workflow, inspired by FL piano roll
* Native HDPI support
* Polyphony support (automatically adds note column, if needed)
* Note preview via Renoise inbuild OSC Server (UDP, Port 8000 currently hardcoded)
* Ghost Track
* and more...

## Important

* Dragging notes currently not possible, use arrow keys
* Its using always the instrument, which is used in the pattern. In an empty pattern, its using the current active
  instrument

## Install

Download latest verison from official tool page:<br>https://www.renoise.com/tools/simple-pianoroll

Alternative download the latest build here and drop it onto
Renoise:<br>https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/out/com.duftetools.SimplePianoroll.xrnx

## How to edit a track

Just right click on a track and choose "Edit with Pianoroll ...":<br>
<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/openit.gif?raw=true" width="300">

## Mouse actions

|Actions||
|---|---|
|Add notes|Double click on a free spot in the grid<br>Alternative: While hold <kbd>alt</kbd> its just one click|
|Remove notes|Double click on a note<br>Alternative: While hold <kbd>alt</kbd> its just one click|
|Select a note|Click on a note.<br>*It also reads out note length and velocity of the selected note and set these values
for new notes.*|
|Preview a note|Click on a note.|
|Select multiple individual notes|While holding <kbd>ctrl</kbd>, click on a note|
|Deselect individual notes in selection|While holding <kbd>ctrl</kbd>, click on a selected note|
|Deselect notes|Click on a free spot in the grid|
|Rectangle select notes|First click on a free spot in the grid to set the first corner, then hold <kbd>shift</kbd> and click another free spot and it will select all notes inside this rectangle

## Keyboard actions

Info: Non handled keyboard events will be sent back to the host. So renoise default keyboard shortcuts should work.

|Keys|Context|Description|
|---|---|---|
|<kbd>up</kbd>|Nothing selected|Move in the grid upwards|
|<kbd>down</kbd>|Nothing selected|Move in the grid downwards|
|<kbd>left</kbd>|Nothing selected|Move in the grid leftwards|
|<kbd>right</kbd>|Nothing selected|Move in the grid rightwards|
|<kbd>shift + up</kbd>|Nothing selected|Move in the grid 12 steps upwards|
|<kbd>shift + down</kbd>|Nothing selected|Move in the grid 12 steps downwards|
|<kbd>shift + left</kbd>|Nothing selected|Move in the grid 4 steps leftwards|
|<kbd>shift + right</kbd>|Nothing selected|Move in the grid 4 steps rightwards|
|<kbd>ctrl + a</kbd>|Nothing selected|Select all visible notes|
|<kbd>ctrl + b</kbd>|Nothing selected|Select all visible notes and duplicate it to the right|
|<kbd>ctrl + u</kbd>|Nothing selected|Select all visible notes and quick chop it|
|<kbd>ctrl + b</kbd>|One or more notes selected|Duplicate selected notes to the right|
|<kbd>ctrl + u</kbd>|One or more notes selected|Quick chop all selected notes|
|<kbd>ctrl + c</kbd>|One or more notes selected|Copy selected notes to internal clipboard|
|<kbd>ctrl + x</kbd>|One or more notes selected|Cut selected notes to internal clipboard|
|<kbd>ctrl + v</kbd>|One or more notes selected|Paste notes to the last click grid position|
|<kbd>up</kbd>|One or more notes selected|Transpose note 1 semitone up|
|<kbd>down</kbd>|One or more notes selected|Transpose note 1 semitone down|
|<kbd>alt + up</kbd>|One or more notes selected|Transpose note 7 semitone up|
|<kbd>alt + down</kbd>|One or more notes selected|Transpose note 7 semitone down|
|<kbd>shift + up</kbd>|One or more notes selected|Transpose note 12 semitone up|
|<kbd>shift + down</kbd>|One or more notes selected|Transpose note 12 semitone down|
|<kbd>ctrl + up</kbd>|One or more notes selected|Transpose note 1 semitone up but stay in scale|
|<kbd>ctrl + down</kbd>|One or more notes selected|Transpose note 1 semitone down but stay in scale|
|<kbd>ctrl + shift + up</kbd>|One or more notes selected|Transpose note 12 semitone up but stay in scale|
|<kbd>ctrl + shift + down</kbd>|One or more notes selected|Transpose note 12 semitone down but stay in scale|
|<kbd>left</kbd>|One or more notes selected|Move note 1 step left|
|<kbd>right</kbd>|One or more notes selected|Move note 1 step right|
|<kbd>shift + left</kbd>|One or more notes selected|Move note 4 step left|
|<kbd>shift + right</kbd>|One or more notes selected|Move note 4 step right|
|<kbd>shift + i</kbd>|One or more notes selected|Invert note selection|
|<kbd>del</kbd>|One or more notes selected|Remove selected notes|
|<kbd>esc</kbd>|One or more notes selected|Deselect all notes|