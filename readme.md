<h1>Simple Pianoroll Tool for Renoise</h1>

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/pianorollanim3.gif?raw=true" alt="Simple Pianoroll Tool for Renoise" />

<h2>Table of contents</h2>

<!-- TOC -->
  * [Videos on Youtube](#videos-on-youtube)
    * [Older ones](#older-ones)
  * [Thread on official Renoise forum](#thread-on-official-renoise-forum)
  * [Features](#features)
  * [Important](#important)
  * [Note rendering in piano roll](#note-rendering-in-piano-roll)
      * [Note overlapping](#note-overlapping)
      * [Note cut fx](#note-cut-fx)
      * [Note retrigger fx](#note-retrigger-fx)
      * [Note delay](#note-delay)
      * [Note delay for note off](#note-delay-for-note-off)
      * [Different instruments in one pattern](#different-instruments-in-one-pattern)
  * [Install and Update](#install-and-update)
  * [How to use it](#how-to-use-it)
    * [General](#general)
    * [Open the piano roll](#open-the-piano-roll)
      * [Pattern editor](#pattern-editor)
      * [Matrix view](#matrix-view)
    * [Note preview](#note-preview)
    * [Timeline bar](#timeline-bar)
    * [Scale highlighting](#scale-highlighting)
    * [Ghost track](#ghost-track)
    * [Step sequencing with computer keyboard](#step-sequencing-with-computer-keyboard)
    * [Histogram](#histogram)
    * [Chord detection and scale degree detection](#chord-detection-and-scale-degree-detection)
    * [Chord stamping](#chord-stamping)
  * [Mouse actions](#mouse-actions)
  * [Keyboard actions](#keyboard-actions)
    * [Nothing selected](#nothing-selected)
    * [One or more notes selected](#one-or-more-notes-selected)
  * [Inbuilt additional tools](#inbuilt-additional-tools)
    * [Sample Editor - Fit sample to beat sync ...](#sample-editor---fit-sample-to-beat-sync-)
      * [Sample Editor - Fit sample to beat sync (Song BPM)](#sample-editor---fit-sample-to-beat-sync--song-bpm-)
    * [Sample Editor - Align sample selection to beat](#sample-editor---align-sample-selection-to-beat)
    * [Instrument box - Change instruments global pitch](#instrument-box---change-instruments-global-pitch)
    * [Matrix view - Duplicate content](#matrix-view---duplicate-content)
    * [Useful global keyboard shortcuts](#useful-global-keyboard-shortcuts)
      * [Audio reference switch](#audio-reference-switch)
      * [Sub Filter switch](#sub-filter-switch)
      * [Show / Hide Analyzer](#show--hide-analyzer)
      * [Show / Hide Waveform Analyzer](#show--hide-waveform-analyzer)
<!-- TOC -->

## Videos on Youtube

Showing version 2.0 in action:

[<img src="https://img.youtube.com/vi/EZJcpnwaY1I/0.jpg" width="400">](https://www.youtube.com/watch?v=EZJcpnwaY1I)

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
* For note preview, you need to enable the OSC server in the Renoise preferences. Be sure, that protocol and port are
  correctly set for both the OSC server and the piano roll.
* The key combination <kbd>alt + shift</kbd> is a default shortcut to change the keyboard layout on Windows OS. It is
  recommended to switch this off or change the keyboard shortcut to avoid problems. <br>See following for more
  details: https://answers.microsoft.com/en-us/windows/forum/all/how-to-disable-the-windows-10-language-shortcut/030016c9-bfed-48d9-8e4f-7d1030ced338
* Renoise have a 12 column limit per tack. So when more than 12 columns are needed, then some notes will stick in the
  current position. A hint should be displayed in Renoise toolbar.

## Note rendering in piano roll

It supports different note column effects, and it will also use different note colors, when more than one instrument was
used in the pattern.

#### Note overlapping

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/noteoverlapping.png?raw=true" width="400" alt="Note overlapping" />

#### Note cut fx

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/notecutfx.png?raw=true" width="400" alt="Note cut fx" />

#### Note retrigger fx

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/noteretriggerfx.png?raw=true" width="400" alt="Note retrigger fx" />

#### Note delay

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/notedelay.png?raw=true" width="400" alt="Note delay" />

#### Note delay for note off

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/noteoffdelay.png?raw=true" width="400" alt="Note delay for note off" />

#### Different instruments in one pattern

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/diffinsinpattern.png?raw=true" width="400" alt="Note delay for note off" />

## Install and Update

Download the latest version from official tool page:<br>https://www.renoise.com/tools/simple-pianoroll

Alternative download the latest build here and drop it onto Renoise (beta
build):<br>https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/out/com.duftetools.SimplePianoroll.xrnx

Tool updater is supported, so when a new version is released, it should show you an update prompt.

More information about how you can install and update Renoise tools:

[<img src="https://img.youtube.com/vi/E3ZfSlQ8m_4/0.jpg" width="400">](https://www.youtube.com/watch?v=E3ZfSlQ8m_4)

## How to use it

### General

Everyone who is familiar with a piano roll, can use it right away. It's heavily inspired by FL, Bitwig and Reason. DAW's
which I've used in the past. Most common keyboard shortcuts of these like <kbd>ctrl+b</kbd>
or <kbd>ctrl+d</kbd> for note duplication are working here, too.

### Open the piano roll

There are several ways to open the piano roll. It's possible in the pattern view, matrix view, mixer view, instruments
pane and also via main menu.

#### Pattern editor

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/openit.gif?raw=true" width="400" alt="Open Piano Roll in Renoise">

#### Matrix view

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/editviamatrix.gif?raw=true" width="400" alt="Open Piano Roll in Renoise in the Matrix view">

### Note preview

With the help of Renoise's OSC server it is possible to play the drawn as well as selected notes. You can also use your
computer keyboard to play notes. The keys are the same as on the Renoise Tracker. With the preview tool you can scroll
through the pattern and play all notes at the respective position.
By default, the OSC server is turned off, so you have to activate it first. Furthermore, the protocol and the port
number must match the settings of the Pianoroll tool. After that it should work immediately.

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/oscserver.png?raw=true" alt="OSC Server settings in Renoise" width="400">

### Timeline bar

With the timeline bar it is possible to set, move or remove loop areas. To draw in a loop, simply hold down the <kbd>
ctrl</kbd> key and mark the desired area with the left mouse button pressed. If the <kbd>shift</kbd> key is pressed, the
loop area can be moved. While the song is playing and the play point is outside the loop on the right, it will be moved
back into the loop automatically. Double click removes the current loop. Single click sets the editor cursor positions.

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/timelineloop.gif?raw=true" alt="Showing usage of timeline" width="600">

Made a Youtube short about this, so you can see it in action:

[<img src="https://img.youtube.com/vi/Ay_wcQsvPrE/0.jpg" width="400">](https://www.youtube.com/shorts/Ay_wcQsvPrE)

### Scale highlighting

Scale highlighting can be easily changed with the button on the bottem left. It opens a dialog, where you can switch
between major or minor or change the root key.

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/scalehighswitch.gif?raw=true" alt="Showing usage of scale highlighting dialog" width="600">

### Ghost track

With a ghost track, you can easily set note guidelines for composing. Simply choose a track, and you will see the notes
in the piano roll background. With enabled mirroring, every note of your selected track will be spread across all
octaves. So manually copy or transpose notes across octaves is not needed anymore. There is also a button to easily
switch between the current and the ghost track.

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/ghosttrack.gif?raw=true" alt="Ghost track" width="600">

### Step sequencing with computer keyboard

In Renoise, you can use your computer keyboard to play notes. This is also possible in the piano roll. So, when you play
and hold notes and use the cursor keys left or right to move the edit cursor, it will create or remove notes on the
current cursor position. You can also use your midi kleyboard to play a chords and use the cursor keys to draw them,
when you have seleted the midi in device in the preferences.

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/stepseq.gif?raw=true" alt="Step sequecing in Simple Pianoroll Tool for Renoise" width="600">

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

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/histogram.gif?raw=true" alt="Histogram feature"  width="600">

Here a little video showing you, how you can use it:

[<img src="https://img.youtube.com/vi/zkE5SCw0TyE/0.jpg" width="400">](https://www.youtube.com/watch?v=zkE5SCw0TyE)

### Chord detection and scale degree detection

The piano roll will always try to detect chords of the current selected or played notes. It also tries to determine the
correct scale degree depending on the current scale. It can be used to unterstand music theory better and gives you more
information about the current playing notes.

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/chorddetect.gif?raw=true" alt="Chord detection and scale degree detection" width="600">

### Chord stamping

With the chord stamping you can easily draw chords into the piano roll. The selected chord can be extended by further
notes
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
| Set a loop range                             | Hold <kbd>ctrl</kbd> and use the mouse on the timeline bar with left mouse button to draw in a loop range                                                                                                                                                                                                                                                                                                                                                                                       |
| Move the current loop range                  | Hold <kbd>shift</kbd>, click and hold left mouse button on the current loop range and move your mouse                                                                                                                                                                                                                                                                                                                                                                                           |
| Remove the current loop range                | Double click on the timeline bar or use the loop button                                                                                                                                                                                                                                                                                                                                                                                                                                         |

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
| <kbd>ctrl + p</kbd>                                    | Show preferences                                                                |****

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
| <kbd>ctrl + shift + left</kbd>                                                                               | Increase note length by 1 micro step                                                         |
| <kbd>ctrl + shift + right</kbd>                                                                              | Decrease note length by 1 micro step                                                         |
| <kbd>shift + i</kbd>                                                                                         | Invert note selection                                                                        |
| <kbd>del</kbd> or <kbd>backspace</kbd>                                                                       | Remove selected notes                                                                        |
| <kbd>esc</kbd>                                                                                               | Deselect all notes                                                                           |
| <kbd>ctrl + shift + r</kbd>                                                                                  | Randomly deselect all notes                                                                  |

## Inbuilt additional tools

I've added some of my internal tools, which improved my workflow in Renoise alot. 
I don't want to mantain more than one tool, so I've added them to this tool instead.
It's optional and disabled by default. You need to enable them in the piano roll settings (restart of Renoise is needed).

[<img src="https://img.youtube.com/vi/TYaiSegnP9A/0.jpg" width="400">](https://www.youtube.com/watch?v=TYaiSegnP9A)

### Sample Editor - Fit sample to beat sync ...

This tool helps you to calculate the correct beat sync value for timestretching of loops and set it. It tries to detect 
the correct BPM by the sample length in samples. Please note that the beat sync value also use your lines per beat song 
parameter. So this parameter shouldn't be automated in your song.
When you select a part of your sample (from snare to snare) to manually select a 4 bar loop, because the sample is longer, 
it's using the selection length for calculation.
It'll also extend the sample, when the calculated beat sync value is not a whole number.
Float numbers for the beat sync parameter is currently not supported in Renoise.

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/beatsynccalc.png?raw=true" width="400">

#### Sample Editor - Fit sample to beat sync (Song BPM)

Instead of calculate the correct BPM of a sample, it uses the current Song BPM.
You can use it for one shot synth for pitch shifting.
Or you can create some glitchy sounds, when you automate the line per beat parameter of your song.
Set a quite high LPB value, 16 for example. Then just load some drum sounds like kick / snare and hihats.
Apply the "Fit sample to beat sync (Song BPM)" to each drum sample.
Now create a simple drum pattern and use the ZLxx parameter to automate / change the line per beats in some parts of your loop.

This idea is inspired by a song from suunk. Here is a good interview about his technique:
[<img src="https://img.youtube.com/vi/G0ZRMnpBh1M/0.jpg" width="400">](https://www.youtube.com/watch?v=G0ZRMnpBh1M)

### Sample Editor - Align sample selection to beat

This tool helps you to align swoops or risers in your song. You set the selection cursor to a point of your riser sample, 
where the crash would hit, and then you choose how many lines you would use for the "rising"-part fit in.
So, when you choose 32 lines, the "tail" part of the riser should be played from line 33.
This can also be used on reverse crash samples, when you want to have it exaclty 32 lines long for your song.

### Instrument box - Change instruments global pitch

With this function it's possible to change the instrument pitch of several instrument at once.
Because of the current API limitations, it's not possible to use the instrument selection.
Instead, its using empty instruments as selection borders.
So, when you group your instruments and want to change the pitch of these in one step, it's possible now.

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/globalpitchinstr.png?raw=true" width="400">

### Matrix view - Duplicate content

I often want to duplicate a whole pattern. 
So a 64 pattern can be enlarged to a 128 pattern and the content will be duplicated.
Just right-click on a pattern and choose "Duplicate content ...".

### Useful global keyboard shortcuts

Some useful keyboard shortcuts for mixing and analysing. 
These can be found under "Global \ Simple Pianoroll - Workflow Tools".  
Supported plugins are currently limited. Other plugins can be added via feature requests. 

<img src="https://github.com/ryrun/com.dufte.SimplePianoroll.xrnx/blob/master/docs/images/keyshortcuts.png?raw=true" width="400">

#### Audio reference switch

Switch between Renoise song and a Reference song in your plugin on a master channel.
Supported plugins currently are:

* MeldaProduction: MCompare
* Plugin Alliance: ADPTR MetricAB

#### Sub Filter switch

Enable / disable sub only filter on master channel for checking sub frequencies.
Supported plugins currently are:

* MeldaProduction: MCompare
* Plugin Alliance: ADPTR MetricAB

#### Show / Hide Analyzer

Show or Hide the audio analyzer plugin on the master channel.
Supported plugins currently are:

* Voxengo: SPAN
* Plugin Alliance: ADPTR MetricAB

#### Show / Hide Waveform Analyzer

Show or Hide the waveform analyzer plugin on the master channel.
Supported plugins currently are:

* Xfer Records: LFOTool_x64
* Cableguys: ShaperBox 3