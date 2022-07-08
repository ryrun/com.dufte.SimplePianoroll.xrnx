# Simple Pianoroll Tool for Renoise

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/pianorollanim3.gif?raw=true" alt="Simple Pianoroll Tool for Renoise" />

## Videos on Youtube

Showing version 2.0 in action:

[<img src="https://img.youtube.com/vi/EZJcpnwaY1I/0.jpg" width="300">](https://www.youtube.com/watch?v=EZJcpnwaY1I)

### Older ones

[<img src="https://img.youtube.com/vi/zUIjN6Wwrgs/0.jpg" width="150">](https://www.youtube.com/watch?v=zUIjN6Wwrgs) [<img src="https://img.youtube.com/vi/5qJCNvbco7M/0.jpg" width="150">](https://www.youtube.com/watch?v=5qJCNvbco7M)

## Thread on official Renoise forum

https://forum.renoise.com/t/simple-pianoroll-com-duftetools-simplepianoroll-xrnx/63034

## Features

* Piano roll workflow (inspired by FL piano roll)
* Mouse support for note moving, scaling and drawing
* Mouse scroll wheel support for scrolling through grid or change the velocity of selected notes
* Follows Renoise user interface scaling option
* Polyphony support (automatically adds and remove note columns, if needed)
* Note preview via Renoise inbuild OSC Server
* Ghost Track
* Many useful mouse and keyboard shortcuts (inspired by FL, Bitwig, Ableton and Reason)
* Show several tracker related effects like note cut, note retrigger, delay
* Scale highlighting support (None, Minor scale, Major scale, Instrument scale, Automatic scale)
* Many useful options to change the behavior for your own taste
* Chord detection for playing and selected notes
* Chord stamping
* Tool Updater support
* Step sequencing via computer keyboard
* Histogram for note property manipulations
* Basic MIDI Input support for playing (no recording yet)
* And more...

## Important

* To improve mouse handling, please disable mouse warping in Renoise preferences. This also fix the jumping mouse
  cursor. There is an option called "Mouse warping compatibility mode", if you still want to use mouse warping in
  Renoise. It will disable some internal functions, where disabled mouse warping is needed.
* The key combination <kbd>alt + shift</kbd> is a default shortcut to change the keyboard layout on Windows OS. It is
  recommended to switch this off or change the keyboard shortcut to avoid problems. <br>See following for more
  details: https://answers.microsoft.com/en-us/windows/forum/all/how-to-disable-the-windows-10-language-shortcut/030016c9-bfed-48d9-8e4f-7d1030ced338
* Renoise have a 12 column limit per tack. So when more than 12 columns are needed, then some notes will stick in the
  current position. A hint should be displayed in Renoise toolbar.

## Note rendering in piano roll

It supports different note column effects, and it will also use different note colors, when more than one instrument was
used in the pattern.

#### Note overlapping

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/noteoverlapping.png?raw=true" width="300" alt="Note overlapping" />

#### Note cut fx

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/notecutfx.png?raw=true" width="300" alt="Note cut fx" />

#### Note retrigger fx

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/noteretriggerfx.png?raw=true" width="300" alt="Note retrigger fx" />

#### Note delay

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/notedelay.png?raw=true" width="300" alt="Note delay" />

#### Note delay for note off

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/noteoffdelay.png?raw=true" width="300" alt="Note delay for note off" />

#### Different instruments in one pattern

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/diffinsinpattern.png?raw=true" width="300" alt="Note delay for note off" />

## Install and Update

Download the latest version from official tool page:<br>https://www.renoise.com/tools/simple-pianoroll

Alternative download the latest build here and drop it onto Renoise (beta
build):<br>https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/out/com.duftetools.SimplePianoroll.xrnx

Tool updater is supported, so when a new version is released, it should show you an update prompt.

More information about how you can install and update Renoise tools:

[<img src="https://img.youtube.com/vi/E3ZfSlQ8m_4/0.jpg" width="300">](https://www.youtube.com/watch?v=E3ZfSlQ8m_4)

## How to use it

### General

Everyone who is familiar with a piano roll, can use it right away. It's heavily inspired by FL, Bitwig and Reason. DAW's
which I've used in the past. Most common keyboard shortcuts of these like <kbd>ctrl+b</kbd>
or <kbd>ctrl+d</kbd> for note duplication are working here, too.

### Open the piano roll

There are several ways to open the piano roll. It's possible in the pattern view, matrix view, mixer view, instruments
pane and also via main menu.

#### Pattern editor

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/openit.gif?raw=true" width="300" alt="Open Piano Roll in Renoise">

#### Matrix view

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/editviamatrix.gif?raw=true" width="300" alt="Open Piano Roll in Renoise in the Matrix view">

### Scale highlighting

Scale highlighting can be easily changed with the button on the bottem left. It opens a dialog, where you can switch
between major or minor or change the root key.

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/scalehighswitch.gif?raw=true" alt="Showing usage of scale highlighting dialog">

### Ghost track

With a ghost track, you can easily set note guidelines for composing. Simply choose a track, and you will see the notes
in the piano roll background. With enabled mirroring, every note of your selected track will be spread across all
octaves. So manually copy or transpose notes across octaves is not needed anymore. There is also a button to easily
switch between the current and the ghost track.

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/ghosttrack.gif?raw=true" alt="Ghost track">

### Step sequencing with computer keyboard

In Renoise, you can use your computer keyboard to play notes. This is also possible in the piano roll. So, when you play
and hold notes and use the cursor keys left or right to move the edit cursor, it will create or remove notes on the
current cursor position. You can also use your midi kleyboard to play a chords and use the cursor keys to draw them,
when you have seleted the midi in device in the preferences.

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/stepseq.gif?raw=true" alt="Step sequecing in Simple Pianoroll Tool for Renoise">

### Histogram

The histogram shows you note values (volume, panning, delay and pitch) of your current note selection in a simple graph.
It can be used to add randomness to your notes. It's inspired by Bitwig's powerful histogram feature.

There are 4 controls to manipulate these values:

* **Offset** is used to move the values up or down.
* **Scale** can be used to grow or shrink the spread across the x-axis. It can also be used to mirror the values via
  negative scale values.
* **Chaos** can be used to add randomness to each value.
* **Asc by Pos / Note** can be used to ascending or descending the values by note position or by note pitch.

With **Apply** the values will be written. With **Reset** the histogram controls will be set back to defaul values.

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/histogram.gif?raw=true" alt="Histogram feature">

Here a little video showing you, how you can use it:

[<img src="https://img.youtube.com/vi/zkE5SCw0TyE/0.jpg" width="300">](https://www.youtube.com/watch?v=zkE5SCw0TyE)

### Chord detection and scale degree detection

The piano roll will always try to detect chords of the current selected or played notes. It also tries to determine the
correct scale degree depending on the current scale. It can be used to unterstand music theory better and gives you more
information about the current playing notes.

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/chorddetect.gif?raw=true" alt="Chord detection and scale degree detection">

### Chord stamping

With the chord stamping you can easily draw chords into the piano roll. The selected chord can be extended by further notes
or chord inversion can be performed. If the note preview has been activated, the drawing in of chords can also be
done via step sequencing. In addition, it is possible that the drawn chords are always aligned to the currently
active scale. Finally, ChordGun chord templates can be read and used, too.

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/pensettings.png?raw=true" alt="Pen settings chord stamping">

## Mouse actions

| Actions                                      |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
|----------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Add notes                                    | Double click on a free spot in the grid<br>Alternative: While hold <kbd>alt</kbd> its just one click                                                                                                                                                                                                                                                                                                                                                                                            |
| Remove notes                                 | Double click on a note<br>Alternative: While hold <kbd>alt</kbd> its just one click                                                                                                                                                                                                                                                                                                                                                                                                             |
| Select a note                                | Click on a note.<br>*It also reads out note length and velocity of the selected note and set these values for new notes.*                                                                                                                                                                                                                                                                                                                                                                       |
| Move one note or multiple notes              | Click and drag a note. It will also move all selected notes, too.<br><br>When <kbd>alt</kbd> is holded, the notes will be moved in micro steps (using delay values). Please note, that alt + note click is note removing. So you need to click first, before you hold <kbd>alt</kbd>. Alternative: Alt click note remove can be disabled in options, so its easier to use. Using <kbd>shift</kbd> during micro step note movement, forces the note to snap into a special grid (0, 0x55, 0xaa). |
| Change note length                           | Click and hold the end of a note and move the mouse to the right. It will also increase the length of all selected notes. To decrease the note length, just move the mouse to the left. Using <kbd>alt</kbd> also allows you to change the length by micro steps                                                                                                                                                                                                                                |
| Change velocity of selected notes            | Hold <kbd>alt</kbd> and use the scroll whell                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| Preview a note                               | Click on a note or use preview mode                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| Play from mouse cursor                       | While holding <kbd>ctrl</kbd>, click on a freespot in the grid                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| Play all notes from mouse cursor             | While holding <kbd>ctrl + shift</kbd>, click and hold on a freespot in the grid                                                                                                                                                                                                                                                                                                                                                                                                                 |
| Select multiple individual notes             | While holding <kbd>ctrl</kbd>, click on a note                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| Deselect individual notes in selection       | While holding <kbd>ctrl</kbd>, click on a selected note                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| Deselect notes                               | Click on a free spot in the grid                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| Rectangle select notes                       | Click and hold left mouse button on a free spot, it starts to select all notes inside mouse position and start point. When you hold <kbd>shift</kbd>, the notes will be added to the current selection.                                                                                                                                                                                                                                                                                         |
| Select all notes with a specific note value  | Hold <kbd>ctrl</kbd> and click one of the notes in the piano keyboard control                                                                                                                                                                                                                                                                                                                                                                                                                   |
| Select all notes with on a specific position | Hold <kbd>ctrl</kbd> and click one of the position indicators above the piano grid                                                                                                                                                                                                                                                                                                                                                                                                              |
| Duplicate selected notes                     | Hold <kbd>shift</kbd> or <kbd>ctrl</kbd> and start dragging the selection to duplicate the notes                                                                                                                                                                                                                                                                                                                                                                                                |
| Scroll vertically                            | Use your mouse wheel above the piano roll grid or the piano roll keys on the left.                                                                                                                                                                                                                                                                                                                                                                                                              |
| Scroll horizontally                          | Use your mouse wheel and hold <kbd>alt</kbd> or <kbd>shift</kbd> or <kbd>control</kbd> above the piano roll grid or the piano roll keys on the left. Please note, some of these combinations only work, when no note is selected.                                                                                                                                                                                                                                                               |
| Quick clear of vol, pan and dly controls     | Left mouse click on the grid, when no note is selected. (can be disabled)                                                                                                                                                                                                                                                                                                                                                                                                                       |

## Keyboard actions

**Info:** Non handled keyboard events will be sent back to the host. So renoise default keyboard shortcuts should work.

**About AZERTY keyboard layout:** AZERTY mode in the preferences will internally convert non number keys to number keys.
So you don't need to hold <kbd>shift</kbd>.

### Nothing selected

| Keys                                                   | Description                                                                     |
|--------------------------------------------------------|---------------------------------------------------------------------------------|
| <kbd>F1</kbd>                                          | Switch to select tool                                                           |
| <kbd>F2</kbd>                                          | Switch to pen tool                                                              |
| <kbd>ctrl + F2</kbd>                                   | Open pen tool seetings dialog                                                   |
| <kbd>F3</kbd>                                          | Switch to audio preview tool                                                    |
| <kbd>up</kbd>                                          | Move in the grid upwards                                                        |
| <kbd>down</kbd>                                        | Move in the grid downwards                                                      |
| <kbd>left</kbd>                                        | Move edit position cursor leftwards, scroll when cursor get's outside the grid  |
| <kbd>right</kbd>                                       | Move edit position cursor rightwards, scroll when cursor get's outside the grid |
| <kbd>page up</kbd>                                     | Move in the grid 16 steps upwards                                               |
| <kbd>page down</kbd>                                   | Move in the grid 16 steps downwards                                             |
| <kbd>shift + up</kbd>                                  | Move in the grid 12 steps upwards                                               |
| <kbd>shift + down</kbd>                                | Move in the grid 12 steps downwards                                             |
| <kbd>shift + left</kbd>                                | Move in the grid 4 steps leftwards                                              |
| <kbd>shift + right</kbd>                               | Move in the grid 4 steps rightwards                                             |
| <kbd>ctrl + a</kbd>                                    | Select all visible notes                                                        |
| <kbd>ctrl + b</kbd> or<br><kbd>ctrl + d</kbd>          | Select all visible notes and duplicate it to the right                          |
| <kbd>ctrl + u</kbd>                                    | Select all visible notes and quick chop it                                      |
| <kbd>ctrl + 1 .. 9</kbd>                               | Set current note length                                                         |
| <kbd>ctrl + 0</kbd>                                    | Double current note length                                                      |
| <kbd>ctrl + shift + 0</kbd>                            | Halve current note length                                                       |
| <kbd>alt + m</kbd>                                     | Mute all visible notes (set volume to 0)                                        |
| <kbd>alt + h</kbd>                                     | All notes will be selected and histogram window will be opened                  |
| <kbd>alt + shift + m</kbd>                             | Unmute all visible notes (remove volume value)                                  |
| <kbd>ctrl + space</kbd> or<br><kbd>shift + space</kbd> | Play from edit cursor position                                                  |

### One or more notes selected

| Keys                                                                                                         | Description                                                                                  |
|--------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|
| <kbd>ctrl + space</kbd>                                                                                      | Play selection                                                                               |
| <kbd>ctrl + b</kbd> or<br><kbd>ctrl + d</kbd>                                                                | Duplicate selected notes to the right                                                        |
| <kbd>ctrl + u</kbd>                                                                                          | Quick chop all selected notes                                                                |
| <kbd>ctrl + 1 .. 9</kbd>                                                                                     | Set current note length and for very selected note                                           |
| <kbd>ctrl + 0</kbd>                                                                                          | Double current note length and for very selected note                                        |
| <kbd>ctrl + shift + 0</kbd>                                                                                  | Halve current note length and for very selected note                                         |
| <kbd>ctrl + c</kbd>                                                                                          | Copy selected notes to internal clipboard                                                    |
| <kbd>ctrl + x</kbd>                                                                                          | Cut selected notes to internal clipboard                                                     |
| <kbd>ctrl + v</kbd>                                                                                          | Paste notes to the last click grid position                                                  |
| <kbd>alt + n</kbd>                                                                                           | Match note value to the first selected one                                                   |
| <kbd>alt + m</kbd>                                                                                           | Mute selected notes (set volume to 0)                                                        |
| <kbd>alt + h</kbd>                                                                                           | Histogram window will be opened                                                              |
| <kbd>alt + shift + m</kbd>                                                                                   | Unmute selected notes (remove volume value)                                                  |
| <kbd>alt + left</kbd> or<br><kbd>alt + right</kbd> or<br><kbd>alt + up</kbd> or<br><kbd>alt + down</kbd><br> | Move note selection. When <kbd>shift</kbd> is holded, it add notes to the current selection. |
| <kbd>up</kbd>                                                                                                | Transpose note 1 semitone up                                                                 |
| <kbd>down</kbd>                                                                                              | Transpose note 1 semitone down                                                               |
| <kbd>shift + up</kbd>                                                                                        | Transpose note 12 semitones up                                                               |
| <kbd>shift + down</kbd>                                                                                      | Transpose note 12 semitones down                                                             |
| <kbd>ctrl + shift + up</kbd>                                                                                 | Transpose note 7 semitones up                                                                |
| <kbd>ctrl + shift + down</kbd>                                                                               | Transpose note 7 semitones down                                                              |
| <kbd>ctrl + up</kbd>                                                                                         | Transpose note 1 semitone up but stay in scale                                               |
| <kbd>ctrl + down</kbd>                                                                                       | Transpose note 1 semitone down but stay in scale                                             |
| <kbd>ctrl + shift + up</kbd>                                                                                 | Transpose note 12 semitone up but stay in scale                                              |
| <kbd>ctrl + shift + down</kbd>                                                                               | Transpose note 12 semitone down but stay in scale                                            |
| <kbd>left</kbd>                                                                                              | Move note 1 step left                                                                        |
| <kbd>right</kbd>                                                                                             | Move note 1 step right                                                                       |
| <kbd>shift + left</kbd>                                                                                      | Move note 4 steps left                                                                       |
| <kbd>shift + right</kbd>                                                                                     | Move note 4 steps right                                                                      |
| <kbd>ctrl + alt + left</kbd>                                                                                 | Move note 1 micro steps left (using note delay)                                              |
| <kbd>ctrl + alt + right</kbd>                                                                                | Move note 1 micro steps right (using note delay)                                             |
| <kbd>ctrl + left</kbd>                                                                                       | Increase note length by 1                                                                    |
| <kbd>ctrl + right</kbd>                                                                                      | Decrease note length by 1                                                                    |
| <kbd>shift + i</kbd>                                                                                         | Invert note selection                                                                        |
| <kbd>del</kbd> or <kbd>backspace</kbd>                                                                       | Remove selected notes                                                                        |
| <kbd>esc</kbd>                                                                                               | Deselect all notes                                                                           |