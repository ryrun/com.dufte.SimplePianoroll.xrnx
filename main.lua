--some basic renoise vars for reuse
local app = renoise.app()
local tool = renoise.tool()
local vb
local vbw
local song

--load manifest for fetching versionnumber
local manifest = renoise.Document.create("RenoiseScriptingTool") {
    Version = "",
}
manifest:load_from("manifest.xml")

--notes table
local notesTable = {
    "C",
    "C#",
    "D",
    "D#",
    "E",
    "F",
    "F#",
    "G",
    "G#",
    "A",
    "A#",
    "B",
}

local scaleTypes = {
    "None",
    "Major scale",
    "Minor scale",
    "Instrument scale",
    "Automatic scale",

}

local scaleDegreeAndRomanNumeral = {
    --none
    nil,
    --maj
    {
        "I - Tonic",
        nil,
        "ii - Supertonic",
        nil,
        "iii - Mediant",
        "IV - Subdominant",
        nil,
        "V - Dominant",
        nil,
        "vi - Submediant",
        nil,
        "vii - Leading tone",
    },
    --min
    {
        "i - Tonic",
        nil,
        "ii - Supertonic",
        "III - Mediant",
        nil,
        "iv - Subdominant",
        nil,
        "v - Dominant",
        "VI - Submediant",
        nil,
        "VII - Subtonic",
    },
}

local chordsTable = {
    ["0,1"] = "minor 2nd",
    ["0,2"] = "Major 2nd",
    ["0,3"] = "minor 3rd",
    ["0,4"] = "Major 3rd",
    ["0,5"] = "Perfect 4th",
    ["0,6"] = "Tritone",
    ["0,7"] = "Perfect 5th",
    ["0,8"] = "minor 6th",
    ["0,9"] = "Major 6th",
    ["0,10"] = "minor 7th",
    ["0,11"] = "Major 7th",
    ["0,4,7"] = "Maj",
    ["0,3,7"] = "min",
    ["0,4,7,10"] = "7",
    ["0,4,7,11"] = "Maj7",
    ["0,4,6,7,11"] = "Maj7(#11)",
    ["0,3,7,10"] = "min7",
    ["0,3,7,11"] = "minMaj7",
    ["0,5,7"] = "Sus4",
    ["0,2,7"] = "Sus2",
    ["0,4,7,9"] = "Maj6",
    ["0,3,7,9"] = "min6",
    ["0,2,4"] = "Maj(add2)",
    ["0,2,3,7,11"] = "min(Maj9)",
    ["0,2,4,5,7,10"] = "11",
    ["0,2,3,5,7,10"] = "min11",
    ["0,2,4,5,7,11"] = "Maj11",
    ["0,2,3,5,7,11"] = "minMaj11",
    ["0,2,4,7,9,10"] = "13",
    ["0,2,3,7,9,10"] = "min13",
    ["0,2,4,7,9,11"] = "Maj13",
    ["0,2,3,7,9,11"] = "minMaj13",
    ["0,2,4,7"] = "Maj(add2)",
    ["0,2,4,7,11"] = "Maj9",
    ["0,2,3,7"] = "minor(add2)",
    ["0,2,4,7,9"] = "Pentatonic",
    ["0,2,3,7,9"] = "min6/9",
    ["0,4,5,7,10"] = "7(add1)",
    ["0,4,5,7,11"] = "SusMaj7(add3)",
    ["0,3,5,7,10"] = "Minor Pentatonic",
    ["0,4,7,9,10"] = "13(no 9)",
    ["0,4,7,9,11"] = "Maj13(no9)",
    ["0,3,7,9,10"] = "min7(13)",
    ["0,3,7,9,11"] = "minMaj7(13)",
    ["0,4,6,10"] = "7b5",
    ["0,4,8,10"] = "7#5",
    ["0,1,4,7,10"] = "7(b9)",
    ["0,3,4,7,10"] = "7(#9)",
    ["0,1,4,8,10"] = "7(b9#5)",
    ["0,3,6,10"] = "min7b5",
    ["0,2,4,6,7,10"] = "9(#11)",
    ["0,5,7,9"] = "6sus4",
    ["0,5,7,10"] = "7sus4",
    ["0,5,7,11"] = "Maj7 Sus4",
    ["0,2,5,7,10"] = "9sus4",
    ["0,2,5,7,11"] = "Maj9sus4",
    ["0,2,4,7,10"] = "9",
    ["0,3,6"] = "dim",
    ["0,3,6,9"] = "dim7",
    ["0,7,10"] = "7(no3)",
    --chords with some missing notes
    ["0,7,11"] = "Maj7",
    ["0,4,11"] = "Maj7",
    ["0,3,5,7"] = "min11",
    ["0,4,5,7"] = "Maj11",
}

--default values, can be used to reset to default
local defaultPreferences = {
    gridStepSizeW = 20,
    gridStepSizeH = 18,
    gridSpacing = 4,
    gridMargin = 1,
    gridWidth = 64,
    gridHeight = 42,
    triggerTime = 250,
    keyInfoTime = 3,
    enableKeyInfo = true,
    dblClickTime = 400,
    forcePenMode = false,
    notePreview = true,
    enableOSCClient = true,
    snapToGridSize = 20,
    oscConnectionString = "udp://127.0.0.1:8000",
    applyVelocityColorShading = true,
    velocityColorShadingAmount = 0.49,
    followPlayCursor = true,
    scaleHighlightingType = 2,
    keyForSelectedScale = 1,
    addNoteOffToEmptyNoteColumns = true,
    addNoteColumnsIfNeeded = true,
    keyboardStyle = 1,
    noNotePreviewDuringSongPlayback = false,
    highlightEntireLineOfPlayingNote = false,
    rowHighlightingAmount = 0.15,
    oddBarsShadingAmount = 0.10,
    scaleBtnShadingAmount = 0.25,
    rootKeyShadingAmount = 0.15,
    outOfNoteScaleShadingAmount = 0.15,
    azertyMode = false,
    scrollWheelSpeed = 2,
    clickAreaSizeForScalingPx = 7,
    disableKeyHandler = false,
    shadingType = 1,
    previewPolyphony = 3,
    limitPreviewBySelectionSize = true,
    disableAltClickNoteRemove = true,
    resetVolPanDlyControlOnClick = true,
    minSizeOfNoteButton = 5,
    setLastEditedTrackAsGhost = true,
    useTrackColorForNoteHighlighting = false,
    useTrackColorForNoteColor = false,
    autoEnableDelayWhenNeeded = true,
    setVelPanDlyLenFromLastNote = true,
    centerViewOnOpen = true,
    chordDetection = true,
    keyLabels = 2,
    --colors
    colorBaseGridColor = "#34444E",
    colorNote = "#AAD9B3",
    colorGhostTrackNote = "#50616B",
    colorNoteGhost = "#C2B1E2",
    colorNoteHighlight = "#E8CC6E",
    colorNoteMuted = "#ABBBC6",
    colorNoteSelected = "#F49695",
    colorStepOff = "#1E0600",
    colorStepOn = "#F16A32",
    colorList = "#464F54",
    colorKeyWhite = "#FFFFFF",
    colorKeyBlack = "#141414",
    colorVelocity = "#D4BC24",
    colorPan = "#8ABB7A",
    colorDelay = "#47C2EC",
}

--tool preferences
local preferences = renoise.Document.create("ScriptingToolPreferences") {
    gridStepSizeW = defaultPreferences.gridStepSizeW,
    gridStepSizeH = defaultPreferences.gridStepSizeH,
    gridSpacing = defaultPreferences.gridSpacing,
    gridMargin = defaultPreferences.gridMargin,
    gridWidth = defaultPreferences.gridWidth,
    gridHeight = defaultPreferences.gridHeight,
    minSizeOfNoteButton = defaultPreferences.minSizeOfNoteButton,
    triggerTime = defaultPreferences.triggerTime,
    enableOSCClient = defaultPreferences.enableOSCClient,
    noNotePreviewDuringSongPlayback = defaultPreferences.noNotePreviewDuringSongPlayback,
    dblClickTime = defaultPreferences.dblClickTime,
    forcePenMode = defaultPreferences.forcePenMode,
    notePreview = defaultPreferences.notePreview,
    oscConnectionString = defaultPreferences.oscConnectionString,
    applyVelocityColorShading = defaultPreferences.applyVelocityColorShading,
    velocityColorShadingAmount = defaultPreferences.velocityColorShadingAmount,
    scaleBtnShadingAmount = defaultPreferences.scaleBtnShadingAmount,
    shadingType = defaultPreferences.shadingType,
    highlightEntireLineOfPlayingNote = defaultPreferences.highlightEntireLineOfPlayingNote,
    rowHighlightingAmount = defaultPreferences.rowHighlightingAmount,
    followPlayCursor = defaultPreferences.followPlayCursor,
    addNoteOffToEmptyNoteColumns = defaultPreferences.addNoteOffToEmptyNoteColumns,
    addNoteColumnsIfNeeded = defaultPreferences.addNoteColumnsIfNeeded,
    keyboardStyle = defaultPreferences.keyboardStyle,
    keyInfoTime = defaultPreferences.keyInfoTime,
    enableKeyInfo = defaultPreferences.enableKeyInfo,
    resetVolPanDlyControlOnClick = defaultPreferences.resetVolPanDlyControlOnClick,
    scaleHighlightingType = defaultPreferences.scaleHighlightingType,
    keyForSelectedScale = defaultPreferences.keyForSelectedScale,
    oddBarsShadingAmount = defaultPreferences.oddBarsShadingAmount,
    rootKeyShadingAmount = defaultPreferences.rootKeyShadingAmount,
    outOfNoteScaleShadingAmount = defaultPreferences.outOfNoteScaleShadingAmount,
    azertyMode = defaultPreferences.azertyMode,
    scrollWheelSpeed = defaultPreferences.scrollWheelSpeed,
    clickAreaSizeForScalingPx = defaultPreferences.clickAreaSizeForScalingPx,
    disableKeyHandler = defaultPreferences.disableKeyHandler,
    disableAltClickNoteRemove = defaultPreferences.disableAltClickNoteRemove,
    setLastEditedTrackAsGhost = defaultPreferences.setLastEditedTrackAsGhost,
    useTrackColorForNoteHighlighting = defaultPreferences.useTrackColorForNoteHighlighting,
    useTrackColorForNoteColor = defaultPreferences.useTrackColorForNoteColor,
    autoEnableDelayWhenNeeded = defaultPreferences.autoEnableDelayWhenNeeded,
    snapToGridSize = defaultPreferences.snapToGridSize,
    setVelPanDlyLenFromLastNote = defaultPreferences.setVelPanDlyLenFromLastNote,
    keyLabels = defaultPreferences.keyLabels,
    centerViewOnOpen = defaultPreferences.centerViewOnOpen,
    previewPolyphony = defaultPreferences.previewPolyphony,
    limitPreviewBySelectionSize = defaultPreferences.limitPreviewBySelectionSize,
    chordDetection = defaultPreferences.chordDetection,
    --colors
    colorBaseGridColor = defaultPreferences.colorBaseGridColor,
    colorNote = defaultPreferences.colorNote,
    colorGhostTrackNote = defaultPreferences.colorGhostTrackNote,
    colorNoteGhost = defaultPreferences.colorNoteGhost,
    colorNoteHighlight = defaultPreferences.colorNoteHighlight,
    colorNoteMuted = defaultPreferences.colorNoteMuted,
    colorNoteSelected = defaultPreferences.colorNoteSelected,
    colorStepOff = defaultPreferences.colorStepOff,
    colorStepOn = defaultPreferences.colorStepOn,
    colorList = defaultPreferences.colorList,
    colorKeyWhite = defaultPreferences.colorKeyWhite,
    colorKeyBlack = defaultPreferences.colorKeyBlack,
    colorVelocity = defaultPreferences.colorVelocity,
    colorPan = defaultPreferences.colorPan,
    colorDelay = defaultPreferences.colorDelay,
}
tool.preferences = preferences

--dialog vars
local windowObj
local windowContent
local stepSlider
local noteSlider

--last step position for resetting the last step button
local lastStepOn
local lastEditPos

--current note offset and stepoffset (x/y) - sliders (scrollbars)
local noteOffset
local stepOffset = 0

--load grid settings
local gridStepSizeW
local gridStepSizeH
local gridSpacing
local gridMargin
local gridWidth
local gridHeight
local pianoKeyWidth

--colors
local colorDefault = { 0, 0, 0 }
local colorBaseGridColor
local colorGhostTrackNote
local colorList
local colorNote
local colorNoteGhost
local colorNoteHighlight
local colorNoteMuted
local colorNoteSelected
local colorStepOff
local colorStepOn
local colorKeyWhite
local colorKeyBlack
local colorVelocity
local colorPan
local colorDelay

--calculated colors
local colorWhiteKey = {}
local colorBlackKey = {}

--temp table to backup colors
local defaultColor = {}

--note trigger vars
local oscClient
local lastTriggerNote = {}

--missing block loop observable? use a variable for check there was a change
local blockloopidx

--main flag for refreshing pianoroll
local rebuildWindowDialog = true
local refreshPianoRollNeeded = false
local blockLineModifier = false
local refreshControls = false
local refreshTimeline = false
local refreshChordDetection = false

--table to save note indices per step for highlighting
local noteOnStep = {}

--table with all current playing notes on step
local notesOnStep = {}
local notesPlaying = {}
local notesPlayingLine = {}

--table for save used notes
local noteButtons = {}

--table for clipboard function
local clipboard = {}

--edit vars
local lastClickCache = {}
local pasteCursor = {}
local currentNoteLength = 2
local currentNoteVelocity = 255
local currentNotePan = 255
local currentNoteDelay = 0
local currentNoteEndDelay = 0
local currentNoteVelocityPreview = 127
local currentNoteEndVelocity = 255
local currentNoteGhost
local currentInstrument
local currentGhostTrack
local currentScale
local currentScaleOffset
local lastTrackIndex

local noteSelection = {}
local lowestNote
local highestNote

local noteData = {}
local usedNoteIndices = {}

local lastKeyInfoTime

--key states
local keyControl = false
local keyRControl = false
local keyShift = false
local keyRShift = false
local keyAlt = false
local lastKeyPress

--mouse handling vars
local xypadpos = {
    x = 0, --click pos x
    y = 0, --click pos y
    nx = 0, --note x pos
    ny = 0, --note y pos
    nlen = 0, --note len
    time = 0, --click time
    lastx = 0,
    lasty = 0,
    lastval = nil,
    notemode = false, --when note mode is active
    scalemode = false, --is scale mode active?
    scaling = false, --are we scaling currently?
    duplicate = false, --for duplicate shortcut state var
    distanceblock = false, --some distance needed before process anything
    resetscale = false,
    pickuptiming = 0.025, --time before trackpad reacts
    scalethreshold = 0.2,
    selection_key = nil,
    idx = nil,
    leftClick = false,
}

--pen mode
local penMode = false
local audioPreviewMode = false

--step preview
local stepPreview = false

--table to save last playing note for qwerty playing
local lastKeyboardNote = {}

--force value between and inclusive min/max values
local function clamp(val, min, max)
    if min > max then
        min, max = max, min
    end
    return math.max(min, math.min(max, val))
end

--calc distance
local function calcDistance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

--show some text in Renoise status bar
local function showStatus(status)
    app:show_status("Simple Pianoroll: " .. status)
end

--set undo description
local function setUndoDescription(description)
    song:describe_undo("Simple Pianoroll: " .. description)
end

local function badTrackError()
    showStatus("Current selected track cant be edited with piano roll.")
    if windowObj and windowObj.visible then
        windowObj:close()
    end
end

--return special "hex" value which allow values like ZF
local function toRenoiseHex(val)
    local t = string.format("%X", val)
    t = string.upper(t)
    if string.len(t) == 1 then
        t = "0" .. t
    end
    if string.len(t) > 2 then
        local tend = string.sub(t, -1)
        local tstart = string.sub(t, 0, string.len(t) - 1)
        tstart = tonumber(tstart, 16)
        tstart = string.char(string.byte("G") - 16 + tstart)
        return tstart .. tend
    else
        return t
    end
end

--converts special "hex" value like ZF to a number
local function fromRenoiseHex(val)
    val = string.upper(val)
    if string.len(val) > 2 then
        return -1
    end
    if string.len(val) < 2 then
        val = "0" .. val
    end
    local tend = string.sub(val, -1)
    local tstart = string.sub(val, 0, 1)
    if string.byte(tstart) >= string.byte("G") then
        tstart = 16 + string.byte(tstart) - string.byte("G")
        tstart = string.format("%X", tstart)
    end
    return tonumber(tstart .. tend, 16)
end

--plural text function
local function getSingularPlural(val, singular, plural, addVal)
    local b = ""
    if addVal then
        b = math.abs(val) .. " "
    end
    if math.abs(val) == 1 then
        return b .. singular
    end
    return b .. plural
end

--simple minMax
local function forceValueToRange(val, min, max)
    if val >= max then
        val = max
    elseif val <= min then
        val = min
    end
    return val
end

--find nearest values
local function findNearestMicroStepValue(currentval, add, array)
    local v
    local val = currentval + add
    local steps = math.floor((currentval + add) / 0x100)
    val = val - (steps * 0x100)
    for key in pairs(array) do
        if not v then
            v = array[key]
        else
            if math.abs(val - array[key]) < math.abs(val - v) then
                v = array[key]
            end
            if math.abs(val - -(array[key])) < math.abs(val - v) then
                v = -array[key]
            end
        end
    end
    v = v - currentval
    v = v + (steps * 0x100)
    return v
end

--change a value randomly
local function randomizeValue(input, scale, min, max)
    local r = math.random(-scale, scale)
    input = input + r
    if input > max then
        input = max
    elseif input < min then
        input = min
    end
    return input
end

--for the line index calculate the correct bar index
local function calculateBarBeat(line, returnbeat, lpb)
    if not lpb then
        lpb = song.transport.lpb
    end
    if returnbeat == true then
        return math.ceil((line - lpb) / lpb) % 4 + 1
    end
    return math.ceil((line - (lpb * 4)) / (lpb * 4)) + 1
end

--shade color
local function shadeColor(color, shade)
    if shade == 0 then
        return color
    end
    return {
        math.max(color[1] * (1 - shade), 1),
        math.max(color[2] * (1 - shade), 1),
        math.max(color[3] * (1 - shade), 1)
    }
end

--alphablend colors
local function alphablendColors(color1, color2, alphablend)
    if alphablend == 0 then
        return color1
    end
    return {
        math.max(color2[1] * (1 - alphablend) + color1[1] * alphablend, 1),
        math.max(color2[2] * (1 - alphablend) + color1[2] * alphablend, 1),
        math.max(color2[3] * (1 - alphablend) + color1[3] * alphablend, 1)
    }
end

--simple function for coloring velocity
local function colorNoteVelocity(vel, ghost, isOnStep, isInSelection)
    local color
    local noteColor = colorNote
    if isInSelection then
        noteColor = colorNoteSelected
    elseif isOnStep == true then
        if preferences.useTrackColorForNoteHighlighting.value then
            return vbw["trackcolor"].color
        else
            return colorNoteHighlight
        end
    elseif vel == 0 then
        return colorNoteMuted
    elseif ghost == true then
        noteColor = colorNoteGhost
    elseif preferences.useTrackColorForNoteColor.value then
        noteColor = vbw["trackcolor"].color
    end
    if vel < 0x7f and preferences.applyVelocityColorShading.value then
        if preferences.shadingType.value == 2 then
            color = alphablendColors(colorBaseGridColor,
                    noteColor,
                    preferences.velocityColorShadingAmount.value / 0x7f * (0x7f - vel))
        else
            color = shadeColor(noteColor, preferences.velocityColorShadingAmount.value / 0x7f * (0x7f - vel))
        end
    else
        color = noteColor
    end
    return color
end

--return true if delay column is enabled, check for auto enable
local function isDelayColumnActive(showHint)
    --auto enable delay column
    if not song.selected_track.delay_column_visible then
        if preferences.autoEnableDelayWhenNeeded.value then
            song.selected_track.delay_column_visible = true
            return true
        else
            --no microstep movement without delay column
            if showHint then
                showStatus("Please enable delay column for micro steps actions.")
            end
            return false
        end
    end
    return true
end

--converts a color string to a table
local function convertStringToColorValue(val, default)
    local ret
    local red, green, blue = string.match(val, '^#*([0-9a-fA-F][0-9a-fA-F])([0-9a-fA-F][0-9a-fA-F])([0-9a-fA-F][0-9a-fA-F])$')
    if red and green and blue then
        ret = {
            fromRenoiseHex(red),
            fromRenoiseHex(green),
            fromRenoiseHex(blue),
        }
    else
        red, green, blue = string.match(val, '^#*([0-9a-fA-F])([0-9a-fA-F])([0-9a-fA-F])$')
        if red and green and blue then
            ret = {
                fromRenoiseHex(red .. red),
                fromRenoiseHex(green .. green),
                fromRenoiseHex(blue .. blue),
            }
        else
            red, green, blue = string.match(val, '^ *([0-9]+) *[,; ] *([0-9]+) *[,; ] *([0-9]+) *$')
            if red and green and blue then
                ret = {
                    clamp(tonumber(red), 0, 255),
                    clamp(tonumber(green), 0, 255),
                    clamp(tonumber(blue), 0, 255),
                }
            end
        end
    end
    if not ret then
        if default then
            ret = convertStringToColorValue(default)
        else
            ret = { 0, 0, 0 }
        end
    end
    return ret
end

--convert table to string
local function convertColorValueToString(val)
    local ret
    if #val == 3 then
        ret = "#" .. toRenoiseHex(val[1]) .. toRenoiseHex(val[2]) .. toRenoiseHex(val[3])
    end
    return ret
end

--init dynamic calculated colors
local function initColors()
    --load colors from preferences
    colorBaseGridColor = convertStringToColorValue(preferences.colorBaseGridColor.value, defaultPreferences.colorBaseGridColor)
    colorNote = convertStringToColorValue(preferences.colorNote.value, defaultPreferences.colorNote)
    colorGhostTrackNote = convertStringToColorValue(preferences.colorGhostTrackNote.value, defaultPreferences.colorGhostTrackNote)
    colorNoteGhost = convertStringToColorValue(preferences.colorNoteGhost.value, defaultPreferences.colorNoteGhost)
    colorNoteHighlight = convertStringToColorValue(preferences.colorNoteHighlight.value, defaultPreferences.colorNoteHighlight)
    colorNoteMuted = convertStringToColorValue(preferences.colorNoteMuted.value, defaultPreferences.colorNoteMuted)
    colorNoteSelected = convertStringToColorValue(preferences.colorNoteSelected.value, defaultPreferences.colorNoteSelected)
    colorStepOn = convertStringToColorValue(preferences.colorStepOn.value, defaultPreferences.colorStepOn)
    colorStepOff = convertStringToColorValue(preferences.colorStepOff.value, defaultPreferences.colorStepOff)
    colorList = convertStringToColorValue(preferences.colorList.value, defaultPreferences.colorList)
    colorKeyWhite = convertStringToColorValue(preferences.colorKeyWhite.value, defaultPreferences.colorKeyWhite)
    colorKeyBlack = convertStringToColorValue(preferences.colorKeyBlack.value, defaultPreferences.colorKeyBlack)
    colorVelocity = convertStringToColorValue(preferences.colorVelocity.value, defaultPreferences.colorVelocity)
    colorPan = convertStringToColorValue(preferences.colorPan.value, defaultPreferences.colorPan)
    colorDelay = convertStringToColorValue(preferences.colorDelay.value, defaultPreferences.colorDelay)
    --prepare shading colors
    colorWhiteKey = { shadeColor(colorBaseGridColor, preferences.oddBarsShadingAmount.value), colorBaseGridColor }
    colorBlackKey = {
        shadeColor(colorWhiteKey[1], preferences.outOfNoteScaleShadingAmount.value),
        shadeColor(colorWhiteKey[2], preferences.outOfNoteScaleShadingAmount.value)
    }
end

--check mode
local function checkMode(mode)
    if mode == "preview" then
        if audioPreviewMode or (keyControl and keyShift and not keyAlt) then
            return true
        end
    end
    if mode == "pen" then
        if (penMode and not keyAlt) or (not keyControl and not keyShift and keyAlt and not penMode) then
            return true
        end
    end
    return false
end

--refresh edit pos
local function refreshEditPosIndicator()
    if lastEditPos == nil or lastEditPos ~= song.transport.edit_pos.line - stepOffset then
        if vbw["se" .. tostring(lastEditPos)] then
            vbw["se" .. tostring(lastEditPos)].visible = false
        end
        lastEditPos = song.transport.edit_pos.line - stepOffset
        if vbw["se" .. tostring(lastEditPos)] then
            vbw["se" .. tostring(lastEditPos)].color = colorStepOn
            vbw["se" .. tostring(lastEditPos)].visible = true
        end
    end
end

--jump to the note position in pattern
local function jumpToNoteInPattern(notedata)
    --jump to the first note in selection, when needed
    if type(notedata) == "string" and notedata == "sel" then
        if #noteSelection > 0 then
            table.sort(noteSelection, function(a, b)
                return a.line + a.dly / 0x100 < b.line + a.dly / 0x100
            end)
            notedata = noteSelection[1]
        else
            --no selection, dont do anything
            return false
        end
    end
    --only when not playing or follow player
    if not song.transport.playing or not song.transport.follow_player then
        --only when the edit cursor is in the correct pattern
        if song.selected_pattern_index == song.sequencer:pattern(song.transport.edit_pos.sequence) then
            local npos = renoise.SongPos()
            npos.line = notedata.line
            npos.sequence = song.transport.edit_pos.sequence
            song.transport.edit_pos = npos
            --switch to the correct note column
            if song.selected_note_column_index ~= notedata.column then
                song.selected_note_column_index = notedata.column
            end
        end
    end
    --refresh edit pos
    refreshEditPosIndicator()
    refreshChordDetection = true
end

--check if a note index is in major scale
local function noteIndexInMajorScale(noteIndex)
    if noteIndex == 1 or noteIndex == 3 or noteIndex == 6 or noteIndex == 8 or noteIndex == 10 then
        return false
    end
    return true
end

--return note index of scale
local function noteIndexInScale(note, forceMajorC)
    if not forceMajorC then
        if currentScaleOffset ~= nil then
            note = note - (currentScaleOffset - 1)
        end
        if currentScale == 1 or currentScale == nil then
            --no scale
            return -1
        elseif currentScale == 3 then
            --minor
            note = note - 3
        end
    end
    note = note % 12
    return note
end

--return true, when note in scale
local function noteInScale(note, forceMajorC)
    note = noteIndexInScale(note, forceMajorC)
    if note == -1 then
        return true
    end
    if noteIndexInMajorScale(note) then
        return true
    end
    return false
end

--return index, when note is in selection
local function noteInSelection(notedata)
    local ret
    for i = 1, #noteSelection do
        local note_data = noteSelection[i]
        --just search for line in pattern and column
        if note_data.line == notedata.line and note_data.column == notedata.column then
            ret = i
            break
        end
    end
    return ret
end

