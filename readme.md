# Simple Pianoroll Tool for Renoise

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/pianorollanim3.gif?raw=true" width="754">

## Video on Youtube

Showing version 2.0 in action:

[<img src="https://img.youtube.com/vi/EZJcpnwaY1I/0.jpg" width="300">](https://www.youtube.com/watch?v=EZJcpnwaY1I)

## Thread on official Renoise forum

https://forum.renoise.com/t/simple-pianoroll-com-duftetools-simplepianoroll-xrnx

## Features

* Piano roll workflow (inspired by FL piano roll)
* Mouse support for note moving, scaling and drawing
* Mouse scroll support for scrolling through grid
* It supports Renoise's native HDPI support
* Polyphony support (automatically adds note column, if needed)
* Note preview via Renoise inbuild OSC Server
* Ghost Track
* Many useful keyboard shortcuts (inspired by FL, Bitwig, Ableton and Reason)
* Can display notes with note cut effects and delayed ones
* Scale highlighting can be changed (None, Minor scale, Major scale, Instrument scale, Automatic scale)
* Many useful options to change the behavior for your own taste
* Tool Updater support
* And more...

### Note rendering in piano roll

It supports to render different note column effects.

#### Note overlapping

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/noteoverlapping.png?raw=true" width="300">

#### Note cut fx

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/notecutfx.png?raw=true" width="300">

#### Note retrigger fx

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/noteretriggerfx.png?raw=true" width="300">

#### Note delay

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/notedelay.png?raw=true" width="300">

#### Note delay for note off

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/noteoffdelay.png?raw=true" width="300">

## Important

* To improve mouse handling, please disable mouse warping in Renoise preferences
* You draw notes with the instrument, which is used in the current track of the pattern. In empty track's, it's using
  the current selected one.
* The key combination <kbd>alt + shift</kbd> is a default shortcut to change the keyboard layout on Windows OS. It is
  recommended to switch this off or change the keyboard shortcut to avoid problems. <br>See following for more
  details: https://answers.microsoft.com/en-us/windows/forum/all/how-to-disable-the-windows-10-language-shortcut/030016c9-bfed-48d9-8e4f-7d1030ced338
* The rectangle of the mouse rectangle selection is currently "invisible". Will be changed in the future.

## Install and Update

Download the latest version from official tool page:<br>https://www.renoise.com/tools/simple-pianoroll

Alternative download the latest build here and drop it onto Renoise (beta
build):<br>https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/out/com.duftetools.SimplePianoroll.xrnx

Tool updater is supported, so when a new version is released, it should show you an update prompt.

More information about how you can install and update Renoise tools:

[<img src="https://img.youtube.com/vi/E3ZfSlQ8m_4/0.jpg" width="300">](https://www.youtube.com/watch?v=E3ZfSlQ8m_4)

## How to use it

### In Pattern Editor

Right-click on a track and choose "Edit with Simple Pianoroll ...":<br>
<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/openit.gif?raw=true" width="300">

### In Pattern Matrix

Right-click on a track and choose "Edit with Simple Pianoroll ...":<br>
<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/editviamatrix.gif?raw=true" width="300">

## Mouse actions

|Actions||
|---|---|
|Add notes|Double click on a free spot in the grid<br>Alternative: While hold <kbd>alt</kbd> its just one click|
|Remove notes|Double click on a note<br>Alternative: While hold <kbd>alt</kbd> its just one click|
|Select a note|Click on a note.<br>*It also reads out note length and velocity of the selected note and set these values for new notes.*|
|Move one note or multiple notes|Click and drag a note. It will also move all selected notes, too. Hold <kbd>ctrl</kbd> during moving will force note movement in scale.|
|Change note length|Click and hold the end of a note and move the mouse to the right. It will also increase the length of all selected notes. To decrease the note length, just move the mouse to the left|
|Change note delay|Hold <kbd>alt</kbd> key, click and hold a note and move the mouse to the right. Delay column needs to be enabled. When <kbd>shift</kbd> is holded also, it set one of the following hardcoded values (0x55, 0xAA). For easy note legato portamento for VSTi's or triplet timings.
|Change velocity of selected notes|Hold <kbd>alt</kbd> and use the scroll whell
|Preview a note|Click on a note or use preview mode|
|Play from mouse cursor|While holding <kbd>ctrl</kbd>, click on a freespot in the grid|
|Play all notes from mouse cursor|While holding <kbd>ctrl + shift</kbd>, click and hold on a freespot in the grid|
|Select multiple individual notes|While holding <kbd>ctrl</kbd>, click on a note|
|Deselect individual notes in selection|While holding <kbd>ctrl</kbd>, click on a selected note|
|Deselect notes|Click on a free spot in the grid|
|Rectangle select notes|Click and hold left mouse button on a free spot, it starts to select all notes inside mouse position and start point. When you hold <kbd>shift</kbd>, the notes will be added to the current selection.
|Select all notes with a specific note value|Hold <kbd>ctrl</kbd> and click one of the notes in the piano keyboard control
|Select all notes with on a specific position|Hold <kbd>ctrl</kbd> and click one of the position indicators above the piano grid
|Duplicate selected notes|Hold <kbd>shift</kbd> and start dragging the selection to duplicate the notes
|Scroll vertically|Use your mouse wheel above the piano roll grid or the piano roll keys on the left.
|Scroll horizontally|Use your mouse wheel and hold <kbd>alt</kbd> or <kbd>shift</kbd> above the piano roll grid or the piano roll keys on the left.
|Quick clear of vol, pan and dly controls|Left mouse click on the grid, when no note is selected. (can be disabled)

## Keyboard actions

**Info:** Non handled keyboard events will be sent back to the host. So renoise default keyboard shortcuts should work.

**About AZERTY keyboard layout:** AZERTY mode in the preferences will internally convert non number keys to number keys.
So you don't need to hold <kbd>shift</kbd>.

### Nothing selected

|Keys|Description|
|---|---|
|<kbd>F1</kbd>|Switch to select tool|
|<kbd>F2</kbd>|Switch to pen tool|
|<kbd>F3</kbd>|Switch to audio preview tool|
|<kbd>up</kbd>|Move in the grid upwards|
|<kbd>down</kbd>|Move in the grid downwards|
|<kbd>left</kbd>|Move in the grid leftwards|
|<kbd>right</kbd>|Move in the grid rightwards|
|<kbd>page up</kbd>|Move in the grid 16 steps upwards|
|<kbd>page down</kbd>|Move in the grid 16 steps downwards|
|<kbd>shift + up</kbd>|Move in the grid 12 steps upwards|
|<kbd>shift + down</kbd>|Move in the grid 12 steps downwards|
|<kbd>shift + left</kbd>|Move in the grid 4 steps leftwards|
|<kbd>shift + right</kbd>|Move in the grid 4 steps rightwards|
|<kbd>ctrl + a</kbd>|Select all visible notes|
|<kbd>ctrl + b</kbd> or<br><kbd>ctrl + d</kbd>|Select all visible notes and duplicate it to the right|
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
|<kbd>ctrl + b</kbd> or<br><kbd>ctrl + d</kbd>|Duplicate selected notes to the right|
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
|<kbd>alt + left</kbd> or<br><kbd>alt + right</kbd> or<br><kbd>alt + up</kbd> or<br><kbd>alt + down</kbd><br>|Move note selection. When <kbd>shift</kbd> is holded, it add notes to the current selection.|
|<kbd>up</kbd>|Transpose note 1 semitone up|
|<kbd>down</kbd>|Transpose note 1 semitone down|
|<kbd>shift + up</kbd>|Transpose note 12 semitones up|
|<kbd>shift + down</kbd>|Transpose note 12 semitones down|
|<kbd>ctrl + shift + up</kbd>|Transpose note 7 semitones up|
|<kbd>ctrl + shift + down</kbd>|Transpose note 7 semitones down|
|<kbd>ctrl + up</kbd>|Transpose note 1 semitone up but stay in scale|
|<kbd>ctrl + down</kbd>|Transpose note 1 semitone down but stay in scale|
|<kbd>ctrl + shift + up</kbd>|Transpose note 12 semitone up but stay in scale|
|<kbd>ctrl + shift + down</kbd>|Transpose note 12 semitone down but stay in scale|
|<kbd>left</kbd>|Move note 1 step left|
|<kbd>right</kbd>|Move note 1 step right|
|<kbd>shift + left</kbd>|Move note 4 steps left|
|<kbd>shift + right</kbd>|Move note 4 steps right|
|<kbd>ctrl + alt + left</kbd>|Move note 1 microsteps left (using note delay)|
|<kbd>ctrl + alt + right</kbd>|Move note 1 microsteps right (using note delay)|
|<kbd>ctrl + left</kbd>|Increase note length by 1|
|<kbd>ctrl + right</kbd>|Decrease note length by 1|
|<kbd>shift + i</kbd>|Invert note selection|
|<kbd>del</kbd>|Remove selected notes|
|<kbd>esc</kbd>|Deselect all notes|