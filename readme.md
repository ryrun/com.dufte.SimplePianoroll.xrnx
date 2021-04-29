# Simple Pianoroll Tool for Renoise

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/pianorollanim.gif?raw=true" width="300">

## Video on Youtube

Showing version 0.7 in action:

[<img src="https://img.youtube.com/vi/zUIjN6Wwrgs/0.jpg" width="300">](https://www.youtube.com/watch?v=zUIjN6Wwrgs)

## Thread on official Renoise forum

https://forum.renoise.com/t/simple-pianoroll-com-duftetools-simplepianoroll-xrnx

## Features

* Piano roll workflow (inspired by FL piano roll)
* It supports Renoise's native HDPI support
* Polyphony support (automatically adds note column, if needed)
* Note preview via Renoise inbuild OSC Server (UDP, Port 8000 currently hardcoded)
* Ghost Track
* Many useful keyboard shortcuts (inspired by FL and Reason)
* and more...

## Important

* Dragging notes currently not possible, use arrow keys
* Its using always the instrument, which is used in the pattern. In an empty pattern, its using the current active
  instrument

## Install

Download latest version from official tool page:<br>https://www.renoise.com/tools/simple-pianoroll

Alternative download the latest build here and drop it onto
Renoise:<br>https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/out/com.duftetools.SimplePianoroll.xrnx

## How to edit a track

Just right click on a track and choose "Edit with Simple Pianoroll ...":<br>
<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/openit.gif?raw=true" width="300">

## Mouse actions

|Actions||
|---|---|
|Add notes|Double click on a free spot in the grid<br>Alternative: While hold <kbd>alt</kbd> its just one click|
|Remove notes|Double click on a note<br>Alternative: While hold <kbd>alt</kbd> its just one click|
|Select a note|Click on a note.<br>*It also reads out note length and velocity of the selected note and set these values for new notes.*|
|Preview a note|Click on a note.|
|Select multiple individual notes|While holding <kbd>ctrl</kbd>, click on a note|
|Deselect individual notes in selection|While holding <kbd>ctrl</kbd>, click on a selected note|
|Deselect notes|Click on a free spot in the grid|
|Rectangle select notes|First click on a free spot in the grid to set the first corner, then hold <kbd>shift</kbd> and click another free spot and it will select all notes inside this rectangle
|Select all notes with a specific note value|Hold <kbd>ctrl</kbd> and click one of the notes in the piano keyboard control
|Select all notes with on a specific position|Hold <kbd>ctrl</kbd> and click one of the position indicators above the piano grid

## Keyboard actions

Info: Non handled keyboard events will be sent back to the host. So renoise default keyboard shortcuts should work.

### Nothing selected

|Keys|Description|
|---|---|
|<kbd>up</kbd>|Move in the grid upwards|
|<kbd>down</kbd>|Move in the grid downwards|
|<kbd>left</kbd>|Move in the grid leftwards|
|<kbd>right</kbd>|Move in the grid rightwards|
|<kbd>shift + up</kbd>|Move in the grid 12 steps upwards|
|<kbd>shift + down</kbd>|Move in the grid 12 steps downwards|
|<kbd>shift + left</kbd>|Move in the grid 4 steps leftwards|
|<kbd>shift + right</kbd>|Move in the grid 4 steps rightwards|
|<kbd>ctrl + a</kbd>|Select all visible notes|
|<kbd>ctrl + b</kbd>|Select all visible notes and duplicate it to the right|
|<kbd>ctrl + u</kbd>|Select all visible notes and quick chop it|
|<kbd>ctrl + 1 .. 9</kbd>|Set current note length|
|<kbd>ctrl + 0</kbd>|Double current note length|
|<kbd>ctrl + shift + 0</kbd>|Halve current note length|
|<kbd>alt + m</kbd>|Mute all visible notes (set volume to 0)|
|<kbd>alt + shift + m</kbd>|Unmute all visible notes (remove volume value)|
|<kbd>ctrl + space</kbd>|Play from last selection|

### One or more notes selected

|Keys|Description|
|---|---|
|<kbd>ctrl + space</kbd>|Play selection|
|<kbd>ctrl + b</kbd>|Duplicate selected notes to the right|
|<kbd>ctrl + u</kbd>|Quick chop all selected notes|
|<kbd>ctrl + 1 .. 9</kbd>|Set current note length and for very selected note|
|<kbd>ctrl + 0</kbd>|Double current note length and for very selected note|
|<kbd>ctrl + shift + 0</kbd>|Halve current note length and for very selected note|
|<kbd>ctrl + c</kbd>|Copy selected notes to internal clipboard|
|<kbd>ctrl + x</kbd>|Cut selected notes to internal clipboard|
|<kbd>ctrl + v</kbd>|Paste notes to the last click grid position|
|<kbd>alt + n</kbd>|Match note value to the first selected one|
|<kbd>alt + m</kbd>|Mute selected notes (set volume to 0)|
|<kbd>alt + shift + m</kbd>|Unmute selected notes (remove volume value)|
|<kbd>up</kbd>|Transpose note 1 semitone up|
|<kbd>down</kbd>|Transpose note 1 semitone down|
|<kbd>alt + up</kbd>|Transpose note 7 semitone up|
|<kbd>alt + down</kbd>|Transpose note 7 semitone down|
|<kbd>shift + up</kbd>|Transpose note 12 semitone up|
|<kbd>shift + down</kbd>|Transpose note 12 semitone down|
|<kbd>ctrl + up</kbd>|Transpose note 1 semitone up but stay in scale|
|<kbd>ctrl + down</kbd>|Transpose note 1 semitone down but stay in scale|
|<kbd>ctrl + shift + up</kbd>|Transpose note 12 semitone up but stay in scale|
|<kbd>ctrl + shift + down</kbd>|Transpose note 12 semitone down but stay in scale|
|<kbd>left</kbd>|Move note 1 step left|
|<kbd>right</kbd>|Move note 1 step right|
|<kbd>shift + left</kbd>|Move note 4 step left|
|<kbd>shift + right</kbd>|Move note 4 step right|
|<kbd>shift + i</kbd>|Invert note selection|
|<kbd>del</kbd>|Remove selected notes|
|<kbd>esc</kbd>|Deselect all notes|