--return true, when a note off was set
local function addNoteToPattern(column, line, len, note, vel, end_vel, pan, dly, end_dly, ghst)
    local noteoff = false
    local lineValues = song.selected_pattern_track.lines

    --when no instrument is set, use the current selected one
    if not currentInstrument then
        currentInstrument = song.selected_instrument_index
    end

    lineValues[line]:note_column(column).note_value = note
    lineValues[line]:note_column(column).volume_string = toRenoiseHex(vel)
    lineValues[line]:note_column(column).panning_string = toRenoiseHex(pan)
    lineValues[line]:note_column(column).delay_string = toRenoiseHex(dly)
    if not ghst then
        lineValues[line]:note_column(column).instrument_value = currentInstrument - 1
    end
    if len > 1 then
        lineValues[line + len - 1]:note_column(column).volume_string = toRenoiseHex(end_vel)
    elseif end_vel > 0 and end_vel ~= 255 then
        lineValues[line]:note_column(column).volume_string = toRenoiseHex(end_vel)
    end
    --set note off?
    if line + len <= song.selected_pattern.number_of_lines then
        if lineValues[line + len]:note_column(column).note_value >= 120 then
            noteoff = true
            lineValues[line + len]:note_column(column).note_value = 120
            lineValues[line + len]:note_column(column).delay_string = toRenoiseHex(end_dly)
        end
    elseif line + len - 1 == song.selected_pattern.number_of_lines then
        --set note off to the beginning of a pattern for looping purpose
        if lineValues[1]:note_column(column).note_value >= 120 then
            --noteoff = true
            lineValues[1]:note_column(column).note_value = 120
        end
    end
    --show note column if hidden
    if column > song.selected_track.visible_note_columns then
        song.selected_track.visible_note_columns = column
    end
    return noteoff
end

--search for a column, which have enough space for the line and length of a new note
local function returnColumnWhenEnoughSpaceForNote(line, len, dly, end_dly)
    local sT = song.selected_pattern_track
    local number_of_lines = song.selected_pattern.number_of_lines
    local lineLen = line + len
    local column, validSpace, maxColumns, lV, lVnC
    --note outside the grid?
    if line < 1 or lineLen - 1 > number_of_lines then
        return nil
    end
    --note with end dly outside the grid?
    if end_dly and end_dly > 0 and lineLen - 1 > number_of_lines - 1 then
        return nil
    end
    --check if enough space for a new note
    maxColumns = song.selected_track.visible_note_columns
    if preferences.addNoteColumnsIfNeeded.value then
        maxColumns = song.selected_track.max_note_columns
    end
    for c = 1, maxColumns do
        validSpace = true
        --check for note on before
        if line > 1 then
            for i = line, 1, -1 do
                lV = sT:line(i)
                if not lV.is_empty then
                    lVnC = lV:note_column(c)
                    if lVnC.note_value < 120 then
                        validSpace = false
                        break
                    elseif lVnC.note_value == 120 then
                        --note off with a delay value?
                        if lVnC.delay_value > 0 and line == i then
                            validSpace = false
                        end
                        break
                    end
                end
            end
        end
        --check for note on in
        if validSpace then
            for i = line, lineLen - 1 do
                lV = sT:line(i)
                if not lV.is_empty then
                    lVnC = lV:note_column(c)
                    --no note off allowed to overwrite, when delay is set and the note off is not on line 1
                    if i == line and line > 1 and dly and dly > 0 and lVnC.note_value == 120 then
                        validSpace = false
                        break
                    elseif lVnC.note_value < 120 then
                        validSpace = false
                        break
                    end
                end
            end
            --check for note on with delay, note off is needed
            if validSpace then
                lV = sT:line(lineLen)
                if lV then
                    if not lV.is_empty then
                        lVnC = lV:note_column(c)
                        if lVnC.note_value < 120
                                and lVnC.delay_value > 0 then
                            validSpace = false
                        end
                        --check if there is enough space for note off with delay
                        if end_dly and end_dly > 0
                                and lVnC.note_value < 121 then
                            validSpace = false
                        end
                    end
                end
                --found valid space, break the loop
                if validSpace then
                    column = c
                    break
                end
            end
        end
    end
    return column
end

--remove note
local function removeNoteInPattern(column, line, len)
    local lineValues = song.selected_pattern_track.lines
    local note_column = lineValues[line]:note_column(column)
    local steps = song.selected_pattern.number_of_lines
    if note_column ~= nil then
        note_column:clear()
        if line == 1 then
            --check for note on before this note, set note off when needed
            for i = steps, 1, -1 do
                local temp = lineValues[i]:note_column(column)
                if temp.note_value < 120 then
                    note_column.note_value = 120
                    break
                elseif temp.note_value == 120 then
                    break
                end
            end
        else
            --check for note on before this note, set note off when needed
            for i = line, 1, -1 do
                local temp = lineValues[i]:note_column(column)
                if temp.note_value < 120 then
                    note_column.note_value = 120
                    break
                elseif temp.note_value == 120 then
                    break
                end
            end
        end
        --remove end note vel
        if len > 1 then
            note_column = lineValues[line + len - 1]:note_column(column)
            note_column:clear()
        end
        --remove note off, when needed
        if line + len <= song.selected_pattern.number_of_lines then
            note_column = lineValues[line + len]:note_column(column)
            if note_column.note_value == 120 then
                note_column:clear()
            end
        end
        --remove note off in the beginning, when note off was added for looping purpose
        if line + len - 1 == song.selected_pattern.number_of_lines then
            note_column = lineValues[1]:note_column(column)
            if note_column.note_value == 120 then
                note_column:clear()
            end
        end
        return true
    end
    return false
end

--remove selected notes
local function removeSelectedNotes(cut)
    --different undo description for cut
    if cut then
        setUndoDescription("Cut notes ...")
    else
        setUndoDescription("Delete notes ...")
    end
    --loop through selected notes
    for i = 1, #noteSelection do
        removeNoteInPattern(noteSelection[i].column, noteSelection[i].line, noteSelection[i].len)
    end
    noteSelection = {}
    refreshPianoRollNeeded = true
end

--simple function for double click detection for buttons
local function dbclkDetector(index)
    if lastClickCache[index] ~= nil and os.clock() - lastClickCache[index] < preferences.dblClickTime.value / 1000 then
        return true
    end
    lastClickCache[index] = os.clock()
    return false
end

--refresh all controls
local function refreshNoteControls()
    local track = song.selected_track

    vbw.note_len.value = currentNoteLength

    if currentNoteGhost == true then
        vbw.note_ghost.color = colorNoteGhost
    else
        vbw.note_ghost.color = colorDefault
    end

    if song.selected_track.volume_column_visible then
        -- velocity column visible
        vbw.notecolumn_vel.color = colorVelocity
        vbw.note_vel.active = true
        vbw.note_vel_clear.active = true
        if #noteSelection > 0 then
            vbw.note_vel_humanize.active = true
        else
            vbw.note_vel_humanize.active = false
        end
        if currentNoteVelocity == 255 then
            vbw.note_vel.value = -1
        else
            vbw.note_vel.value = currentNoteVelocity
        end
        if currentNoteVelocity > 0 and currentNoteVelocity < 128 then
            currentNoteVelocityPreview = currentNoteVelocity
        else
            currentNoteVelocityPreview = 127
        end
        if currentNoteEndVelocity == 255 then
            vbw.note_end_vel.value = -1
        else
            vbw.note_end_vel.value = currentNoteEndVelocity
        end
        vbw.note_end_vel.active = true
        vbw.note_end_vel_clear.active = true
    else
        -- velocity column not visible
        vbw.notecolumn_vel.color = colorDefault
        currentNoteVelocityPreview = 127
        vbw.note_vel.value = -1
        vbw.note_end_vel.value = -1
        vbw.note_vel.active = false
        vbw.note_end_vel.active = false
        vbw.note_vel_clear.active = false
        vbw.note_vel_humanize.active = false
        vbw.note_end_vel_clear.active = false
    end

    if song.selected_track.panning_column_visible then
        vbw.notecolumn_pan.color = colorPan
        if currentNotePan == 255 then
            vbw.note_pan.value = -1
        else
            vbw.note_pan.value = currentNotePan
        end
        vbw.note_pan.active = true
        vbw.note_pan_clear.active = true
        if #noteSelection > 0 then
            vbw.note_pan_humanize.active = true
        else
            vbw.note_pan_humanize.active = false
        end
    else
        vbw.notecolumn_pan.color = colorDefault
        vbw.note_pan.value = -1
        vbw.note_pan.active = false
        vbw.note_pan_clear.active = false
        vbw.note_pan_humanize.active = false
    end

    if song.selected_track.delay_column_visible then
        vbw.notecolumn_delay.color = colorDelay
        vbw.note_dly.value = currentNoteDelay
        vbw.note_dly.active = true
        vbw.note_dly_clear.active = true
        vbw.note_end_dly.value = currentNoteEndDelay
        vbw.note_end_dly.active = true
        vbw.note_end_dly_clear.active = true
        if #noteSelection > 0 then
            vbw.note_dly_humanize.active = true
        else
            vbw.note_dly_humanize.active = false
        end
    else
        vbw.notecolumn_delay.color = colorDefault
        vbw.note_dly.value = 0
        vbw.note_dly.active = false
        vbw.note_dly_clear.active = false
        vbw.note_dly_humanize.active = false
        vbw.note_end_dly.value = 0
        vbw.note_end_dly.active = false
        vbw.note_end_dly_clear.active = false
    end

    local ghostTracks = {}
    for i = 1, song.sequencer_track_count do
        if i == song.selected_track_index then
            ghostTracks[i] = "---"
        else
            if song:track(i).type == renoise.Track.TRACK_TYPE_GROUP then
                ghostTracks[i] = "Group: " .. song:track(i).name
            else
                ghostTracks[i] = song:track(i).name
            end
        end
    end
    vbw.ghosttracks.items = ghostTracks
    if not currentGhostTrack or currentGhostTrack > song.sequencer_track_count then
        currentGhostTrack = song.selected_track_index
        vbw.ghosttracks.value = currentGhostTrack
    end

    if checkMode("pen") then
        vbw.mode_pen.color = colorStepOn
        vbw.mode_select.color = colorDefault
        vbw.mode_audiopreview.color = colorDefault
    elseif checkMode("preview") then
        vbw.mode_pen.color = colorDefault
        vbw.mode_select.color = colorDefault
        vbw.mode_audiopreview.color = colorStepOn
    else
        vbw.mode_pen.color = colorDefault
        vbw.mode_select.color = colorStepOn
        vbw.mode_audiopreview.color = colorDefault
    end

    if song.transport.loop_pattern then
        vbw.loopbutton.color = colorStepOn
    else
        vbw.loopbutton.color = colorDefault
    end
    if song.transport.playing then
        vbw.playbutton.color = colorStepOn
    else
        vbw.playbutton.color = colorDefault
    end

    --set color indicator to current track color and name
    vbw.trackcolor.color = track.color
    vbw.trackcolor.tooltip = track.name .. "\n(Switch to ghost track)"
    if string.len(track.name) > 9 then
        vbw.trackcolor.text = string.sub(track.name, 1, 8) .. "…"
    else
        vbw.trackcolor.text = track.name
    end
    if track.solo_state then
        vbw.solo.color = colorStepOn
    else
        vbw.solo.color = colorDefault
    end
    if track.mute_state == 3 then
        vbw.mute.color = colorStepOn
    else
        vbw.mute.color = colorDefault
    end
    vbw.chorddetection.visible = preferences.chordDetection.value
    refreshControls = false
end

--simple note trigger
local function triggerNoteOfCurrentInstrument(note_value, pressed, velocity, newOrChanged)
    local socket_error, successSend, errorSend
    --if osc client is enabled
    if not preferences.enableOSCClient.value then
        return
    end
    --special handling of preview notes, on new notes or changed notes (transpose)
    if newOrChanged then
        if not preferences.notePreview.value then
            return
        end
        if preferences.noNotePreviewDuringSongPlayback.value and song.transport.playing then
            return
        end
    end
    --when no instrument is set, use the current selected one
    local instrument = currentInstrument
    if not currentInstrument then
        instrument = song.selected_instrument_index
    end
    --disable record mode, when enabled
    song.transport.edit_mode = false
    --init server connection, when not ready
    if oscClient == nil then
        local protocol, host, port = string.match(
                preferences.oscConnectionString.value,
                '([a-zA-Z]+)://([0-9a-zA-Z.]+):([0-9]+)'
        )
        if protocol and host and port then
            port = tonumber(port)
            if string.lower(protocol) == "udp" then
                oscClient, socket_error = renoise.Socket.create_client(host, port, renoise.Socket.PROTOCOL_UDP)
            elseif string.lower(protocol) == "tcp" then
                oscClient, socket_error = renoise.Socket.create_client(host, port, renoise.Socket.PROTOCOL_TCP)
            else
                socket_error = "Invalid protocol"
            end
            if (socket_error) then
                showStatus("Error: Cant create OSC socket: " .. socket_error)
                preferences.notePreview.value = false
                preferences.enableOSCClient.value = false
                refreshControls = true
                return
            end
        else
            showStatus("Error: OSC connection string malformed. Note preview disabled.")
            preferences.notePreview.value = false
            preferences.enableOSCClient.value = false
            refreshControls = true
            return
        end
    end
    if not velocity or velocity > 127 then
        velocity = currentNoteVelocityPreview
    end
    if pressed == true then
        notesPlaying[note_value] = 1
        notesPlayingLine[note_value] = nil
        successSend, errorSend = oscClient:send(
                renoise.Osc.Message("/renoise/trigger/note_on", { { tag = "i", value = instrument },
                                                                  { tag = "i", value = song.selected_track_index },
                                                                  { tag = "i", value = note_value },
                                                                  { tag = "i", value = velocity } })
        )
        refreshChordDetection = true
    elseif pressed == false then
        notesPlaying[note_value] = nil
        notesPlayingLine[note_value] = nil
        successSend, errorSend = oscClient:send(
                renoise.Osc.Message("/renoise/trigger/note_off", { { tag = "i", value = instrument },
                                                                   { tag = "i", value = song.selected_track_index },
                                                                   { tag = "i", value = note_value } })
        )
        refreshChordDetection = true
    else
        local polyLimit = preferences.previewPolyphony.value
        --check if the current note already playing
        for i = 1, #lastTriggerNote do
            if lastTriggerNote[i] and lastTriggerNote[i].packet[3].value == note_value then
                return
            end
        end
        --reduce preview polyphony to just the count of selected notes
        if #noteSelection > 0 and preferences.limitPreviewBySelectionSize.value then
            polyLimit = math.min(#noteSelection, polyLimit)
        end
        --check if previewPolyphony limit was hit
        if #lastTriggerNote >= polyLimit then
            local newLastTriggerNote = {}
            --stop playing older notes
            table.sort(lastTriggerNote, function(a, b)
                return a.time < b.time
            end)
            for i = 1, #lastTriggerNote do
                if i <= math.max(1, #lastTriggerNote - preferences.previewPolyphony.value) then
                    table.remove(lastTriggerNote[i].packet, 4) --remove velocity
                    oscClient:send(renoise.Osc.Message("/renoise/trigger/note_off", lastTriggerNote[i].packet))
                else
                    table.insert(newLastTriggerNote, lastTriggerNote[i])
                end
            end
            lastTriggerNote = newLastTriggerNote
        end
        local packet = { { tag = "i", value = instrument },
                         { tag = "i", value = song.selected_track_index },
                         { tag = "i", value = note_value },
                         { tag = "i", value = velocity } }
        --send note event to osc server
        successSend, errorSend = oscClient:send(renoise.Osc.Message("/renoise/trigger/note_on", packet))
        --create a timer for note off, whenn note on was successful
        if successSend then
            table.insert(lastTriggerNote, {
                time = os.clock(),
                packet = packet,
            }
            )
        end
    end
    --on send fail, disable note preview, clsoe socket and show error
    if not successSend then
        showStatus("Error: OSC socket send: " .. errorSend)
        preferences.notePreview.value = false
        preferences.enableOSCClient.value = false
        if oscClient then
            oscClient:close()
            oscClient = nil
        end
        refreshControls = true
    end
end

--start playing from specific line in pattern
local function playPatternFromLine(line)
    song.transport:stop()
    --check for truncated notes, TODO currently not working OFF doesn't send note off, when no note on was before
    --[[
    for key in pairs(noteData) do
        local note_data = noteData[key]
        if line > note_data.line and line < note_data.line + note_data.len then
            triggerNoteOfCurrentInstrument(note_data.note, true, note_data.vel)
        end
    end
    ]]--
    song.transport:start_at(line)
end

--move selected notes
local function moveSelectedNotes(steps)
    local column
    local state = true
    --when nothing is selected, then nothing is to do
    if #noteSelection == 0 then
        return false
    end
    --resort note selection table, so when one note in selection cant be moved, the whole move will be ignored
    if #noteSelection > 1 then
        if steps < 0 then
            --left one notes first
            table.sort(noteSelection, function(a, b)
                return a.line < b.line
            end)
        else
            --right one notes first
            table.sort(noteSelection, function(a, b)
                return a.line + a.len > b.line + b.len
            end)
        end
    end
    --disable edit mode and following to prevent side effects
    song.transport.edit_mode = false
    song.transport.follow_player = false
    --
    setUndoDescription("Move notes ...")
    --go through selection
    for key = 1, #noteSelection do
        --remove note
        removeNoteInPattern(noteSelection[key].column, noteSelection[key].line, noteSelection[key].len)
        --search for valid column
        column = returnColumnWhenEnoughSpaceForNote(
                noteSelection[key].line + steps,
                noteSelection[key].len,
                noteSelection[key].dly,
                noteSelection[key].end_dly
        )
        if column then
            noteSelection[key].step = noteSelection[key].step + steps
            noteSelection[key].line = noteSelection[key].line + steps
            noteSelection[key].column = column
        end
        noteSelection[key].noteoff = addNoteToPattern(
                noteSelection[key].column,
                noteSelection[key].line,
                noteSelection[key].len,
                noteSelection[key].note,
                noteSelection[key].vel,
                noteSelection[key].end_vel,
                noteSelection[key].pan,
                noteSelection[key].dly,
                noteSelection[key].end_dly,
                noteSelection[key].ghst
        )
        if not column then
            state = false
            break
        end
    end
    jumpToNoteInPattern("sel")
    return state
end

--micro step movement selected notes using delay values
local function moveSelectedNotesByMicroSteps(microsteps, snapSpecialGrid)
    local column
    local steps
    local len
    local delay
    --when nothing is selected, then nothing is to do
    if #noteSelection == 0 then
        return false
    end

    --resort note selection table, so when one note in selection cant be moved, the whole move will be ignored
    if #noteSelection > 1 then
        if microsteps < 0 or snapSpecialGrid then
            --left one notes first
            table.sort(noteSelection, function(a, b)
                return a.line + a.dly / 0x100 < b.line + a.dly / 0x100
            end)
        else
            --right one notes first
            table.sort(noteSelection, function(a, b)
                return a.line + a.len + a.end_dly / 0x100 > b.line + b.len + a.end_dly / 0x100
            end)
        end
    end

    --try to snap microsteps to a special grid
    if snapSpecialGrid then
        microsteps = findNearestMicroStepValue(noteSelection[1].dly, microsteps, { 0, 0x55, 0x80, 0xaa })
    end

    --reduce microsteps when there is not enough space
    if microsteps < 0 then
        microsteps = -math.min(math.abs(microsteps), noteSelection[1].dly + ((noteSelection[1].line - 1) * 0x100))
    elseif microsteps > 0 then
        microsteps = math.min(microsteps, song.selected_pattern.number_of_lines * 0x100 -
                ((noteSelection[1].line + noteSelection[1].len - 1) * 0x100 +
                        noteSelection[1].end_dly))
    end

    --no movement necessary?
    if math.floor(microsteps) == 0 then
        return false
    end

    --disable edit mode and following to prevent side effects
    song.transport.edit_mode = false
    song.transport.follow_player = false
    --
    setUndoDescription("Move notes ...")
    --go through selection
    for key = 1, #noteSelection do
        --remove note
        removeNoteInPattern(noteSelection[key].column, noteSelection[key].line, noteSelection[key].len)
        --calculate step and delay difference
        delay = microsteps % 0x100
        steps = math.floor((noteSelection[key].dly + microsteps) / 0x100)
        len = math.floor((noteSelection[key].end_dly + microsteps) / 0x100)
        --prepare len difference for new delay values
        len = len - steps
        --search for column
        column = returnColumnWhenEnoughSpaceForNote(
                noteSelection[key].line + steps,
                noteSelection[key].len + len,
                (noteSelection[key].dly + delay) % 0x100,
                (noteSelection[key].end_dly + delay) % 0x100
        )
        if column then
            noteSelection[key].step = noteSelection[key].step + steps
            noteSelection[key].line = noteSelection[key].line + steps
            noteSelection[key].len = noteSelection[key].len + len
            noteSelection[key].dly = (noteSelection[key].dly + delay) % 0x100
            noteSelection[key].end_dly = (noteSelection[key].end_dly + delay) % 0x100
            noteSelection[key].column = column
        end
        noteSelection[key].noteoff = addNoteToPattern(
                noteSelection[key].column,
                noteSelection[key].line,
                noteSelection[key].len,
                noteSelection[key].note,
                noteSelection[key].vel,
                noteSelection[key].end_vel,
                noteSelection[key].pan,
                noteSelection[key].dly,
                noteSelection[key].end_dly,
                noteSelection[key].ghst
        )
        if not column then
            return false
        end
    end
    jumpToNoteInPattern("sel")
    return microsteps
end

--transpose each selected notes
local function transposeSelectedNotes(transpose, keepscale)
    local lineValues = song.selected_pattern_track.lines
    local ret = true
    --resort note selection table, so when one note in selection cant be moved, the whole move will be ignored
    if transpose > 0 then
        --higher one notes first
        table.sort(noteSelection, function(a, b)
            return a.note > b.note
        end)
    else
        --lower one notes first
        table.sort(noteSelection, function(a, b)
            return a.note < b.note
        end)
    end
    --disable edit mode and following to prevent side effects
    song.transport.edit_mode = false
    song.transport.follow_player = false
    --
    setUndoDescription("Transpose notes ...")
    --go through selection
    for key = 1, #noteSelection do
        local transposeVal = transpose
        --transpose
        local note_column = lineValues[noteSelection[key].line]:note_column(noteSelection[key].column)
        --when in scale transposing is active move note further, when needed
        if keepscale and not noteInScale(noteSelection[key].note + transposeVal) then
            if transposeVal > 0 then
                transposeVal = transposeVal + 1
            else
                transposeVal = transposeVal - 1
            end
        end
        transposeVal = noteSelection[key].note + transposeVal
        --outside the not range skip the whole tansposing
        if transposeVal < 0 then
            ret = false
            break
        elseif transposeVal >= 120 then
            ret = false
            break
        end
        --default transpose note
        noteSelection[key].note = transposeVal
        if noteSelection[key].note < 0 then
            noteSelection[key].note = 0
        elseif noteSelection[key].note >= 120 then
            noteSelection[key].note = 119
        end
        note_column.note_value = noteSelection[key].note
    end
    --trigger notes after transpose
    for key = 1, #noteSelection do
        triggerNoteOfCurrentInstrument(noteSelection[key].note, nil, nil, true)
    end
    jumpToNoteInPattern("sel")
    return ret
end

--paste notes from clipboard
local function pasteNotesFromClipboard()
    local column
    local noteoffset = 0
    local lineoffset = 0
    --disable edit mode and following to prevent side effects
    song.transport.edit_mode = false
    song.transport.follow_player = false
    --describe undo for renoise
    setUndoDescription("Paste notes from clipboard ...")
    if #pasteCursor > 0 then
        table.sort(clipboard, function(a, b)
            if a.line == b.line then
                return a.note < b.note
            end
            return a.line < b.line
        end)
        lineoffset = pasteCursor[1] - clipboard[1].line
        if pasteCursor[2] then
            noteoffset = pasteCursor[2] - clipboard[1].note
        else
            noteoffset = 0
        end
    end
    --process last note first
    table.sort(clipboard, function(a, b)
        return a.line > b.line
    end)
    --clear current note selection
    noteSelection = {}
    --go through clipboard
    for key in pairs(clipboard) do
        --search for valid column
        column = returnColumnWhenEnoughSpaceForNote(
                clipboard[key].line + lineoffset,
                clipboard[key].len,
                clipboard[key].dly,
                clipboard[key].end_dly
        )
        if column then
            clipboard[key].column = column
            clipboard[key].line = clipboard[key].line + lineoffset
            clipboard[key].note = clipboard[key].note + noteoffset
        else
            showStatus("Not enough space to paste notes here.")
            refreshPianoRollNeeded = true
            return false
        end
        clipboard[key].noteoff = addNoteToPattern(
                clipboard[key].column,
                clipboard[key].line,
                clipboard[key].len,
                clipboard[key].note,
                clipboard[key].vel,
                clipboard[key].end_vel,
                clipboard[key].pan,
                clipboard[key].dly,
                clipboard[key].end_dly,
                clipboard[key].ghst
        )
        --add pasted note to selection
        table.insert(noteSelection, clipboard[key])
    end
    --move paste cursor
    table.sort(noteSelection, function(a, b)
        return a.line > b.line
    end)
    pasteCursor = { noteSelection[1].line + noteSelection[1].len, pasteCursor[2] }
    --
    refreshPianoRollNeeded = true
    return true
end

--scale note selection
local function scaleNoteSelection(times)
    setUndoDescription("Scale note selection ...")
    --get offset
    table.sort(noteSelection, function(a, b)
        return a.line < b.line
    end)
    local first_line = noteSelection[1].line
    --change note order depends of sclaing or shrinking
    if times > 1 then
        table.sort(noteSelection, function(a, b)
            return a.line > b.line
        end)
    else
        table.sort(noteSelection, function(a, b)
            return a.line < b.line
        end)
    end
    --go through selection
    for key = 1, #noteSelection do
        removeNoteInPattern(noteSelection[key].column, noteSelection[key].line, noteSelection[key].len)
        --change len and position
        local len = math.max(math.floor(noteSelection[key].len * times), 1)
        local line = math.floor((noteSelection[key].line - first_line) * times) + first_line
        local column = returnColumnWhenEnoughSpaceForNote(line, len, noteSelection[key].dly, noteSelection[key].end_dly)
        if column then
            if noteSelection[key].len == 1 and len > 1 then
                if toRenoiseHex(noteSelection[key].vel):sub(1, 1) == "C" then
                    noteSelection[key].end_vel = noteSelection[key].vel
                    noteSelection[key].vel = 255
                end
            end
            noteSelection[key].column = column
            noteSelection[key].line = line
            noteSelection[key].len = len
        end
        noteSelection[key].noteoff = addNoteToPattern(
                noteSelection[key].column,
                noteSelection[key].line,
                noteSelection[key].len,
                noteSelection[key].note,
                noteSelection[key].vel,
                noteSelection[key].end_vel,
                noteSelection[key].pan,
                noteSelection[key].dly,
                noteSelection[key].end_dly,
                noteSelection[key].ghst
        )
        if not column then
            showStatus("Not enough space to scale selection.")
            return false
        end
    end
    refreshPianoRollNeeded = true
    return true
end

--chop selected notes
local function chopSelectedNotes()
    local newSelection = {}
    setUndoDescription("Chop notes ...")
    --first notes first
    table.sort(noteSelection, function(a, b)
        return a.line < b.line
    end)
    --go through selection
    for key = 1, #noteSelection do
        if noteSelection[key].len > 1 then
            --remove old note
            removeNoteInPattern(noteSelection[key].column, noteSelection[key].line, noteSelection[key].len)
            --create two new notes (chop chop)
            for _, v in pairs({
                {
                    line = noteSelection[key].line,
                    len = math.floor(noteSelection[key].len / 2),
                },
                {
                    line = noteSelection[key].line + math.floor(noteSelection[key].len / 2),
                    len = noteSelection[key].len - math.floor(noteSelection[key].len / 2),
                },
            }) do
                --search for valid column
                local column = returnColumnWhenEnoughSpaceForNote(v.line, v.len, noteSelection[key].dly, noteSelection[key].end_dly)
                if not column then
                    showStatus("Not enough space to chop notes here.")
                    return false
                end
                local note_data = {
                    line = v.line,
                    note = noteSelection[key].note,
                    vel = noteSelection[key].vel,
                    end_vel = noteSelection[key].end_vel,
                    dly = noteSelection[key].dly,
                    end_dly = noteSelection[key].end_dly,
                    pan = noteSelection[key].pan,
                    len = v.len,
                    noteoff = noteSelection[key].noteoff,
                    column = column,
                    ghst = noteSelection[key].ghst
                }
                note_data.noteoff = addNoteToPattern(
                        note_data.column,
                        note_data.line,
                        note_data.len,
                        note_data.note,
                        note_data.vel,
                        note_data.end_vel,
                        note_data.pan,
                        note_data.dly,
                        note_data.end_dly,
                        note_data.ghst
                )
                table.insert(newSelection, note_data)
            end
        else
            table.insert(newSelection, noteSelection[key])
        end
    end
    noteSelection = newSelection
    refreshPianoRollNeeded = true
    return true
end

--duplicate content
local function duplicateSelectedNotes(noOffset)
    local offset
    local column
    --first notes first
    table.sort(noteSelection, function(a, b)
        return a.line < b.line
    end)
    offset = noteSelection[1].line
    --last notes first
    table.sort(noteSelection, function(a, b)
        return a.line > b.line
    end)
    --get offset
    offset = (noteSelection[1].line + noteSelection[1].len) - offset
    --disable edit mode and following to prevent side effects
    song.transport.edit_mode = false
    song.transport.follow_player = false
    --
    --remove offset to duplicate on same pos
    if noOffset then
        offset = 0
        setUndoDescription("Duplicate notes ...")
    else
        setUndoDescription("Duplicate notes to right ...")
    end
    --go through selection
    for key = 1, #noteSelection do
        --search for valid column
        column = returnColumnWhenEnoughSpaceForNote(
                noteSelection[key].line + offset,
                noteSelection[key].len,
                noteSelection[key].dly,
                noteSelection[key].end_dly
        )
        if column then
            noteSelection[key].column = column
            noteSelection[key].line = noteSelection[key].line + offset
            noteSelection[key].step = noteSelection[key].step + offset
        else
            showStatus("Not enough space to duplicate notes here.")
            return false
        end
        noteSelection[key].noteoff = addNoteToPattern(
                noteSelection[key].column,
                noteSelection[key].line,
                noteSelection[key].len,
                noteSelection[key].note,
                noteSelection[key].vel,
                noteSelection[key].end_vel,
                noteSelection[key].pan,
                noteSelection[key].dly,
                noteSelection[key].end_dly,
                noteSelection[key].ghst
        )
    end
    refreshPianoRollNeeded = true
    return true
end

--change note length by micro steps
local function changeSizeSelectedNotesByMicroSteps(microsteps)
    local column
    local state = true
    local len
    local delay

    --no scaling necessary?
    if math.floor(microsteps) == 0 then
        return false
    end

    --disable edit mode and following to prevent side effects
    song.transport.edit_mode = false
    song.transport.follow_player = false
    --
    setUndoDescription("Change note lengths ...")
    --go through selection
    for key = 1, #noteSelection do
        --remove note
        removeNoteInPattern(noteSelection[key].column, noteSelection[key].line, noteSelection[key].len)
        --calculate step and delay difference
        delay = (noteSelection[key].end_dly + microsteps) % 0x100
        len = math.floor((noteSelection[key].end_dly + microsteps) / 0x100)
        --prepare len difference for new delay values
        if noteSelection[key].len + len < 1 then
            len = 0
            delay = 0
        end
        --search for column
        column = returnColumnWhenEnoughSpaceForNote(
                noteSelection[key].line,
                noteSelection[key].len + len,
                noteSelection[key].dly,
                delay
        )
        if column then
            if noteSelection[key].len == 1 and noteSelection[key].len + len > 1 then
                if toRenoiseHex(noteSelection[key].vel):sub(1, 1) == "C" then
                    noteSelection[key].end_vel = noteSelection[key].vel
                    noteSelection[key].vel = 255
                end
            end
            noteSelection[key].step = noteSelection[key].step
            noteSelection[key].line = noteSelection[key].line
            noteSelection[key].len = noteSelection[key].len + len
            noteSelection[key].dly = noteSelection[key].dly
            noteSelection[key].end_dly = delay
            noteSelection[key].column = column
        end
        noteSelection[key].noteoff = addNoteToPattern(
                noteSelection[key].column,
                noteSelection[key].line,
                noteSelection[key].len,
                noteSelection[key].note,
                noteSelection[key].vel,
                noteSelection[key].end_vel,
                noteSelection[key].pan,
                noteSelection[key].dly,
                noteSelection[key].end_dly,
                noteSelection[key].ghst
        )
        if not column then
            state = false
            break
        end
    end
    if #noteSelection == 1 and preferences.setVelPanDlyLenFromLastNote.value then
        currentNoteLength = noteSelection[1].len
        refreshControls = true
    end
    return state
end

--change note size
local function changeSizeSelectedNotes(len, add)
    local ret = true
    local column
    local newLen = len
    --first notes first
    table.sort(noteSelection, function(a, b)
        return a.line < b.line
    end)
    --disable edit mode and following to prevent side effects
    song.transport.edit_mode = false
    song.transport.follow_player = false
    --
    setUndoDescription("Change note lengths ...")
    --go through selection
    for key = 1, #noteSelection do
        --remove note
        removeNoteInPattern(noteSelection[key].column, noteSelection[key].line, noteSelection[key].len)
        --add mode
        if add then
            newLen = math.max(noteSelection[key].len + len, 1)
        end
        --search for valid column
        column = returnColumnWhenEnoughSpaceForNote(noteSelection[key].line, newLen, noteSelection[key].dly, noteSelection[key].end_dly)
        if column then
            if noteSelection[key].len == 1 and newLen > 1 then
                if toRenoiseHex(noteSelection[key].vel):sub(1, 1) == "C" then
                    noteSelection[key].end_vel = noteSelection[key].vel
                    noteSelection[key].vel = 255
                end
            end
            noteSelection[key].len = newLen
            noteSelection[key].column = column
        else
            ret = false
        end
        noteSelection[key].noteoff = addNoteToPattern(
                noteSelection[key].column,
                noteSelection[key].line,
                noteSelection[key].len,
                noteSelection[key].note,
                noteSelection[key].vel,
                noteSelection[key].end_vel,
                noteSelection[key].pan,
                noteSelection[key].dly,
                noteSelection[key].end_dly,
                noteSelection[key].ghst
        )
    end
    --set current scale length as new current length
    if #noteSelection == 1 and preferences.setVelPanDlyLenFromLastNote.value then
        currentNoteLength = newLen
        refreshControls = true
    end
    return ret
end

--change note properties
local function changePropertiesOfSelectedNotes(vel, end_vel, dly, end_dly, pan, special)
    local lineValues = song.selected_pattern_track.lines
    --randomize seed for humanizing
    math.randomseed(os.clock() * 100000000000)
    --describe for undo
    if tostring(vel) == "mute" then
        setUndoDescription("Mute selected notes ...")
    elseif tostring(vel) == "unmute" then
        setUndoDescription("Unmute selected notes ...")
    elseif tostring(special) == "matchingnotes" then
        setUndoDescription("Matching selected notes ...")
    elseif tostring(special) == "ghost" then
        setUndoDescription("Turn selected notes to ghost notes ...")
    elseif tostring(special) == "noghost" then
        setUndoDescription("Turn selected notes to normal notes ...")
    else
        setUndoDescription("Change note properties ...")
    end
    --disable edit mode and following to prevent side effects
    song.transport.edit_mode = false
    song.transport.follow_player = false
    --go through selection
    local selection
    local note
    local note_end
    local noteoff
    for key = 1, #noteSelection do
        selection = noteSelection[key]
        note = lineValues[selection.line]:note_column(selection.column)
        note_end = lineValues[selection.line + selection.len - 1]:note_column(selection.column)
        if selection.noteoff then
            noteoff = lineValues[selection.line + selection.len]:note_column(selection.column)
        else
            noteoff = nil
        end
        if tostring(special) == "removecut" then
            if selection.vel >= fromRenoiseHex("C0") and selection.vel <= fromRenoiseHex("CF") then
                vel = 255
            end
            if selection.end_vel >= fromRenoiseHex("C0") and selection.end_vel <= fromRenoiseHex("CF") then
                end_vel = 255
            end
            if selection.pan >= fromRenoiseHex("C0") and selection.pan <= fromRenoiseHex("CF") then
                pan = 255
            end
        end
        if vel ~= nil then
            if tostring(vel) == "h" then
                if note.volume_value <= 127 then
                    note.volume_value = randomizeValue(note.volume_value, 2, 1, 127)
                    selection.vel = note.volume_value
                end
            elseif tostring(vel) == "mute" then
                note.volume_value = 0
                selection.vel = note.volume_value
            elseif tostring(vel) == "unmute" then
                note.volume_value = 255
                selection.vel = note.volume_value
            else
                if tostring(special) == "add" then
                    if selection.vel == 255 and vel < 0 then
                        selection.vel = forceValueToRange(128 + vel, 0, 127)
                        note.volume_string = toRenoiseHex(selection.vel)
                    elseif selection.vel >= 0 and selection.vel <= 127 then
                        selection.vel = forceValueToRange(selection.vel + vel, 0, 127)
                        note.volume_string = toRenoiseHex(selection.vel)
                    end
                else
                    note.volume_string = toRenoiseHex(vel)
                    selection.vel = vel
                    if selection.len == 1 then
                        selection.end_vel = vel
                    end
                end
            end
        end
        if end_vel ~= nil then
            selection.end_vel = end_vel
            if selection.len > 1 then
                note_end.volume_string = toRenoiseHex(selection.end_vel)
            else
                note.volume_string = toRenoiseHex(selection.end_vel)
                selection.vel = end_vel
            end
        end
        if pan ~= nil then
            if tostring(pan) == "h" then
                if note.panning_value <= 127 then
                    note.panning_value = randomizeValue(note.panning_value, 2, 1, 127)
                    selection.pan = note.panning_value
                end
            else
                note.panning_string = toRenoiseHex(pan)
                selection.pan = pan
            end
        end
        if dly ~= nil then
            if tostring(dly) == "h" then
                if note.delay_value <= 127 then
                    dly = randomizeValue(note.delay_value, 2, 0, 127)
                    selection.dly = note.delay_value
                else
                    dly = nil
                end
            end
            if dly then
                --when a note get a delay value, check if an off is before or no notes, otherwise
                --search for a new column, because the note before will not be played correctly (bleeding over),
                --when "hidden" note off is not triggered in correct time
                if selection.dly == 0 and dly > 0 and selection.line > 1 then
                    local newColumnNeeded = false
                    for i = selection.line, 1, -1 do
                        if lineValues[i]:note_column(selection.column).note_value < 120 then
                            newColumnNeeded = true
                            break
                        elseif lineValues[i]:note_column(selection.column).note_value == 120 then
                            break
                        end
                    end
                    --when new column is needed move the note
                    if newColumnNeeded then
                        --remove note
                        removeNoteInPattern(selection.column, selection.line, selection.len)
                        --search for valid column
                        local column = returnColumnWhenEnoughSpaceForNote(selection.line, selection.len, dly, selection.end_dly)
                        if column then
                            selection.line = selection.line
                            selection.column = column
                        end
                        selection.noteoff = addNoteToPattern(
                                selection.column,
                                selection.line,
                                selection.len,
                                selection.note,
                                selection.vel,
                                selection.end_vel,
                                selection.pan,
                                selection.dly,
                                selection.end_dly,
                                selection.ghst
                        )
                        --refresh note var
                        note = lineValues[selection.line]:note_column(selection.column)
                    end
                end
                note.delay_string = toRenoiseHex(dly)
                selection.dly = dly
            end
        end
        if end_dly ~= nil then
            if selection.end_dly == 0 and end_dly > 0 and not selection.noteoff then
                --remove note
                removeNoteInPattern(selection.column, selection.line, selection.len)
                --search for valid column
                local column = returnColumnWhenEnoughSpaceForNote(selection.line, selection.len, selection.end_dly, end_dly)
                if column then
                    selection.line = selection.line
                    selection.column = column
                end
                selection.noteoff = addNoteToPattern(
                        selection.column,
                        selection.line,
                        selection.len,
                        selection.note,
                        selection.vel,
                        selection.end_vel,
                        selection.pan,
                        selection.dly,
                        selection.end_dly,
                        selection.ghst
                )
                --refresh note var
                note = lineValues[selection.line]:note_column(selection.column)
                if selection.noteoff then
                    noteoff = lineValues[selection.line + selection.len]:note_column(selection.column)
                else
                    noteoff = nil
                end
            end
            if noteoff then
                noteoff.delay_string = toRenoiseHex(end_dly)
                selection.end_dly = end_dly
            end
        end
        if special == "matchingnotes" then
            note.note_value = noteSelection[1].note
            noteSelection[key].note = note.note_value
        elseif special == "ghost" then
            note.instrument_value = 255
        elseif special == "noghost" then
            --when no instrument is set, use the current selected one
            if not currentInstrument then
                currentInstrument = song.selected_instrument_index
            end
            note.instrument_value = currentInstrument - 1
        end
    end
    if tostring(special) ~= "quick" and tostring(special) ~= "removecut" then
        refreshPianoRollNeeded = true
    end
    return true
end

--convert the note value to a grid y position
local function noteValue2GridRowOffset(noteValue, allowOutside)
    noteValue = noteValue + (-noteOffset) + 1
    if (noteValue >= 1 and noteValue <= gridHeight) or allowOutside then
        return noteValue
    end
    return nil
end

--convert grid y value to note value
local function gridOffset2NoteValue(y)
    return y + noteOffset - 1
end

--color keyboard key
local function setKeyboardKeyColor(row, pressed, highlighted)
    local idx = "k" .. row
    if notesPlaying[gridOffset2NoteValue(row)] then
        vbw[idx].color = colorStepOn
    elseif highlighted then
        if preferences.useTrackColorForNoteHighlighting.value then
            vbw[idx].color = vbw["trackcolor"].color
        else
            vbw[idx].color = colorNoteHighlight
        end
    elseif not pressed then
        vbw[idx].color = defaultColor[idx]
    else
        vbw[idx].color = colorStepOn
    end
end

--highlight entire row
local function highlightNoteRow(row, highlighted)
    if preferences.highlightEntireLineOfPlayingNote.value then
        for l = 1, math.min(song.selected_pattern.number_of_lines, gridWidth) do
            local idx = "p" .. l .. "_" .. row
            if highlighted then
                vbw[idx].color = shadeColor(defaultColor[idx], -preferences.rowHighlightingAmount.value)
            else
                vbw[idx].color = defaultColor[idx]
            end
        end
    end
end

--step sequencing like in other daws
local function stepSequencing(pos, steps)
    local refresh = false
    local column
    local newLen
    local notedata
    --search for notes on negative steps
    for note in pairs(notesPlaying) do
        --search for a note
        if steps < 0 and not notesPlayingLine[note] then
            for key in pairs(noteData) do
                notedata = noteData[key]
                if note == notedata.note and
                        ((notedata.line <= pos and notedata.line + notedata.len >= pos))
                then
                    notesPlayingLine[note] = notedata.line
                    break
                end
            end
        end
        --no note found? create one
        if not notesPlayingLine[note] and steps > 0 then
            notedata = {
                column = 0,
                line = pos,
                len = 1,
                note = note,
                vel = currentNoteVelocity,
                end_vel = 0,
                pan = 0,
                dly = 0,
                end_dly = 0,
                ghst = currentNoteGhost
            }
            column = returnColumnWhenEnoughSpaceForNote(notedata.line, notedata.len, notedata.dly, notedata.end_dly)
            if column then
                notedata.column = column
                notedata.noteoff = addNoteToPattern(
                        notedata.column,
                        notedata.line,
                        notedata.len,
                        notedata.note,
                        notedata.vel,
                        notedata.end_vel,
                        notedata.pan,
                        notedata.dly,
                        notedata.end_dly,
                        notedata.ghst
                )
                notesPlayingLine[note] = notedata.line
                refresh = true
            end
        elseif notesPlayingLine[note] then
            for key in pairs(noteData) do
                notedata = noteData[key]
                if note == notedata.note and notesPlayingLine[note] == notedata.line then
                    newLen = pos - notedata.line + steps
                    removeNoteInPattern(notedata.column, notedata.line, notedata.len)
                    if newLen > 0 then
                        --if note hits end of pattern, remove note from notesPlaying table
                        if steps<0 and notedata.line + notedata.len - 1 == 64 then
                            notesPlayingLine[note] = nil
                        end
                        column = returnColumnWhenEnoughSpaceForNote(notedata.line, newLen, notedata.dly, notedata.end_dly)
                        if column then
                            notedata.len = newLen
                            notedata.column = column
                        end
                        notedata.noteoff = addNoteToPattern(
                                notedata.column,
                                notedata.line,
                                notedata.len,
                                notedata.note,
                                notedata.vel,
                                notedata.end_vel,
                                notedata.pan,
                                notedata.dly,
                                notedata.end_dly,
                                notedata.ghst
                        )
                    else
                        notesPlayingLine[note] = nil
                    end
                    refresh = true
                end
            end
        end
    end
    if refresh then
        setUndoDescription("Step sequencing notes ...")
        refreshPianoRollNeeded = true
    end
    return refresh
end

--move the current seleciton to the next desired note
local function moveSelectionThroughNotes(dx, dy, addToSelection)
    local note_data
    local distance = 99999
    local x1
    local y1
    local x2
    local y2
    local newDistance

    if #noteSelection > 0 then
        --select one of the note when shift is not holded
        if #noteSelection > 1 and not (keyShift or keyRShift) then
            note_data = noteSelection[#noteSelection]
            noteSelection = {}
            table.insert(noteSelection, note_data)
            jumpToNoteInPattern(note_data)
            refreshPianoRollNeeded = true
            return true
        else
            x1 = noteSelection[1].step + (noteSelection[1].len - 1) / 2
            y1 = noteSelection[1].note
            --calc center of selection
            for i = 2, #noteSelection do
                x1 = (x1 + noteSelection[i].step + (noteSelection[i].len - 1) / 2) / 2
                y1 = (y1 + noteSelection[i].note) / 2
            end
        end
    else
        x1 = song.transport.edit_pos.line
        if dy < 0 then
            y1 = 120
        else
            y1 = 0
        end
    end

    x1 = math.floor(x1 + clamp(dx, -1, 1))
    y1 = math.floor(y1 + clamp(dy, -1, 1))

    for key in pairs(noteData) do
        if not noteInSelection(noteData[key]) then
            x2 = noteData[key].step
            y2 = noteData[key].note
            if dy ~= 0 then
                x2 = x2 + (noteData[key].len - 1) / 2
            elseif dx < 0 then
                x2 = x2 + (noteData[key].len - 1)
            end
            if
            (dx < 0 and x2 <= x1) or
                    (dx > 0 and x1 <= x2) or
                    (dy < 0 and y2 <= y1) or
                    (dy > 0 and y1 <= y2)
            then
                newDistance = calcDistance(x1, y1, x2, y2)
                if newDistance < distance then
                    note_data = noteData[key]
                    distance = newDistance
                end
            end
        end
    end

    if note_data then
        if not addToSelection then
            noteSelection = {}
        end
        table.insert(noteSelection, note_data)
        jumpToNoteInPattern(note_data)
        refreshPianoRollNeeded = true
        return true
    end
    return false
end

--draw selection rectangle
local function drawRectangle(show, x, y, x2, y2)
    if not show then
        vbw["sel"].visible = false
    else
        local rx = math.min(x, x2)
        local rx2 = math.min(math.max(x, x2), gridWidth)
        local ry = math.min(y, y2)
        local ry2 = math.min(math.max(y, y2), gridHeight)
        local addW
        if rx ~= rx2 or ry ~= ry2 then
            if (gridHeight - ry2) * gridStepSizeH > 0 then
                vbw["seltopspace"].height = (gridHeight - ry2) * (gridStepSizeH - 3)
                vbw["seltopspace1"].height = vbw["seltopspace"].height
                vbw["seltopspace2"].height = vbw["seltopspace"].height
                vbw["seltopspace"].visible = true
                vbw["seltopspace1"].visible = true
                vbw["seltopspace2"].visible = true
            else
                vbw["seltopspace"].visible = false
                vbw["seltopspace1"].visible = false
                vbw["seltopspace2"].visible = false
            end
            if rx > 1 then
                vbw["selleftspace"].width = (rx - 1) * (gridStepSizeW - 4)
                addW = 2
            else
                vbw["selleftspace"].width = 2
                addW = 0
            end
            vbw["seltop"].width = gridStepSizeW + ((rx2 - rx) * (gridStepSizeW - 4)) - 5 + addW
            vbw["seltop"].color = colorStepOn
            vbw["selbottom"].width = vbw["seltop"].width
            vbw["selbottom"].color = colorStepOn
            vbw["selheightspace"].height = math.max(1, (ry2 - ry) * (gridStepSizeH - 3)) + 9
            vbw["selleft"].height = vbw["selheightspace"].height + 10
            vbw["selleft"].color = colorStepOn
            vbw["selright"].height = vbw["selheightspace"].height + 10
            vbw["selright"].color = colorStepOn
            vbw["sel"].visible = true
        else
            vbw["sel"].visible = false
        end
    end
end

--add notes from a rectangle to the selection
local function selectRectangle(x, y, x2, y2, addToSelection)
    local smin = math.min(x, x2)
    local smax = math.max(x, x2)
    local nmin = gridOffset2NoteValue(math.min(y, y2))
    local nmax = gridOffset2NoteValue(math.max(y, y2))
    local note_data
    local refreshNeeded = false
    local wasInSelection = {}
    if not addToSelection and #noteSelection > 0 then
        for i = 1, #noteSelection do
            wasInSelection[noteSelection[i].idx] = 1
        end
        noteSelection = {}
        refreshNeeded = true
    end
    --loop through all notes
    for key in pairs(noteData) do
        note_data = noteData[key]
        if nmin <= note_data.note and
                nmax >= note_data.note and
                (
                        (smin >= note_data.step and smin <= note_data.step + note_data.len - 1) or
                                (smax >= note_data.step and smax <= note_data.step + note_data.len - 1) or
                                (note_data.step >= smin and note_data.step + note_data.len - 1 <= smax)
                ) and
                not noteInSelection(note_data)
        then
            --add to selection table
            table.insert(noteSelection, note_data)
            wasInSelection[note_data.idx] = nil
            if vbw["b" .. note_data.idx] then
                vbw["b" .. note_data.idx].color = colorNoteVelocity(note_data.vel, note_data.ghst, nil, true)
                vbw["bs" .. note_data.idx].color = shadeColor(vbw["b" .. note_data.idx].color, preferences.scaleBtnShadingAmount.value)
            end
            --refresh of piano roll needed
            refreshNeeded = true
        end
    end
    --piano refresh only when something was found
    if refreshNeeded then
        --reset note colors
        for key in pairs(wasInSelection) do
            note_data = noteData[key]
            if note_data and vbw["b" .. note_data.idx] then
                vbw["b" .. note_data.idx].color = colorNoteVelocity(note_data.vel, note_data.ghst)
                vbw["bs" .. note_data.idx].color = shadeColor(vbw["b" .. note_data.idx].color, preferences.scaleBtnShadingAmount.value)
            end
        end
        jumpToNoteInPattern("sel")
    end
    return refreshNeeded
end

--keyboard preview
function keyClick(y, pressed)
    local note = gridOffset2NoteValue(y)
    --disable edit mode
    song.transport.edit_mode = false
    --select all note events which have the specific note
    if keyControl then
        if not keyShift then
            noteSelection = {}
        end
        for key in pairs(noteData) do
            local note_data = noteData[key]
            if note_data.note == note and noteInSelection(note_data) == nil then
                table.insert(noteSelection, note_data)
            end
        end
        jumpToNoteInPattern("sel")
        refreshPianoRollNeeded = true
    else
        local row = noteValue2GridRowOffset(note)
        if row ~= nil then
            highlightNoteRow(row, pressed)
        end
        triggerNoteOfCurrentInstrument(note, pressed)
    end
end

--will be called, when a note was clicked
function noteClick(x, y, c, released, forceScaling)
    local index = tostring(x) .. "_" .. tostring(y) .. "_" .. tostring(c)
    local note_data = noteData[index]
    local row = noteValue2GridRowOffset(note_data.note)

    --mouse drag support, very very hacky
    if not released and not checkMode("preview") then
        --disable grid buttons, so these doesn't receive click events
        for i = 1, gridWidth do
            vbw["p" .. i .. "_" .. y].active = false
        end
        --disable all notes on step, so other notes doesn't receive click events
        for j = 1, note_data.len do
            local ns = noteOnStep[x + (j - 1)]
            if ns ~= nil and #ns > 0 then
                for i = 1, #ns do
                    if ns[i] ~= nil and ns[i].note == note_data.note and ns[i].index ~= index then
                        vbw["b" .. ns[i].index].active = false
                    end
                end
            end
        end
        --remove and add the clicked button, disable underlaying buttons, so the xypad in the background
        --can receive the click event, remove/add trick from joule:
        --https://forum.renoise.com/t/custom-sliders-demo-including-the-panning-slider/48921/6
        if forceScaling then
            vbw["bbbs" .. index]:remove_child(vbw["bs" .. index])
            vbw["bbbs" .. index]:add_child(vbw["bs" .. index])
            vbw["b" .. index].active = false
        else
            vbw["bbb" .. index]:remove_child(vbw["b" .. index])
            vbw["bbb" .. index]:add_child(vbw["b" .. index])
        end
        xypadpos.selection_key = noteInSelection(note_data)
        xypadpos.idx = note_data.idx
        xypadpos.nx = x
        xypadpos.ny = y
        xypadpos.nlen = note_data.len
        if forceScaling then
            xypadpos.scalemode = true
            xypadpos.scaling = true
        else
            xypadpos.scalemode = false
            xypadpos.scaling = false
        end
        xypadpos.resetscale = false
        xypadpos.notemode = true
        xypadpos.lastval = nil
        xypadpos.duplicate = (keyShift or keyControl) and not checkMode("pen") and not keyAlt
        xypadpos.time = os.clock()
        triggerNoteOfCurrentInstrument(note_data.note, nil, note_data.vel, true)
        refreshPianoRollNeeded = true
        return
    end

    if checkMode("preview") then
        triggerNoteOfCurrentInstrument(note_data.note, not released, note_data.vel)
        if row ~= nil then
            setKeyboardKeyColor(row, not released, false)
            highlightNoteRow(row, not released)
        end
    end

    if released then
        local dbclk = dbclkDetector("b" .. index)
        --always set note date for the next new note
        if note_data ~= nil then
            if preferences.setVelPanDlyLenFromLastNote.value then
                currentNoteGhost = note_data.ghst
                currentNoteLength = note_data.len
                currentNoteVelocity = note_data.vel
                if currentNoteVelocity > 0 and currentNoteVelocity < 128 then
                    currentNoteVelocityPreview = currentNoteVelocity
                else
                    currentNoteVelocityPreview = 127
                end
                if note_data.len > 1 then
                    currentNoteEndVelocity = note_data.end_vel
                else
                    if toRenoiseHex(note_data.vel):sub(1, 1) == "C" then
                        currentNoteVelocity = 255
                        currentNoteEndVelocity = note_data.vel
                    else
                        currentNoteEndVelocity = 255
                    end
                end
                currentNotePan = note_data.pan
                currentNoteDelay = note_data.dly
                currentNoteEndDelay = note_data.end_dly
                refreshControls = true
            end
            --always jump to the note
            jumpToNoteInPattern(note_data)
        end
        --remove on dblclk or when in penmode or previewmode
        if checkMode("pen") or (dbclk and not checkMode("preview")) then
            --set clicked note as selected for remove function
            if note_data ~= nil then
                if preferences.disableAltClickNoteRemove.value and keyAlt then
                    --dont delete notes, when use altKey in non pen mode
                    if not noteInSelection(note_data) then
                        noteSelection = {}
                        table.insert(noteSelection, note_data)
                        jumpToNoteInPattern("sel")
                    end
                    refreshPianoRollNeeded = true
                else
                    noteSelection = {}
                    table.insert(noteSelection, note_data)
                    jumpToNoteInPattern("sel")
                    removeSelectedNotes()
                end
            end
        else
            if note_data ~= nil then
                if not checkMode("preview") then
                    local deselect = false
                    --clear selection, when ctrl is not holded
                    if #noteSelection > 0 and keyControl and not forceScaling then
                        --check if the note is in selection, then just deselect
                        for i = 1, #noteSelection do
                            if noteSelection[i].line == note_data.line
                                    and noteSelection[i].len == note_data.len
                                    and noteSelection[i].column == note_data.column then
                                deselect = true
                                table.remove(noteSelection, i)
                                jumpToNoteInPattern("sel")
                                break
                            end
                        end
                    else
                        if #noteSelection > 0 then
                            for i = 1, #noteSelection do
                                if noteSelection[i].line == note_data.line
                                        and noteSelection[i].len == note_data.len
                                        and noteSelection[i].column == note_data.column then
                                    return
                                end
                            end
                        end
                        noteSelection = {}
                    end
                    --when note was not deselected, then add this note to selection
                    if not deselect and not noteInSelection(note_data) then
                        table.insert(noteSelection, note_data)
                        jumpToNoteInPattern("sel")
                    end
                    refreshPianoRollNeeded = true
                end
            end
        end
    end
end

--will be called, when an empty grid button was clicked
function pianoGridClick(x, y, released)
    local index = tostring(x) .. "_" .. tostring(y)
    local outside = false

    --just allow selection, deselect notes, when pos is outside the grid
    if x + stepOffset > song.selected_pattern.number_of_lines then
        outside = true
    end

    if not released and not checkMode("preview") and not keyControl and not (outside and checkMode("pen")) then
        --deselect current notes, when outside was clicked
        if outside and #noteSelection > 0 then
            noteSelection = {}
            refreshPianoRollNeeded = true
        end
        --remove and add the clicked button, disable all buttons in the row, so the xypad in the background can
        --receive the click event remove/add trick from joule:
        --https://forum.renoise.com/t/custom-sliders-demo-including-the-panning-slider/48921/6
        for i = 1, gridWidth do
            vbw["p" .. i .. "_" .. y].active = false
            --prevent accidentally note drawing "twins", when piano grid buttons overlap
            if vbw["p" .. i .. "_" .. y + 1] then
                vbw["p" .. i .. "_" .. y + 1].active = false
            end
        end
        vbw["ppp" .. index]:remove_child(vbw["p" .. index])
        vbw["ppp" .. index]:add_child(vbw["p" .. index])
        if checkMode("pen") then
            xypadpos.nx = x
            xypadpos.ny = y
            xypadpos.scalemode = true
            xypadpos.resetscale = true
            xypadpos.notemode = true
            xypadpos.time = os.clock()
        else
            xypadpos.nx = x
            xypadpos.ny = y
            xypadpos.notemode = false
            xypadpos.leftClick = true
        end
        --disabled button need to be enabled again outside this call when just one click was triggered,
        --use idle function
        refreshPianoRollNeeded = true
        return
    end

    --dont do anything, when position is outside pattern
    if outside then
        return
    end

    if checkMode("preview") or (stepPreview and released) then
        local line = x + stepOffset
        stepPreview = not released
        for key in pairs(noteData) do
            local note_data = noteData[key]
            if line >= note_data.line and line < note_data.line + note_data.len then
                triggerNoteOfCurrentInstrument(note_data.note, not released, note_data.vel)
                local row = noteValue2GridRowOffset(note_data.note)
                if row ~= nil then
                    setKeyboardKeyColor(row, not released, false)
                    highlightNoteRow(row, not released)
                end
            end
        end
        return
    end
    if released then
        local dbclk = dbclkDetector("p" .. index)
        --set paste cursor
        pasteCursor = { x + stepOffset, gridOffset2NoteValue(y) }

        if dbclk or checkMode("pen") then
            local steps = song.selected_pattern.number_of_lines
            local column
            local note_value
            local noteoff
            --move x by stepoffset
            x = x + stepOffset
            --check if current note length is too long for pattern size, reduce len if needed
            if x + currentNoteLength > steps then
                currentNoteLength = steps - x + 1
                refreshControls = true
            end
            --disable edit mode because of side effects
            song.transport.edit_mode = false
            --when currentNoteDelay or currentNoteEndDelay is used, recalculate them
            if currentNoteDelay > 0 and currentNoteEndDelay == 0 then
                currentNoteEndDelay = 0x100 - currentNoteDelay
                currentNoteLength = currentNoteLength - 1
                currentNoteDelay = 0
            elseif currentNoteDelay > 0 and currentNoteEndDelay > 0 then
                currentNoteEndDelay = currentNoteEndDelay - currentNoteDelay
                currentNoteDelay = 0
                if currentNoteEndDelay < 0 then
                    currentNoteEndDelay = 0x100 + currentNoteEndDelay
                    currentNoteLength = currentNoteLength - 1
                end
            end
            --fix, when note gets shorter than one
            if currentNoteLength < 1 then
                currentNoteLength = 1
                currentNoteEndDelay = 0
                currentNoteDelay = 0
            end
            column = returnColumnWhenEnoughSpaceForNote(x, currentNoteLength, currentNoteDelay, currentNoteEndDelay)
            --no column found
            if column == nil then
                --no space for this note
                return false
            end
            --
            setUndoDescription("Draw a note ...")
            --add new note
            note_value = gridOffset2NoteValue(y)
            noteoff = addNoteToPattern(
                    column,
                    x,
                    currentNoteLength,
                    note_value,
                    currentNoteVelocity,
                    currentNoteEndVelocity,
                    currentNotePan,
                    currentNoteDelay,
                    currentNoteEndDelay,
                    currentNoteGhost
            )
            --
            local note_data = {
                idx = tostring(x - stepOffset) .. "_" .. tostring(y) .. "_" .. tostring(column),
                line = x,
                step = x - stepOffset,
                note = note_value,
                vel = currentNoteVelocity,
                end_vel = currentNoteEndVelocity,
                dly = currentNoteDelay,
                end_dly = currentNoteEndDelay,
                pan = currentNotePan,
                len = currentNoteLength,
                noteoff = noteoff,
                column = column,
                ghst = currentNoteGhost
            }
            --trigger preview notes
            triggerNoteOfCurrentInstrument(note_data.note, nil, nil, true)
            --clear selection and add new note as new selection
            noteSelection = {}
            table.insert(noteSelection, note_data)
            jumpToNoteInPattern(note_data)
            --
            refreshPianoRollNeeded = true
            refreshChordDetection = true
        else
            --fast play from cursor
            if keyControl and not keyAlt and not keyShift then
                playPatternFromLine(x + stepOffset)
            else
                --deselect selected notes
                if #noteSelection > 0 then
                    if not keyShift then
                        noteSelection = {}
                        refreshChordDetection = true
                    end
                    refreshPianoRollNeeded = true
                elseif preferences.resetVolPanDlyControlOnClick.value then
                    --nothing selected reset vol, pan and dly
                    currentNoteVelocity = 255
                    currentNotePan = 255
                    currentNoteDelay = 0
                    currentNoteEndDelay = 0
                    currentNoteVelocityPreview = 127
                    currentNoteEndVelocity = 255
                    refreshControls = true
                end
            end
        end
    end
end

--enable a note button, when its visible, set correct length of the button
local function drawNoteToGrid(column,
                              current_note_line,
                              current_note_step,
                              current_note_rowIndex,
                              current_note,
                              current_note_len,
                              current_note_string,
                              current_note_vel,
                              current_note_end_vel,
                              current_note_pan,
                              current_note_dly,
                              current_note_end_dly,
                              noteoff,
                              ghost)
    local l_song = song
    local l_song_transport = l_song.transport
    local l_song_st = l_song.selected_track
    local l_vbw = vbw
    local isOnStep = false
    local isInSelection = false
    --save highest and lowest note
    if lowestNote == nil then
        lowestNote = current_note
    end
    if highestNote == nil then
        highestNote = current_note
    end
    lowestNote = math.min(lowestNote, current_note)
    highestNote = math.max(highestNote, current_note)
    if current_note_rowIndex ~= nil then
        local noteOnStepIndex = current_note_step
        local current_note_index = tostring(current_note_step) .. "_" .. tostring(current_note_rowIndex) .. "_" .. tostring(column)
        local current_note_param = "noteClick(" .. string.gsub(current_note_index, "_", ",")
        if current_note_vel == nil then
            current_note_vel = 255
        end
        if current_note_end_vel == nil then
            current_note_end_vel = 255
        end
        if current_note_pan == nil then
            current_note_pan = 255
        end
        if current_note_dly == nil then
            current_note_dly = 0
        end
        if current_note_end_dly == nil then
            current_note_end_dly = 0
        end
        noteData[current_note_index] = {
            idx = current_note_index,
            line = current_note_line,
            step = current_note_step,
            note = current_note,
            vel = current_note_vel,
            end_vel = current_note_end_vel,
            dly = current_note_dly,
            end_dly = current_note_end_dly,
            pan = current_note_pan,
            len = current_note_len,
            noteoff = noteoff,
            column = column,
            ghst = ghost
        }
        --check if note is in selection and refresh noteData
        if #noteSelection then
            local key = noteInSelection(noteData[current_note_index])
            if key then
                noteSelection[key] = noteData[current_note_index]
                isInSelection = true
            end
        end

        --fill noteOnStep not just note start, also the full length
        if noteOnStepIndex then
            local len = current_note_len - 1
            --when cut value is set, then change note length to 1
            if (l_song_st.volume_column_visible and current_note_vel >= 192 and current_note_vel <= 207) or
                    (l_song_st.panning_column_visible and current_note_pan >= 192 and current_note_pan <= 207)
            then
                len = 0
            end
            for i = 0, len do
                --only when velocity is not 0 (muted)
                if current_note_vel > 0 then
                    if noteOnStep[noteOnStepIndex + i] == nil then
                        noteOnStep[noteOnStepIndex + i] = {}
                    end
                    table.insert(noteOnStep[noteOnStepIndex + i], {
                        index = current_note_index,
                        step = current_note_step,
                        row = current_note_rowIndex,
                        note = current_note,
                        len = current_note_len - i,
                        vel = current_note_vel,
                        ghst = ghost
                    })
                    if l_song_transport.playing
                            and l_song_transport.playback_pos.line - stepOffset == noteOnStepIndex + i
                            and l_song.selected_pattern_index == l_song.sequencer:pattern(l_song_transport.playback_pos.sequence) then
                        isOnStep = true
                    end
                end
            end
        end

        --only process notes on steps and visibility, when there is a valid row
        if l_vbw["row" .. current_note_rowIndex] then
            --change note display len
            if current_note_step < 1 then
                current_note_len = current_note_len + (current_note_step - 1)
            end
            if current_note_step > gridWidth then
                current_note_len = 0
            elseif current_note_step + current_note_len > gridWidth and current_note_step <= gridWidth then
                current_note_len = current_note_len - (current_note_step + current_note_len - gridWidth - 1)
            end
            if current_note_len > gridWidth then
                current_note_len = gridWidth
            end

            --display note button, note len is greater 0 and when the row is visible
            if current_note_len > 0 then
                local color
                local spaceWidth = 0
                local retriggerWidth = 0
                local delayWidth = 0
                local addWidth = 0
                local cutValue = 0

                if l_song_st.volume_column_visible and current_note_end_vel >= 192 and current_note_end_vel <= 207 then
                    cutValue = current_note_end_vel
                end

                if l_song_st.volume_column_visible then
                    if current_note_vel >= 192 and current_note_vel <= 207 then
                        current_note_len = 1
                        cutValue = current_note_vel
                        --wenn note is cut and outside, dont render it
                        if stepOffset >= current_note_line then
                            return
                        end
                    elseif current_note_vel >= 416 and current_note_vel <= 431 then
                        delayWidth = current_note_vel
                    elseif current_note_vel >= 432 and current_note_vel <= 447 then
                        retriggerWidth = current_note_vel
                    end
                end

                if l_song_st.panning_column_visible then
                    if current_note_pan >= 192 and current_note_pan <= 207 then
                        current_note_len = 1
                        cutValue = current_note_pan
                    elseif current_note_pan >= 416 and current_note_pan <= 431 then
                        delayWidth = current_note_pan
                    elseif current_note_pan >= 432 and current_note_pan <= 447 then
                        retriggerWidth = current_note_pan
                    end
                end

                local buttonWidth = (gridStepSizeW) * current_note_len
                local buttonSpace = gridSpacing * (current_note_len - 1)

                if delayWidth > 0 then
                    delayWidth = delayWidth - 416
                    if delayWidth < l_song_transport.tpl then
                        delayWidth = math.floor(0x100 / l_song_transport.tpl * delayWidth)
                    else
                        delayWidth = 0
                    end
                end

                if cutValue > 0 then
                    cutValue = cutValue - 192
                    if cutValue < l_song_transport.tpl then
                        buttonWidth = buttonWidth - ((gridStepSizeW - gridSpacing) / 100 * (100 / l_song_transport.tpl * (l_song_transport.tpl - cutValue)))
                    end
                end

                if isInSelection and #noteSelection == 1 and preferences.setVelPanDlyLenFromLastNote.value then
                    currentNotePan = current_note_pan
                    currentNoteVelocity = current_note_vel
                    currentNoteEndVelocity = current_note_end_vel
                    currentNoteDelay = current_note_dly
                    currentNoteEndDelay = current_note_end_dly
                    refreshControls = true
                end
                color = colorNoteVelocity(current_note_vel, ghost, isOnStep, isInSelection)

                local btn = vb:row {
                    margin = -gridMargin,
                    spacing = -gridSpacing,
                }

                if current_note_step > 1 then
                    spaceWidth = (gridStepSizeW * (current_note_step - 1)) - (gridSpacing * (current_note_step - 2))
                end

                if l_song_st.delay_column_visible then
                    if current_note_dly > 0 then
                        delayWidth = math.max(current_note_dly, delayWidth)
                    end
                    if current_note_end_dly > 0 then
                        addWidth = math.max(current_note_end_dly, addWidth)
                    end
                end

                if delayWidth > 0 and stepOffset < current_note_line then
                    delayWidth = math.max(math.floor((gridStepSizeW - gridSpacing) / 0x100 * delayWidth), 1)
                    spaceWidth = spaceWidth + delayWidth
                    buttonWidth = buttonWidth - delayWidth
                    if current_note_step < 2 then
                        spaceWidth = spaceWidth + gridSpacing
                    end
                end

                if addWidth > 0 and (current_note_step + current_note_len) - 1 < gridWidth then
                    addWidth = math.max(math.floor((gridStepSizeW - gridSpacing) / 0x100 * addWidth), 1)
                    buttonWidth = buttonWidth + addWidth
                end

                if spaceWidth > 0 then
                    btn:add_child(vb:space {
                        width = spaceWidth,
                    });
                end

                --recalc retrigger value, reset it to 0, when greater than tpl
                if retriggerWidth > 0 then
                    retriggerWidth = retriggerWidth - 432
                    if retriggerWidth >= l_song_transport.tpl then
                        retriggerWidth = 0
                    end
                end

                --no note labels when to short
                if buttonWidth - buttonSpace - 1 < 32 or (retriggerWidth > 0 and buttonWidth - buttonSpace - 1 < 52) then
                    if not string.find(current_note_string, '#') and buttonWidth - buttonSpace - 1 > 25 and retriggerWidth == 0 then
                        current_note_string = string.gsub(current_note_string, '-', '')
                    else
                        current_note_string = nil
                    end
                end

                l_vbw["b" .. current_note_index] = nil
                l_vbw["bbb" .. current_note_index] = nil
                btn:add_child(
                        vb:row {
                            id = "bbb" .. current_note_index,
                            vb:button {
                                id = "b" .. current_note_index,
                                height = gridStepSizeH,
                                width = math.max(buttonWidth - buttonSpace - 1, math.max(1, preferences.minSizeOfNoteButton.value + preferences.clickAreaSizeForScalingPx.value)),
                                visible = true,
                                color = color,
                                text = current_note_string,
                                notifier = loadstring(current_note_param .. ",true)"),
                                pressed = loadstring(current_note_param .. ",false)")
                            },
                        }
                );

                if not noteButtons[current_note_rowIndex] then
                    noteButtons[current_note_rowIndex] = {}
                end

                table.insert(noteButtons[current_note_rowIndex], btn);
                l_vbw["row" .. current_note_rowIndex]:add_child(btn)

                --size button
                local sizebutton = vb:row {
                    margin = -gridMargin,
                    spacing = -gridSpacing,
                }
                if spaceWidth > 0 then
                    sizebutton:add_child(vb:space {
                        width = spaceWidth,
                    })
                end
                l_vbw["bs" .. current_note_index] = nil
                l_vbw["bbbs" .. current_note_index] = nil
                sizebutton:add_child(vb:row {
                    spacing = -2,
                    vb:space {
                        width = l_vbw["b" .. current_note_index].width - (preferences.clickAreaSizeForScalingPx.value - 4),
                    },
                    vb:row {
                        id = "bbbs" .. current_note_index,
                        spacing = -3,
                        vb:space {
                            width = 1,
                        },
                        vb:button {
                            id = "bs" .. current_note_index,
                            height = gridStepSizeH,
                            width = preferences.clickAreaSizeForScalingPx.value,
                            visible = true,
                            color = shadeColor(color, preferences.scaleBtnShadingAmount.value),
                            notifier = loadstring(current_note_param .. ",true,true)"),
                            pressed = loadstring(current_note_param .. ",false,true)")
                        }
                    }
                });
                l_vbw["row" .. current_note_rowIndex]:add_child(sizebutton)
                table.insert(noteButtons[current_note_rowIndex], sizebutton);

                --display retrigger effect
                if retriggerWidth > 0 then
                    spaceWidth = math.max(spaceWidth, 4)
                    local rTpl = l_song_transport.tpl - 1
                    if cutValue > 0 and cutValue < l_song_transport.tpl and current_note_len == 1 then
                        rTpl = rTpl + (cutValue - 0xf)
                    end
                    local i = 1
                    for spc = retriggerWidth, rTpl, retriggerWidth do
                        l_vbw["br" .. current_note_index .. "_" .. i] = nil
                        local retrigger = vb:row {
                            id = "br" .. current_note_index .. "_" .. i,
                            margin = -gridMargin,
                            spacing = -gridSpacing,
                        }
                        retrigger:add_child(vb:space {
                            width = spaceWidth + (((gridStepSizeW - 3) / l_song_transport.tpl) * (spc + 1)),
                        });
                        retrigger:add_child(
                                vb:row {
                                    spacing = -2,
                                    vb:space {
                                        width = 1
                                    },
                                    vb:button {
                                        height = gridStepSizeH,
                                        width = 2,
                                        visible = true,
                                        active = false,
                                    }
                                }
                        );
                        table.insert(noteButtons[current_note_rowIndex], retrigger);
                        l_vbw["row" .. current_note_rowIndex]:add_child(retrigger)
                        i = i + 1
                    end
                end
            end
        end
    end
end

--refresh timeline
local function fillTimeline()
    local lpb = song.transport.lpb
    local steps = song.selected_pattern.number_of_lines
    local stepsCount = math.min(steps, gridWidth)
    --setup timeline
    local timestep = 0
    local lastbeat
    local timeslot
    local timeslotsize = 1
    for i = 1, stepsCount do
        local line = i + stepOffset
        local beat = math.ceil((line - lpb) / lpb) % 4 + 1
        local bar = calculateBarBeat(line, false, lpb)

        if lastbeat ~= beat then
            timestep = timestep + 1
            timeslot = vbw["timeline" .. timestep]
            timeslot.width = (gridStepSizeW - 4)
            if line % lpb == 1 then
                if lpb == 2 and beat % lpb == 0 then
                    timeslot.text = ""
                else
                    timeslot.text = "│"
                end
            else
                timeslot.text = ""
            end
            if beat == 1 then
                timeslot.style = "strong"
            else
                timeslot.style = "disabled"
            end
            timeslot.visible = true
            lastbeat = beat
            timeslotsize = 1
        else
            if line % lpb == 2 or (lpb == 2 and line % lpb == 0) then
                timeslot.text = "│ " .. bar .. "." .. beat
            end
            if lpb == 2 and beat % lpb == 0 then
                timeslot.text = ""
            end
            timeslotsize = timeslotsize + 1
            timeslot.width = (gridStepSizeW - 4) * timeslotsize
        end
    end
    while vbw["timeline" .. timestep + 1] do
        vbw["timeline" .. timestep + 1].visible = false
        timestep = timestep + 1
    end
    --set blockloop indicator, when enabled
    local hideblockloop = false
    if not song.transport.loop_block_enabled then
        hideblockloop = true
    else
        --calculate width and start pos for block loop line indicator
        local len = math.max(math.floor(song.selected_pattern.number_of_lines / song.transport.loop_block_range_coeff), 1)
        local pos = song.transport.loop_block_start_pos.line
        pos = pos - stepOffset
        if pos < 1 then
            len = len + (pos - 1)
            pos = 1
        end
        if len + pos - 1 > gridWidth then
            len = len + (gridWidth - len - pos + 1)
        end
        if len < 1 or pos > gridWidth then
            hideblockloop = true
        else
            vbw.blockloop.width = gridStepSizeW * len - (gridSpacing * (len - 1)) - 2
            vbw.blockloopspc.width = math.max(gridStepSizeW * (pos - 1) - (gridSpacing * (pos - 1)), 1)
            vbw.blockloop.visible = true
        end
    end
    --hide blockmode loop indicator
    if hideblockloop and vbw.blockloop.visible then
        vbw.blockloop.visible = false
        vbw.blockloopspc.width = 1
    end
    refreshTimeline = false
end

--render ghost track by simply change the color of piano grid buttons
local function ghostTrack(trackIndex)
    local track = song:track(trackIndex)
    local columns = track.visible_note_columns
    local steps = song.selected_pattern.number_of_lines
    local stepsCount = math.min(steps, gridWidth)
    local lineValues = song.selected_pattern:track(trackIndex).lines
    for c = 1, columns do
        local rowoffset

        if stepOffset > 0 then
            for i = stepOffset + 1, 1, -1 do
                local note_column = lineValues[i]:note_column(c)
                local note = note_column.note_value
                if note < 120 then
                    rowoffset = noteValue2GridRowOffset(note)
                    break
                elseif note == 120 then
                    break
                end
            end
        end

        for s = 1, stepsCount do
            local note_column = lineValues[s + stepOffset]:note_column(c)
            local note = note_column.note_value

            if note < 120 then
                rowoffset = noteValue2GridRowOffset(note)
            elseif note == 120 then
                rowoffset = nil
            end

            if rowoffset then
                local p = vbw["p" .. s .. "_" .. rowoffset]
                if p then
                    p.color = colorGhostTrackNote
                    defaultColor["p" .. s .. "_" .. rowoffset] = p.color
                end
            end
        end
    end
end

--set scale highlighting, none, manual modes, instrument scale, automatic mode
local function setScaleHighlighting(afterPianoRollRefresh)
    local ret = false
    if vbw["currentscale"].text == "" then
        currentScale = nil
        currentScaleOffset = nil
    end
    --simple scale highlighting
    if preferences.scaleHighlightingType.value == 1 and
            (currentScale ~= 1 or currentScaleOffset ~= 1) then
        currentScale = 1
        currentScaleOffset = 1
        ret = true
    elseif (preferences.scaleHighlightingType.value == 2 or preferences.scaleHighlightingType.value == 3) and
            (currentScale ~= preferences.scaleHighlightingType.value or currentScaleOffset ~= preferences.keyForSelectedScale.value)
    then
        currentScale = preferences.scaleHighlightingType.value
        currentScaleOffset = preferences.keyForSelectedScale.value
        ret = true
    elseif preferences.scaleHighlightingType.value == 4 then
        local idx = currentInstrument
        if not idx then
            idx = song.selected_instrument_index
        end
        local scale_key = song.instruments[idx].trigger_options.scale_key
        local scale_mode = song.instruments[idx].trigger_options.scale_mode

        if scale_mode == "Natural Major" then
            if currentScale ~= 2 or currentScaleOffset ~= scale_key then
                currentScale = 2
                currentScaleOffset = scale_key
                ret = true
            end
        elseif scale_mode == "Natural Minor" then
            if currentScale ~= 3 or currentScaleOffset ~= scale_key then
                currentScale = 3
                currentScaleOffset = scale_key
                ret = true
            end
        elseif currentScale ~= 2 or currentScaleOffset ~= 1 then
            --switch to c major as default, when no scale is set
            currentScale = 2
            currentScaleOffset = 1
            ret = true
        end
    elseif preferences.scaleHighlightingType.value == 5 then
        --only process, after piano roll refresh
        if afterPianoRollRefresh then
            --loop through scales and choose one
            local keyCount = table.count(usedNoteIndices)
            if keyCount > 2 then
                local foundScaleKey
                local lowErrorScaleKey
                local minErrors = 255
                local errorCount = 0
                for scaleKey = 0, 12 do
                    local allKeysInKey = true
                    for key in pairs(usedNoteIndices) do
                        if not noteIndexInMajorScale((usedNoteIndices[key] - scaleKey) % 12) then
                            allKeysInKey = false
                            errorCount = errorCount + 1
                        end
                    end
                    if allKeysInKey then
                        foundScaleKey = scaleKey
                        break
                    elseif errorCount > 0 and minErrors > errorCount then
                        minErrors = errorCount
                        lowErrorScaleKey = scaleKey
                    end
                end
                if not foundScaleKey then
                    foundScaleKey = lowErrorScaleKey
                end
                if foundScaleKey ~= nil then
                    if currentScale ~= 2 then
                        currentScale = 2
                        ret = true
                    end
                    if currentScaleOffset ~= (foundScaleKey + 1) then
                        currentScaleOffset = (foundScaleKey + 1)
                        ret = true
                    end
                end
            else
                if (currentScale ~= 1 or currentScaleOffset ~= 1) then
                    currentScale = 1
                    currentScaleOffset = 1
                    ret = true
                end
            end
        end
    end
    if ret then
        if currentScale == 1 then
            vbw["currentscale"].text = "None"
        elseif currentScale == 2 then
            vbw["currentscale"].text = notesTable[currentScaleOffset] .. " Major"
        elseif currentScale == 3 then
            vbw["currentscale"].text = notesTable[currentScaleOffset] .. " Minor"
        end
    end
    return ret
end

--detect chords and progression
local function refreshDetectedChord()
    local distance_string = {}
    local notelabels = ""
    local rawnotes = {}
    local notes = {}
    local dummy = {}
    local chord
    local chordprog = ""
    local dis
    --current playing notes?
    for key in pairs(notesPlaying) do
        table.insert(rawnotes, key)
    end
    --no notes found? current selected notes?
    if #rawnotes == 0 and #noteSelection > 0 and not song.transport.playing then
        for i = 1, #noteSelection do
            table.insert(rawnotes, noteSelection[i].note)
        end
    end
    --no notes found, current notes on step?
    if #rawnotes == 0 and #notesOnStep > 0 then
        rawnotes = notesOnStep
    end
    --no notes?
    if #rawnotes > 0 then
        --sort notes
        table.sort(rawnotes, function(a, b)
            return a < b
        end)
        --cleaup notes, create notes labels
        for i = 1, #rawnotes do
            --check distance to first note
            if i > 1 then
                if rawnotes[i] - rawnotes[1] > 12 then
                    rawnotes[i] = rawnotes[1] + (rawnotes[i] - rawnotes[1]) % 12
                end
            end
            if not dummy[rawnotes[i] % 12] then
                table.insert(notes, rawnotes[i])
                if notelabels ~= "" then
                    notelabels = notelabels .. ","
                end
                notelabels = notelabels .. notesTable[rawnotes[i] % 12 + 1]
                dummy[rawnotes[i] % 12] = 1
            end
        end
        --sort notes again
        for j = 1, #notes do
            distance_string[j] = {
                note = 0,
                key = "0",
            }
            table.sort(notes, function(a, b)
                return a < b
            end)
            --calc note distance
            for i = 2, #notes do
                dis = (notes[i] - notes[1]) % 12
                if dis > 0 then
                    distance_string[j].key = distance_string[j].key .. "," .. dis
                end
            end
            --
            distance_string[j].note = notes[1]
            notes[#notes] = notes[#notes] - 12
            --
        end
        --search for chord also try inversions
        for i = 1, #distance_string do
            if distance_string ~= "" then
                if chordsTable[distance_string[i].key] then
                    if scaleDegreeAndRomanNumeral[currentScale] then
                        chordprog = scaleDegreeAndRomanNumeral[currentScale][(distance_string[i].note - (currentScaleOffset - 1)) % 12 + 1]
                    end
                    chord = notesTable[distance_string[i].note % 12 + 1] .. " " .. chordsTable[distance_string[i].key]
                    break
                end
            end
        end
        if not chord and #rawnotes > 0 then
            if scaleDegreeAndRomanNumeral[currentScale] then
                chordprog = scaleDegreeAndRomanNumeral[currentScale][(rawnotes[1] % 12 - (currentScaleOffset - 1)) % 12 + 1]
            end
            if #rawnotes == 2 and rawnotes[1] % 12 == rawnotes[2] % 12 then
                chord = notesTable[rawnotes[1] % 12 + 1] .. " Octave"
            elseif #rawnotes == 1 then
                chord = notesTable[rawnotes[1] % 12 + 1] .. " unison"
            end
        end
    end
    if not notelabels or notelabels == "" then
        vbw["currentnotes"].text = "-"
    else
        vbw["currentnotes"].text = notelabels
    end
    if not chord or chord == "" then
        vbw["currentchord"].text = "-"
    else
        vbw["currentchord"].text = chord
    end
    if not chordprog or chordprog == "" then
        vbw["chordprog"].text = "-"
    else
        vbw["chordprog"].text = chordprog
    end
    refreshChordDetection = false
end

--highlight each note on the current playback pos
local function highlightNotesOnStep(step, highlight)
    local rows = {}
    notesOnStep = {}
    if noteOnStep[step] ~= nil and #noteOnStep[step] > 0 then
        for i = 1, #noteOnStep[step] do
            --when notes are on current step and not selected
            if noteOnStep[step][i] ~= nil then
                local note = noteOnStep[step][i]
                local idx = "b" .. note.index
                local sidx = "bs" .. note.index
                table.insert(notesOnStep, note.note)
                if vbw[idx] then
                    rows[note.row] = note.note
                    if highlight then
                        if not noteData[note.index] or not noteInSelection(noteData[note.index]) then
                            if preferences.useTrackColorForNoteHighlighting.value then
                                vbw[idx].color = vbw["trackcolor"].color
                            else
                                vbw[idx].color = colorNoteHighlight
                            end
                        end
                    else
                        if not noteData[note.index] or not noteInSelection(noteData[note.index]) then
                            vbw[idx].color = colorNoteVelocity(note.vel, note.ghst)
                        end
                    end
                    vbw[sidx].color = shadeColor(vbw[idx].color, preferences.scaleBtnShadingAmount.value)
                end
            end
        end
    end
    --color rows and keyboard
    for key in pairs(rows) do
        setKeyboardKeyColor(key, false, highlight)
        highlightNoteRow(key, highlight)
    end
    refreshChordDetection = true
end

--refresh playback pos indicator
local function refreshPlaybackPosIndicator()
    local line = song.transport.playback_pos.line
    local seq = song.sequencer:pattern(song.transport.playback_pos.sequence)
    if song.selected_pattern_index == seq and lastStepOn ~= line and song.transport.playing then
        if lastStepOn then
            vbw["s" .. tostring(lastStepOn)].color = colorStepOff
            highlightNotesOnStep(lastStepOn, false)
            lastStepOn = nil
        end
        lastStepOn = line - stepOffset

        if preferences.followPlayCursor.value and song.transport.follow_player and (lastStepOn > gridWidth or lastStepOn < 0) then
            --follow play cursor, when enabled
            local v = stepSlider.value + (gridWidth * (lastStepOn / gridWidth)) - 1
            if v > stepSlider.max then
                v = stepSlider.max
            end
            if v < stepSlider.min then
                v = stepSlider.min
            end
            lastStepOn = nil
            stepSlider.value = v
        elseif lastStepOn > 0 and lastStepOn <= gridWidth then
            --highlight when inside the grid
            vbw["s" .. tostring(lastStepOn)].color = colorStepOn
            highlightNotesOnStep(lastStepOn, true)
        else
            lastStepOn = nil
        end
    elseif (song.selected_pattern_index ~= seq or not song.transport.playing) then
        if #notesOnStep > 0 then
            notesOnStep = {}
            refreshChordDetection = true
        end
        if lastStepOn then
            vbw["s" .. tostring(lastStepOn)].color = colorStepOff
            highlightNotesOnStep(lastStepOn, false)
            lastStepOn = nil
        end
    end
end

--reset pianoroll and enable notes
local function fillPianoRoll(quickRefresh)
    local l_vbw = vbw
    local l_song = song
    local track = l_song.selected_track
    local steps = l_song.selected_pattern.number_of_lines
    local lpb = l_song.transport.lpb
    local lineValues = l_song.selected_pattern_track.lines
    local columns = track.visible_note_columns
    local stepsCount = math.min(steps, gridWidth)
    local noffset = noteOffset - 1
    local blackKey
    local temp

    --set auto ghost track
    if preferences.setLastEditedTrackAsGhost.value and lastTrackIndex and lastTrackIndex ~= l_song.selected_track_index then
        l_vbw.ghosttracks.value = lastTrackIndex
    end

    --set track index
    lastTrackIndex = l_song.selected_track_index

    --disable line modifier block and force a quick refresh
    if blockLineModifier then
        quickRefresh = true
        blockLineModifier = false
    end

    --remove old notes
    for y = 1, gridHeight do
        if noteButtons[y] then
            for key in pairs(noteButtons[y]) do
                l_vbw["row" .. y]:remove_child(noteButtons[y][key])
            end
        end
    end

    --reset vars
    noteButtons = {}
    noteOnStep = {}
    noteData = {}

    if not quickRefresh then
        currentInstrument = nil
        usedNoteIndices = {}
        defaultColor = {}
        lastStepOn = nil
        lastEditPos = nil
        refreshPianoRollNeeded = false
        --show keyboard info bar
        l_vbw["key_state_panel"].visible = preferences.enableKeyInfo.value
        --set scale for piano roll
        setScaleHighlighting()
    end

    --check if stepoffset is inside the grid, also setup stepSlider if needed
    if steps > gridWidth then
        stepSlider.max = steps - gridWidth
        if stepOffset > stepSlider.max then
            stepOffset = stepSlider.max
        end
        stepSlider.visible = true
    else
        stepSlider.max = 0
        stepSlider.visible = false
        stepOffset = 0
    end

    --loop through columns
    for c = 1, columns do
        local current_note
        local current_note_ghost
        local current_note_string
        local current_note_len = 0
        local current_note_vel = 255
        local current_note_end_vel = 255
        local current_note_pan = 255
        local current_note_dly = 0
        local current_note_end_dly = 0
        local current_note_step
        local current_note_line
        local current_note_rowIndex

        --loop through lines as steps
        for line = 1, steps do
            local s = line - stepOffset
            local stepString
            if line > stepOffset and line - stepOffset <= gridWidth then
                stepString = tostring(s)
            end

            --only reset buttons on first column
            if not quickRefresh and c == 1 and stepString then
                local bar = calculateBarBeat(s + stepOffset, false, lpb)

                for y = 1, gridHeight do
                    local ystring = tostring(y)
                    local index = stepString .. "_" .. ystring
                    local p = l_vbw["p" .. index]
                    local color = colorWhiteKey[bar % 2 + 1]
                    p.active = true
                    blackKey = not noteInScale((y + noffset) % 12)
                    --color black notes
                    if blackKey then
                        color = colorBlackKey[bar % 2 + 1]
                    end
                    if s <= stepsCount then
                        defaultColor["p" .. index] = color
                        p.color = color
                        --refresh step indicator
                        if y == 1 then
                            l_vbw["s" .. stepString].active = true
                            l_vbw["se" .. stepString].visible = false
                            l_vbw["s" .. stepString].color = colorStepOff
                        end
                        --refresh keyboad
                        if s == 1 then
                            local idx = "k" .. ystring
                            local key = l_vbw[idx]
                            local isRootKey = (preferences.scaleHighlightingType.value ~= 5 and currentScale == 2 and noteIndexInScale((y + noffset) % 12) == 0) or
                                    (preferences.scaleHighlightingType.value ~= 5 and currentScale == 3 and noteIndexInScale((y + noffset) % 12) == 9) or
                                    (preferences.scaleHighlightingType.value == 5 and currentScale == 2 and noteIndexInScale((y + noffset) % 12) == 0)
                            if preferences.keyboardStyle.value == 2 then
                                defaultColor[idx] = colorList
                            elseif noteInScale((y + noffset) % 12, true) then
                                defaultColor[idx] = colorKeyWhite
                            else
                                defaultColor[idx] = colorKeyBlack
                            end
                            if isRootKey then
                                defaultColor[idx] = shadeColor(defaultColor[idx], preferences.rootKeyShadingAmount.value)
                            end
                            if notesPlaying[y + noffset] then
                                key.color = colorStepOn
                            else
                                key.color = defaultColor[idx]
                            end
                            --set root label
                            if preferences.keyLabels.value == 4 or
                                    (preferences.keyLabels.value == 2 and (
                                            ((currentScale == 1 or (preferences.scaleHighlightingType.value == 5 and currentScale == 1)) and noteIndexInScale((y + noffset) % 12, true) == 0) or
                                                    isRootKey))
                                    or
                                    (preferences.keyLabels.value == 3 and
                                            noteInScale((y + noffset) % 12))
                            then
                                local note = notesTable[(y + noffset) % 12 + 1]
                                if string.len(note) == 1 then
                                    note = note .. "-"
                                end
                                if preferences.keyboardStyle.value == 2 then
                                    key.text = note .. tostring(math.floor((y + noffset) / 12)) .. "         "
                                else
                                    key.text = "         " .. note .. tostring(math.floor((y + noffset) / 12))
                                end
                            else
                                key.text = ""
                            end
                            --reset key sub state button color
                            l_vbw["ks" .. ystring].visible = false
                            l_vbw["kss" .. ystring].visible = true
                        end
                    end
                end
            end
            --render notes
            local note_column = lineValues[line]:note_column(c)
            local note = note_column.note_value
            local note_string = note_column.note_string
            local volume_string = note_column.volume_string
            local panning_string = note_column.panning_string
            local delay_string = note_column.delay_string
            local instrument = note_column.instrument_value

            --add missing note off
            if line == 1 and preferences.addNoteOffToEmptyNoteColumns.value then
                if note_column.note_value == 121 then
                    note_column.note_value = 120
                end
            end

            if note < 120 then
                if currentInstrument == nil and note_column.instrument_value < 255 then
                    currentInstrument = note_column.instrument_value + 1
                end
                if current_note ~= nil then
                    drawNoteToGrid(c,
                            current_note_line,
                            current_note_step,
                            current_note_rowIndex,
                            current_note,
                            current_note_len,
                            current_note_string,
                            current_note_vel,
                            current_note_end_vel,
                            current_note_pan,
                            current_note_dly,
                            current_note_end_dly,
                            false,
                            current_note_ghost)
                end
                current_note = note
                current_note_string = note_string
                current_note_len = 0
                current_note_end_vel = nil
                current_note_step = s
                current_note_line = line
                current_note_vel = fromRenoiseHex(volume_string)
                current_note_pan = fromRenoiseHex(panning_string)
                current_note_dly = fromRenoiseHex(delay_string)
                current_note_end_dly = 0
                current_note_rowIndex = noteValue2GridRowOffset(current_note, true)
                if instrument == 255 then
                    current_note_ghost = true
                else
                    current_note_ghost = false
                end
                --add current note to note index table for scale detection
                usedNoteIndices[line .. "_" .. c] = note % 12
            elseif note == 120 and current_note ~= nil then
                --note off delay
                current_note_end_dly = fromRenoiseHex(delay_string)
                if not current_note_step and s then
                    current_note_step = current_note_line - stepOffset
                end
                drawNoteToGrid(c,
                        current_note_line,
                        current_note_step,
                        current_note_rowIndex,
                        current_note,
                        current_note_len,
                        current_note_string,
                        current_note_vel,
                        current_note_end_vel,
                        current_note_pan,
                        current_note_dly,
                        current_note_end_dly,
                        true,
                        current_note_ghost)
                current_note = nil
                current_note_len = 0
                current_note_rowIndex = nil
                current_note_ghost = nil
            else
                current_note_end_vel = fromRenoiseHex(volume_string)
            end

            if current_note_rowIndex ~= nil then
                current_note_len = current_note_len + 1
            end
        end
        --pattern end, no note off, enable last note
        if current_note ~= nil then
            drawNoteToGrid(c,
                    current_note_line,
                    current_note_step,
                    current_note_rowIndex,
                    current_note,
                    current_note_len,
                    current_note_string,
                    current_note_vel,
                    current_note_end_vel,
                    current_note_pan,
                    current_note_dly,
                    current_note_end_dly,
                    false,
                    current_note_ghost)
        end
    end

    --nothing else to do in quick refresh
    if quickRefresh then
        return
    end

    --hide non used elements of the piano roll grid
    for y = 1, gridHeight do
        temp = shadeColor(defaultColor["p1_" .. y], 0.4)
        for i = steps + 1, gridWidth do
            if y == 1 then
                l_vbw["s" .. i].active = false
                l_vbw["se" .. i].visible = false
                l_vbw["s" .. i].color = colorDefault
            end
            l_vbw["p" .. i .. "_" .. y].color = temp
            l_vbw["p" .. i .. "_" .. y].active = true
        end
    end

    --quirk? i need to visible and hide a note button to get fast vertical scroll
    if not l_vbw["dummy" .. tostring(4) .. "_" .. tostring(4)].visible then
        l_vbw["dummy" .. tostring(4) .. "_" .. tostring(4)].visible = true
        l_vbw["dummy" .. tostring(4) .. "_" .. tostring(4)].visible = false
    end

    --switch to instrument which is used in pattern
    if currentInstrument and currentInstrument ~= l_song.selected_instrument_index then
        if currentInstrument < #l_song.instruments then
            l_song.selected_instrument_index = currentInstrument
        end
    end

    --for automatic mode or empty patterns, set scale highlighting again, if needed
    if setScaleHighlighting(true) then
        refreshPianoRollNeeded = true
    end

    --enable buttons when something selected
    if #noteSelection > 0 then
        l_vbw.note_vel_humanize.active = vbw.note_vel_clear.active
        l_vbw.note_pan_humanize.active = vbw.note_pan_clear.active
        l_vbw.note_dly_humanize.active = vbw.note_dly_clear.active
    else
        l_vbw.note_vel_humanize.active = false
        l_vbw.note_pan_humanize.active = false
        l_vbw.note_dly_humanize.active = false
    end

    --render ghost notes, only when index is not the current track
    if currentGhostTrack and currentGhostTrack ~= l_song.selected_track_index then
        if l_song:track(currentGhostTrack).type == renoise.Track.TRACK_TYPE_SEQUENCER then
            ghostTrack(currentGhostTrack)
        elseif l_song:track(currentGhostTrack).type ~= renoise.Track.TRACK_TYPE_SEQUENCER then
            currentGhostTrack = l_song.selected_track_index
            vbw.ghosttracks.value = currentGhostTrack
            showStatus("Current selected track cant be a ghost track.")
        end
    end

    --refresh playback pos indicator
    refreshPlaybackPosIndicator()
end

--set playback pos via playback pos indicator
function setPlaybackPos(pos)
    --select all note events which are on specific pos
    if keyControl then
        local line = pos + stepOffset
        if not keyShift then
            noteSelection = {}
        end
        for key in pairs(noteData) do
            local note_data = noteData[key]
            if line >= note_data.line and line < note_data.line + note_data.len then
                table.insert(noteSelection, note_data)
            end
        end
        jumpToNoteInPattern("sel")
        refreshPianoRollNeeded = true
    else
        playPatternFromLine(pos + stepOffset)
    end
end

--app idle
local function appIdleEvent()
    --only process when window is created and visible
    if windowObj and windowObj.visible then

        --refresh modifier states, when keys are pressed outside focus
        local keyState = app.key_modifier_states
        if (keyState["alt"] == "pressed" and keyAlt == false) or (keyState["alt"] == "released" and keyAlt == true) then
            keyAlt = not keyAlt
            refreshControls = true
        end
        if (keyState["control"] == "pressed" and keyControl == false) or (keyState["control"] == "released" and keyControl == true) then
            keyControl = not keyControl
            refreshControls = true
        end
        if (keyState["shift"] == "pressed" and keyShift == false) or (keyState["shift"] == "released" and keyShift == true) then
            keyShift = not keyShift
            refreshControls = true
        end

        --refresh pianoroll, when needed
        if refreshPianoRollNeeded then
            fillPianoRoll()
        end

        --refresh control, when needed
        if refreshControls then
            refreshNoteControls()
        end

        --refresh timeline, when needed
        if refreshTimeline then
            fillTimeline()
        end

        --refresh chord states
        if refreshChordDetection and preferences.chordDetection.value then
            refreshDetectedChord()
        end

        --key info state
        if lastKeyInfoTime and lastKeyInfoTime + preferences.keyInfoTime.value < os.clock() then
            vbw["key_state"].text = ""
        end

        --refresh playback pos indicator
        refreshPlaybackPosIndicator()

        --edit pos render
        refreshEditPosIndicator()

        --block loop, create an index for comparison, because obserable's are missing here
        local currentblockloop = tostring(song.transport.loop_block_enabled)
                .. tostring(song.transport.loop_block_start_pos)
                .. tostring(song.transport.loop_block_range_coeff)
        if blockloopidx ~= currentblockloop then
            blockloopidx = currentblockloop
            refreshTimeline = true
        end

        --
        if #lastTriggerNote > 0 and oscClient then
            local newLastTriggerNote = {}
            for i = 1, #lastTriggerNote do
                if lastTriggerNote[i].time < os.clock() - (preferences.triggerTime.value / 1000) then
                    table.remove(lastTriggerNote[i].packet, 4) --remove velocity
                    oscClient:send(renoise.Osc.Message("/renoise/trigger/note_off", lastTriggerNote[i].packet))
                else
                    table.insert(newLastTriggerNote, lastTriggerNote[i])
                end
            end
            lastTriggerNote = newLastTriggerNote
        end
    end
end

--refresh notifier for observers
local function obsPianoRefresh()
    --clear note selection
    noteSelection = {}
    --set refresh flags
    refreshPianoRollNeeded = true
end

--will be called when the visibility of columns will be changed
local function obsColumnRefresh()
    refreshControls = true
    refreshPianoRollNeeded = true
    refreshChordDetection = true
end

--will be called when something in the pattern will be changed
local function lineNotifier()
    --when global flag is set, then piano roll refresh on specific events will be blocked
    if not blockLineModifier then
        refreshPianoRollNeeded = true
    end
end

--number of lines refresh, fix missing note off, when pattern length get increased
local function numberOfLinesNotifier()
    --fix missing note off
    local lineValues = song.selected_pattern_track.lines
    for key in pairs(noteData) do
        local note_data = noteData[key]
        if not note_data.noteoff then
            local linVal = lineValues[note_data.line + note_data.len]
            if linVal then
                local note_column = linVal:note_column(note_data.column)
                if note_column.note_value == 121 then
                    note_column.note_value = 120
                    note_data.noteoff = true
                end
            end
        end
    end
    refreshTimeline = true
    obsPianoRefresh()
end

--on each new song, reset pianoroll and setup locals
local function appNewDoc()
    --close window, when a new song was opened
    if windowObj and windowObj.visible then
        windowObj:close()
    end

    song = renoise.song()
    --reset vars
    lastTrackIndex = nil
    currentNoteVelocity = 255
    currentNotePan = 255
    currentNoteDelay = 0
    currentNoteEndDelay = 0
    currentNoteVelocityPreview = 127
    currentNoteEndVelocity = 255
    --set new observers
    song.transport.lpb_observable:add_notifier(function()
        refreshPianoRollNeeded = true
        refreshTimeline = true
    end)
    song.selected_pattern_track_observable:add_notifier(obsPianoRefresh)
    song.selected_pattern_observable:add_notifier(function()
        if not song.selected_pattern:has_line_notifier(lineNotifier) then
            song.selected_pattern:add_line_notifier(lineNotifier)
        end
        if not song.selected_pattern.number_of_lines_observable:has_notifier(numberOfLinesNotifier) then
            song.selected_pattern.number_of_lines_observable:add_notifier(numberOfLinesNotifier)
        end
        pasteCursor = {}
        stepSlider.value = 0
        refreshPianoRollNeeded = true
        refreshTimeline = true
    end)
    song.selected_pattern:add_line_notifier(lineNotifier)
    if not song.selected_pattern.number_of_lines_observable:has_notifier(numberOfLinesNotifier) then
        song.selected_pattern.number_of_lines_observable:add_notifier(numberOfLinesNotifier)
    end
    song.selected_track_observable:add_notifier(function()
        if song.selected_track.type ~= renoise.Track.TRACK_TYPE_SEQUENCER and windowObj and windowObj.visible then
            badTrackError()
        end
        if not song.selected_track.volume_column_visible_observable:has_notifier(obsColumnRefresh) then
            song.selected_track.volume_column_visible_observable:add_notifier(obsColumnRefresh)
        end
        if not song.selected_track.panning_column_visible_observable:has_notifier(obsColumnRefresh) then
            song.selected_track.panning_column_visible_observable:add_notifier(obsColumnRefresh)
        end
        if not song.selected_track.delay_column_visible_observable:has_notifier(obsColumnRefresh) then
            song.selected_track.delay_column_visible_observable:add_notifier(obsColumnRefresh)
        end
        pasteCursor = {}
        refreshControls = true
    end)
    song.selected_track.volume_column_visible_observable:add_notifier(obsColumnRefresh)
    song.selected_track.panning_column_visible_observable:add_notifier(obsColumnRefresh)
    song.selected_track.delay_column_visible_observable:add_notifier(obsColumnRefresh)
    song.selected_track.name_observable:add_notifier(obsColumnRefresh)
    song.selected_track.color_observable:add_notifier(obsColumnRefresh)
    song.selected_track.mute_state_observable:add_notifier(obsColumnRefresh)
    song.selected_track.solo_state_observable:add_notifier(obsColumnRefresh)
    --transport observable
    song.transport.loop_pattern_observable:add_notifier(obsColumnRefresh)
    song.transport.playing_observable:add_notifier(obsColumnRefresh)
    --clear selection and refresh piano roll
    obsPianoRefresh()
    obsColumnRefresh()
    refreshTimeline = true
end

--convert some keys to qwerty layout
local function azertyMode(key)
    key = table.copy(key)
    if key.name == "&" then
        key.name = "1"
    elseif key.name == "é" then
        key.name = "2"
    elseif key.name == "\"" then
        key.name = "3"
    elseif key.name == "'" then
        key.name = "4"
    elseif key.name == "(" then
        key.name = "5"
    elseif key.name == "-" then
        key.name = "6"
    elseif key.name == "è" then
        key.name = "7"
    elseif key.name == "_" then
        key.name = "8"
    elseif key.name == "ç" then
        key.name = "9"
    elseif key.name == "à" then
        key.name = "0"
    end
    return key
end

--function for all keyboard shortcuts
local function handleKeyEvent(keyEvent)
    local handled = false
    local keyInfoText
    local isModifierKey = false
    local key

    if preferences.disableKeyHandler.value then
        return false
    end

    --convert number keys from azerty to qwerty
    if preferences.azertyMode.value then
        key = azertyMode(keyEvent)
    else
        key = keyEvent
    end

    --check if current key is a modifier
    if key.name == "lalt" or key.name == "lshift" or key.name == "lcontrol" or key.name == "ralt" or key.name == "rshift" or key.name == "rcontrol" then
        isModifierKey = true
    end

    --ignore press events from last key event with modifiers
    if lastKeyPress and lastKeyPress == key.name and key.state == "pressed" and key.modifiers == "" then
        return false
    end

    --focus pattern editor - https://forum.renoise.com/t/set-focus-from-lua-code/42281/3
    app.window.lock_keyboard_focus = false
    app.window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
    app.window.lock_keyboard_focus = true

    if key.name == "lcontrol" and key.state == "pressed" then
        keyControl = true
        handled = true
    elseif key.name == "lcontrol" and key.state == "released" then
        keyControl = false
        handled = true
    end
    if key.name == "rcontrol" and key.state == "pressed" then
        keyRControl = true
        handled = true
    elseif key.name == "rcontrol" and key.state == "released" then
        keyRControl = false
        handled = true
    end
    if key.name == "lalt" and key.state == "pressed" then
        keyAlt = true
        handled = true
        refreshControls = true
    elseif key.name == "lalt" and key.state == "released" then
        keyAlt = false
        handled = true
        refreshControls = true
    end
    if key.name == "lshift" and key.state == "pressed" then
        keyShift = true
        handled = true
        refreshControls = true
    elseif key.name == "lshift" and key.state == "released" then
        keyShift = false
        handled = true
        refreshControls = true
    end
    if key.name == "rshift" and key.state == "pressed" then
        keyRShift = true
        handled = true
    elseif key.name == "rshift" and key.state == "released" then
        keyRShift = false
        handled = true
    end

    --convert scrollwheel events
    if key.name == "scrollup" or key.name == "scrolldown" then
        key.state = "pressed"
        key.modifiers = ""
        if keyShift or keyRShift then
            key.modifiers = "shift"
        end
        if keyAlt then
            if key.modifiers ~= "" then
                key.modifiers = key.modifiers .. " + "
            end
            key.modifiers = key.modifiers .. "alt"
        end
        if keyControl then
            if key.modifiers ~= "" then
                key.modifiers = key.modifiers .. " + "
            end
            key.modifiers = key.modifiers .. "control"
        end
    end

    if key.name == "del" then
        if key.state == "pressed" then
            keyInfoText = "Delete selected notes"
            if #noteSelection > 0 then
                showStatus(#noteSelection .. " notes deleted.")
                removeSelectedNotes()
            end
        end
        handled = true
    end
    if key.name == "esc" then
        if key.state == "pressed" then
            keyInfoText = "Deselect current note selection"
            if #noteSelection > 0 then
                noteSelection = {}
                refreshPianoRollNeeded = true
                refreshChordDetection = true
            end
        end
        handled = true
    end
    if key.name == "f1" then
        if key.state == "pressed" then
            keyInfoText = "Select mode"
            penMode = false
            audioPreviewMode = false
            refreshControls = true
        end
        handled = true
    end
    if key.name == "f2" then
        if key.state == "pressed" then
            keyInfoText = "Pen mode"
            penMode = true
            audioPreviewMode = false
            refreshControls = true
        end
        handled = true
    end
    if key.name == "f3" then
        if key.state == "pressed" then
            keyInfoText = "Audio preview mode"
            penMode = false
            audioPreviewMode = true
            refreshControls = true
        end
        handled = true
    end
    if key.name == "i" and key.modifiers == "shift" then
        if key.state == "pressed" then
            if #noteSelection > 0 then
                showStatus("Inverted note selection.")
                keyInfoText = "Invert note selection"
                local newSelection = {}
                for k in pairs(noteData) do
                    if not noteInSelection(noteData[k]) then
                        table.insert(newSelection, noteData[k])
                    end
                end
                noteSelection = newSelection
                refreshPianoRollNeeded = true
            end
        end
        handled = true
    end
    if key.modifiers == "control" and (
            key.name == "1" or
                    key.name == "2" or
                    key.name == "3" or
                    key.name == "4" or
                    key.name == "5" or
                    key.name == "6" or
                    key.name == "7" or
                    key.name == "8" or
                    key.name == "9"
    ) then
        if key.state == "pressed" and not key.repeated then
            keyInfoText = "Change note length to " .. key.name
            if #noteSelection > 0 then
                currentNoteLength = tonumber(key.name)
                changeSizeSelectedNotes(currentNoteLength)
                refreshControls = true
            else
                vbw.note_len.value = tonumber(key.name)
            end
        end
        handled = true
    end

    if key.name == "0" then
        if key.state == "pressed" then
            if key.modifiers == "control" then
                if #noteSelection > 0 then
                    scaleNoteSelection(2)
                    keyInfoText = "Grow note selection"
                end
                currentNoteLength = math.min(math.floor(currentNoteLength * 2), 256)
            elseif key.modifiers == "shift + control" then
                if #noteSelection > 0 then
                    scaleNoteSelection(0.5)
                    keyInfoText = "Shrink note selection"
                end
                currentNoteLength = math.max(math.floor(currentNoteLength / 2), 1)
            end
            refreshControls = true
        end
        handled = true
    end
    if key.name == "u" and key.modifiers == "control" then
        if key.state == "pressed" then
            if #noteSelection == 0 then
                for k in pairs(noteData) do
                    local note_data = noteData[k]
                    table.insert(noteSelection, note_data)
                end
            end
            if #noteSelection > 0 then
                local ret = chopSelectedNotes()
                --was not possible then deselect
                if not ret then
                    noteSelection = {}
                    refreshPianoRollNeeded = true
                else
                    showStatus((#noteSelection / 2) .. " notes chopped.")
                    keyInfoText = "Chop selected notes"
                end
            end
        end
        handled = true
    end
    if key.name == "m" and key.modifiers == "alt" then
        if key.state == "pressed" then
            local selectall = false
            if #noteSelection == 0 then
                for k in pairs(noteData) do
                    local note_data = noteData[k]
                    table.insert(noteSelection, note_data)
                end
                selectall = true
            end
            if #noteSelection > 0 then
                changePropertiesOfSelectedNotes("mute")
                keyInfoText = "Mute selected notes"
                showStatus(#noteSelection .. " notes was muted.")
                --when all was automatically selected, deselect it
                if selectall then
                    noteSelection = {}
                    keyInfoText = "Mute all notes"
                end
            end
        end
        handled = true
    end
    if key.name == "n" and key.modifiers == "alt" then
        if key.state == "pressed" then
            if #noteSelection > 0 then
                changePropertiesOfSelectedNotes(nil, nil, nil, nil, nil, "matchingnotes")
                keyInfoText = "Match notes"
                showStatus(#noteSelection .. " notes was matched.")
            end
        end
        handled = true
    end
    if key.name == "m" and key.modifiers == "shift + alt" then
        if key.state == "pressed" then
            local selectall = false
            if #noteSelection == 0 then
                for k in pairs(noteData) do
                    local note_data = noteData[k]
                    table.insert(noteSelection, note_data)
                end
                selectall = true
            end
            if #noteSelection > 0 then
                changePropertiesOfSelectedNotes("unmute")
                keyInfoText = "Unmute selected notes"
                showStatus(#noteSelection .. " notes was unmuted.")
                --when all was automatically selected, deselect it
                if selectall then
                    noteSelection = {}
                    keyInfoText = "Unmute all notes"
                end
            end
        end
        handled = true
    end
    if (key.name == "b" or key.name == "d") and key.modifiers == "control" then
        if key.state == "pressed" then
            if #noteSelection == 0 then
                --step through all current notes and add them to noteSelection, TODO select all notes, not only the visible ones
                for k in pairs(noteData) do
                    local note_data = noteData[k]
                    table.insert(noteSelection, note_data)
                end
            end
            if #noteSelection > 0 then
                local ret = duplicateSelectedNotes()
                --was not possible then deselect
                if not ret then
                    noteSelection = {}
                    refreshPianoRollNeeded = true
                else
                    keyInfoText = "Duplicate notes"
                    jumpToNoteInPattern("sel")
                    showStatus(#noteSelection .. " notes duplicated.")
                end
            end
        end
        handled = true
    end
    if key.name == "c" and key.modifiers == "control" then
        keyInfoText = "Copy selected notes"
        if key.state == "pressed" and not key.repeated then
            if #noteSelection > 0 then
                clipboard = {}
                for k in pairs(noteSelection) do
                    local note_data = noteSelection[k]
                    table.insert(clipboard, note_data)
                end
                --set paste cursor
                table.sort(clipboard, function(a, b)
                    return a.line > b.line
                end)
                pasteCursor = { clipboard[1].line + clipboard[1].len, 0 }
                table.sort(clipboard, function(a, b)
                    if a.line == b.line then
                        return a.note < b.note
                    end
                    return a.line < b.line
                end)
                pasteCursor = { pasteCursor[1], clipboard[1].note }
                showStatus(#noteSelection .. " notes copied.", true)
            end
        end
        handled = true
    end
    if key.name == "x" and key.modifiers == "control" then
        keyInfoText = "Cut selected notes"
        if key.state == "pressed" and not key.repeated then
            if #noteSelection > 0 then
                clipboard = {}
                for k in pairs(noteSelection) do
                    local note_data = noteSelection[k]
                    table.insert(clipboard, note_data)
                end
                --set paste cursor, to the first note
                table.sort(clipboard, function(a, b)
                    return a.line < b.line
                end)
                pasteCursor = { clipboard[1].line, clipboard[1].note }
                --set status
                showStatus(#noteSelection .. " notes cut.", true)
                --remove selected notes
                removeSelectedNotes(true)
            end
        end
        handled = true
    end
    if key.name == "v" and key.modifiers == "control" then
        keyInfoText = "Paste notes"
        if #clipboard > 0 then
            if key.state == "pressed" then
                showStatus(#clipboard .. " notes pasted.", true)
                pasteNotesFromClipboard()
                jumpToNoteInPattern("sel")
            end
        end
        handled = true
    end
    if key.name == "a" and key.modifiers == "control" then
        if key.state == "pressed" then
            --clear current selection
            noteSelection = {}
            --step through all current notes and add them to noteSelection, TODO select all notes, not only the visible ones
            for k in pairs(noteData) do
                local note_data = noteData[k]
                table.insert(noteSelection, note_data)
            end
            keyInfoText = "Select all notes"
            showStatus(#noteSelection .. " notes selected.", true)
            jumpToNoteInPattern("sel")
            refreshPianoRollNeeded = true
        end
        handled = true
    end
    if (key.name == "scrollup" or key.name == "scrolldown") then
        if key.state == "pressed" then
            local steps = preferences.scrollWheelSpeed.value
            if key.name == "scrolldown" then
                steps = steps * -1
            end
            if (keyAlt or keyShift or keyRShift) and not keyControl then
                if #noteSelection > 0 and keyAlt and not keyShift and not keyControl then
                    if steps > 0 then
                        keyInfoText = "Increase velocity of selected notes"
                    else
                        keyInfoText = "Decrease velocity of selected notes"
                    end
                    changePropertiesOfSelectedNotes(steps, nil, nil, nil, nil, "add")
                    --play new velocity
                    triggerNoteOfCurrentInstrument(noteSelection[1].note, nil, noteSelection[1].vel, true)
                elseif #noteSelection > 0 and keyShift and not keyAlt and not keyControl then
                    steps = -steps
                    keyInfoText = "Move notes by " .. steps .. " micro steps"
                    if isDelayColumnActive(true) then
                        moveSelectedNotesByMicroSteps(steps)
                    end
                else
                    keyInfoText = "Move through the grid"
                    steps = steps * -1
                    stepSlider.value = forceValueToRange(stepSlider.value + steps, stepSlider.min, stepSlider.max)
                end
            elseif not keyAlt and not keyControl and not keyShift and not keyRShift then
                keyInfoText = "Move through the grid"
                noteSlider.value = forceValueToRange(noteSlider.value + steps, noteSlider.min, noteSlider.max)
            end
        end
        handled = true
    end
    if (key.name == "next" or key.name == "prior") then
        if key.state == "pressed" and key.modifiers == "" then
            local steps = 16
            if key.name == "next" then
                steps = steps * -1
            end
            keyInfoText = "Move through the grid"
            noteSlider.value = forceValueToRange(noteSlider.value + steps, noteSlider.min, noteSlider.max)
        end
        handled = true
    end
    if (key.name == "up" or key.name == "down") then
        if key.state == "pressed" then
            local transpose = 1
            if keyShift or keyRShift then
                transpose = 12
            end
            if (keyShift or keyRShift) and keyControl then
                transpose = 7
            end
            if key.name == "down" then
                transpose = transpose * -1
            end
            if #noteSelection > 0 and not keyAlt then
                transposeSelectedNotes(transpose, (keyControl or keyRControl) and not (keyShift or keyRShift))
                keyInfoText = "Transpose selected notes by " .. getSingularPlural(transpose, "semitone", "semitones", true)
                if (keyControl or keyRControl) and not (keyShift or keyRShift) then
                    keyInfoText = keyInfoText .. ", keep in scale"
                end
            else
                if keyAlt then
                    moveSelectionThroughNotes(0, transpose, keyShift)
                    if keyShift then
                        keyInfoText = "Add a note from above/below to selection"
                    else
                        keyInfoText = "Move note selection " .. key.name
                    end
                else
                    keyInfoText = "Move through the grid"
                    noteSlider.value = forceValueToRange(noteSlider.value + transpose, noteSlider.min, noteSlider.max)
                end
            end
        end
        handled = true
    end
    if (key.name == "left" or key.name == "right") then
        if key.state == "pressed" then
            local steps = 1
            if keyShift or keyRShift then
                steps = 4
            end
            if key.name == "left" then
                steps = steps * -1
            end
            if #noteSelection > 0 and not keyAlt then
                if keyControl then
                    steps = steps / math.abs(steps)
                    changeSizeSelectedNotes(steps, true)
                    keyInfoText = "Change note length of selected notes"
                else
                    moveSelectedNotes(steps)
                    keyInfoText = "Move selected notes by " .. getSingularPlural(steps, "step", "steps", true)
                end
            else
                if keyAlt then
                    if keyControl then
                        if isDelayColumnActive(true) then
                            moveSelectedNotesByMicroSteps(steps)
                        end
                        keyInfoText = "Move note selection by microsteps to the " .. key.name
                    else
                        moveSelectionThroughNotes(steps, 0, keyShift)
                        if keyShift then
                            keyInfoText = "Add a note from left/right to selection"
                        else
                            keyInfoText = "Move note selection to the " .. key.name
                        end
                    end
                else
                    keyInfoText = "Move edit cursor position"
                    local npos = renoise.SongPos()
                    npos.line = song.transport.edit_pos.line + steps
                    --move cursor
                    if npos.line >= 1 and npos.line <= song.selected_pattern.number_of_lines then
                        --do step sequencing
                        if not song.transport.playing and math.abs(steps) == 1 then
                            keyInfoText = keyInfoText .. ", do step sequencing ..."
                            stepSequencing(song.transport.edit_pos.line, steps)
                        end
                        --move
                        npos.sequence = song.transport.edit_pos.sequence
                        song.transport.edit_pos = npos
                        if npos.line > gridWidth + stepOffset or npos.line <= stepOffset then
                            if npos.line - gridWidth >= stepSlider.min then
                                stepSlider.value = npos.line - gridWidth
                            elseif npos.line <= stepOffset then
                                stepSlider.value = npos.line - 1
                            end
                        end
                    end
                end
            end
        end
        handled = true
    end
    --play selection
    if key.name == "space" and (key.modifiers == "control" or key.modifiers == "shift") and not key.repeated then
        if key.state == "pressed" then
            if lastEditPos then
                playPatternFromLine(lastEditPos + stepOffset)
            else
                playPatternFromLine(1)
            end
            keyInfoText = "Start song from cursor position"
        end
        handled = true
    end
    --loving tracker computer keyboard note playing <3 (returning it back to host is buggy, so do your own)
    if key.note then
        local row
        if not key.repeated and key.state == "released" and lastKeyboardNote[key.name] ~= nil then
            row = noteValue2GridRowOffset(lastKeyboardNote[key.name])
            triggerNoteOfCurrentInstrument(lastKeyboardNote[key.name], false)
            if row ~= nil then
                setKeyboardKeyColor(row, false, false)
                highlightNoteRow(row, false)
            end
            lastKeyboardNote[key.name] = nil
            if key.modifiers == "" then
                handled = true
            end
        elseif not key.repeated and key.state == "pressed" and key.modifiers == "" then
            local note = key.note + (12 * song.transport.octave)
            lastKeyboardNote[key.name] = note
            row = noteValue2GridRowOffset(lastKeyboardNote[key.name])
            triggerNoteOfCurrentInstrument(lastKeyboardNote[key.name], true)
            if row ~= nil then
                setKeyboardKeyColor(row, true, false)
                highlightNoteRow(row, true)
            end
            keyInfoText = "Play a note"
            handled = true
        end
    end

    if keyEvent.state == "pressed" then
        lastKeyInfoTime = nil
        local keystatetext = ""
        if keyEvent.modifiers ~= "" then
            keystatetext = keyEvent.modifiers
        end
        if not isModifierKey then
            if keystatetext ~= "" then
                keystatetext = keystatetext .. " + "
            end
            keystatetext = keystatetext .. keyEvent.name
            lastKeyInfoTime = os.clock()
            --save last key nmame, when modifier was used
            if keyEvent.modifiers ~= "" then
                lastKeyPress = keyEvent.name
            end
        end
        vbw["key_state"].text = string.upper(keystatetext)
        if keyInfoText then
            vbw["key_state"].text = vbw["key_state"].text .. "   ⵈ   " .. keyInfoText
        end
        if preferences.azertyMode.value then
            vbw["key_state"].text = vbw["key_state"].text .. " (AZERTY)"
        end
    elseif keyEvent.state == "released" then
        if lastKeyPress and not isModifierKey then
            --reset last key press, when release event was received
            lastKeyPress = nil
        end
        if not lastKeyInfoTime then
            vbw["key_state"].text = ""
        end
    end
    return handled
end

--handle scroll wheel value boxes
local function handleSrollWheel(number, id)
    if number > 0 then
        handleKeyEvent({ name = "scrollup" })
    elseif number < 0 then
        handleKeyEvent({ name = "scrolldown" })
    end
    vbw[id].value = 0
end

--just refresh selected notes, improves mouse actions
local function refreshSelectedNotes()
    local l_vbw = vbw
    local lineValues = song.selected_pattern_track.lines
    for key = 1, #noteSelection do
        if l_vbw["b" .. noteSelection[key].idx] then
            l_vbw["b" .. noteSelection[key].idx].visible = false
            l_vbw["bs" .. noteSelection[key].idx].visible = false
        end
        for i = 1, 0xf do
            if l_vbw["br" .. noteSelection[key].idx .. "_" .. i] then
                l_vbw["br" .. noteSelection[key].idx .. "_" .. i].visible = false
            else
                break
            end
        end
        local rowIndex = noteValue2GridRowOffset(noteSelection[key].note, true)
        noteSelection[key].idx = tostring(noteSelection[key].step) .. "_" .. tostring(rowIndex) .. "_" .. tostring(noteSelection[key].column)
        local noteString = lineValues[noteSelection[key].line]:note_column(noteSelection[key].column).note_string
        drawNoteToGrid(
                noteSelection[key].column,
                noteSelection[key].line,
                noteSelection[key].step,
                rowIndex,
                noteSelection[key].note,
                noteSelection[key].len,
                noteString,
                noteSelection[key].vel,
                noteSelection[key].end_vel,
                noteSelection[key].pan,
                noteSelection[key].dly,
                noteSelection[key].end_dly,
                noteSelection[key].noteoff,
                noteSelection[key].ghst
        )
    end
    refreshPianoRollNeeded = true
end

--handle xy pad events
local function handleXypad(val)
    local quickRefresh
    local forceFullRefresh
    --snap back
    if (val.x == 1.01234 or val.y == 1.01234) then
        if val.x == 1.01234 and val.y == 1.01234 and xypadpos.leftClick then
            xypadpos.leftClick = false
            drawRectangle(false)
        end
        return
    end
    if xypadpos.notemode then
        --mouse dragging and scaling
        local max = math.min(song.selected_pattern.number_of_lines, gridWidth) + 1
        if xypadpos.time > os.clock() - xypadpos.pickuptiming then
            xypadpos.x = val.x
            xypadpos.y = val.y
            if xypadpos.scalemode then
                xypadpos.distanceblock = true
            end
        elseif xypadpos.distanceblock then
            --some distance is needed
            if math.max(math.abs(xypadpos.x - val.x), math.abs(xypadpos.y - val.y)) > 0.69 then
                xypadpos.distanceblock = false
            end
        else
            --prevent moving and scaling outside the grid
            if val.x > max then
                val.x = max
            end
            --when scale mode is active, scale notes
            if xypadpos.scalemode then
                if #noteSelection == 1 and xypadpos.resetscale then
                    --when a new len will be drawn, then reset len to 1
                    changeSizeSelectedNotes(1)
                    --and remove delay
                    changePropertiesOfSelectedNotes(nil, nil, 0, 0, nil, "removecut")
                    --switch to scale mode, when note was resettet
                    xypadpos.scaling = true
                    xypadpos.resetscale = false
                end
                local v = 0
                local note_data = noteSelection[xypadpos.selection_key]
                if not note_data and noteSelection[1] then
                    note_data = noteSelection[1]
                end
                if note_data then
                    if keyAlt and isDelayColumnActive() then
                        v = math.floor((val.x - (xypadpos.nx + note_data.len + (note_data.end_dly / 0x100))) * 0x100)
                        --calculate snap
                        local delay = (note_data.end_dly + v) % 0x100
                        local len = math.floor((note_data.end_dly + v) / 0x100)
                        local scalesnapsize = math.floor(0x100 / 100 * preferences.snapToGridSize.value)
                        if delay > 0x100 - scalesnapsize then
                            v = v - delay + 0x100
                        elseif delay < scalesnapsize then
                            v = v - delay
                        end
                        --no scaling when target len < 1, then no scaling
                        if note_data.len + len < 1 then
                            v = 0
                        end
                    else
                        v = math.floor(math.floor((val.x - (xypadpos.nx + note_data.len)) * 0x100 - note_data.end_dly) / 0x100 + 0.5) * 0x100
                        if note_data.len + math.floor((note_data.end_dly + v) / 0x100) < 1 then
                            v = 0
                        end
                    end
                end
                if v ~= 0 then
                    blockLineModifier = true
                    quickRefresh = true
                    if changeSizeSelectedNotesByMicroSteps(v) then
                        xypadpos.scaling = true
                        xypadpos.resetscale = false
                    end
                end
            end
            --when move note is active, move notes
            if not xypadpos.scalemode then
                --scroll through, when note hits border
                if val.y == 1 and noteSlider.value > 0 then
                    noteSlider.value = forceValueToRange(noteSlider.value - 1, noteSlider.min, noteSlider.max)
                    xypadpos.y = xypadpos.y + 1
                    forceFullRefresh = true
                elseif val.y - 1 == gridHeight and noteSlider.value < noteSlider.max then
                    noteSlider.value = forceValueToRange(noteSlider.value + 1, noteSlider.min, noteSlider.max)
                    xypadpos.y = xypadpos.y - 1
                    forceFullRefresh = true
                end
                if val.x == 1 and stepSlider.value > 0 then
                    stepSlider.value = forceValueToRange(stepSlider.value - 1, stepSlider.min, stepSlider.max)
                    xypadpos.x = xypadpos.x + 1
                    xypadpos.lastx = xypadpos.lastx + 1
                    forceFullRefresh = true
                elseif val.x - 1 == gridWidth and stepSlider.value < stepSlider.max then
                    stepSlider.value = forceValueToRange(stepSlider.value + 1, stepSlider.min, stepSlider.max)
                    xypadpos.x = xypadpos.x - 1
                    xypadpos.lastx = xypadpos.lastx - 1
                    forceFullRefresh = true
                end
                if keyAlt and isDelayColumnActive(true) then
                    local v = math.floor((val.x - xypadpos.x) * 0x100)
                    if v ~= 0 then
                        blockLineModifier = true
                        quickRefresh = true
                        v = moveSelectedNotesByMicroSteps(v, keyShift)
                        if v ~= false then
                            xypadpos.x = xypadpos.x + (v / 0x100)
                        end
                    end
                else
                    xypadpos.x = math.floor(xypadpos.x)
                    xypadpos.y = math.floor(xypadpos.y)
                    if xypadpos.x - math.floor(val.x) > 0 and math.floor(val.x) ~= xypadpos.lastx then
                        if xypadpos.duplicate then
                            if keyControl and xypadpos.idx then
                                if noteInSelection(noteData[xypadpos.idx]) then
                                    noteSelection = {}
                                end
                                table.insert(noteSelection, noteData[xypadpos.idx])
                                xypadpos.idx = nil
                            end
                            duplicateSelectedNotes(0)
                            forceFullRefresh = true
                            xypadpos.duplicate = false
                        end
                        for d = math.abs(xypadpos.x - math.floor(val.x)), 1, -1 do
                            blockLineModifier = true
                            quickRefresh = true
                            if moveSelectedNotes(-d) then
                                xypadpos.x = xypadpos.x - d
                                break
                            end
                        end
                        xypadpos.lastx = math.floor(val.x)
                    elseif xypadpos.x - math.floor(val.x) < 0 and math.floor(val.x) ~= xypadpos.lastx then
                        if xypadpos.duplicate then
                            if keyControl and xypadpos.idx then
                                if noteInSelection(noteData[xypadpos.idx]) then
                                    noteSelection = {}
                                end
                                table.insert(noteSelection, noteData[xypadpos.idx])
                                xypadpos.idx = nil
                            end
                            duplicateSelectedNotes(0)
                            forceFullRefresh = true
                            xypadpos.duplicate = false
                        end
                        for d = math.abs(xypadpos.x - math.floor(val.x)), 1, -1 do
                            blockLineModifier = true
                            quickRefresh = true
                            if moveSelectedNotes(d) then
                                xypadpos.x = xypadpos.x + d
                                break
                            end
                        end
                        xypadpos.lastx = math.floor(val.x)
                    end
                end
                if math.floor(xypadpos.y) - math.floor(val.y + 0.1) > 0 then
                    if xypadpos.duplicate then
                        if keyControl and xypadpos.idx then
                            if noteInSelection(noteData[xypadpos.idx]) then
                                noteSelection = {}
                            end
                            table.insert(noteSelection, noteData[xypadpos.idx])
                            xypadpos.idx = nil
                        end
                        duplicateSelectedNotes(0)
                        forceFullRefresh = true
                        xypadpos.duplicate = false
                    end
                    for d = math.abs(math.floor(xypadpos.y) - math.floor(val.y + 0.1)), 1, -1 do
                        blockLineModifier = true
                        quickRefresh = true
                        if transposeSelectedNotes(-d) then
                            xypadpos.y = math.floor(xypadpos.y) - d
                            break
                        end
                    end
                elseif math.floor(xypadpos.y) - math.floor(val.y - 0.1) < 0 then
                    if xypadpos.duplicate then
                        if keyControl and xypadpos.idx then
                            if noteInSelection(noteData[xypadpos.idx]) then
                                noteSelection = {}
                            end
                            table.insert(noteSelection, noteData[xypadpos.idx])
                            xypadpos.idx = nil
                        end
                        duplicateSelectedNotes(0)
                        forceFullRefresh = true
                        xypadpos.duplicate = false
                    end
                    for d = math.abs(math.floor(xypadpos.y) - math.floor(val.y - 0.1)), 1, -1 do
                        blockLineModifier = true
                        quickRefresh = true
                        if transposeSelectedNotes(d) then
                            xypadpos.y = math.floor(xypadpos.y) + d
                            break
                        end
                    end
                end
            end
        end
    else
        --only process rectangle selection, when left mouse button is holded
        if xypadpos.leftClick then
            if xypadpos.x ~= math.floor(val.x) or xypadpos.y ~= math.floor(val.y) then
                xypadpos.x = math.floor(val.x)
                xypadpos.y = math.floor(val.y)
                drawRectangle(true, xypadpos.x, xypadpos.y, xypadpos.nx, xypadpos.ny)
                selectRectangle(xypadpos.x, xypadpos.y, xypadpos.nx, xypadpos.ny, keyShift)
            end
        end
    end
    if forceFullRefresh then
        blockLineModifier = false
        fillPianoRoll()
    elseif quickRefresh then
        --fillPianoRoll(quickRefresh)
        refreshSelectedNotes()
    end
end

--preferences window
local function showPreferences()
    local vbp = renoise.ViewBuilder()
    local vbwp = vbp.views
    local btn = app:show_custom_prompt("Preferences", vbp:row {
        uniform = true,
        margin = 5,
        spacing = 5,
        vbp:column {
            style = "group",
            margin = 5,
            uniform = true,
            spacing = 4,
            vbp:text {
                text = "Piano roll grid",
                font = "big",
                style = "strong",
            },
            vbp:row {
                vbp:text {
                    text = "Grid size:",
                },
                vbp:valuebox {
                    steps = { 1, 2 },
                    min = 16,
                    max = 256,
                    bind = preferences.gridWidth,
                    notifier = function()
                        rebuildWindowDialog = true
                    end
                },
                vbp:text { text = "x", align = "center", },
                vbp:valuebox {
                    steps = { 1, 2 },
                    min = 16,
                    max = 64,
                    bind = preferences.gridHeight,
                    notifier = function()
                        rebuildWindowDialog = true
                    end
                },
            },
            vbp:text {
                text = "Grid size settings takes effect,\nwhen the piano roll will be reopened.",
            },
            vbp:space { height = 8 },
            vbp:row {
                vbp:text {
                    text = "Min size of a note button (px):",
                },
                vbp:valuebox {
                    min = 2,
                    max = 16,
                    bind = preferences.minSizeOfNoteButton,
                    tostring = function(v)
                        return string.format("%i", v)
                    end,
                    tonumber = function(v)
                        return tonumber(v)
                    end
                },
            },
            vbp:row {
                vbp:text {
                    text = "Click area size for scaling (px):",
                },
                vbp:valuebox {
                    steps = { 1, 2 },
                    min = 6,
                    max = 15,
                    bind = preferences.clickAreaSizeForScalingPx,
                    tostring = function(v)
                        return string.format("%i", v)
                    end,
                    tonumber = function(v)
                        return tonumber(v)
                    end
                },
            },
            vbp:space { height = 8 },
            vbp:row {
                vbp:text {
                    text = "Shading amount of out of scale notes:",
                },
                vbp:valuebox {
                    steps = { 0.01, 0.1 },
                    min = 0,
                    max = 1,
                    bind = preferences.outOfNoteScaleShadingAmount,
                    tostring = function(v)
                        return string.format("%.2f", v)
                    end,
                    tonumber = function(v)
                        return tonumber(v)
                    end
                },
            },
            vbp:row {
                vbp:text {
                    text = "Shading amount of odd bars:",
                },
                vbp:valuebox {
                    steps = { 0.01, 0.1 },
                    min = 0,
                    max = 1,
                    bind = preferences.oddBarsShadingAmount,
                    tostring = function(v)
                        return string.format("%.2f", v)
                    end,
                    tonumber = function(v)
                        return tonumber(v)
                    end
                },
            },
            vbp:row {
                vbp:text {
                    text = "Shading amount for scale part of notes:",
                },
                vbp:valuebox {
                    steps = { 0.01, 0.1 },
                    min = 0,
                    max = 1,
                    bind = preferences.scaleBtnShadingAmount,
                    tostring = function(v)
                        return string.format("%.2f", v)
                    end,
                    tonumber = function(v)
                        return tonumber(v)
                    end
                },
            },
            vbp:row {
                vbp:text {
                    text = "Shading amount of root keys:",
                },
                vbp:valuebox {
                    steps = { 0.01, 0.1 },
                    min = 0,
                    max = 1,
                    bind = preferences.rootKeyShadingAmount,
                    tostring = function(v)
                        return string.format("%.2f", v)
                    end,
                    tonumber = function(v)
                        return tonumber(v)
                    end
                },
            },
            vbp:space { height = 8 },
            vbp:row {
                vbp:checkbox {
                    bind = preferences.applyVelocityColorShading
                },
                vbp:text {
                    text = "Shading note color according to velocity",
                },
            },
            vbp:row {
                vbp:text {
                    text = "Shading mode type:",
                },
                vbp:popup {
                    width = 110,
                    items = {
                        "Shading",
                        "Alpha blending",
                    },
                    bind = preferences.shadingType,
                },
            },
            vbp:row {
                vbp:text {
                    text = "Shading / alpha blending amount:",
                },
                vbp:valuebox {
                    steps = { 0.01, 0.1 },
                    min = 0,
                    max = 1,
                    bind = preferences.velocityColorShadingAmount,
                    tostring = function(v)
                        return string.format("%.2f", v)
                    end,
                    tonumber = function(v)
                        return tonumber(v)
                    end
                },
            },
            vbp:space { height = 8 },
            vbp:row {
                vbp:checkbox {
                    bind = preferences.highlightEntireLineOfPlayingNote
                },
                vbp:text {
                    text = "Highlight the entire row of a playing note (slow)",
                },
            },
            vbp:row {
                vbp:text {
                    text = "Highlighting amount:",
                },
                vbp:valuebox {
                    steps = { 0.01, 0.1 },
                    min = 0,
                    max = 1,
                    bind = preferences.rowHighlightingAmount,
                    tostring = function(v)
                        return string.format("%.2f", v)
                    end,
                    tonumber = function(v)
                        return tonumber(v)
                    end
                },
            },
            vbp:space { height = 8 },
            vbp:row {
                uniform = true,
                vbp:text {
                    text = "Scale highlighting:",
                },
                vbp:popup {
                    width = 110,
                    items = scaleTypes,
                    bind = preferences.scaleHighlightingType,
                },
            },
            vbp:row {
                vbp:text {
                    text = "Key for selected scale:",
                    width = "50%"
                },
                vbp:popup {
                    items = notesTable,
                    bind = preferences.keyForSelectedScale,
                },
            },
            vbp:row {
                vbp:text {
                    text = "Keyboard style:",
                    width = "50%"
                },
                vbp:popup {
                    items = {
                        "Flat",
                        "List",
                    },
                    bind = preferences.keyboardStyle,
                },
            },
            vbp:row {
                vbp:text {
                    text = "Key labels:",
                    width = "50%"
                },
                vbp:popup {
                    items = {
                        "None",
                        "Root notes",
                        "In scale",
                        "All notes",
                    },
                    bind = preferences.keyLabels,
                },
            },
        },
        vbp:column {
            style = "group",
            margin = 5,
            uniform = true,
            spacing = 4,
            vbp:text {
                text = "Color settings",
                font = "big",
                style = "strong",
            },
            vbp:row {
                vbp:checkbox {
                    bind = preferences.useTrackColorForNoteHighlighting
                },
                vbp:text {
                    text = "Use track color for note highlighting",
                },
            },
            vbp:row {
                vbp:checkbox {
                    bind = preferences.useTrackColorForNoteColor
                },
                vbp:text {
                    text = "Use track color for note color",
                },
            },
            vbp:row {
                vbp:text {
                    text = "Base grid:",
                    width = 104,
                    align = "right",
                },
                vbp:textfield {
                    id = "colorBaseGridColorField",
                    bind = preferences.colorBaseGridColor,
                    notifier = function()
                        initColors()
                        vbwp.colorBaseGridColor.color = colorBaseGridColor
                        vbwp.colorBaseGridColorField.value = convertColorValueToString(colorBaseGridColor)
                    end
                },
                vbp:button {
                    id = "colorBaseGridColor",
                    color = colorBaseGridColor,
                }
            },
            vbp:row {
                vbp:text {
                    text = "Ghost track note:",
                    width = 104,
                    align = "right",
                },
                vbp:textfield {
                    id = "colorGhostTrackNoteField",
                    bind = preferences.colorGhostTrackNote,
                    notifier = function()
                        initColors()
                        vbwp.colorGhostTrackNote.color = colorGhostTrackNote
                        vbwp.colorGhostTrackNoteField.value = convertColorValueToString(colorGhostTrackNote)
                    end
                },
                vbp:button {
                    id = "colorGhostTrackNote",
                    color = colorGhostTrackNote,
                }
            },
            vbp:row {
                vbp:text {
                    text = "Note:",
                    width = 104,
                    align = "right",
                },
                vbp:textfield {
                    id = "colorNoteField",
                    bind = preferences.colorNote,
                    notifier = function()
                        initColors()
                        vbwp.colorNote.color = colorNote
                        vbwp.colorNoteField.value = convertColorValueToString(colorNote)
                    end
                },
                vbp:button {
                    id = "colorNote",
                    color = colorNote,
                }
            },
            vbp:row {
                vbp:text {
                    text = "Ghost note:",
                    width = 104,
                    align = "right",
                },
                vbp:textfield {
                    id = "colorNoteGhostField",
                    bind = preferences.colorNoteGhost,
                    notifier = function()
                        initColors()
                        vbwp.colorNoteGhost.color = colorNoteGhost
                        vbwp.colorNoteGhostField.value = convertColorValueToString(colorNoteGhost)
                    end
                },
                vbp:button {
                    id = "colorNoteGhost",
                    color = colorNoteGhost,
                }
            },
            vbp:row {
                vbp:text {
                    text = "Highlighting note:",
                    width = 104,
                    align = "right",
                },
                vbp:textfield {
                    id = "colorNoteHighlightField",
                    bind = preferences.colorNoteHighlight,
                    notifier = function()
                        initColors()
                        vbwp.colorNoteHighlight.color = colorNoteHighlight
                        vbwp.colorNoteHighlightField.value = convertColorValueToString(colorNoteHighlight)
                    end
                },
                vbp:button {
                    id = "colorNoteHighlight",
                    color = colorNoteHighlight,
                }
            },
            vbp:row {
                vbp:text {
                    text = "Muted note:",
                    width = 104,
                    align = "right",
                },
                vbp:textfield {
                    id = "colorNoteMutedField",
                    bind = preferences.colorNoteMuted,
                    notifier = function()
                        initColors()
                        vbwp.colorNoteMuted.color = colorNoteMuted
                        vbwp.colorNoteMutedField.value = convertColorValueToString(colorNoteMuted)
                    end
                },
                vbp:button {
                    id = "colorNoteMuted",
                    color = colorNoteMuted,
                }
            },
            vbp:row {
                vbp:text {
                    text = "Selected note:",
                    width = 104,
                    align = "right",
                },
                vbp:textfield {
                    id = "colorNoteSelectedField",
                    bind = preferences.colorNoteSelected,
                    notifier = function()
                        initColors()
                        vbwp.colorNoteSelected.color = colorNoteSelected
                        vbwp.colorNoteSelectedField.value = convertColorValueToString(colorNoteSelected)
                    end
                },
                vbp:button {
                    id = "colorNoteSelected",
                    color = colorNoteSelected,
                }
            },
            vbp:row {
                vbp:text {
                    text = "Step on / Active btn:",
                    width = 104,
                    align = "right",
                },
                vbp:textfield {
                    id = "colorStepOnField",
                    bind = preferences.colorStepOn,
                    notifier = function()
                        initColors()
                        vbwp.colorStepOn.color = colorStepOn
                        vbwp.colorStepOnField.value = convertColorValueToString(colorStepOn)
                    end
                },
                vbp:button {
                    id = "colorStepOn",
                    color = colorStepOn,
                }
            },
            vbp:row {
                vbp:text {
                    text = "Step off:",
                    width = 104,
                    align = "right",
                },
                vbp:textfield {
                    id = "colorStepOffField",
                    bind = preferences.colorStepOff,
                    notifier = function()
                        initColors()
                        vbwp.colorStepOff.color = colorStepOff
                        vbwp.colorStepOffField.value = convertColorValueToString(colorStepOff)
                    end
                },
                vbp:button {
                    id = "colorStepOff",
                    color = colorStepOff,
                }
            },
            vbp:row {
                vbp:text {
                    text = "Keyboard list:",
                    width = 104,
                    align = "right",
                },
                vbp:textfield {
                    id = "colorListField",
                    bind = preferences.colorList,
                    notifier = function()
                        initColors()
                        vbwp.colorList.color = colorList
                        vbwp.colorListField.value = convertColorValueToString(colorList)
                    end
                },
                vbp:button {
                    id = "colorList",
                    color = colorList,
                }
            },
            vbp:row {
                vbp:text {
                    text = "Keyboard white key:",
                    width = 104,
                    align = "right",
                },
                vbp:textfield {
                    id = "colorKeyWhiteField",
                    bind = preferences.colorKeyWhite,
                    notifier = function()
                        initColors()
                        vbwp.colorKeyWhite.color = colorKeyWhite
                        vbwp.colorKeyWhiteField.value = convertColorValueToString(colorKeyWhite)
                    end
                },
                vbp:button {
                    id = "colorKeyWhite",
                    color = colorKeyWhite,
                }
            },
            vbp:row {
                vbp:text {
                    text = "Keyboard black key:",
                    width = 104,
                    align = "right",
                },
                vbp:textfield {
                    id = "colorKeyBlackField",
                    bind = preferences.colorKeyBlack,
                    notifier = function()
                        initColors()
                        vbwp.colorKeyBlack.color = colorKeyBlack
                        vbwp.colorKeyBlackField.value = convertColorValueToString(colorKeyBlack)
                    end
                },
                vbp:button {
                    id = "colorKeyBlack",
                    color = colorKeyBlack,
                }
            },
            vbp:row {
                vbp:text {
                    text = "Vol button:",
                    width = 104,
                    align = "right",
                },
                vbp:textfield {
                    id = "colorVelocityField",
                    bind = preferences.colorVelocity,
                    notifier = function()
                        initColors()
                        vbwp.colorVelocity.color = colorVelocity
                        vbwp.colorVelocityField.value = convertColorValueToString(colorVelocity)
                    end
                },
                vbp:button {
                    id = "colorVelocity",
                    color = colorVelocity,
                }
            },
            vbp:row {
                vbp:text {
                    text = "Pan button:",
                    width = 104,
                    align = "right",
                },
                vbp:textfield {
                    id = "colorPanField",
                    bind = preferences.colorPan,
                    notifier = function()
                        initColors()
                        vbwp.colorPan.color = colorPan
                        vbwp.colorPanField.value = convertColorValueToString(colorPan)
                    end
                },
                vbp:button {
                    id = "colorPan",
                    color = colorPan,
                }
            },
            vbp:row {
                vbp:text {
                    text = "Dly button:",
                    width = 104,
                    align = "right",
                },
                vbp:textfield {
                    id = "colorDelayField",
                    bind = preferences.colorDelay,
                    notifier = function()
                        initColors()
                        vbwp.colorDelay.color = colorDelay
                        vbwp.colorDelayField.value = convertColorValueToString(colorDelay)
                    end
                },
                vbp:button {
                    id = "colorDelay",
                    color = colorDelay,
                }
            },
            vbp:text {
                text = "IMPORTANT: Please note that color #000000\n" ..
                        "will use the default control theme color. It's a\n" ..
                        "Renoise Viewbuilder restriction, which can't be\n" .. "changed, yet."
            },
        },
        vbp:column {
            style = "group",
            margin = 5,
            uniform = true,
            spacing = 4,
            vbp:text {
                text = "Note playback and preview",
                font = "big",
                style = "strong",
            },
            vbp:row {
                vbp:checkbox {
                    bind = preferences.enableOSCClient
                },
                vbp:text {
                    text = "Enable OSC client",
                },
            },
            vbp:row {
                vbp:checkbox {
                    bind = preferences.notePreview
                },
                vbp:text {
                    text = "Enable note preview",
                },
            },
            vbp:row {
                vbp:checkbox {
                    bind = preferences.noNotePreviewDuringSongPlayback,
                },
                vbp:text {
                    text = "No note preview during song playback",
                },
            },
            vbp:row {
                vbp:text {
                    text = "Note preview polyphony:",
                },
                vbp:valuebox {
                    steps = { 1, 2 },
                    min = 1,
                    max = 32,
                    bind = preferences.previewPolyphony,
                },
            },
            vbp:row {
                vbp:checkbox {
                    bind = preferences.limitPreviewBySelectionSize,
                },
                vbp:text {
                    text = "Reduce preview polyphony to selection size",
                },
            },
            vbp:row {
                vbp:text {
                    text = "Note preview length (ms):",
                },
                vbp:valuebox {
                    steps = { 1, 2 },
                    min = 50,
                    max = 2000,
                    bind = preferences.triggerTime,
                },
            },
            vbp:text {
                text = "OSC connection string: [protocol]://[ip]:[port]",
            },
            vbp:textfield {
                bind = preferences.oscConnectionString,
            },
            vbp:text {
                text = "Please check in the Renoise preferences in the OSC\n" ..
                        "section that the OSC server has been activated and is\n" ..
                        "running with the same protocol (UDP, TCP) and port\n" ..
                        "settings as specified here."
            },
        },
        vbp:column {
            style = "group",
            margin = 5,
            uniform = true,
            spacing = 4,
            vbp:text {
                text = "Misc",
                font = "big",
                style = "strong",
            },
            vbp:row {
                vbp:text {
                    text = "Max double click time (ms):",
                },
                vbp:valuebox {
                    steps = { 1, 2 },
                    min = 50,
                    max = 2000,
                    bind = preferences.dblClickTime,
                },
            },
            vbp:row {
                vbp:text {
                    text = "Scroll wheel speed (lines):",
                },
                vbp:valuebox {
                    steps = { 1, 2 },
                    min = 1,
                    max = 6,
                    bind = preferences.scrollWheelSpeed,
                    tostring = function(v)
                        return string.format("%i", v)
                    end,
                    tonumber = function(v)
                        return tonumber(v)
                    end
                },
            },
            vbp:row {
                vbp:text {
                    text = "Snap to grid amount for scaling (%):",
                },
                vbp:valuebox {
                    steps = { 1, 2 },
                    min = 0,
                    max = 50,
                    bind = preferences.snapToGridSize,
                    tostring = function(v)
                        return string.format("%i", v)
                    end,
                    tonumber = function(v)
                        return tonumber(v)
                    end
                },
            },
            vbp:row {
                vbp:checkbox {
                    bind = preferences.forcePenMode,
                },
                vbp:text {
                    text = "Enable pen mode by default",
                },
            },
            vbp:row {
                vbp:checkbox {
                    bind = preferences.chordDetection,
                },
                vbp:text {
                    text = "Enable chord detection for playing and selected notes",
                },
            },
            vbp:row {
                vbp:checkbox {
                    bind = preferences.setVelPanDlyLenFromLastNote,
                },
                vbp:text {
                    text = "Set vel, pan, dly and len from last drawn or selected note",
                },
            },
            vbp:row {
                vbp:checkbox {
                    bind = preferences.resetVolPanDlyControlOnClick,
                },
                vbp:text {
                    text = "Reset vol, pan and dly on grid click, when nothing is selected",
                },
            },
            vbp:row {
                vbp:checkbox {
                    bind = preferences.followPlayCursor,
                },
                vbp:text {
                    text = "Follow play cursor, when enabled in Renoise",
                },
            },
            vbp:row {
                vbp:checkbox {
                    bind = preferences.centerViewOnOpen,
                },
                vbp:text {
                    text = "Center piano roll when opening based on pattern notes",
                },
            },
            vbp:row {
                vbp:checkbox {
                    bind = preferences.addNoteColumnsIfNeeded,
                },
                vbp:text {
                    text = "Automatically add note columns, when needed",
                },
            },
            vbp:row {
                vbp:checkbox {
                    bind = preferences.addNoteOffToEmptyNoteColumns,
                },
                vbp:text {
                    text = "Automatically add Note-Off in empty note columns",
                },
            },
            vbp:row {
                vbp:checkbox {
                    bind = preferences.autoEnableDelayWhenNeeded,
                },
                vbp:text {
                    text = "Automatically enable delay column, when needed",
                },
            },
            vbp:row {
                vbp:checkbox {
                    bind = preferences.setLastEditedTrackAsGhost,
                },
                vbp:text {
                    text = "Automatically set the last edited track as ghost track",
                },
            },
            vbp:row {
                vbp:checkbox {
                    bind = preferences.disableAltClickNoteRemove,
                },
                vbp:text {
                    text = "Disable alt key click note remove",
                },
            },
            vbp:row {
                vbp:checkbox {
                    bind = preferences.azertyMode,
                },
                vbp:text {
                    text = "Enable AZERTY keyboard mode",
                },
            },
            vbp:row {
                vbp:checkbox {
                    bind = preferences.disableKeyHandler,
                },
                vbp:text {
                    text = "Disable all keyboard shortcuts",
                },
            },
            vbp:row {
                vbp:checkbox {
                    bind = preferences.enableKeyInfo,
                },
                vbp:text {
                    text = "Show current pressed keyboard keys in the status bar",
                },
            },
            vbp:row {
                vbp:text {
                    text = "Max display time of status bar text (s):",
                },
                vbp:valuebox {
                    steps = { 1, 2 },
                    min = 1,
                    max = 10,
                    bind = preferences.keyInfoTime,
                    tostring = function(v)
                        return string.format("%i", v)
                    end,
                    tonumber = function(v)
                        return tonumber(v)
                    end
                },
            },
            vbp:text {
                text = "IMPORTANT: To improve mouse control, please disable\nthe mouse warping option in the Renoise preferences\nin section GUI."
            },
        },
    }, { "Close", "Reset to default", "Help / Feedback" })
    if btn == "Reset to default" then
        if app:show_prompt("Reset to default", "Are you sure you want to reset all settings to their default values?", { "Yes", "No" }) == "Yes" then
            for key in pairs(defaultPreferences) do
                preferences[key].value = defaultPreferences[key]
            end
            app:show_message("All preferences was set to default values.")
        end
    end
    if btn == "Help / Feedback" then
        app:open_url("https://forum.renoise.com/t/simple-pianoroll-com-duftetools-simplepianoroll-xrnx/63034")
    end
    if oscClient then
        oscClient:close()
        oscClient = nil
    end
    refreshControls = true
    refreshPianoRollNeeded = true
    --apply new highlighting colors
    initColors()
end

--create main piano roll dialog
local function createPianoRollDialog()
    local vb_temp
    local playCursor = vb:row {
        margin = -gridMargin,
        spacing = -gridSpacing,
    }
    for x = 1, gridWidth do
        local temp = "setPlaybackPos(" .. tostring(x) .. ")"
        vb_temp = vb:row {
            vb:space {
                width = 2
            },
            vb:row {
                spacing = -(gridStepSizeW - 4),
                vb:button {
                    id = "se" .. tostring(x),
                    height = 13,
                    width = gridStepSizeW - 4,
                    color = colorStepOn,
                    active = false,
                    visible = false,
                },
                vb:column {
                    vb:space {
                        height = 2,
                    },
                    vb:button {
                        id = "s" .. tostring(x),
                        height = 9,
                        width = gridStepSizeW - 4,
                        color = colorStepOff,
                        active = false,
                        notifier = loadstring(temp),
                    },
                },
                vb:space {
                    height = 13,
                },
            },
            vb:space {
                width = 2
            },
        }
        playCursor:add_child(vb_temp)
    end
    local pianorollColumns = vb:column {
        margin = 0,
        spacing = -1,
    }

    for y = gridHeight, 1, -1 do
        local grow = vb:column {
            id = "row" .. tostring(y),
            spacing = -(gridStepSizeH - gridSpacing + 2)
        }
        local row = vb:row {
            margin = -gridMargin,
            spacing = -gridSpacing,
        }
        for x = 1, gridWidth do
            local temp = "pianoGridClick(" .. tostring(x) .. "," .. tostring(y) .. ",true)"
            local temp2 = "pianoGridClick(" .. tostring(x) .. "," .. tostring(y) .. ",false)"
            vb_temp = vb:row {
                id = "ppp" .. tostring(x) .. "_" .. tostring(y),
                vb:button {
                    id = "p" .. tostring(x) .. "_" .. tostring(y),
                    height = gridStepSizeH,
                    width = gridStepSizeW,
                    color = colorWhiteKey[1],
                    notifier = loadstring(temp),
                    pressed = loadstring(temp2)
                }
            }
            row:add_child(vb_temp)
            --dummy for quirk?
            vb_temp = vb:button {
                id = "dummy" .. tostring(x) .. "_" .. tostring(y),
                height = gridStepSizeH,
                width = gridStepSizeW,
                visible = false,
                color = colorNote,
            }
            row:add_child(vb_temp)
        end
        grow:add_child(row)
        pianorollColumns:add_child(grow)
    end

    --horizontal scrollbar
    stepSlider = vb:minislider {
        width = gridStepSizeW * gridWidth - (gridSpacing * (gridWidth)),
        height = math.max(16, gridStepSizeW / 2),
        min = 0,
        max = 0,
        visible = false,
        notifier = function(number)
            number = math.floor(number)
            if number ~= stepOffset then
                stepOffset = number
                refreshPianoRollNeeded = true
                refreshTimeline = true
            end
        end,
    }

    --vertical scrollbar
    noteSlider = vb:minislider {
        width = math.max(16, gridStepSizeW / 2),
        height = "100%",
        min = 0,
        max = 120 - gridHeight,
        notifier = function(number)
            number = math.floor(number)
            if number ~= noteOffset then
                noteOffset = number
                refreshPianoRollNeeded = true
            end
        end,
        value = noteOffset
    }

    local whiteKeys = vb:column {
        margin = 0,
        spacing = -1,
    }
    for y = gridHeight, 1, -1 do
        whiteKeys:add_child(
                vb:row {
                    margin = -gridMargin,
                    spacing = -gridSpacing,
                    vb:button {
                        id = "k" .. tostring(y),
                        height = gridStepSizeH,
                        width = pianoKeyWidth,
                        color = { 255, 255, 255 },
                        pressed = loadstring("keyClick(" .. y .. ",true)"),
                        released = loadstring("keyClick(" .. y .. ",false)"),
                        visible = true,
                    },
                    vb:space {
                        width = 5,
                    },
                    vb:button {
                        id = "ks" .. tostring(y),
                        height = gridStepSizeH,
                        width = 6,
                        visible = false,
                        active = false,
                    },
                    vb:space {
                        id = "kss" .. tostring(y),
                        width = 6,
                        visible = false,
                    },
                }
        )
    end

    local timeline = vb:row {
        style = "plain",
        width = gridStepSizeW * gridWidth - (gridSpacing * (gridWidth)) + 6,
        spacing = -(gridStepSizeW * gridWidth - (gridSpacing * (gridWidth)) + 6),
    }
    timeline:add_child(vb:space {
        width = gridStepSizeW * gridWidth - (gridSpacing * (gridWidth)) + 6,
    })
    local timeline_row = vb:row {}
    for i = 1, gridWidth do
        local temp = vb:text {
            id = "timeline" .. i,
            visible = false,
        }
        timeline_row:add_child(temp)
    end
    timeline:add_child(timeline_row)

    --another quirk, instead of using jsut one valuebox, i need a valuebox for each column
    --its alot faster scrolling without stuttering, it seems a big valuebox slows down the rendering
    local scrollwheelgrid = vb:row {
        style = "plain",
        spacing = -gridSpacing,
    }
    for i = 1, gridWidth do
        local temp = vb:valuebox {
            id = "sw" .. i,
            width = gridStepSizeW,
            height = (gridStepSizeH - 2.9) * (gridHeight + 1),
            min = -1,
            max = 1,
            notifier = function(number)
                handleSrollWheel(number, "sw" .. i)
            end,
        }
        scrollwheelgrid:add_child(temp)
    end

    windowContent = vb:column {
        vb:row {
            margin = 3,
            spacing = -1,
            vb:row {
                margin = 3,
                spacing = -3,
                style = "panel",
                vb:button {
                    id = "playbutton",
                    bitmap = "Icons/Transport_Play.bmp",
                    width = 24,
                    tooltip = "Start playing song or pattern",
                    notifier = function()
                        song.transport:start(renoise.Transport.PLAYMODE_RESTART_PATTERN)
                    end
                },
                vb:button {
                    id = "loopbutton",
                    bitmap = "Icons/Transport_LoopPattern.bmp",
                    width = 24,
                    tooltip = "Loop current pattern",
                    notifier = function()
                        song.transport.loop_pattern = not song.transport.loop_pattern
                    end
                },
                vb:button {
                    bitmap = "Icons/Transport_Stop.bmp",
                    width = 24,
                    tooltip = "Stop playing",
                    notifier = function()
                        song.transport:stop()
                        notesPlaying = {}
                        notesPlayingLine = {}
                        refreshChordDetection = true
                        refreshPianoRollNeeded = true
                    end
                },
            },
            vb:row {
                margin = 3,
                spacing = -3,
                style = "panel",
                vb:button {
                    text = "↖",
                    width = 24,
                    tooltip = "Select mode (F1)",
                    id = "mode_select",
                    notifier = function()
                        penMode = false
                        audioPreviewMode = false
                        refreshControls = true
                    end,
                },
                vb:button {
                    bitmap = "Icons/SampleEd_DrawTool.bmp",
                    width = 24,
                    tooltip = "Pen mode (F2)",
                    id = "mode_pen",
                    notifier = function()
                        penMode = true
                        audioPreviewMode = false
                        refreshControls = true
                    end,
                },
                vb:button {
                    bitmap = "Icons/Browser_AudioFile.bmp",
                    width = 24,
                    tooltip = "Audio preview mode (F3)",
                    id = "mode_audiopreview",
                    notifier = function()
                        audioPreviewMode = true
                        penMode = false
                        refreshControls = true
                    end,
                },
            },
            vb:row {
                margin = 3,
                spacing = 3,
                style = "panel",
                vb:text {
                    text = "Len:",
                },
                vb:valuebox {
                    id = "note_len",
                    tooltip = "Note length",
                    steps = { 1, 2 },
                    min = 1,
                    max = 256,
                    value = currentNoteLength,
                    notifier = function(number)
                        if #noteSelection > 0 and currentNoteLength ~= number then
                            changeSizeSelectedNotes(number)
                        end
                        currentNoteLength = number
                        refreshControls = true
                    end,
                    tonumber = function(string)
                        local lpb = song.transport.lpb
                        if string == "bar" then
                            return lpb * 4
                        elseif string == "beat" then
                            return lpb
                        end
                        return tonumber(string)
                    end,
                    tostring = function(number)
                        return tostring(number)
                    end
                },
                vb:button {
                    text = ":2",
                    tooltip = "Halve current note length number",
                    notifier = function()
                        if #noteSelection > 0 then
                            scaleNoteSelection(0.5)
                        end
                        currentNoteLength = math.max(math.floor(currentNoteLength / 2), 1)
                        refreshControls = true
                    end,
                },
                vb:button {
                    text = "*2",
                    tooltip = "Double current note length number",
                    notifier = function()
                        if #noteSelection > 0 then
                            scaleNoteSelection(2)
                        end
                        currentNoteLength = math.min(math.floor(currentNoteLength * 2), 256)
                        refreshControls = true
                    end,
                },
            },
            vb:row {
                margin = 3,
                spacing = 3,
                style = "panel",
                vb:button {
                    id = "notecolumn_vel",
                    --text = "Vol",
                    bitmap = "Icons/Transport_ViewVolumeColumn.bmp",
                    width = 24,
                    tooltip = "Enable / disable note volume column",
                    notifier = function()
                        if song.selected_track.volume_column_visible then
                            song.selected_track.volume_column_visible = false
                        else
                            song.selected_track.volume_column_visible = true
                        end
                        refreshPianoRollNeeded = true
                    end
                },
                vb:valuebox {
                    id = "note_vel",
                    tooltip = "Note velocity",
                    steps = { 1, 2 },
                    min = -1,
                    max = 575,
                    value = -1,
                    width = 54,
                    tostring = function(number)
                        if number == -1 then
                            return "--"
                        end
                        return toRenoiseHex(number)
                    end,
                    tonumber = function(string)
                        if string == "--" then
                            return -1
                        end
                        return fromRenoiseHex(string)
                    end,
                    notifier = function(number)
                        if number == -1 then
                            currentNoteVelocity = 255
                        else
                            currentNoteVelocity = number
                        end
                        if #noteSelection > 0 and not refreshControls then
                            changePropertiesOfSelectedNotes(currentNoteVelocity)
                        end
                        refreshControls = true
                    end,
                },
                vb:button {
                    id = "note_vel_clear",
                    text = "C",
                    tooltip = "Clear note velocity\n(While holding shift: Clear both velocity values)",
                    notifier = function()
                        currentNoteVelocity = 255
                        if #noteSelection > 0 then
                            changePropertiesOfSelectedNotes(currentNoteVelocity)
                            if keyShift then
                                currentNoteEndVelocity = 255
                                changePropertiesOfSelectedNotes(nil, currentNoteEndVelocity)
                            end
                        end
                        refreshControls = true
                    end,
                },
                vb:button {
                    id = "note_vel_humanize",
                    text = "H",
                    tooltip = "Humanize note velocity of selected notes",
                    notifier = function()
                        if #noteSelection > 0 then
                            changePropertiesOfSelectedNotes("h")
                        end
                    end,
                },
                vb:valuebox {
                    id = "note_end_vel",
                    tooltip = "End note velocity",
                    steps = { 1, 2 },
                    min = -1,
                    max = 575,
                    value = -1,
                    width = 54,
                    tostring = function(number)
                        if number == -1 then
                            return "--"
                        end
                        return toRenoiseHex(number)
                    end,
                    tonumber = function(string)
                        if string == "--" then
                            return -1
                        end
                        return fromRenoiseHex(string)
                    end,
                    notifier = function(number)
                        if number == -1 then
                            currentNoteEndVelocity = 255
                        else
                            currentNoteEndVelocity = number
                        end
                        if #noteSelection > 0 and not refreshControls then
                            changePropertiesOfSelectedNotes(nil, currentNoteEndVelocity)
                        end
                        refreshControls = true
                    end,
                },
                vb:button {
                    id = "note_end_vel_clear",
                    text = "C",
                    tooltip = "Clear end note velocity",
                    notifier = function()
                        currentNoteEndVelocity = 255
                        if #noteSelection > 0 then
                            changePropertiesOfSelectedNotes(nil, currentNoteEndVelocity)
                        end
                        refreshControls = true
                    end,
                },
                vb:button {
                    id = "notecolumn_pan",
                    --text = "Pan",
                    bitmap = "Icons/Transport_ViewPanColumn.bmp",
                    width = 24,
                    tooltip = "Enable / disable note pan column",
                    notifier = function()
                        if song.selected_track.panning_column_visible then
                            song.selected_track.panning_column_visible = false
                        else
                            song.selected_track.panning_column_visible = true
                        end
                        refreshPianoRollNeeded = true
                    end
                },
                vb:valuebox {
                    id = "note_pan",
                    tooltip = "Note panning",
                    steps = { 1, 2 },
                    min = -1,
                    max = 575,
                    value = -1,
                    width = 54,
                    tostring = function(number)
                        if number == -1 then
                            return "--"
                        end
                        return toRenoiseHex(number)
                    end,
                    tonumber = function(string)
                        if string == "--" then
                            return -1
                        end
                        return fromRenoiseHex(string)
                    end,
                    notifier = function(number)
                        if number == -1 then
                            currentNotePan = 255
                        else
                            currentNotePan = number
                        end
                        if #noteSelection > 0 and not refreshControls then
                            changePropertiesOfSelectedNotes(nil, nil, nil, nil, currentNotePan)
                        end
                        refreshControls = true
                    end,
                },
                vb:button {
                    id = "note_pan_clear",
                    text = "C",
                    tooltip = "Clear note panning",
                    notifier = function()
                        currentNotePan = 255
                        changePropertiesOfSelectedNotes(nil, nil, nil, nil, currentNotePan)
                        refreshControls = true
                        refreshPianoRollNeeded = true
                    end,
                },
                vb:button {
                    id = "note_pan_humanize",
                    text = "H",
                    tooltip = "Humanize note panning of selected notes",
                    notifier = function()
                        if #noteSelection > 0 then
                            changePropertiesOfSelectedNotes(nil, nil, nil, nil, "h")
                        end
                    end,
                },
                vb:button {
                    id = "notecolumn_delay",
                    --text = "Dly",
                    bitmap = "Icons/Transport_ViewDelayColumn.bmp",
                    width = 24,
                    tooltip = "Enable / disable note delay column",
                    notifier = function()
                        if song.selected_track.delay_column_visible then
                            song.selected_track.delay_column_visible = false
                        else
                            song.selected_track.delay_column_visible = true
                        end
                        refreshPianoRollNeeded = true
                    end,
                },
                vb:valuebox {
                    id = "note_dly",
                    tooltip = "Note delay",
                    steps = { 1, 2 },
                    min = 0,
                    max = 255,
                    width = 54,
                    value = currentNoteDelay,
                    tostring = function(number)
                        if number == 0 then
                            return "--"
                        end
                        return toRenoiseHex(number)
                    end,
                    tonumber = function(string)
                        if string == "--" then
                            return 0
                        end
                        return fromRenoiseHex(string)
                    end,
                    notifier = function(number)
                        currentNoteDelay = number
                        if #noteSelection > 0 and not refreshControls then
                            changePropertiesOfSelectedNotes(nil, nil, currentNoteDelay)
                        end
                        refreshControls = true
                    end,
                },
                vb:button {
                    id = "note_dly_clear",
                    text = "C",
                    tooltip = "Clear note delay\n(While holding shift: Clear both delay values)",
                    notifier = function()
                        currentNoteDelay = 0
                        changePropertiesOfSelectedNotes(nil, nil, currentNoteDelay)
                        if keyShift then
                            currentNoteEndDelay = 0
                            changePropertiesOfSelectedNotes(nil, nil, nil, currentNoteEndDelay)
                        end
                        refreshControls = true
                        refreshPianoRollNeeded = true
                    end,
                },
                vb:button {
                    id = "note_dly_humanize",
                    text = "H",
                    tooltip = "Humanize note delay of selected notes",
                    notifier = function()
                        if #noteSelection > 0 then
                            changePropertiesOfSelectedNotes(nil, nil, "h")
                        end
                    end,
                },
                vb:valuebox {
                    id = "note_end_dly",
                    tooltip = "Note delay for note off",
                    steps = { 1, 2 },
                    min = 0,
                    max = 255,
                    width = 54,
                    value = currentNoteEndDelay,
                    tostring = function(number)
                        if number == 0 then
                            return "--"
                        end
                        return toRenoiseHex(number)
                    end,
                    tonumber = function(string)
                        if string == "--" then
                            return 0
                        end
                        return fromRenoiseHex(string)
                    end,
                    notifier = function(number)
                        currentNoteEndDelay = number
                        if #noteSelection > 0 and not refreshControls then
                            changePropertiesOfSelectedNotes(nil, nil, nil, currentNoteEndDelay)
                        end
                        refreshControls = true
                    end,
                },
                vb:button {
                    id = "note_end_dly_clear",
                    text = "C",
                    tooltip = "Clear note delay",
                    notifier = function()
                        currentNoteEndDelay = 0
                        changePropertiesOfSelectedNotes(nil, nil, nil, currentNoteEndDelay)
                        refreshControls = true
                        refreshPianoRollNeeded = true
                    end,
                },
                vb:button {
                    id = "note_ghost",
                    text = "G",
                    tooltip = "Enable / disable to draw ghost notes",
                    notifier = function()
                        if currentNoteGhost then
                            currentNoteGhost = false
                            if #noteSelection > 0 then
                                changePropertiesOfSelectedNotes(nil, nil, nil, nil, nil, "noghost")
                            end
                        else
                            currentNoteGhost = true
                            if #noteSelection > 0 then
                                changePropertiesOfSelectedNotes(nil, nil, nil, nil, nil, "ghost")
                            end
                        end
                        refreshControls = true
                    end
                },
            },
            vb:row {
                margin = 3,
                spacing = 3,
                style = "panel",
                vb:text {
                    text = "Ghost Track:",
                },
                vb:popup {
                    id = "ghosttracks",
                    notifier = function(index)
                        if not currentGhostTrack or currentGhostTrack ~= index then
                            currentGhostTrack = index
                            refreshControls = true
                            refreshPianoRollNeeded = true
                        end
                    end,
                },
            },
            vb:row {
                margin = 3,
                spacing = 3,
                style = "panel",
                vb:button {
                    text = "Preferences",
                    tooltip = "Simple Pianoroll Preferences ...",
                    notifier = function()
                        showPreferences()
                    end,
                },
            }
        },
        vb:row {
            vb:column {
                vb:row {
                    noteSlider,
                    vb:column {
                        vb:column {
                            spacing = -1,
                            vb:row {
                                spacing = -pianoKeyWidth,
                                width = pianoKeyWidth,
                                margin = -1,
                                vb:space {
                                    width = pianoKeyWidth + 1,
                                },
                                vb:button {
                                    id = "trackcolor",
                                    height = gridStepSizeH + 3,
                                    color = { 44, 77, 66 },
                                    active = true,
                                    width = pianoKeyWidth,
                                    notifier = function()
                                        if currentGhostTrack and currentGhostTrack ~= song.selected_track_index then
                                            local temp = currentGhostTrack
                                            vbw.ghosttracks.value = song.selected_track_index
                                            song.selected_track_index = temp
                                        else
                                            showStatus("Info: Can't switch to ghost track, please select a ghost track first.")
                                        end
                                    end
                                }
                            },
                            vb:row {
                                spacing = -4,
                                vb:button {
                                    id = "mute",
                                    text = "M",
                                    tooltip = "Mute/Unmute current track",
                                    height = gridStepSizeH,
                                    width = pianoKeyWidth / 2 + 2,
                                    notifier = function()
                                        if song.selected_track.mute_state == 3 then
                                            song.selected_track:unmute()
                                        else
                                            song.selected_track:mute()
                                        end
                                        refreshControls = true
                                    end
                                },
                                vb:button {
                                    id = "solo",
                                    text = "S",
                                    height = gridStepSizeH,
                                    tooltip = "Solo/Unsolo current track",
                                    width = pianoKeyWidth / 2 + 2,
                                    notifier = function()
                                        song.selected_track:solo()
                                        refreshControls = true
                                    end
                                },
                            },
                        },
                        vb:row {
                            spacing = -pianoKeyWidth + 1,
                            vb:valuebox {
                                id = "swk",
                                width = pianoKeyWidth,
                                height = (gridStepSizeH - 2.9) * (gridHeight + 1),
                                min = -1,
                                max = 1,
                                notifier = function(number)
                                    handleSrollWheel(number, "swk")
                                end,
                            },
                            vb:column {
                                spacing = -1,
                                whiteKeys,
                                vb:space {
                                    height = 2
                                },
                                vb:row {
                                    margin = -1,
                                    vb:button {
                                        id = "currentscale",
                                        text = "",
                                        width = pianoKeyWidth,
                                        height = gridStepSizeH + 3,
                                        tooltip = "Scale highlighting",
                                        notifier = function()
                                            local vbp = renoise.ViewBuilder()
                                            app:show_custom_prompt("Scale highlighting",
                                                    vbp:row {
                                                        uniform = true,
                                                        margin = 5,
                                                        spacing = 5,
                                                        vbp:column {
                                                            style = "group",
                                                            margin = 5,
                                                            uniform = true,
                                                            spacing = 4,
                                                            width = 432,
                                                            vbp:text {
                                                                text = "Scale highlighting:",
                                                            },
                                                            vbp:switch {
                                                                width = "100%",
                                                                items = scaleTypes,
                                                                bind = preferences.scaleHighlightingType,
                                                                tooltip = "Switch current scale type\n(when ctrl is holded, the note switched too. eg. C Maj->A Min)",
                                                                notifier = function(i)
                                                                    if i == 3 and currentScale == 2 then
                                                                        if app.key_modifier_states["control"] == "pressed" then
                                                                            preferences.keyForSelectedScale.value = ((preferences.keyForSelectedScale.value - 1 + 9) % 12) + 1
                                                                        end
                                                                        currentScale = i
                                                                    end
                                                                    if i == 2 and currentScale == 3 then
                                                                        if app.key_modifier_states["control"] == "pressed" then
                                                                            preferences.keyForSelectedScale.value = ((preferences.keyForSelectedScale.value - 1 + 3) % 12) + 1
                                                                        end
                                                                        currentScale = i
                                                                    end
                                                                end
                                                            },
                                                            vbp:text {
                                                                text = "Key for selected scale:",
                                                            },
                                                            vbp:switch {
                                                                width = "100%",
                                                                items = notesTable,
                                                                bind = preferences.keyForSelectedScale,
                                                            },
                                                        } }, { "Ok" })
                                            refreshPianoRollNeeded = true
                                        end
                                    },
                                }
                            }
                        },
                    },
                },
            },
            vb:column {
                vb:column {
                    vb:space {
                        height = 3,
                    },
                    playCursor,
                    vb:space {
                        height = 1,
                    },
                },
                vb:column {
                    vb:row {
                        margin = -1,
                        vb:space {
                            id = "blockloopspc",
                            width = gridStepSizeW * 1 - (gridSpacing * 1),
                            height = 5,
                        },
                        vb:button {
                            id = "blockloop",
                            color = colorNoteHighlight,
                            height = 5,
                            width = gridStepSizeW * 3 - (gridSpacing * 2),
                            active = false,
                            visible = false,
                        },
                    },
                    vb:row {
                        spacing = -5,
                        vb:space {
                            width = 1,
                        },
                        timeline,
                    },
                    vb:row {
                        spacing = -(gridStepSizeW * gridWidth - (gridSpacing * (gridWidth))),
                        vb:row {
                            spacing = -(gridStepSizeW * (gridWidth) - (gridSpacing * (gridWidth))) - 4,
                            vb:space {
                                width = gridStepSizeW * gridWidth - (gridSpacing * (gridWidth)),
                            },
                            vb:row {
                                scrollwheelgrid,
                            },
                        },
                        vb:xypad {
                            id = "xypad",
                            width = gridStepSizeW * gridWidth - (gridSpacing * (gridWidth)),
                            height = (gridStepSizeH - 3) * gridHeight,
                            min = { x = 1, y = 1 },
                            snapback = { x = 1.01234, y = 1.01234 },
                            max = { x = gridWidth + 1, y = gridHeight + 1 },
                            notifier = function(val)
                                handleXypad(val)
                            end
                        },
                        vb:column {
                            spacing = -1,
                            pianorollColumns,
                            vb:space {
                                height = 2
                            },
                            vb:row {
                                style = "panel",
                                spacing = -(gridStepSizeW * gridWidth - (gridSpacing * (gridWidth)) + 2),
                                vb:bitmap {
                                    width = gridStepSizeW * gridWidth - (gridSpacing * (gridWidth)) + 2,
                                    height = gridStepSizeH + 1,
                                    bitmap = "Icons/SwitchOff.bmp",
                                    mode = "transparent",
                                    notifier = function()
                                        --nothing
                                    end
                                },
                                vb:row {
                                    id = "chorddetection",
                                    width = gridStepSizeW * gridWidth - (gridSpacing * (gridWidth)) + 2,
                                    vb:horizontal_aligner {
                                        width = gridStepSizeW * gridWidth - (gridSpacing * (gridWidth)) + 2,
                                        mode = "right",
                                        spacing = -2,
                                        vb:row {
                                            style = "panel",
                                            margin = 1,
                                            vb:space {
                                                width = 2,
                                            },
                                            vb:vertical_aligner {
                                                mode = "center",
                                                vb:bitmap {
                                                    bitmap = "Icons/Browser_RenoiseSongFile.bmp",
                                                    mode = "transparent",
                                                    tooltip = "Notes",
                                                },
                                            },
                                            vb:space {
                                                width = 2,
                                            },
                                            vb:text {
                                                id = "currentnotes",
                                                width = 122,
                                                text = "-",
                                                font = "bold",
                                                style = "strong",
                                                align = "center",
                                            },
                                            vb:space {
                                                width = 4,
                                            },
                                        },
                                        vb:row {
                                            style = "panel",
                                            margin = 1,
                                            vb:space {
                                                width = 2,
                                            },
                                            vb:vertical_aligner {
                                                mode = "center",
                                                vb:bitmap {
                                                    bitmap = "Icons/Transport_ChordModeOff.bmp",
                                                    mode = "transparent",
                                                    tooltip = "Chord",
                                                },
                                            },
                                            vb:space {
                                                width = 2,
                                            },
                                            vb:text {
                                                id = "currentchord",
                                                width = 114,
                                                text = "-",
                                                font = "bold",
                                                style = "strong",
                                                align = "center",
                                            },
                                            vb:space {
                                                width = 4,
                                            },
                                        },
                                        vb:row {
                                            style = "panel",
                                            margin = 1,
                                            vb:space {
                                                width = 2,
                                            },
                                            vb:vertical_aligner {
                                                mode = "center",
                                                vb:bitmap {
                                                    bitmap = "Icons/Mixer_ShowDelay.bmp",
                                                    mode = "transparent",
                                                    tooltip = "Scale degree and roman numeral",
                                                },
                                            },
                                            vb:space {
                                                width = 2,
                                            },
                                            vb:text {
                                                id = "chordprog",
                                                width = 110,
                                                text = "-",
                                                font = "bold",
                                                style = "strong",
                                                align = "center",
                                            },
                                            vb:space {
                                                width = 4,
                                            },
                                        },
                                    },
                                },
                                vb:column {
                                    width = gridStepSizeW * gridWidth - (gridSpacing * (gridWidth)) + 2,
                                    id = "key_state_panel",
                                    visible = false,
                                    vb:text {
                                        id = "key_state",
                                        text = "",
                                        font = "bold",
                                        style = "strong",
                                    },
                                },
                            }
                        },
                        vb:row {
                            id = "sel",
                            visible = false,
                            spacing = -3,
                            margin = -gridMargin,
                            vb:space {
                                id = "selleftspace",
                                width = 1,
                                height = 1,
                            },
                            vb:column {
                                vb:space {
                                    id = "seltopspace1",
                                    height = 1,
                                    width = 1,
                                },
                                vb:button {
                                    id = "selleft",
                                    width = 5,
                                    height = 1,
                                    active = false,
                                    color = colorStepOn,
                                },
                            },
                            vb:column {
                                vb:space {
                                    id = "seltopspace",
                                    height = 1,
                                },
                                vb:button {
                                    id = "seltop",
                                    active = false,
                                    width = gridStepSizeW * 2 - gridSpacing * 2,
                                    height = 5,
                                    color = colorStepOn,
                                },
                                vb:space {
                                    id = "selheightspace",
                                    height = gridStepSizeH * 2,
                                },
                                vb:button {
                                    id = "selbottom",
                                    active = false,
                                    width = gridStepSizeW * 2 - gridSpacing * 2,
                                    height = 5,
                                    color = colorStepOn,
                                },
                            },
                            vb:column {
                                vb:space {
                                    id = "seltopspace2",
                                    height = 1,
                                    width = 1,
                                },
                                vb:button {
                                    id = "selright",
                                    width = 5,
                                    height = 1,
                                    active = false,
                                    color = colorStepOn,
                                },
                            },
                        },
                    },
                },
            },
        },
        vb:row {
            vb:space {
                width = math.max(16, gridStepSizeW / 2) + (gridStepSizeW * 3)
            },
            stepSlider,
        },
    }
end

--edit in pianoroll main function
local function main_function()
    --setup observers
    if not tool.app_new_document_observable:has_notifier(appNewDoc) then
        tool.app_new_document_observable:add_notifier(appNewDoc)
        appNewDoc()
    end

    if not tool.app_idle_observable:has_notifier(appIdleEvent) then
        tool.app_idle_observable:add_notifier(appIdleEvent)
    end

    if song.selected_track.type ~= renoise.Track.TRACK_TYPE_SEQUENCER then
        badTrackError()
        return
    end

    --only create pianoroll grid, when window is not created and not visible
    if not windowObj or not windowObj.visible then
        lastStepOn = nil
        currentGhostTrack = nil
        --reset lowest / highest note for center view
        lowestNote = nil
        highestNote = nil
        --reset note selection
        noteSelection = {}
        --reset note playing
        notesPlaying = {}
        notesPlayingLine = {}
        --when needed set enable penmode
        penMode = preferences.forcePenMode.value
        --create main dialog
        if not windowContent or rebuildWindowDialog then
            --init colors
            initColors()
            --setup grid settings
            gridStepSizeW = defaultPreferences.gridStepSizeW
            gridStepSizeH = defaultPreferences.gridStepSizeH
            gridSpacing = preferences.gridSpacing.value
            gridMargin = preferences.gridMargin.value
            gridWidth = preferences.gridWidth.value
            pianoKeyWidth = preferences.gridStepSizeW.value * 3
            --limit gridHeight
            preferences.gridHeight.value = clamp(preferences.gridHeight.value, 16, 64)
            gridHeight = preferences.gridHeight.value
            stepOffset = 0
            -- default offset
            noteOffset = clamp(28, 0, 119 - gridHeight)
            --reset note btn table
            noteButtons = {}
            vb = renoise.ViewBuilder()
            vbw = vb.views
            createPianoRollDialog()
        end

        --fill new created pianoroll, timeline and refresh controls
        refreshNoteControls()
        fillTimeline()
        fillPianoRoll()
        --center note view
        if lowestNote ~= nil and preferences.centerViewOnOpen.value then
            local nOffset = math.floor(((lowestNote + highestNote) / 2) - (gridHeight / 2))
            if nOffset < 0 then
                nOffset = 0
            elseif nOffset > noteSlider.max then
                nOffset = noteSlider.max
            end
            noteSlider.value = nOffset
            noteOffset = nOffset
        end
        --reset rebuild flag
        rebuildWindowDialog = false
        --show dialog
        windowObj = app:show_custom_dialog("Simple Pianoroll v" .. manifest:property("Version").value, windowContent, function(_, key)
            local handled
            --always disable edit mode because of side effects
            song.transport.edit_mode = false
            --process key shortcuts
            handled = handleKeyEvent(key)
            --return key to host
            --TODO BUG sometimes key events got missed when bringed back to host
            if not handled then
                return key
            end
        end, {
            send_key_repeat = true,
            send_key_release = true,
        })
    else
        --refresh pianoroll
        refreshPianoRollNeeded = true
        --show window
        windowObj:show()
    end
end

--add main function to context menu of pattern editor
tool:add_menu_entry {
    name = "Pattern Editor:Edit with Simple Pianoroll ...",
    invoke = function()
        main_function()
    end
}

--add main function to context menu of pattern matrix
tool:add_menu_entry {
    name = "Pattern Matrix:Edit with Simple Pianoroll ...",
    invoke = function()
        song = renoise.song()
        for s = 1, #song.sequencer.pattern_sequence do
            for t = 1, #song.tracks do
                if song.sequencer:track_sequence_slot_is_selected(t, s) then
                    --focus pattern editor
                    app.window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
                    --disable follow player
                    song.transport.follow_player = false
                    --switch to sequence and track
                    song.selected_sequence_index = s
                    song.selected_track_index = t
                    --call default main_function
                    return main_function()
                end
            end
        end
    end
}

--add key shortcut
tool:add_keybinding {
    name = "Pattern Editor:Tools:Edit with Simple Pianoroll ...",
    invoke = function()
        if windowObj and windowObj.visible then
            windowObj:close()
        else
            main_function()
        end
    end
}

--add global key shortcut
tool:add_keybinding {
    name = "Global:Simple Pianoroll:Edit with Simple Pianoroll ...",
    invoke = function()
        if windowObj and windowObj.visible then
            windowObj:close()
        else
            --focus pattern editor
            app.window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
            --create window
            main_function()
        end
    end
}

tool:add_keybinding {
    name = "Global:Simple Pianoroll:Open/Close current plugin instrument editor ...",
    invoke = function()
        if not song then
            song = renoise.song()
        end
        if not currentInstrument or not (windowObj and windowObj.visible) then
            currentInstrument = song.selected_instrument_index
        end
        if currentInstrument and song.instruments[currentInstrument] then
            local plugin = song.instruments[currentInstrument].plugin_properties
            if plugin and plugin.plugin_device and plugin.plugin_device.external_editor_available then
                plugin.plugin_device.external_editor_visible = not plugin.plugin_device.external_editor_visible
            else
                showStatus("Current instrument doesn't have an editor window.")
            end
        end
    end
}

tool:add_keybinding {
    name = "Global:Simple Pianoroll:Close piano roll and switch to mixer view ...",
    invoke = function()
        if windowObj and windowObj.visible then
            windowObj:close()
        end
        app.window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_MIXER
    end
}