--some basic renoise vars for reuse
local app = renoise.app()
local tool = renoise.tool()
local song

--predefine functions
local showPreferences

--viewbuilder for pianoroll dialog
local vb
local vbw
--viewbuilder for preferences and set scale
local vbp = renoise.ViewBuilder()
local vbc = renoise.ViewBuilder
local vbwp = vbp.views

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
    ["0,4,8"] = "aug",
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
    ["0,2,3,7,10"] = "min9",
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
    gridHLines = 1,
    gridVLines = 1,
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
    oddBeatShadingAmount = 0.0,
    scaleBtnShadingAmount = 0.25,
    rootKeyShadingAmount = 0.15,
    outOfNoteScaleShadingAmount = 0.15,
    outOfPentatonicScaleHighlightingAmount = 0.00,
    azertyMode = false,
    swapCtrlAlt = false,
    scrollWheelSpeed = 2,
    clickAreaSizeForScalingPx = 7,
    disableKeyHandler = false,
    shadingType = 1,
    previewPolyphony = 3,
    previewMidiStuckWorkaround = false,
    limitPreviewBySelectionSize = true,
    disableAltClickNoteRemove = true,
    resetVolPanDlyControlOnClick = true,
    minSizeOfNoteButton = 5,
    setLastEditedTrackAsGhost = true,
    autoEnableDelayWhenNeeded = true,
    setVelPanDlyLenFromLastNote = true,
    centerViewOnOpen = true,
    chordDetection = true,
    keyLabels = 2,
    mouseWarpingCompatibilityMode = false,
    setComputerKeyboardVelocity = false,
    moveNoteInPenMode = false,
    mirroringGhostTrack = false,
    noteColorShiftDegree = 45,
    midiDevice = "",
    midiIn = false,
    chordGunPreset = false,
    useChordStampingForNotePreview = true,
    useTrackColorFor = 1,
    enableAdditonalSampleTools = false,
    --colors
    colorBaseGridColor = "#34444E",
    colorNote = "#AAD9B3",
    colorGhostTrackNote = "#50616B",
    colorNoteHighlight = "#E8CC6E",
    colorNoteHighlight2 = "#C2B1E2",
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
    gridHLines = defaultPreferences.gridHLines,
    gridVLines = defaultPreferences.gridVLines,
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
    oddBeatShadingAmount = defaultPreferences.oddBeatShadingAmount,
    rootKeyShadingAmount = defaultPreferences.rootKeyShadingAmount,
    outOfNoteScaleShadingAmount = defaultPreferences.outOfNoteScaleShadingAmount,
    azertyMode = defaultPreferences.azertyMode,
    swapCtrlAlt = defaultPreferences.swapCtrlAlt,
    scrollWheelSpeed = defaultPreferences.scrollWheelSpeed,
    clickAreaSizeForScalingPx = defaultPreferences.clickAreaSizeForScalingPx,
    disableKeyHandler = defaultPreferences.disableKeyHandler,
    disableAltClickNoteRemove = defaultPreferences.disableAltClickNoteRemove,
    setLastEditedTrackAsGhost = defaultPreferences.setLastEditedTrackAsGhost,
    useTrackColorFor = defaultPreferences.useTrackColorFor,
    autoEnableDelayWhenNeeded = defaultPreferences.autoEnableDelayWhenNeeded,
    snapToGridSize = defaultPreferences.snapToGridSize,
    setVelPanDlyLenFromLastNote = defaultPreferences.setVelPanDlyLenFromLastNote,
    keyLabels = defaultPreferences.keyLabels,
    centerViewOnOpen = defaultPreferences.centerViewOnOpen,
    previewPolyphony = defaultPreferences.previewPolyphony,
    previewMidiStuckWorkaround = defaultPreferences.previewMidiStuckWorkaround,
    limitPreviewBySelectionSize = defaultPreferences.limitPreviewBySelectionSize,
    chordDetection = defaultPreferences.chordDetection,
    mouseWarpingCompatibilityMode = defaultPreferences.mouseWarpingCompatibilityMode,
    outOfPentatonicScaleHighlightingAmount = defaultPreferences.outOfPentatonicScaleHighlightingAmount,
    setComputerKeyboardVelocity = defaultPreferences.setComputerKeyboardVelocity,
    moveNoteInPenMode = defaultPreferences.moveNoteInPenMode,
    mirroringGhostTrack = defaultPreferences.mirroringGhostTrack,
    noteColorShiftDegree = defaultPreferences.noteColorShiftDegree,
    midiDevice = defaultPreferences.midiDevice,
    midiIn = defaultPreferences.midiIn,
    chordGunPreset = defaultPreferences.chordGunPreset,
    enableAdditonalSampleTools = defaultPreferences.enableAdditonalSampleTools,
    useChordStampingForNotePreview = defaultPreferences.useChordStampingForNotePreview,
    chordPainterPresetTbl = 1, --default bank
    --colors
    colorBaseGridColor = defaultPreferences.colorBaseGridColor,
    colorNote = defaultPreferences.colorNote,
    colorGhostTrackNote = defaultPreferences.colorGhostTrackNote,
    colorNoteHighlight = defaultPreferences.colorNoteHighlight,
    colorNoteHighlight2 = defaultPreferences.colorNoteHighlight2,
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
local dialogVars = {
    setScaleObj = nil,
    setScaleContent = nil,
    histogramObj = nil,
    histogramContent = nil,
    penSettingsObj = nil,
    penSettingsContent = nil,
    preferencesObj = nil,
    preferencesContent = nil,
    preferencesWasShown = false
}
local stepSlider
local noteSlider
local snapBackVal = { x = 1.01234, y = 1.01234 }

--last step position for resetting the last step button
local lastStepOn
local lastEditPos
local currentEditPos

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
local colorNoteHighlight
local colorNoteHighlight2
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
local loopingrange
local instrumentScaleMode

--backup state values, to set it back when piano roll was closed
local wasFollowPlayer

--main flag for refreshing pianoroll
local rebuildWindowDialog = true
local refreshPianoRollNeeded = false
local blockLineModifier = false
local refreshControls = false
local refreshTimeline = false
local refreshChordDetection = false
local refreshHistogram = false
local afterEditProcessTime

--table to save note indices per step for highlighting
local noteOnStep = {}

--table with all current playing notes on step
local notesOnStep = {}
local notesPlaying = {}
local notesPlayingLine = {}
local patternInstrument

--table for save used notes
local noteButtons = {}

--table for clipboard function
local clipboard = {}

--table for histogram
local randomHistogramValues = {}

--edit vars
local chordPainter = { 0 }
local chordPainterForceInScale = false
local chordPainterUpperNoteLimit = 120
local chordPainterPresets = {
    inbuild = {
        name = {
            "None",
            "---",
            "Major",
            "Major 3rd",
            "Major7",
            "Major9",
            "---",
            "Minor",
            "Minor 3rd",
            "Minor7",
            "Minor9",
            "---",
            "Sus2",
            "Sus4",
            "7",
            "Diminished",
            "Augmented",
        },
        notes = {
            { 0 },
            nil,
            { 0, 4, 7 },
            { 0, 4 },
            { 0, 4, 7, 11 },
            { 0, 4, 7, 11, 14 },
            nil,
            { 0, 3, 7 },
            { 0, 3 },
            { 0, 3, 7, 10 },
            { 0, 3, 7, 10, 14 },
            nil,
            { 0, 2, 7 },
            { 0, 5, 7 },
            { 0, 4, 7, 10 },
            { 0, 3, 6 },
            { 0, 4, 8 },
        }
    },
    chordgun = {
        name = {},
        notes = {}
    }
}
local lastClickCache = {}
local lastClickIndex
local pasteCursor = {}
local currentInstrument
local currentNoteLength = 2
local currentNoteVelocity = 255
local currentNotePan = 255
local currentNoteDelay = 0
local currentNoteEndDelay = 0
local currentNoteVelocityPreview = 127
local currentNoteEndVelocity = 255
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
local modifier = {
    keyControl = false,
    keyRControl = false,
    keyShift = false,
    keyRShift = false,
    keyAlt = false
}

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
    lastval = nil,
    notemode = false, --when note mode is active
    previewmode = false, --is scale mode active?
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
    disabled = {},
    preview = {},
    loopslider = nil
}

--pen mode
local penMode = false
local audioPreviewMode = false

--step preview
local stepPreview = false

--table to save last playing note for qwerty playing
local lastKeyboardNote = {}

--midi
local midiDevice

--default sort functions
local sortFunc = {
    sortLeftOneFirst = function(a, b)
        local x, y
        x = a.line + a.dly / 0x100
        y = b.line + b.dly / 0x100
        if x == y then
            x = a.column
            y = b.column
        end
        return x < y
    end,
    sortLeftOneFirstFromLowToTop = function(a, b)
        local x, y
        x = a.line + a.dly / 0x100
        y = b.line + b.dly / 0x100
        if x == y then
            x = a.note
            y = b.note
        end
        return x < y
    end,
    sortRightOneFirst = function(a, b)
        local x, y
        x = a.line + a.len + a.end_dly / 0x100
        y = b.line + b.len + a.end_dly / 0x100
        if x == y then
            --flip x and y, because column order shouldn't changed
            y = a.column
            x = b.column
        end
        return x > y
    end,
    sortFromLowToTop = function(a, b)
        local x, y
        x = a.note
        y = b.note
        return x < y
    end,
    sortFirstColumnFirst = function(a, b)
        local x, y
        x = a.column
        y = b.column
        return x < y
    end
}

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

--bring focus back to main dialog, when out of focus
local function restoreFocus()
    if windowObj and windowObj.visible then
        windowObj:show()
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
    if val == ".." then
        return nil
    end
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

--for the line index calculate the correct bar index
local function calculateBarBeat(line, returnbeat, lpb)
    local math_ceil = math.ceil
    if not lpb then
        lpb = song.transport.lpb
    end
    if returnbeat == true then
        return math_ceil((line - lpb) / lpb) % 4 + 1
    end
    return math_ceil((line - (lpb * 4)) / (lpb * 4)) + 1
end

--shade color
local function shadeColor(color, shade)
    if shade == 0 then
        return color
    end
    local math_ceil = math.ceil
    local math_max = math.max
    return {
        math_ceil(math_max(color[1] * (1 - shade), 1)),
        math_ceil(math_max(color[2] * (1 - shade), 1)),
        math_ceil(math_max(color[3] * (1 - shade), 1))
    }
end

--alphablend colors
local function alphablendColors(color1, color2, alphablend)
    if alphablend == 0 then
        return color1
    end
    local math_ceil = math.ceil
    local math_max = math.max
    return {
        math_ceil(math_max(color1[1] * (1 - alphablend) + color2[1] * alphablend, 1)),
        math_ceil(math_max(color1[2] * (1 - alphablend) + color2[2] * alphablend, 1)),
        math_ceil(math_max(color1[3] * (1 - alphablend) + color2[3] * alphablend, 1))
    }
end

--shift hue value
local function shiftHueColor(col, degree)
    local m = {
        { 1, 0, 0 },
        { 0, 1, 0 },
        { 0, 0, 1 }
    }
    local rad = math.rad(degree)
    local sinA = math.sin(rad)
    local cosA = math.cos(rad)
    m[1][1] = cosA + (1 - cosA) / 3
    m[1][2] = 1 / 3 * (1 - cosA) - math.sqrt(1 / 3) * sinA
    m[1][3] = 1 / 3 * (1 - cosA) + math.sqrt(1 / 3) * sinA
    m[2][1] = 1 / 3 * (1 - cosA) + math.sqrt(1 / 3) * sinA
    m[2][2] = cosA + 1 / 3 * (1 - cosA)
    m[2][3] = 1 / 3 * (1 - cosA) - math.sqrt(1 / 3) * sinA
    m[3][1] = 1 / 3 * (1 - cosA) - math.sqrt(1 / 3) * sinA
    m[3][2] = 1 / 3 * (1 - cosA) + math.sqrt(1 / 3) * sinA
    m[3][3] = cosA + 1 / 3 * (1 - cosA)
    return {
        clamp(math.floor((col[1] * m[1][1] + col[2] * m[1][2] + col[3] * m[1][3]) + 0.5), 1, 254),
        clamp(math.floor((col[1] * m[2][1] + col[2] * m[2][2] + col[3] * m[2][3]) + 0.5), 1, 254),
        clamp(math.floor((col[1] * m[3][1] + col[2] * m[3][2] + col[3] * m[3][3]) + 0.5), 1, 254)
    }
end

--simple function for coloring velocity
local function colorNoteVelocity(vel, isOnStep, isInSelection, ins)
    local color
    local noteColor = colorNote
    if preferences.useTrackColorFor.value == 3 then
        noteColor = vbw["trackcolor"].color
    end
    if ins ~= nil and patternInstrument ~= nil and patternInstrument ~= ins then
        noteColor = shiftHueColor(noteColor, (ins - patternInstrument) * preferences.noteColorShiftDegree.value)
    end
    if isInSelection then
        noteColor = colorNoteSelected
    elseif isOnStep == true then
        if preferences.useTrackColorFor.value == 2 then
            return vbw["trackcolor"].color
        else
            return colorNoteHighlight
        end
    elseif vel == 0 then
        return colorNoteMuted
    end
    if vel < 0x7f and preferences.applyVelocityColorShading.value then
        if preferences.shadingType.value == 2 then
            color = alphablendColors(noteColor, colorBaseGridColor,
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

--check if x is in range of note
local function posInNoteRange(pos, note_data)
    local posn = math.floor(pos * 0x100)
    local posx1 = note_data.line * 0x100
    local posx2 = (note_data.line + note_data.len) * 0x100
    local cut
    local endcut
    local dly

    --when on the right side, sub -1 so the last note is still plaing
    if posn == (math.min(song.selected_pattern.number_of_lines, gridWidth) + 1) * 0x100 then
        posn = posn - 1
    end

    if song.selected_track.volume_column_visible then
        if note_data.vel >= fromRenoiseHex("C0") and note_data.vel <= fromRenoiseHex("CF") then
            cut = note_data.vel - fromRenoiseHex("C0")
        end
        if note_data.end_vel >= fromRenoiseHex("C0") and note_data.end_vel <= fromRenoiseHex("CF") then
            endcut = note_data.end_vel - fromRenoiseHex("C0")
        end
        if note_data.vel >= fromRenoiseHex("Q0") and note_data.vel <= fromRenoiseHex("QF") then
            dly = note_data.vel - fromRenoiseHex("Q0")
        end
    end
    if song.selected_track.panning_column_visible then
        if note_data.pan >= fromRenoiseHex("C0") and note_data.pan <= fromRenoiseHex("CF") and cut == nil then
            cut = note_data.pan - 0xc0
        end
        if note_data.pan >= fromRenoiseHex("Q0") and note_data.pan <= fromRenoiseHex("QF") and dly == nil then
            dly = note_data.pan - fromRenoiseHex("Q0")
        end
    end

    if song.selected_track.delay_column_visible then
        posx1 = posx1 + note_data.dly
        if endcut and endcut > 0 then
            endcut = 0x100 / song.transport.tpl * math.min(endcut, song.transport.tpl)
            posx2 = posx2 - endcut
        else
            posx2 = posx2 + note_data.end_dly
        end
    elseif endcut and endcut > 0 then
        endcut = 0x100 - 0x100 / song.transport.tpl * math.min(endcut, song.transport.tpl)
        posx2 = posx2 - endcut
    end

    if dly and dly > 0 then
        dly = 0x100 / song.transport.tpl * math.min(dly, song.transport.tpl)
        posx1 = note_data.line * 0x100 + dly
    end

    if cut and cut > 0 then
        cut = 0x100 / song.transport.tpl * math.min(cut, song.transport.tpl)
        posx2 = posx1 + cut
    end

    if posn >= posx1 and posn < posx2 then
        return true
    end
    return false
end

--init dynamic calculated colors
local function initColors()
    --load colors from preferences
    colorBaseGridColor = convertStringToColorValue(preferences.colorBaseGridColor.value, defaultPreferences.colorBaseGridColor)
    colorNote = convertStringToColorValue(preferences.colorNote.value, defaultPreferences.colorNote)
    colorGhostTrackNote = convertStringToColorValue(preferences.colorGhostTrackNote.value, defaultPreferences.colorGhostTrackNote)
    colorNoteHighlight = convertStringToColorValue(preferences.colorNoteHighlight.value, defaultPreferences.colorNoteHighlight)
    colorNoteHighlight2 = convertStringToColorValue(preferences.colorNoteHighlight2.value, defaultPreferences.colorNoteHighlight2)
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
    colorWhiteKey = {
        colorBaseGridColor,
        shadeColor(colorBaseGridColor, preferences.oddBeatShadingAmount.value),
        colorBaseGridColor,
        shadeColor(colorBaseGridColor, preferences.oddBeatShadingAmount.value),
        shadeColor(colorBaseGridColor, preferences.oddBarsShadingAmount.value),
        shadeColor(shadeColor(colorBaseGridColor, preferences.oddBarsShadingAmount.value), preferences.oddBeatShadingAmount.value),
        shadeColor(colorBaseGridColor, preferences.oddBarsShadingAmount.value),
        shadeColor(shadeColor(colorBaseGridColor, preferences.oddBarsShadingAmount.value), preferences.oddBeatShadingAmount.value),
    }
    colorBlackKey = {
        shadeColor(colorWhiteKey[1], preferences.outOfNoteScaleShadingAmount.value),
        shadeColor(shadeColor(colorWhiteKey[1], preferences.outOfNoteScaleShadingAmount.value), preferences.oddBeatShadingAmount.value),
        shadeColor(colorWhiteKey[1], preferences.outOfNoteScaleShadingAmount.value),
        shadeColor(shadeColor(colorWhiteKey[1], preferences.outOfNoteScaleShadingAmount.value), preferences.oddBeatShadingAmount.value),
        shadeColor(colorWhiteKey[5], preferences.outOfNoteScaleShadingAmount.value),
        shadeColor(shadeColor(colorWhiteKey[5], preferences.outOfNoteScaleShadingAmount.value), preferences.oddBeatShadingAmount.value),
        shadeColor(colorWhiteKey[5], preferences.outOfNoteScaleShadingAmount.value),
        shadeColor(shadeColor(colorWhiteKey[5], preferences.outOfNoteScaleShadingAmount.value), preferences.oddBeatShadingAmount.value),
    }
end

--check mode
local function checkMode(mode)
    if mode == "preview" then
        if audioPreviewMode or (modifier.keyControl and modifier.keyShift and not modifier.keyAlt) then
            return true
        end
    end
    if mode == "pen" then
        if (penMode and not modifier.keyAlt) or (not modifier.keyControl and not modifier.keyShift and modifier.keyAlt and not penMode) then
            return true
        end
    end
    return false
end

--refresh edit pos
local function refreshEditPosIndicator()
    local eP = song.transport.edit_pos.line
    local se = vbw["se" .. tostring(lastEditPos)]
    if (currentEditPos < song.selected_pattern.number_of_lines + 1 or currentEditPos > song.selected_pattern.number_of_lines + 1) and currentEditPos ~= eP then
        currentEditPos = eP
    end
    if se then
        if currentEditPos == song.selected_pattern.number_of_lines + 1 then
            se.color = shadeColor(colorStepOn, 0.5)
        else
            se.color = colorStepOn
        end
    end
    if lastEditPos == nil or lastEditPos ~= eP - stepOffset then
        if se then
            se.visible = false
        end
        lastEditPos = eP - stepOffset
        se = vbw["se" .. tostring(lastEditPos)]
        if se then
            se.visible = true
        end
    end
end

--jump to the note position in pattern
local function jumpToNoteInPattern(notedata)
    --jump to the first note in selection, when needed
    if type(notedata) == "string" and notedata == "sel" then
        if #noteSelection > 0 then
            table.sort(noteSelection, sortFunc.sortLeftOneFirst)
            notedata = noteSelection[1]
        else
            --no selection, dont do anything
            return false
        end
    elseif type(notedata) == "number" then
        notedata = {
            line = notedata,
            column = 1
        }
    end
    --only when not playing or follow player
    if not song.transport.playing or not song.transport.follow_player then
        --only when the edit cursor is in the correct pattern
        if song.selected_pattern_index == song.sequencer:pattern(song.transport.edit_pos.sequence) then
            local npos = renoise.SongPos()
            currentEditPos = clamp(notedata.line, 1, song.selected_pattern.number_of_lines)
            npos.line = currentEditPos
            npos.sequence = song.transport.edit_pos.sequence
            song.transport.edit_pos = npos
            --switch to the correct note column
            if song.selected_note_column_index ~= notedata.column then
                song.selected_note_column_index = clamp(notedata.column, 1, song.selected_track.visible_note_columns)
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
local function noteInSelection(notedata, otherTable)
    if otherTable == nil then
        otherTable = noteSelection
    end
    local n = #otherTable
    for i = 1, n do
        --just search for line in pattern and column
        if otherTable[i].column == notedata.column and otherTable[i].line == notedata.line then
            return i
        end
    end
    return nil
end

--function set set note button colors
local function setNoteColor(note_data, isOnStep, isInSelection)
    local nB = vbw["b" .. note_data.idx]
    if nB then
        nB.color = colorNoteVelocity(note_data.vel, isOnStep, isInSelection, note_data.ins)
        if vbw["bs" .. note_data.idx] then
            vbw["bs" .. note_data.idx].color = shadeColor(nB.color, preferences.scaleBtnShadingAmount.value)
        end
    end
end

--clear selection and set note colors back
local function updateNoteSelection(note_data, clear)
    local newNotes = {}
    local wasInSelection = {}
    if note_data ~= nil then
        if note_data == "all" then
            for k in pairs(noteData) do
                table.insert(newNotes, noteData[k])
            end
        elseif #note_data == 0 and note_data.idx then
            table.insert(newNotes, note_data)
        elseif #note_data > 0 then
            newNotes = note_data
        end
    end
    if clear ~= nil then
        if #noteSelection > 0 then
            if type(clear) == "table" then
                local idx = noteInSelection(clear)
                local nidx = noteInSelection(clear, newNotes)
                if idx then
                    wasInSelection[noteSelection[idx].idx] = 1
                    table.remove(noteSelection, idx)
                    --also remove note, when its in new note table
                    if nidx then
                        table.remove(newNotes, nidx)
                    end
                end
            elseif clear == "note" then
                local idx = noteInSelection(note_data)
                if idx then
                    wasInSelection[noteSelection[idx].idx] = 1
                    table.remove(noteSelection, idx)
                else
                    for i = 1, #noteSelection do
                        wasInSelection[noteSelection[i].idx] = 1
                    end
                    noteSelection = {}
                end
            elseif clear == true then
                for i = 1, #noteSelection do
                    wasInSelection[noteSelection[i].idx] = 1
                end
                noteSelection = {}
            end
        end
    end
    --add new notes to selection
    for i = 1, #newNotes do
        --pre check, if note is a note and not already in selection
        if newNotes[i].idx and not noteInSelection(newNotes[i]) then
            table.insert(noteSelection, newNotes[i])
            if wasInSelection[newNotes[i].idx] == 1 then
                wasInSelection[newNotes[i].idx] = 0
            else
                setNoteColor(newNotes[i], nil, true)
            end
        end
    end
    --change color of old notes back
    for key, val in pairs(wasInSelection) do
        if val == 1 and noteData[key] then
            setNoteColor(noteData[key])
        end
    end
    --jump sel start
    if #noteSelection > 0 then
        jumpToNoteInPattern("sel")
        --set control values
        if preferences.setVelPanDlyLenFromLastNote.value then
            --set note length
            if note_data and note_data.idx then
                currentNoteLength = note_data.len
                refreshControls = true
            end

            local vel, end_vel, pan, dly, end_dly, ins, len
            for i = 1, #noteSelection do
                if len == nil then
                    len = noteSelection[i].len
                elseif len ~= noteSelection[i].len then
                    len = "mixed"
                end
                if ins == nil then
                    ins = noteSelection[i].ins
                elseif ins ~= noteSelection[i].ins then
                    ins = "mixed"
                end
                if vel == nil then
                    vel = noteSelection[i].vel
                elseif type(vel) == "number" and vel ~= noteSelection[i].vel and noteSelection[i].vel < 129 then
                    vel = math.max(vel, noteSelection[i].vel)
                elseif vel ~= noteSelection[i].vel then
                    vel = "mixed"
                end
                if end_vel == nil then
                    end_vel = noteSelection[i].end_vel
                elseif type(end_vel) == "number" and end_vel ~= noteSelection[i].end_vel and noteSelection[i].end_vel < 129 then
                    end_vel = math.max(end_vel, noteSelection[i].end_vel)
                elseif end_vel ~= noteSelection[i].end_vel then
                    end_vel = "mixed"
                end
                if pan == nil then
                    pan = noteSelection[i].pan
                elseif type(pan) == "number" and pan ~= noteSelection[i].pan and noteSelection[i].pan < 129 then
                    pan = math.max(pan, noteSelection[i].pan)
                elseif pan ~= noteSelection[i].pan then
                    pan = "mixed"
                end
                if dly == nil then
                    dly = noteSelection[i].dly
                elseif dly ~= noteSelection[i].dly then
                    dly = math.max(dly, noteSelection[i].dly)
                end
                if end_dly == nil then
                    end_dly = noteSelection[i].end_dly
                elseif end_dly ~= noteSelection[i].end_dly then
                    end_dly = math.max(end_dly, noteSelection[i].end_dly)
                end
            end

            if vel == "mixed" and currentNoteVelocity ~= 255 then
                currentNoteVelocity = 255
                currentNoteVelocityPreview = 127
                refreshControls = true
            elseif type(vel) == "number" and vel ~= currentNoteVelocity then
                currentNoteVelocity = vel
                if currentNoteVelocity > 0 and currentNoteVelocity < 128 then
                    currentNoteVelocityPreview = currentNoteVelocity
                else
                    currentNoteVelocityPreview = 127
                end
                refreshControls = true
            end

            if type(ins) == "number" and ins ~= currentInstrument then
                currentInstrument = ins
                refreshControls = true
            end

            if type(len) == "number" and len ~= currentNoteLength then
                currentNoteLength = len
                refreshControls = true
            end

            if end_vel == "mixed" and currentNoteEndVelocity ~= 255 then
                currentNoteEndVelocity = 255
                refreshControls = true
            elseif type(end_vel) == "number" and end_vel ~= currentNoteEndVelocity then
                currentNoteEndVelocity = end_vel
                refreshControls = true
            end

            if pan == "mixed" and currentNotePan ~= 255 then
                currentNotePan = 255
                refreshControls = true
            elseif type(pan) == "number" and pan ~= currentNotePan then
                currentNotePan = pan
                refreshControls = true
            end

            if dly == "mixed" and currentNoteDelay ~= 0 then
                currentNoteDelay = 0
                refreshControls = true
            elseif type(dly) == "number" and dly ~= currentNoteDelay then
                currentNoteDelay = dly
                refreshControls = true
            end

            if end_dly == "mixed" and currentNoteEndDelay ~= 0 then
                currentNoteEndDelay = 0
                refreshControls = true
            elseif type(end_dly) == "number" and end_dly ~= currentNoteEndDelay then
                currentNoteEndDelay = end_dly
                refreshControls = true
            end
        end
        refreshHistogram = true
    else
        --refresh chord detection
        refreshChordDetection = true
        refreshHistogram = true
    end
end

--return true, when a note off was set
local function addNoteToPattern(column, line, len, note, vel, end_vel, pan, dly, end_dly, ins)
    local noteoff = false
    local lineValues = song.selected_pattern_track.lines

    lineValues[line]:note_column(column).note_value = note
    lineValues[line]:note_column(column).volume_string = toRenoiseHex(vel)
    lineValues[line]:note_column(column).panning_string = toRenoiseHex(pan)
    lineValues[line]:note_column(column).delay_string = toRenoiseHex(dly)
    lineValues[line]:note_column(column).instrument_value = ins
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
        --trigger after edit
        afterEditProcessTime = os.clock()
        return true
    end
    return false
end

--remove selected notes, resort all other notes on same line and bring them to free columns
local function removeSelectedNotes(cut)
    local notesOnLine = {}
    local note_data
    local column
    local lines = {}
    --get all lines
    for i = 1, #noteSelection do
        lines[noteSelection[i].line] = 1
    end
    --different undo description for cut
    if cut then
        setUndoDescription("Cut notes ...")
    else
        setUndoDescription("Delete notes ...")
    end
    --save all notes on current line and remove them
    for key in pairs(noteData) do
        note_data = noteData[key]
        for x in pairs(lines) do
            if note_data.line == x and not noteInSelection(note_data) then
                table.insert(notesOnLine, key)
                removeNoteInPattern(note_data.column, note_data.line, note_data.len)
                break
            end
        end
    end
    --sort notes by line and column
    table.sort(notesOnLine, function(a, b)
        local x = noteData[a].line
        local y = noteData[b].line
        if x == y then
            x = noteData[a].column
            y = noteData[b].column
        end
        return x < y
    end)
    --loop through selected notes
    for i = 1, #noteSelection do
        removeNoteInPattern(noteSelection[i].column, noteSelection[i].line, noteSelection[i].len)
    end
    updateNoteSelection(nil, true)
    --add other notes on this line back
    for i = 1, #notesOnLine do
        note_data = noteData[notesOnLine[i]]
        column = returnColumnWhenEnoughSpaceForNote(
                note_data.line,
                note_data.len,
                note_data.dly,
                note_data.end_dly
        )
        if column then
            note_data.column = column
        end
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
                note_data.ins
        )
        noteData[notesOnLine[i]] = note_data
    end
    refreshPianoRollNeeded = true
end

--simple function for double click detection for buttons
local function dbclkDetector(index)
    if lastClickIndex == index and lastClickCache[index] ~= nil and os.clock() - lastClickCache[index] < preferences.dblClickTime.value / 1000 then
        return true
    end
    lastClickCache[index] = os.clock()
    lastClickIndex = index
    return false
end

--refresh all controls
local function refreshNoteControls()
    local track = song.selected_track

    vbw.note_len.value = currentNoteLength

    if song.selected_track.volume_column_visible then
        -- velocity column visible
        vbw.notecolumn_vel.color = colorVelocity
        vbw.note_vel.active = true
        vbw.note_vel_clear.active = true
        if currentNoteVelocity == 255 then
            vbw.note_vel.value = -1
        else
            vbw.note_vel.value = currentNoteVelocity
        end
        if currentNoteVelocity > 0 and currentNoteVelocity < 128 then
            currentNoteVelocityPreview = currentNoteVelocity
            if preferences.setComputerKeyboardVelocity.value then
                song.transport.keyboard_velocity_enabled = true
                song.transport.keyboard_velocity = currentNoteVelocityPreview
            end
        else
            currentNoteVelocityPreview = 127
            if preferences.setComputerKeyboardVelocity.value then
                song.transport.keyboard_velocity_enabled = false
            end
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
    else
        vbw.notecolumn_pan.color = colorDefault
        vbw.note_pan.value = -1
        vbw.note_pan.active = false
        vbw.note_pan_clear.active = false
    end

    if song.selected_track.delay_column_visible then
        vbw.notecolumn_delay.color = colorDelay
        vbw.note_dly.value = currentNoteDelay
        vbw.note_dly.active = true
        vbw.note_dly_clear.active = true
        vbw.note_end_dly.value = currentNoteEndDelay
        vbw.note_end_dly.active = true
        vbw.note_end_dly_clear.active = true
    else
        vbw.notecolumn_delay.color = colorDefault
        vbw.note_dly.value = 0
        vbw.note_dly.active = false
        vbw.note_dly_clear.active = false
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

    local instruments = {}
    vbw.ins.active = false
    table.insert(instruments, "- Ghost note - [FF]")
    for i = 1, #song.instruments do
        if string.len(song.instruments[i].name) > 0 then
            table.insert(instruments, song.instruments[i].name .. " [" .. toRenoiseHex(i - 1) .. "]")
        else
            table.insert(instruments, "-- [" .. toRenoiseHex(i - 1) .. "]")
        end
    end
    vbw.ins.items = instruments
    if currentInstrument ~= nil then
        if currentInstrument == 255 then
            vbw.ins.value = 1
        elseif currentInstrument + 2 > #instruments then
            currentInstrument = nil
        else
            vbw.ins.value = currentInstrument + 2
        end
    end
    vbw.ins.active = true

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

    if loopingrange then
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
    if preferences.mirroringGhostTrack.value then
        vbw.ghosttrackmirror.color = colorStepOn
    else
        vbw.ghosttrackmirror.color = colorDefault
    end
    refreshControls = false
end

--simple note trigger
local function triggerNoteOfCurrentInstrument(note_value, pressed, velocity, newOrChanged, instrument)
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
    if instrument == nil then
        instrument = currentInstrument
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
                renoise.Osc.Message("/renoise/trigger/note_on", { { tag = "i", value = instrument + 1 },
                                                                  { tag = "i", value = song.selected_track_index },
                                                                  { tag = "i", value = note_value },
                                                                  { tag = "i", value = velocity } })
        )
        refreshChordDetection = true
    elseif pressed == false then
        notesPlaying[note_value] = nil
        notesPlayingLine[note_value] = nil
        successSend, errorSend = oscClient:send(
                renoise.Osc.Message("/renoise/trigger/note_off", { { tag = "i", value = instrument + 1 },
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
        if #lastTriggerNote > (polyLimit - 1) then
            local newLastTriggerNote = {}
            --stop playing older notes
            table.sort(lastTriggerNote, function(a, b)
                return a.time < b.time
            end)
            if preferences.previewMidiStuckWorkaround.value then
                --use idle function to send note off notes to prevent stuck notes of some vst plugins
                for i = 1, #lastTriggerNote do
                    if i <= math.max(1, #lastTriggerNote - preferences.previewPolyphony.value) then
                        lastTriggerNote[i].time = 0
                    end
                end
            else
                --just send note off's directly
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
        end
        local packet = { { tag = "i", value = instrument + 1 },
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
    if line == nil then
        if song.transport.edit_pos.sequence == song.transport.loop_start.sequence
                and song.transport.loop_start.line < song.selected_pattern.number_of_lines + 1 then
            line = song.transport.loop_start
        else
            line = 1
        end
    end
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
            table.sort(noteSelection, sortFunc.sortLeftOneFirst)
        else
            --right one notes first
            table.sort(noteSelection, sortFunc.sortRightOneFirst)
        end
    end
    --disable edit mode and following to prevent side effects
    song.transport.edit_mode = false
    if song.transport.follow_player then
        wasFollowPlayer = song.transport.follow_player
        song.transport.follow_player = false
    end
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
                noteSelection[key].ins
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
            table.sort(noteSelection, sortFunc.sortLeftOneFirst)
        else
            --right one notes first
            table.sort(noteSelection, sortFunc.sortRightOneFirst)
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
    if song.transport.follow_player then
        wasFollowPlayer = song.transport.follow_player
        song.transport.follow_player = false
    end
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
                noteSelection[key].ins
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
    if song.transport.follow_player then
        wasFollowPlayer = song.transport.follow_player
        song.transport.follow_player = false
    end
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
        triggerNoteOfCurrentInstrument(noteSelection[key].note, nil, nil, true, noteSelection[key].ins)
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
    if song.transport.follow_player then
        wasFollowPlayer = song.transport.follow_player
        song.transport.follow_player = false
    end
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
    updateNoteSelection(nil, true)
    --resort so column order stays
    table.sort(clipboard, sortFunc.sortFirstColumnFirst)
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
                clipboard[key].ins
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
    table.sort(noteSelection, sortFunc.sortLeftOneFirst)
    local first_line = noteSelection[1].line
    --change note order depends of scaling or shrinking
    if times > 1 then
        table.sort(noteSelection, sortFunc.sortRightOneFirst)
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
            elseif noteSelection[key].len > 1 and len == 1 then
                if toRenoiseHex(noteSelection[key].vel):sub(1, 1) == "Q" then
                    noteSelection[key].end_vel = noteSelection[key].vel
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
                noteSelection[key].ins
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
    table.sort(noteSelection, sortFunc.sortLeftOneFirst)
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
                    ins = noteSelection[key].ins
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
                        note_data.ins
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
    table.sort(noteSelection, sortFunc.sortLeftOneFirst)
    offset = noteSelection[1].line
    --last notes first
    table.sort(noteSelection, sortFunc.sortRightOneFirst)
    --get offset
    offset = (noteSelection[1].line + noteSelection[1].len) - offset
    --disable edit mode and following to prevent side effects
    song.transport.edit_mode = false
    if song.transport.follow_player then
        wasFollowPlayer = song.transport.follow_player
        song.transport.follow_player = false
    end
    --
    --remove offset to duplicate on same pos
    if noOffset then
        offset = 0
        setUndoDescription("Duplicate notes ...")
    else
        setUndoDescription("Duplicate notes to right ...")
    end
    --resort so column order stays
    table.sort(noteSelection, sortFunc.sortFirstColumnFirst)
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
                noteSelection[key].ins
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
    if song.transport.follow_player then
        wasFollowPlayer = song.transport.follow_player
        song.transport.follow_player = false
    end
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
            elseif noteSelection[key].len > 1 and len == 1 then
                if toRenoiseHex(noteSelection[key].vel):sub(1, 1) == "Q" then
                    noteSelection[key].end_vel = noteSelection[key].vel
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
                noteSelection[key].ins
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
    table.sort(noteSelection, sortFunc.sortLeftOneFirst)
    --disable edit mode and following to prevent side effects
    song.transport.edit_mode = false
    if song.transport.follow_player then
        wasFollowPlayer = song.transport.follow_player
        song.transport.follow_player = false
    end
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
            elseif noteSelection[key].len > 1 and len == 1 then
                if toRenoiseHex(noteSelection[key].vel):sub(1, 1) == "Q" then
                    noteSelection[key].end_vel = noteSelection[key].vel
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
                noteSelection[key].ins
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
local function changePropertiesOfSelectedNotes(vel, end_vel, dly, end_dly, pan, ins, pitch, special)
    local lineValues = song.selected_pattern_track.lines
    local temp
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
    elseif tostring(special) == "histogram" then
        setUndoDescription("Change note properties via histogram ...")
    else
        setUndoDescription("Change note properties ...")
    end
    --disable edit mode and following to prevent side effects
    song.transport.edit_mode = false
    if song.transport.follow_player then
        wasFollowPlayer = song.transport.follow_player
        song.transport.follow_player = false
    end
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
        elseif tostring(special) == "histogram" then
            if vel then
                if not temp then
                    temp = vel
                end
                vel = temp[key]
            elseif pan then
                if not temp then
                    temp = pan
                end
                pan = temp[key]
            elseif dly then
                if not temp then
                    temp = dly
                end
                dly = temp[key]
            elseif pitch then
                if not temp then
                    temp = pitch
                end
                pitch = temp[key]
            end
        end
        if ins ~= nil then
            note.instrument_value = ins
            selection.ins = ins
        end
        if vel ~= nil then
            if tostring(vel) == "mute" then
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
            note.panning_string = toRenoiseHex(pan)
            selection.pan = pan
        end
        if dly ~= nil then
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
                                selection.ins
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
                        selection.ins
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
        if pitch ~= nil then
            note.note_value = pitch
            noteSelection[key].note = note.note_value
        elseif special == "matchingnotes" then
            note.note_value = noteSelection[1].note
            noteSelection[key].note = note.note_value
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

--change note_value when not in scale or above limit
local function modifyNoteValueChord(note_value, last_note_value)
    if chordPainterForceInScale and not noteInScale(note_value) then
        if last_note_value ~= nil then
            if note_value - last_note_value > 2 then
                note_value = note_value - 1
            else
                note_value = note_value + 1
            end
        else
            note_value = note_value - 1
        end
    end
    if chordPainterUpperNoteLimit < 120 and note_value > chordPainterUpperNoteLimit then
        note_value = note_value - (12 * (math.floor((note_value - chordPainterUpperNoteLimit - 1) / 12) + 1))
    end
    return note_value
end

--color keyboard key
local function setKeyboardKeyColor(row, pressed, highlighted)
    local idx = "k" .. row
    if notesPlaying[gridOffset2NoteValue(row)] then
        vbw[idx].color = colorStepOn
    elseif highlighted then
        if preferences.useTrackColorFor.value == 2 then
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
        local n = math.min(song.selected_pattern.number_of_lines, gridWidth)
        for l = 1, n do
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
    setUndoDescription("Step sequencing notes ...")
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
                ins = currentInstrument
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
                        notedata.ins
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
                                notedata.ins
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
        if #noteSelection > 1 and not (modifier.keyShift or modifier.keyRShift) then
            note_data = noteSelection[#noteSelection]
            updateNoteSelection(note_data, true)
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
        updateNoteSelection(note_data, not addToSelection)
        return true
    end
    return false
end

--draw selection rectangle
local function drawRectangle(show, x, y, x2, y2)
    if not show then
        vbw["sel"].visible = false
    elseif x ~= nil and y ~= nil and x2 ~= nil and y2 ~= nil then
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
            vbw["seltop"].visible = true
            vbw["selbottom"].width = vbw["seltop"].width
            vbw["selbottom"].color = colorStepOn
            vbw["selbottom"].visible = true
            vbw["selheightspace"].height = math.max(1, (ry2 - ry) * (gridStepSizeH - 3)) + 9
            vbw["selleft"].height = vbw["selheightspace"].height + 10
            vbw["selleft"].color = colorStepOn
            vbw["selright"].height = vbw["selheightspace"].height + 10
            vbw["selright"].color = colorStepOn
            vbw["sel"].visible = true
        else
            vbw["sel"].visible = false
        end
    elseif x ~= nil then
        vbw["seltopspace"].height = 1
        vbw["seltopspace1"].height = vbw["seltopspace"].height
        vbw["seltopspace2"].height = vbw["seltopspace"].height
        vbw["seltop"].visible = false
        vbw["selbottom"].visible = false
        vbw["selleft"].height = gridHeight * (gridStepSizeH - 3)
        vbw["selleft"].color = colorStepOn
        if x > 1 then
            vbw["selleftspace"].width = (x - 1) * (gridStepSizeW - 4)
        else
            vbw["selleftspace"].width = 2
        end
        vbw["sel"].visible = true
    end
end

--add notes from a rectangle to the selection
local function selectRectangle(x, y, x2, y2, addToSelection)
    local smin = math.min(x, x2)
    local smax = math.max(x, x2)
    local nmin = gridOffset2NoteValue(math.min(y, y2))
    local nmax = gridOffset2NoteValue(math.max(y, y2))
    local note_data
    local newNoteSelection = {}
    local n = 0
    --loop through all notes
    for key in pairs(noteData) do
        note_data = noteData[key]
        if nmin <= note_data.note and
                nmax >= note_data.note and
                (
                        (smin >= note_data.step and smin <= note_data.step + note_data.len - 1) or
                                (smax >= note_data.step and smax <= note_data.step + note_data.len - 1) or
                                (note_data.step >= smin and note_data.step + note_data.len - 1 <= smax)
                )
        then
            --add to selection table
            n = n + 1
            newNoteSelection[n] = note_data
        end
    end
    updateNoteSelection(newNoteSelection, not addToSelection)
end

--keyboard preview
function keyClick(y, pressed)
    local note = gridOffset2NoteValue(y)
    --disable edit mode
    song.transport.edit_mode = false
    --select all note events which have the specific note
    if modifier.keyControl then
        if not pressed then
            local newNoteSelection = {}
            for key in pairs(noteData) do
                local note_data = noteData[key]
                if note_data.note == note and noteInSelection(note_data) == nil then
                    table.insert(newNoteSelection, note_data)
                end
            end
            updateNoteSelection(newNoteSelection, not modifier.keyShift)
        end
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
        xypadpos.disabled = {}
        --disable grid buttons, so these doesn't receive click events
        for i = 1, gridWidth do
            vbw["p" .. i .. "_" .. y].active = false
            table.insert(xypadpos.disabled, "p" .. i .. "_" .. y)
        end
        --disable all notes on step, so other notes doesn't receive click events
        for j = 1, note_data.len do
            local ns = noteOnStep[x + (j - 1)]
            if ns ~= nil and #ns > 0 then
                for i = 1, #ns do
                    if ns[i] ~= nil and ns[i].note == note_data.note and ns[i].index ~= index then
                        if vbw["b" .. ns[i].index] then
                            vbw["b" .. ns[i].index].active = false
                            table.insert(xypadpos.disabled, "b" .. ns[i].index)
                        end
                        if vbw["bs" .. ns[i].index] then
                            vbw["bs" .. ns[i].index].active = false
                            table.insert(xypadpos.disabled, "bs" .. ns[i].index)
                        end
                    end
                end
            end
        end
        --remove and add the clicked button, disable underlaying buttons, so the xypad in the background
        --can receive the click event, remove/add trick from joule:
        --https://forum.renoise.com/t/custom-sliders-demo-including-the-panning-slider/48921/6
        local rowidx = noteValue2GridRowOffset(note_data.note, true)
        vbw["row" .. rowidx]:remove_child(vbw["bc" .. index])
        vbw["row" .. rowidx]:add_child(vbw["bc" .. index])
        if forceScaling then
            vbw["b" .. index].active = false
            table.insert(xypadpos.disabled, "b" .. index)
        end
        xypadpos.leftClick = true
        xypadpos.selection_key = noteInSelection(note_data)
        xypadpos.idx = note_data.idx
        xypadpos.lastx = -1
        xypadpos.nx = x
        xypadpos.ny = y
        xypadpos.nlen = note_data.len
        xypadpos.previewmode = false
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
        xypadpos.duplicate = (modifier.keyShift or modifier.keyControl) and (not checkMode("pen") or preferences.moveNoteInPenMode.value) and not modifier.keyAlt
        xypadpos.time = os.clock()
        triggerNoteOfCurrentInstrument(note_data.note, nil, note_data.vel, true, note_data.ins)
        return
    end

    if checkMode("preview") then
        triggerNoteOfCurrentInstrument(note_data.note, not released, note_data.vel, nil, note_data.ins)
        if row ~= nil then
            setKeyboardKeyColor(row, not released, false)
            highlightNoteRow(row, not released)
        end
    end

    if released then
        local dbclk
        if not forceScaling then
            dbclk = dbclkDetector("b" .. index)
        end
        --remove on dblclk or when in penmode or previewmode
        if (checkMode("pen") and not preferences.moveNoteInPenMode.value) or (dbclk and not checkMode("preview")) then
            --set clicked note as selected for remove function
            if note_data ~= nil then
                if preferences.disableAltClickNoteRemove.value and modifier.keyAlt then
                    --dont delete notes, when use altKey in non pen mode
                    updateNoteSelection(note_data, note_data)
                else
                    updateNoteSelection(note_data, true)
                    removeSelectedNotes()
                end
            end
        else
            if note_data ~= nil then
                if not checkMode("preview") then
                    --clear selection, when ctrl is not holded
                    if #noteSelection > 0 and modifier.keyControl and not forceScaling then
                        updateNoteSelection(note_data, note_data)
                    else
                        updateNoteSelection(note_data, "note")
                    end
                end
            end
        end
    end
end

--will be called, when an empty grid button was clicked
function pianoGridClick(x, y, released)
    local index = tostring(x) .. "_" .. tostring(y)
    local outside = false
    local noteDrawn = {}

    --just allow selection, deselect notes, when pos is outside the grid
    if x + stepOffset > song.selected_pattern.number_of_lines then
        outside = true
    end

    if not released and
            (
                    (not checkMode("preview") and not modifier.keyControl and not (outside and checkMode("pen")))
                            or (checkMode("preview") and not preferences.mouseWarpingCompatibilityMode.value)
            )
    then
        xypadpos.disabled = {}
        --deselect current notes, when outside was clicked
        if outside and #noteSelection > 0 then
            updateNoteSelection(nil, true)
        end
        --remove and add the clicked button, disable all buttons in the row, so the xypad in the background can
        --receive the click event remove/add trick from joule:
        --https://forum.renoise.com/t/custom-sliders-demo-including-the-panning-slider/48921/6
        --disabled buttons need to be enabled again outside this call when just one click was triggered
        for i = 1, gridWidth do
            vbw["p" .. i .. "_" .. y].active = false
            table.insert(xypadpos.disabled, "p" .. i .. "_" .. y)
            --prevent accidentally note drawing "twins", when piano grid buttons overlap
            if vbw["p" .. i .. "_" .. y + 1] then
                vbw["p" .. i .. "_" .. y + 1].active = false
                table.insert(xypadpos.disabled, "p" .. i .. "_" .. y + 1)
            end
        end
        vbw["ppp" .. index]:remove_child(vbw["p" .. index])
        vbw["ppp" .. index]:remove_child(vbw["ps" .. index])
        vbw["ppp" .. index]:add_child(vbw["p" .. index])
        vbw["ppp" .. index]:add_child(vbw["ps" .. index])
        xypadpos.nx = x
        xypadpos.ny = y
        xypadpos.preview = {}
        xypadpos.previewmode = false
        xypadpos.scalemode = false
        xypadpos.resetscale = false
        xypadpos.notemode = false
        xypadpos.time = os.clock()
        if checkMode("preview") and not preferences.mouseWarpingCompatibilityMode.value then
            xypadpos.previewmode = true
            xypadpos.leftClick = true
        elseif checkMode("pen") then
            xypadpos.scalemode = true
            xypadpos.resetscale = true
            xypadpos.notemode = true
            xypadpos.previewmode = false
        else
            xypadpos.notemode = false
            xypadpos.leftClick = true
        end
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
                triggerNoteOfCurrentInstrument(note_data.note, not released, note_data.vel, false, note_data.ins)
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
            local last_note_value
            local column
            local note_value
            local noteoff
            local notesOnLine
            local note_data
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
            for cidx = 1, #chordPainter do
                notesOnLine = {}
                note_value = gridOffset2NoteValue(y + chordPainter[cidx])
                note_value = modifyNoteValueChord(note_value, last_note_value)
                if note_value >= 0 and note_value <= 120 and not noteDrawn[note_value] then
                    last_note_value = note_value
                    --prevent duplicate notes
                    noteDrawn[note_value] = true
                    --pre check if there is enough space
                    column = returnColumnWhenEnoughSpaceForNote(x, currentNoteLength, currentNoteDelay, currentNoteEndDelay)
                    --no column found
                    if column == nil then
                        --no space for this note
                        return false
                    end
                    --
                    setUndoDescription("Draw a note ...")
                    --save all notes on current line and remove them
                    for key in pairs(noteData) do
                        note_data = noteData[key]
                        if note_data.line == x then
                            table.insert(notesOnLine, key)
                            removeNoteInPattern(note_data.column, note_data.line, note_data.len)
                        end
                    end
                    --sort notes by column
                    table.sort(notesOnLine, function(a, b)
                        return noteData[a].column < noteData[b].column
                    end)
                    --add new note, so its the first one on line, better for legato porta
                    column = returnColumnWhenEnoughSpaceForNote(x, currentNoteLength, currentNoteDelay, currentNoteEndDelay)
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
                            currentInstrument
                    )
                    --create note data table
                    note_data = {
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
                        ins = currentInstrument
                    }
                    --clear selection and add new note as new selection
                    if cidx > 1 then
                        updateNoteSelection(note_data, false)
                    else
                        updateNoteSelection(note_data, true)
                    end
                    --add other notes on this line back
                    for i = 1, #notesOnLine do
                        note_data = noteData[notesOnLine[i]]
                        column = returnColumnWhenEnoughSpaceForNote(
                                note_data.line,
                                note_data.len,
                                note_data.dly,
                                note_data.end_dly
                        )
                        if column then
                            note_data.column = column
                        end
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
                                note_data.ins
                        )
                        noteData[notesOnLine[i]] = note_data
                    end
                else
                    showStatus("Some notes are outside the valid range or have already been drawn. These notes were skipped.")
                end
            end
            --trigger new notes
            for i = 1, #noteSelection do
                triggerNoteOfCurrentInstrument(noteSelection[i].note, nil, nil, true, noteSelection[i].ins)
            end
            --
            refreshPianoRollNeeded = true
            refreshChordDetection = true
        else
            --fast play from cursor
            if modifier.keyControl and not modifier.keyAlt and not modifier.keyShift then
                playPatternFromLine(x + stepOffset)
            else
                --deselect selected notes
                if #noteSelection > 0 then
                    if not modifier.keyShift then
                        updateNoteSelection(nil, true)
                        jumpToNoteInPattern(x + stepOffset)
                    end
                elseif preferences.resetVolPanDlyControlOnClick.value then
                    jumpToNoteInPattern(x + stepOffset)
                    --nothing selected reset vol, pan and dly
                    currentNoteVelocity = 255
                    currentNotePan = 255
                    currentNoteDelay = 0
                    currentNoteEndDelay = 0
                    currentNoteVelocityPreview = 127
                    currentNoteEndVelocity = 255
                    refreshControls = true
                else
                    jumpToNoteInPattern(x + stepOffset)
                end
            end
        end
    end
end

--enable a note button, when its visible, set correct length of the button
local function drawNotesToGrid(allNotes)
    local l_song = song
    local l_song_transport = l_song.transport
    local l_song_st = l_song.selected_track
    local l_vbw = vbw
    local l_math_min = math.min
    local l_math_max = math.max
    local l_math_floor = math.floor
    local l_table_insert = table.insert
    local l_string_gsub = string.gsub
    local l_string_sub = string.sub
    local l_string_len = string.len
    local allNotes_length = #allNotes
    local isInSelection
    local isScaleBtnHidden
    local column
    local current_note_line
    local current_note_step
    local current_note_rowIndex
    local current_note
    local current_note_len
    local current_note_string
    local current_note_vel
    local current_note_end_vel
    local current_note_pan
    local current_note_dly
    local current_note_end_dly
    local current_note_ins
    local noteoff
    local noteWidth
    local buttonWidth
    local buttonSpace
    local spaceWidth
    local retriggerWidth
    local delayWidth
    local addWidth
    local cutValue
    local rTpl
    local n

    --resort, left ones first, higest column
    if allNotes_length > 1 then
        table.sort(allNotes, function(a, b)
            local v1 = a[2]
            local v2 = b[2]
            if a[11] then
                v1 = v1 + a[11] / 0x100
            end
            if b[11] then
                v2 = v2 + b[11] / 0x100
            end
            if v1 == v2 then
                v2 = a[6]
                v1 = b[6]
            end
            if v1 == v2 then
                v1 = a[1]
                v2 = b[1]
            end
            return v1 < v2
        end)
    end

    for j = 1, allNotes_length do

        isInSelection = false
        isScaleBtnHidden = false

        column = allNotes[j][1]
        current_note_line = allNotes[j][2]
        current_note_step = allNotes[j][3]
        current_note_rowIndex = allNotes[j][4]
        current_note = allNotes[j][5]
        current_note_len = allNotes[j][6]
        current_note_string = allNotes[j][7]
        current_note_vel = allNotes[j][8]
        current_note_end_vel = allNotes[j][9]
        current_note_pan = allNotes[j][10]
        current_note_dly = allNotes[j][11]
        current_note_end_dly = allNotes[j][12]
        current_note_ins = allNotes[j][13]
        noteoff = allNotes[j][14]

        --save highest and lowest note
        if lowestNote == nil then
            lowestNote = current_note
        end
        if highestNote == nil then
            highestNote = current_note
        end

        lowestNote = l_math_min(lowestNote, current_note)
        highestNote = l_math_max(highestNote, current_note)

        if current_note_rowIndex ~= nil then
            local noteOnStepIndex = current_note_step
            local current_note_index = tostring(current_note_step) .. "_" .. tostring(current_note_rowIndex) .. "_" .. tostring(column)
            local current_note_param = "noteClick(" .. l_string_gsub(current_note_index, "_", ",")
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
                ins = current_note_ins,
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
                column = column
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
                n = current_note_len - 1
                --when cut value is set, then change note length to 1
                if (l_song_st.volume_column_visible and current_note_vel >= 192 and current_note_vel <= 207) or
                        (l_song_st.panning_column_visible and current_note_pan >= 192 and current_note_pan <= 207)
                then
                    n = 0
                end
                for i = 0, n do
                    --only when velocity is not 0 (muted)
                    if current_note_vel > 0 then
                        if noteOnStep[noteOnStepIndex + i] == nil then
                            noteOnStep[noteOnStepIndex + i] = {}
                        end
                        l_table_insert(noteOnStep[noteOnStepIndex + i], {
                            index = current_note_index,
                            step = current_note_step,
                            row = current_note_rowIndex,
                            note = current_note,
                            len = current_note_len - i,
                            vel = current_note_vel,
                            ins = current_note_ins
                        })
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
                elseif current_note_step + current_note_len > gridWidth + 1 and current_note_step <= gridWidth then
                    current_note_len = current_note_len - (current_note_step + current_note_len - gridWidth - 1)
                    isScaleBtnHidden = true
                end
                if current_note_len > gridWidth then
                    current_note_len = gridWidth
                end

                --display note button, note len is greater 0 and when the row is visible
                if current_note_len > 0 then
                    spaceWidth = 0
                    retriggerWidth = 0
                    delayWidth = 0
                    addWidth = 0
                    cutValue = nil

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
                            if not cutValue or (cutValue > 0 and current_note_pan < cutValue) then
                                cutValue = current_note_pan
                            end
                        elseif current_note_pan >= 416 and current_note_pan <= 431 then
                            delayWidth = current_note_pan
                        elseif current_note_pan >= 432 and current_note_pan <= 447 then
                            retriggerWidth = current_note_pan
                        end
                    end

                    buttonWidth = (gridStepSizeW) * current_note_len
                    buttonSpace = gridSpacing * (current_note_len - 1)

                    if delayWidth > 0 then
                        delayWidth = delayWidth - 416
                        if delayWidth < l_song_transport.tpl then
                            delayWidth = l_math_floor(0x100 / l_song_transport.tpl * delayWidth)
                        else
                            delayWidth = 0
                        end
                    end

                    if cutValue and cutValue > 0 then
                        cutValue = cutValue - 192
                        if cutValue < l_song_transport.tpl then
                            buttonWidth = buttonWidth - ((gridStepSizeW - gridSpacing) / 100 * (100 / l_song_transport.tpl * (l_song_transport.tpl - cutValue)))
                        end
                    end

                    l_vbw["bc" .. current_note_index] = nil
                    local btn = vb:row {
                        margin = -gridMargin,
                        spacing = -gridSpacing,
                        id = "bc" .. current_note_index,
                    }

                    if current_note_step > 1 then
                        spaceWidth = (gridStepSizeW * (current_note_step - 1)) - (gridSpacing * (current_note_step - 2))
                    end

                    if l_song_st.delay_column_visible then
                        if current_note_dly > 0 then
                            delayWidth = l_math_max(current_note_dly, delayWidth)
                        end
                        if current_note_end_dly > 0 then
                            addWidth = l_math_max(current_note_end_dly, addWidth)
                        end
                    end

                    if delayWidth > 0 and stepOffset < current_note_line then
                        delayWidth = l_math_max(l_math_floor((gridStepSizeW - gridSpacing) / 0x100 * delayWidth), 1)
                        spaceWidth = spaceWidth + delayWidth
                        buttonWidth = buttonWidth - delayWidth
                        if current_note_step < 2 then
                            spaceWidth = spaceWidth + gridSpacing
                        end
                    end

                    if addWidth > 0 and (current_note_step + current_note_len) - 1 < gridWidth then
                        addWidth = l_math_max(l_math_floor((gridStepSizeW - gridSpacing) / 0x100 * addWidth), 1)
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

                    noteWidth = l_math_max(buttonWidth - buttonSpace - 1, l_math_max(1, preferences.minSizeOfNoteButton.value + preferences.clickAreaSizeForScalingPx.value))

                    if not isScaleBtnHidden then
                        noteWidth = noteWidth - preferences.clickAreaSizeForScalingPx.value + 4
                    end

                    l_vbw["b" .. current_note_index] = nil
                    local btn_body = vb:row {
                        spacing = -2,
                        vb:button {
                            id = "b" .. current_note_index,
                            height = gridStepSizeH,
                            width = noteWidth,
                            text = current_note_string,
                            notifier = loadstring(current_note_param .. ",true)"),
                            pressed = loadstring(current_note_param .. ",false)")
                        },
                    }

                    if not noteButtons[current_note_rowIndex] then
                        noteButtons[current_note_rowIndex] = {}
                    end

                    if not isScaleBtnHidden then
                        l_vbw["bs" .. current_note_index] = nil
                        btn_body:add_child(
                                vb:row {
                                    spacing = -3,
                                    vb:space {
                                        width = 1,
                                    },
                                    vb:button {
                                        id = "bs" .. current_note_index,
                                        height = gridStepSizeH,
                                        width = preferences.clickAreaSizeForScalingPx.value,
                                        notifier = loadstring(current_note_param .. ",true,true)"),
                                        pressed = loadstring(current_note_param .. ",false,true)")
                                    }
                                }
                        )
                    end

                    --shorten note button text, when its too large
                    if l_vbw["b" .. current_note_index].width > noteWidth then
                        current_note_string = l_string_gsub(current_note_string, '-', '')
                        l_vbw["b" .. current_note_index].width = noteWidth
                        l_vbw["b" .. current_note_index].text = current_note_string
                        if l_vbw["b" .. current_note_index].width > noteWidth then
                            l_vbw["b" .. current_note_index].width = noteWidth
                            l_vbw["b" .. current_note_index].text = l_string_sub(current_note_string, 1, l_string_len(current_note_string) - 1)
                            if l_vbw["b" .. current_note_index].width > noteWidth then
                                l_vbw["b" .. current_note_index].text = ""
                                l_vbw["b" .. current_note_index].width = noteWidth
                            end
                        end
                    end

                    --add button body
                    btn:add_child(btn_body);

                    l_table_insert(noteButtons[current_note_rowIndex], btn);
                    l_vbw["row" .. current_note_rowIndex]:add_child(btn)

                    --set color
                    setNoteColor(noteData[current_note_index], false, isInSelection, current_note_ins)

                    --display retrigger effect
                    if retriggerWidth > 0 then
                        spaceWidth = l_math_max(spaceWidth, 4)
                        rTpl = l_song_transport.tpl - 1
                        if cutValue and cutValue > 0 and cutValue < l_song_transport.tpl and current_note_len == 1 then
                            rTpl = rTpl + (cutValue - 0xf)
                        end
                        n = 1
                        for spc = retriggerWidth, rTpl, retriggerWidth do
                            l_vbw["br" .. current_note_index .. "_" .. n] = nil
                            local retrigger = vb:row {
                                id = "br" .. current_note_index .. "_" .. n,
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
                                            active = false,
                                        }
                                    }
                            );
                            l_table_insert(noteButtons[current_note_rowIndex], retrigger);
                            l_vbw["row" .. current_note_rowIndex]:add_child(retrigger)
                            n = n + 1
                        end
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
    local math_ceil = math.ceil
    --setup timeline
    local timestep = 0
    local lastbeat
    local timeslot
    local timeslotsize = 1
    for i = 1, stepsCount do
        local line = i + stepOffset
        local beat = math_ceil((line - lpb) / lpb) % 4 + 1
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
    if loopingrange == nil then
        hideblockloop = true
    else
        --calculate width and start pos for block loop line indicator
        local len = song.transport.loop_range[2].line - song.transport.loop_range[1].line
        if song.transport.edit_pos.sequence == song.transport.loop_end.sequence - 1 and song.transport.loop_end.line == 1 then
            len = song.selected_pattern.number_of_lines + 1 - song.transport.loop_range[1].line
        end
        local pos = song.transport.loop_range[1].line
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
            vbw.blockloop.width = gridStepSizeW * len - (gridSpacing * (len - 1)) - 1
            vbw.blockloopspc.width = math.max(gridStepSizeW * (pos - 1) - (gridSpacing * (pos - 1)) + 4, 4)
            vbw.blockloop.color = colorNoteSelected
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
    local mirrorMode = preferences.mirroringGhostTrack.value
    local note, note_column, rowoffset
    for c = 1, columns do
        rowoffset = nil

        if stepOffset > 0 then
            for i = stepOffset + 1, 1, -1 do
                note_column = lineValues[i]:note_column(c)
                note = note_column.note_value
                if note < 120 then
                    rowoffset = noteValue2GridRowOffset(note, mirrorMode)
                    break
                elseif note == 120 then
                    break
                end
            end
        end

        for s = 1, stepsCount do
            note_column = lineValues[s + stepOffset]:note_column(c)
            note = note_column.note_value

            if note < 120 then
                rowoffset = noteValue2GridRowOffset(note, mirrorMode)
            elseif note == 120 then
                rowoffset = nil
            end

            if rowoffset then
                local idx = "p" .. s .. "_"
                local p
                p = vbw[idx .. rowoffset]
                if p then
                    p.color = colorGhostTrackNote
                    defaultColor[idx] = p.color
                end
                if mirrorMode then
                    for i = -108, 108, 12 do
                        p = vbw[idx .. (rowoffset + i)]
                        if p then
                            p.color = colorGhostTrackNote
                            defaultColor[idx] = p.color
                        end
                    end
                end
            end
        end
    end
end

--switch to current selected ghost if possible
local function switchGhostTrack()
    if currentGhostTrack and currentGhostTrack ~= song.selected_track_index then
        local temp = currentGhostTrack
        vbw.ghosttracks.value = song.selected_track_index
        song.selected_track_index = temp
    else
        showStatus("Info: Can't switch to ghost track, please select a ghost track first.")
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
        else
            idx = idx + 1
        end
        local scale_key
        local scale_mode
        if song.instruments[idx] then
            scale_key = song.instruments[idx].trigger_options.scale_key
            scale_mode = song.instruments[idx].trigger_options.scale_mode
        end

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

--returns corresponding numeral and degree
local function romanNumeralsAndScaleDegree(scale, note, chordname)
    --realign note
    local roman
    local before = ""
    local after = ""
    local secDom = false
    local name
    note = (note - (currentScaleOffset - 1)) % 12
    if scale == 2 then
        if note == 0 then
            roman = "I"
            name = "Tonic"
            if chordname and chordname == "7" then
                roman = "V7/IV"
                secDom = true
            end
        elseif note == 2 then
            roman = "ii"
            name = "Supertonic"
            if chordname and (chordname == "Maj" or chordname == "7") then
                if chordname == "7" then
                    roman = "V7/V"
                else
                    roman = "V/V"
                end
                secDom = true
            end
        elseif note == 3 then
            roman = "III"
            before = "b"
            name = "Flattened Third"
            if chordname and (chordname == "Maj" or chordname == "7") then
                if chordname == "7" then
                    roman = "V7/bVI"
                else
                    roman = "V/bVI"
                end
                secDom = true
            end
        elseif note == 4 then
            roman = "iii"
            name = "Mediant"
            if chordname and (chordname == "Maj" or chordname == "7") then
                if chordname == "7" then
                    roman = "V7/vi"
                else
                    roman = "V/vi"
                end
                secDom = true
            end
        elseif note == 5 then
            roman = "IV"
            name = "Subdominant"
            if chordname and chordname == "7" then
                roman = "V7/bVII"
                secDom = true
            end
        elseif note == 7 then
            roman = "V"
            name = "Dominant"
        elseif note == 8 then
            roman = "VI"
            before = "b"
            name = "Flattened Sixth"
        elseif note == 9 then
            roman = "vi"
            name = "Submediant"
            if chordname and (chordname == "Maj" or chordname == "7") then
                if chordname == "7" then
                    roman = "V7/ii"
                else
                    roman = "V/ii"
                end
                secDom = true
            end
        elseif note == 10 then
            roman = "VII"
            before = "b"
            name = "Flattened Seventh"
        elseif note == 11 then
            roman = "vii"
            name = "Leading tone"
            if chordname and (chordname == "Maj" or chordname == "7") then
                if chordname == "7" then
                    roman = "V7/iii"
                else
                    roman = "V/iii"
                end
                secDom = true
            end
        else
            return "-"
        end
    elseif scale == 3 then
        if note == 0 then
            roman = "i"
            name = "Tonic"
            if chordname and (chordname == "Maj" or chordname == "7") then
                if chordname == "7" then
                    roman = "V7/iv"
                else
                    roman = "V/iv"
                end
                secDom = true
            end
        elseif note == 2 then
            roman = "ii"
            name = "Supertonic"
            if chordname and (chordname == "Maj" or chordname == "7") then
                if chordname == "7" then
                    roman = "V7/v"
                else
                    roman = "V/v"
                end
                secDom = true
            end
        elseif note == 3 then
            roman = "III"
            name = "Mediant"
            if chordname and chordname == "7" then
                roman = "V7/VI"
                secDom = true
            end
        elseif note == 5 then
            roman = "iv"
            name = "Subdominant"
            if chordname and (chordname == "Maj" or chordname == "7") then
                if chordname == "7" then
                    roman = "V7/VII"
                else
                    roman = "V/VII"
                end
                secDom = true
            end
        elseif note == 7 then
            roman = "v"
            name = "Dominant"
            if chordname and (chordname == "Maj" or chordname == "7") then
                if chordname == "7" then
                    roman = "V7/i"
                else
                    roman = "V/i"
                end
                secDom = true
            end
        elseif note == 8 then
            roman = "VI"
            name = "Submediant"
        elseif note == 10 then
            roman = "VII"
            name = "Subtonic"
        else
            return "-"
        end
    else
        return "-"
    end
    if secDom then
        name = " - Secondary Dominant"
    elseif name ~= "" then
        name = " - " .. name
    end
    --change case of numeral, if needed
    if chordname ~= nil and not secDom then
        if string.match(chordname, '^Maj7') or chordname == '7' then
            roman = string.upper(roman)
            after = "7"
        elseif string.match(chordname, '^Maj9') or chordname == '9' then
            roman = string.upper(roman)
            after = "9"
        elseif string.match(chordname, '^min7') then
            roman = string.lower(roman)
            after = "7"
        elseif string.match(chordname, '^min9') then
            roman = string.lower(roman)
            after = "9"
        elseif string.match(chordname, '^Maj') then
            roman = string.upper(roman)
        elseif string.match(chordname, '^min') then
            roman = string.lower(roman)
        elseif string.match(chordname, '^dim') then
            roman = string.lower(roman)
            after = "°"
        elseif string.match(chordname, '^aug') then
            roman = string.upper(roman)
            after = "+"
        elseif string.match(chordname, '^Sus') then
            roman = string.upper(roman)
            after = "sus"
        end
    end
    return before .. roman .. after .. name
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
                    chord = notesTable[distance_string[i].note % 12 + 1] .. " " .. chordsTable[distance_string[i].key]
                    chordprog = romanNumeralsAndScaleDegree(currentScale, distance_string[i].note, chordsTable[distance_string[i].key])
                    break
                end
            end
        end
        if not chord and #rawnotes > 0 then
            if #rawnotes == 2 and rawnotes[1] % 12 == rawnotes[2] % 12 then
                chord = notesTable[rawnotes[1] % 12 + 1] .. " Octave"
            elseif #rawnotes == 1 then
                chord = notesTable[rawnotes[1] % 12 + 1] .. " unison"
            end
            chordprog = romanNumeralsAndScaleDegree(currentScale, rawnotes[1])
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
    local n = 0
    notesOnStep = {}
    if noteOnStep[step] ~= nil and #noteOnStep[step] > 0 then
        for i = 1, #noteOnStep[step] do
            --when notes are on current step and not selected
            if noteOnStep[step][i] ~= nil then
                local note = noteOnStep[step][i]
                local idx = "b" .. note.index
                local sidx = "bs" .. note.index
                n = n + 1
                notesOnStep[n] = note.note
                if vbw[idx] then
                    rows[note.row] = note.note
                    if highlight then
                        if not noteData[note.index] or not noteInSelection(noteData[note.index]) then
                            if preferences.useTrackColorFor.value == 2 then
                                vbw[idx].color = vbw["trackcolor"].color
                            else
                                vbw[idx].color = colorNoteHighlight
                            end
                        end
                    else
                        if not noteData[note.index] or not noteInSelection(noteData[note.index]) then
                            vbw[idx].color = colorNoteVelocity(note.vel, nil, nil, note.ins)
                        end
                    end
                    if vbw[sidx] then
                        vbw[sidx].color = shadeColor(vbw[idx].color, preferences.scaleBtnShadingAmount.value)
                    end
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

--process some features, which should be triggered once after a change
local function afterEditProcess()
    local l_song = song
    local patterns = l_song.patterns
    local maxColumns = l_song.selected_track.visible_note_columns
    local patternTrack
    local lineValues
    local note_column
    local empty
    --reset timer
    afterEditProcessTime = nil
    setUndoDescription("Automatically add note offs and reduce note columns ...")
    --go through active columns on all patterns, remove column if needed
    if maxColumns > 1 and preferences.addNoteColumnsIfNeeded.value then
        for c = maxColumns, 2, -1 do
            empty = true
            for i = 1, #patterns do
                patternTrack = patterns[i]:track(l_song.selected_track_index)
                lineValues = patternTrack.lines
                for line = 1, #patternTrack.lines do
                    note_column = lineValues[line]:note_column(c)
                    if not note_column.is_empty then
                        if not (line == 1 and note_column.note_value == 120) then
                            empty = false
                            break
                        end
                    end
                end
                if not empty then
                    break
                end
            end
            if not empty then
                break
            else
                l_song.selected_track.visible_note_columns = c - 1
            end
        end
    end
    --add missing note off for current track
    if preferences.addNoteOffToEmptyNoteColumns.value then
        maxColumns = l_song.selected_track.visible_note_columns
        patternTrack = patterns[l_song.selected_pattern_index]:track(l_song.selected_track_index)
        lineValues = patternTrack.lines
        for c = 1, maxColumns do
            note_column = lineValues[1]:note_column(c)
            if note_column.note_value == 121 then
                note_column.note_value = 120
            end
        end
    end
end

--reset pianoroll and enable notes
local function fillPianoRoll(quickRefresh)
    local l_vbw = vbw
    local l_song = song
    local l_math_floor = math.floor
    local track = l_song.selected_track
    local steps = l_song.selected_pattern.number_of_lines
    local lpb = l_song.transport.lpb
    local lineValues = l_song.selected_pattern_track.lines
    local columns = track.visible_note_columns
    local stepsCount = math.min(steps, gridWidth)
    local noffset = noteOffset - 1
    local blackKey
    local temp
    local newNotes = {}
    local newNotes_length = 0
    local usedInstruments = {}
    local noteIndexCache = {}

    --set auto ghost track
    if preferences.setLastEditedTrackAsGhost.value and lastTrackIndex and lastTrackIndex ~= l_song.selected_track_index and lastTrackIndex <= song.sequencer_track_count then
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
        local current_note_string
        local current_note_ins = 0
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
                local beat = calculateBarBeat(s + stepOffset, true, lpb)
                local bb = (bar - 1) * 4 + (beat - 1)

                for y = 1, gridHeight do
                    local ystring = tostring(y)
                    local index = stepString .. "_" .. ystring
                    local p = l_vbw["p" .. index]
                    local ps = l_vbw["ps" .. index]
                    local color = colorWhiteKey[bb % 8 + 1]
                    local yPLusOffMod12 = (y + noffset) % 12
                    p.active = true

                    if s < stepsCount and (
                            (preferences.gridVLines.value == 2 and (s + stepOffset) % (lpb * 4) == 0) or
                                    (preferences.gridVLines.value == 3 and (s + stepOffset) % lpb == 0))
                    then
                        p.width = gridStepSizeW - 2
                        ps.width = 2
                    else
                        p.width = gridStepSizeW - 1
                        ps.width = 1
                    end

                    if
                    currentScaleOffset and (
                            (preferences.gridHLines.value == 2 and (y + noteOffset) % 12 == 1) or
                                    (preferences.gridHLines.value == 3 and (y + noteOffset - currentScaleOffset) % 12 == 0))
                    then
                        p.height = gridStepSizeH - 1
                    else
                        p.height = gridStepSizeH
                    end

                    if noteIndexCache[yPLusOffMod12] == nil then
                        noteIndexCache[yPLusOffMod12] = noteInScale(yPLusOffMod12)
                    end
                    blackKey = not noteIndexCache[yPLusOffMod12]
                    --color black notes
                    if blackKey then
                        color = colorBlackKey[bb % 8 + 1]
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
                        --refresh keyboard
                        if s == 1 then
                            local idx = "k" .. ystring
                            local key = l_vbw[idx]
                            local isRootKey = false
                            local outOfPentatnicScale = false
                            local nIdx
                            if preferences.scaleHighlightingType.value ~= 5 then
                                nIdx = noteIndexInScale(yPLusOffMod12)
                                if nIdx == 5 or nIdx == 11 then
                                    outOfPentatnicScale = true
                                end
                                if currentScale == 2 then
                                    if nIdx == 0 then
                                        isRootKey = true
                                    end
                                elseif currentScale == 3 then
                                    if nIdx == 9 then
                                        isRootKey = true
                                    end
                                end
                            elseif preferences.scaleHighlightingType.value == 5 and currentScale == 2 and noteIndexInScale(yPLusOffMod12) == 0 then
                                isRootKey = true
                            end
                            if preferences.keyboardStyle.value == 2 then
                                defaultColor[idx] = colorList
                            elseif noteInScale(yPLusOffMod12, true) then
                                defaultColor[idx] = colorKeyWhite
                            else
                                defaultColor[idx] = colorKeyBlack
                            end
                            if isRootKey then
                                defaultColor[idx] = shadeColor(defaultColor[idx], preferences.rootKeyShadingAmount.value)
                            elseif outOfPentatnicScale then
                                defaultColor[idx] = alphablendColors(defaultColor[idx], colorNoteHighlight2, preferences.outOfPentatonicScaleHighlightingAmount.value)
                            end
                            if notesPlaying[y + noffset] then
                                key.color = colorStepOn
                            else
                                key.color = defaultColor[idx]
                            end
                            --set root label
                            if preferences.keyLabels.value == 4 or
                                    (preferences.keyLabels.value == 2 and (
                                            ((currentScale == 1 or (preferences.scaleHighlightingType.value == 5 and currentScale == 1)) and noteIndexInScale(yPLusOffMod12, true) == 0) or
                                                    isRootKey))
                                    or
                                    (preferences.keyLabels.value == 3 and
                                            noteInScale(yPLusOffMod12))
                            then
                                local note = notesTable[yPLusOffMod12 + 1]
                                if string.len(note) == 1 then
                                    note = note .. "-"
                                end
                                if preferences.keyboardStyle.value == 2 then
                                    key.text = note .. tostring(l_math_floor((y + noffset) / 12)) .. "         "
                                else
                                    key.text = "         " .. note .. tostring(l_math_floor((y + noffset) / 12))
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

            if note < 120 then
                if currentInstrument == nil and note_column.instrument_value < 255 then
                    currentInstrument = note_column.instrument_value
                    refreshControls = true
                end
                if current_note ~= nil then
                    if usedInstruments[current_note_ins] then
                        usedInstruments[current_note_ins] = usedInstruments[current_note_ins] + 1
                    else
                        usedInstruments[current_note_ins] = 1
                    end
                    newNotes_length = newNotes_length + 1
                    newNotes[newNotes_length] = { c,
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
                                                  current_note_ins,
                                                  false --note off
                    }
                end
                current_note = note
                current_note_string = note_string
                current_note_len = 0
                current_note_end_vel = nil
                current_note_step = s
                current_note_line = line
                current_note_ins = instrument
                current_note_vel = fromRenoiseHex(volume_string)
                current_note_pan = fromRenoiseHex(panning_string)
                current_note_dly = fromRenoiseHex(delay_string)
                current_note_end_dly = 0
                current_note_rowIndex = noteValue2GridRowOffset(current_note, true)
                --add current note to note index table for scale detection
                usedNoteIndices[line .. "_" .. c] = note % 12
            elseif note == 120 and current_note ~= nil then
                --note off delay
                current_note_end_dly = fromRenoiseHex(delay_string)
                if not current_note_step and s then
                    current_note_step = current_note_line - stepOffset
                end
                if usedInstruments[current_note_ins] then
                    usedInstruments[current_note_ins] = usedInstruments[current_note_ins] + 1
                else
                    usedInstruments[current_note_ins] = 1
                end
                newNotes_length = newNotes_length + 1
                newNotes[newNotes_length] = { c,
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
                                              current_note_ins,
                                              true --note off
                }
                current_note = nil
                current_note_len = 0
                current_note_rowIndex = nil
                current_note_ins = 0
            else
                current_note_end_vel = fromRenoiseHex(volume_string)
            end

            if current_note_rowIndex ~= nil then
                current_note_len = current_note_len + 1
            end
        end
        --pattern end, no note off, enable last note
        if current_note ~= nil then
            if usedInstruments[current_note_ins] then
                usedInstruments[current_note_ins] = usedInstruments[current_note_ins] + 1
            else
                usedInstruments[current_note_ins] = 1
            end
            newNotes_length = newNotes_length + 1
            newNotes[newNotes_length] = { c,
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
                                          current_note_ins,
                                          false  --note off
            }
        end
    end
    --search for the most used instrument in pattern
    if patternInstrument == nil or not usedInstruments[patternInstrument] then
        temp = 0
        for key, value in pairs(usedInstruments) do
            if value > temp then
                patternInstrument = key
                temp = value
            end
        end
        --no notes? try to set pattern instrument via current instrument
        if patternInstrument == nil then
            patternInstrument = currentInstrument
        end
    end

    --add note buttons
    if newNotes_length > 0 then
        drawNotesToGrid(newNotes)
    end

    --nothing else to do in quick refresh
    if quickRefresh then
        return
    end

    --hide non used elements of the piano roll grid
    for y = 1, gridHeight do
        temp = shadeColor(defaultColor["p1_" .. y], 0.4)
        for i = steps + 1, gridWidth do
            local p = l_vbw["p" .. i .. "_" .. y]
            if y == 1 then
                local s = l_vbw["s" .. i]
                s.active = false
                s.color = colorDefault
                l_vbw["se" .. i].visible = false
            end
            p.color = temp
            p.active = true
            p.width = gridStepSizeW - 1
            p.height = gridStepSizeH
            l_vbw["ps" .. i .. "_" .. y].width = 1
        end
    end

    --quirk? i need to visible and hide a note button to get fast vertical scroll
    local dummy = l_vbw["dummy" .. tostring(4) .. "_" .. tostring(4)]
    if not dummy.visible then
        dummy.visible = true
        dummy.visible = false
    end

    --set current instrument, when no instrument is used
    if currentInstrument == nil then
        currentInstrument = l_song.selected_instrument_index - 1
        refreshControls = true
    end

    --for automatic mode or empty patterns, set scale highlighting again, if needed
    if setScaleHighlighting(true) then
        refreshPianoRollNeeded = true
    else
        --just refresh selection also values of controls, when enabled
        updateNoteSelection()
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

    --refresh histogram if needed
    refreshHistogram = true
end

--set playback pos via playback pos indicator
function setPlaybackPos(pos)
    --select all note events which are on specific pos
    if modifier.keyControl then
        local newNotes = {}
        local line = pos + stepOffset
        for key in pairs(noteData) do
            local note_data = noteData[key]
            if line >= note_data.line and line < note_data.line + note_data.len then
                table.insert(newNotes, note_data)
            end
        end
        updateNoteSelection(newNotes, not modifier.keyShift)
    else
        playPatternFromLine(pos + stepOffset)
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
    currentEditPos = 0
    --set new observers
    song.transport.lpb_observable:add_notifier(function()
        refreshPianoRollNeeded = true
        refreshTimeline = true
    end)
    song.instruments_observable:add_notifier(obsColumnRefresh)
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
        currentInstrument = nil
        patternInstrument = nil
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
    song.transport.playing_observable:add_notifier(obsColumnRefresh)
    --clear selection and refresh piano roll
    obsPianoRefresh()
    obsColumnRefresh()
    refreshTimeline = true
end

--refresh histogram / apply values
local function refreshHistogramWindow(apply)
    local max = 128
    local min = 0
    local val = 0
    local oldval
    local maxVal = 0
    local midVal
    local minVal = 99999
    local values = {}
    local notevalue = {}
    local newnotevalue = {}
    local index
    local note
    local groupsmember = {}
    local groupindex
    local groups = {}
    --fill values with empty
    for i = 1, 100 do
        values[i] = 0
    end
    if vbwp["histogrammode"].value == 4 then
        vbwp["histogrampitchmode"].visible = true
    else
        vbwp["histogrampitchmode"].visible = false
    end
    vbwp.histocount.text = "Humanizing " .. tostring(#noteSelection) .. " note values."
    if #noteSelection > 0 then
        --resort note selection
        if vbwp["histogramasctype"].value == 2 then
            table.sort(noteSelection, sortFunc.sortFromLowToTop)
        else
            table.sort(noteSelection, sortFunc.sortLeftOneFirstFromLowToTop)
        end
        --fill value table
        for i = 1, #noteSelection do
            if vbwp["histogrammode"].value == 1 then
                val = noteSelection[i].vel
                max = 0x80
                min = 1
                if val == 255 then
                    val = max
                end
            elseif vbwp["histogrammode"].value == 2 then
                val = noteSelection[i].pan
                if val == 255 then
                    val = 0x40
                end
                max = 0x80
            elseif vbwp["histogrammode"].value == 3 then
                val = noteSelection[i].dly
                max = 0xff
            elseif vbwp["histogrammode"].value == 4 then
                val = noteSelection[i].note
                max = 119
            end
            notevalue[i] = val
            --only calculate min / max, when value is in range
            if val >= min and val <= max then
                maxVal = math.max(maxVal, val)
                minVal = math.min(minVal, val)
            end
        end
        midVal = (minVal + maxVal) / 2
        vbwp.histomin.text = tostring(min)
        vbwp.histomax.text = tostring(max)
        for i = 1, #noteSelection do
            if vbwp["histogramasctype"].value == 2 then
                groupindex = noteSelection[i].line
            else
                groupindex = noteSelection[i].note
            end
            if groups[groupindex] == nil then
                groups[groupindex] = 1
                groupsmember[groupindex] = 0
            else
                groups[groupindex] = groups[groupindex] + 1
            end
        end
        --change values by scale
        for i = 1, #noteSelection do
            val = notevalue[i]
            if vbwp["histogrammode"].value >= 3 or (val >= min and val <= max) then
                oldval = val
                --apply ascending
                if vbwp["histogramascgroup"].value then
                    if vbwp["histogramasctype"].value == 2 then
                        groupindex = noteSelection[i].line
                    else
                        groupindex = noteSelection[i].note
                    end
                    groupsmember[groupindex] = groupsmember[groupindex] + 1
                    if groupsmember[groupindex] > 1 then
                        val = val + (max / (groups[groupindex] - 1) * (groupsmember[groupindex] - 1)) * vbwp["histogramasc"].value
                    end
                else
                    if i > 1 then
                        val = val + (max / (#noteSelection - 1) * (i - 1)) * vbwp["histogramasc"].value
                    end
                end
                --apply chaos
                val = val + (
                        randomHistogramValues[i] *
                                max *
                                vbwp["histogramchaos"].value
                )
                --apply scale
                val = val + ((vbwp["histogramscale"].value - 1) * (val - midVal))
                --apply offset
                val = val + (max * vbwp["histogramoffset"].value)
                --round value
                val = math.floor(val + 0.5)
                --pitch correction
                if vbwp["histogrammode"].value == 4 and vbwp["histogrampitchmode"].value > 1 then
                    --force in scale
                    if not noteInScale(val) then
                        if val > oldval then
                            val = val + 1
                        else
                            val = val - 1
                        end
                    end
                    --force in pentatonic
                    if vbwp["histogrampitchmode"].value == 3 then
                        if noteIndexInScale(val) == 5 then
                            val = val - 1
                        elseif noteIndexInScale(val) == 11 then
                            val = val + 1
                        end
                    end
                end
                --clamp value
                val = clamp(val, min, max)
                index = clamp(math.floor(#values / max * val), 1, #values)
                values[index] = values[index] + 1
                if apply ~= nil then
                    if vbwp["histogrammode"].value == 1 then
                        --no value = max vel, so set no value
                        if val == 0x80 then
                            val = 255
                        end
                        newnotevalue[i] = val
                    elseif vbwp["histogrammode"].value == 2 then
                        song.selected_track.panning_column_visible = true
                        --no value = center, so set no value when center
                        if val == 0x40 then
                            val = 255
                        end
                        newnotevalue[i] = val
                    elseif vbwp["histogrammode"].value == 3 then
                        song.selected_track.delay_column_visible = true
                        newnotevalue[i] = val
                    elseif vbwp["histogrammode"].value == 4 then
                        newnotevalue[i] = val
                    end
                end
            elseif apply ~= nil then
                --set old value for ignored ones
                newnotevalue[i] = val
            end
        end
    end
    --new values to set?
    if #newnotevalue > 0 then
        if vbwp["histogrammode"].value == 1 then
            changePropertiesOfSelectedNotes(newnotevalue, nil, nil, nil, nil, nil, nil, "histogram")
        elseif vbwp["histogrammode"].value == 2 then
            changePropertiesOfSelectedNotes(nil, nil, nil, nil, newnotevalue, nil, nil, "histogram")
        elseif vbwp["histogrammode"].value == 3 then
            changePropertiesOfSelectedNotes(nil, nil, newnotevalue, nil, nil, nil, nil, "histogram")
        elseif vbwp["histogrammode"].value == 4 then
            changePropertiesOfSelectedNotes(nil, nil, nil, nil, nil, nil, newnotevalue, "histogram")
        end
    end
    --set histogram
    for i = 1, #values do
        note = vbwp["histogram" .. tostring(i)]
        note.height = clamp(100 / math.min(#noteSelection, 5) * values[i], 5, 100)
        if vbwp["histogrammode"].value == 1 then
            note.color = colorVelocity
        elseif vbwp["histogrammode"].value == 2 then
            note.color = colorPan
        elseif vbwp["histogrammode"].value == 3 then
            note.color = colorDelay
        elseif vbwp["histogrammode"].value == 4 then
            note.color = colorNote
        end
    end
end

--init histogram start values and random values
local function initHistogram()
    --
    song.transport.edit_mode = false
    if song.transport.follow_player then
        wasFollowPlayer = song.transport.follow_player
        song.transport.follow_player = false
    end
    randomHistogramValues = {}
    --set random values
    math.randomseed(os.time())
    for i = 1, math.max(#noteSelection, 1000) do
        randomHistogramValues[i] = math.random(1, 1000) / 1000 - 0.5
    end
    vbwp.histogramscale.value = 1
    vbwp.histogramchaos.value = 0
    vbwp.histogramoffset.value = 0
    vbwp.histogramasc.value = 0
    refreshHistogramWindow()
end

--histogram window
local function showHistogram()
    if dialogVars.histogramContent == nil then
        dialogVars.histogramContent = vbp:column {
            spacing = -8,
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
                    vbp:switch {
                        id = "histogrammode",
                        width = "100%",
                        items = {
                            "Vol",
                            "Pan",
                            "Dly",
                            "Pitch",
                        },
                        notifier = function()
                            refreshHistogramWindow()
                        end
                    },
                    vb:horizontal_aligner {
                        mode = "center",
                        vbp:switch {
                            width = "80%",
                            id = "histogrampitchmode",
                            items = {
                                "All notes",
                                "Current scale",
                                "Pentatonic",
                            },
                            notifier = function()
                                refreshHistogramWindow()
                            end
                        },
                    },
                    vbp:row {
                        id = "histogram",
                        spacing = -4,
                        style = "border",
                    },
                    vbp:horizontal_aligner {
                        mode = "justify",
                        vbp:text {
                            id = "histomin",
                            text = "",
                            font = "mono",
                        },
                        vbp:text {
                            align = "center",
                            id = "histocount",
                            text = "",
                        },
                        vbp:text {
                            id = "histomax",
                            text = "",
                            font = "mono",
                        },
                    },
                    vbp:horizontal_aligner {
                        mode = "distribute",
                        vb:column {
                            vbp:text {
                                text = "Offset:",
                            },
                            vbp:valuebox {
                                id = "histogramoffset",
                                steps = { 0.02, 0.01 },
                                min = -1,
                                max = 1,
                                value = 0,
                                width = 80,
                                tostring = function(v)
                                    return string.format("%.1f %%", v * 100)
                                end,
                                tonumber = function(v)
                                    v = string.gsub(v, "[^0-9.-]", "")
                                    if tonumber(v) == nil then
                                        v = 0
                                    end
                                    return tonumber(v) / 100
                                end,
                                notifier = function()
                                    refreshHistogramWindow()
                                end
                            },
                        },
                        vb:column {
                            vbp:text {
                                text = "Scale:",
                            },
                            vbp:valuebox {
                                id = "histogramscale",
                                steps = { 0.02, 0.01 },
                                min = -2,
                                max = 2,
                                value = 1,
                                width = 80,
                                tostring = function(v)
                                    return string.format("%.1f %%", v * 100)
                                end,
                                tonumber = function(v)
                                    v = string.gsub(v, "[^0-9.-]", "")
                                    if tonumber(v) == nil then
                                        v = 100
                                    end
                                    return tonumber(v) / 100
                                end,
                                notifier = function()
                                    refreshHistogramWindow()
                                end
                            },
                        },
                        vb:column {
                            vbp:text {
                                text = "Chaos:",
                            },
                            vbp:valuebox {
                                id = "histogramchaos",
                                steps = { 0.02, 0.01 },
                                min = -1,
                                max = 1,
                                value = 0,
                                width = 80,
                                tostring = function(v)
                                    return string.format("%.1f %%", v * 100)
                                end,
                                tonumber = function(v)
                                    v = string.gsub(v, "[^0-9.-]", "")
                                    if tonumber(v) == nil then
                                        v = 0
                                    end
                                    return tonumber(v) / 100
                                end,
                                notifier = function()
                                    refreshHistogramWindow()
                                end
                            },
                        },
                        vb:column {
                            vbp:popup {
                                id = "histogramasctype",
                                items = {
                                    "Asc by pos",
                                    "Asc by note",
                                },
                                width = 82,
                                tooltip = "Apply ascending values by note position or by note pitch",
                                notifier = function(i)
                                    if i == 1 then
                                        vbwp.groupthem.text = "Group: note"
                                    else
                                        vbwp.groupthem.text = "Group: pos"
                                    end
                                end
                            },
                            vbp:valuebox {
                                id = "histogramasc",
                                steps = { 0.02, 0.01 },
                                min = -1,
                                max = 1,
                                value = 0,
                                width = 80,
                                tostring = function(v)
                                    return string.format("%.1f %%", v * 100)
                                end,
                                tonumber = function(v)
                                    v = string.gsub(v, "[^0-9.-]", "")
                                    if tonumber(v) == nil then
                                        v = 0
                                    end
                                    return tonumber(v) / 100
                                end,
                                notifier = function()
                                    refreshHistogramWindow()
                                end
                            },
                            vbp:row {
                                vbp:checkbox {
                                    id = "histogramascgroup",
                                    tooltip = "Group note or pos values and apply them the same value.",
                                    value = false,
                                },
                                vbp:text {
                                    id = "groupthem",
                                    text = "Group: note",
                                },
                            },
                        },
                        vbp:vertical_aligner {
                            mode = "center",
                            vbp:row {
                                vbp:button {
                                    text = "Apply",
                                    notifier = function()
                                        refreshHistogramWindow(true)
                                        refreshPianoRollNeeded = true
                                        initHistogram()
                                    end
                                },
                                vbp:button {
                                    text = "Reset",
                                    notifier = function()
                                        initHistogram()
                                    end
                                },
                            },
                        },
                    },
                    vbp:text {
                        align = "center",
                        text = "Please note that muted notes for volume changes\n" ..
                                "and generally notes with column effects will be ignored."
                    }
                }
            },
            vbp:horizontal_aligner {
                mode = "center",
                margin = vbc.DEFAULT_DIALOG_MARGIN,
                spacing = vbc.DEFAULT_CONTROL_SPACING,
                vbp:button {
                    text = "Ok",
                    height = vbc.DEFAULT_DIALOG_BUTTON_HEIGHT,
                    width = 100,
                    notifier = function()
                        dialogVars.histogramObj:close()
                        restoreFocus()
                    end
                },
            },
        }
        for i = 1, 100 do
            vbwp.histogram:add_child(
                    vb:vertical_aligner {
                        mode = "bottom",
                        height = 100,
                        vbp:button {
                            id = "histogram" .. tostring(i),
                            width = 8,
                            height = 100,
                            active = false,
                            color = colorVelocity,
                        },
                    }
            )
        end
    end
    initHistogram()
    if not dialogVars.histogramObj or not dialogVars.histogramObj.visible then
        dialogVars.histogramObj = app:show_custom_dialog("Histogram - " .. "Simple Pianoroll v" .. manifest:property("Version").value,
                dialogVars.histogramContent, function(_, key)
                    if key.name == "esc" then
                        dialogVars.histogramObj:close()
                        restoreFocus()
                    end
                    return key
                end)
    else
        dialogVars.histogramObj:show()
    end
end

--init chord painter table
local function setupChordPainter()
    local idx = vbwp.chordpreset.value
    local presettable = chordPainterPresets.inbuild
    local chord = {}
    local hash = {}
    --switch table
    if preferences.chordPainterPresetTbl.value == 2 then
        presettable = chordPainterPresets.chordgun
    end
    --defaul chord presets
    if not presettable.notes[idx] then
        chord = { 0 }
        vbwp.chordpreset.value = 1
    else
        for i = 1, #presettable.notes[idx] do
            table.insert(chord, presettable.notes[idx][i])
        end
    end
    --do chord inversion
    table.sort(chord, function(a, b)
        return a < b
    end)
    if vbwp.chrdinvers.value > 0 then
        for i = 1, vbwp.chrdinvers.value do
            chord[((i - 1) % #chord) + 1] = chord[((i - 1) % #chord) + 1] + 12
        end
    elseif vbwp.chrdinvers.value < 0 then
        for i = math.abs(vbwp.chrdinvers.value), 1, -1 do
            chord[#chord - ((i - 1) % #chord)] = chord[#chord - ((i - 1) % #chord)] - 12
        end
    end
    --double chord
    if vbwp.dupchrdup.color[1] ~= 0 then
        for i = 1, #chord do
            table.insert(chord, chord[i] + 12)
        end
    end
    if vbwp.dupchrddown.color[1] ~= 0 then
        for i = 1, #chord do
            table.insert(chord, chord[i] - 12)
        end
    end
    --add more notes
    if vbwp.octsub1.color[1] ~= 0 then
        table.insert(chord, -12)
    end
    if vbwp.octsub2.color[1] ~= 0 then
        table.insert(chord, -24)
    end
    if vbwp.octadd1.color[1] ~= 0 then
        table.insert(chord, 12)
    end
    if vbwp.octadd2.color[1] ~= 0 then
        table.insert(chord, 24)
    end
    if vbwp.p5sub1.color[1] ~= 0 then
        table.insert(chord, -5)
    end
    if vbwp.p5sub2.color[1] ~= 0 then
        table.insert(chord, -17)
    end
    if vbwp.p5add1.color[1] ~= 0 then
        table.insert(chord, 7)
    end
    if vbwp.p5add2.color[1] ~= 0 then
        table.insert(chord, 19)
    end
    --setup chord painter table and prevent duplicate notes
    chordPainter = {}
    for i = 1, #chord do
        if hash[chord[i]] == nil then
            table.insert(chordPainter, chord[i])
            hash[chord[i]] = true
        end
    end
    --empty chord? add root note
    if #chordPainter == 0 then
        chordPainter = { 0 }
    else
        --resort chord table
        table.sort(chordPainter, function(a, b)
            return a < b
        end)
    end
end

--pen settings window
local function showPenSettingsDialog()
    if dialogVars.penSettingsContent == nil then
        dialogVars.penSettingsContent = vbp:column {
            spacing = -8,
            vbp:row {
                uniform = true,
                margin = 5,
                spacing = 5,
                vbp:column {
                    style = "group",
                    margin = 5,
                    uniform = true,
                    spacing = 4,
                    width = 250,
                    vbp:text {
                        text = "Chord stamping",
                        font = "big",
                        style = "strong",
                    },
                    vbp:switch {
                        id = "chordpresettbl",
                        width = 180,
                        value = 1,
                        items = {
                            "Inbuild",
                            "Chordgun",
                        },
                        notifier = function(i)
                            vbwp.chordpreset.value = 1
                            preferences.chordPainterPresetTbl.value = i
                            if i == 2 then
                                vbwp.chordpreset.items = chordPainterPresets.chordgun.name
                            else
                                vbwp.chordpreset.items = chordPainterPresets.inbuild.name
                            end
                        end
                    },
                    vbp:horizontal_aligner {
                        mode = "justify",
                        vbp:text {
                            text = "Chord preset:",
                        },
                        vbp:popup {
                            id = "chordpreset",
                            width = 180,
                            items = chordPainterPresets.inbuild.name,
                            notifier = function()
                                setupChordPainter()
                            end
                        },
                    },
                    vbp:space {
                        height = 8,
                    },
                    vbp:horizontal_aligner {
                        mode = "justify",
                        vbp:text {
                            text = "Chord inversion:",
                        },
                        vbp:valuebox {
                            id = "chrdinvers",
                            width = 60,
                            min = -7,
                            max = 7,
                            value = 0,
                            notifier = function()
                                setupChordPainter()
                            end
                        },
                    },
                    vbp:space {
                        height = 8,
                    },
                    vbp:horizontal_aligner {
                        mode = "justify",
                        vbp:text {
                            text = "Duplicate chord:",
                        },
                        vbp:row {
                            spacing = -3,
                            vbp:button {
                                id = "dupchrddown",
                                text = "-1",
                                width = 40,
                                color = { 0, 0, 0 },
                                notifier = function()
                                    if vbwp.dupchrddown.color[1] == 0 then
                                        vbwp.dupchrddown.color = colorStepOn
                                    else
                                        vbwp.dupchrddown.color = { 0, 0, 0 }
                                    end
                                    setupChordPainter()
                                end
                            },
                            vbp:button {
                                text = "None",
                                width = 40,
                                notifier = function()
                                    vbwp.dupchrddown.color = { 0, 0, 0 }
                                    vbwp.dupchrdup.color = { 0, 0, 0 }
                                    setupChordPainter()
                                end
                            },
                            vbp:button {
                                id = "dupchrdup",
                                text = "+1",
                                width = 40,
                                color = { 0, 0, 0 },
                                notifier = function()
                                    if vbwp.dupchrdup.color[1] == 0 then
                                        vbwp.dupchrdup.color = colorStepOn
                                    else
                                        vbwp.dupchrdup.color = { 0, 0, 0 }
                                    end
                                    setupChordPainter()
                                end
                            },
                        },
                    },
                    vbp:space {
                        height = 8,
                    },
                    vbp:horizontal_aligner {
                        mode = "justify",
                        vbp:text {
                            text = "Add octave:",
                        },
                        vbp:row {
                            spacing = -3,
                            vbp:button {
                                id = "octsub2",
                                text = "-2",
                                width = 40,
                                color = { 0, 0, 0 },
                                notifier = function()
                                    if vbwp.octsub2.color[1] == 0 then
                                        vbwp.octsub2.color = colorStepOn
                                    else
                                        vbwp.octsub2.color = { 0, 0, 0 }
                                    end
                                    setupChordPainter()
                                end
                            },
                            vbp:button {
                                id = "octsub1",
                                text = "-1",
                                width = 40,
                                color = { 0, 0, 0 },
                                notifier = function()
                                    if vbwp.octsub1.color[1] == 0 then
                                        vbwp.octsub1.color = colorStepOn
                                    else
                                        vbwp.octsub1.color = { 0, 0, 0 }
                                    end
                                    setupChordPainter()
                                end
                            },
                            vbp:button {
                                text = "None",
                                width = 40,
                                notifier = function()
                                    vbwp.octsub1.color = { 0, 0, 0 }
                                    vbwp.octadd1.color = { 0, 0, 0 }
                                    vbwp.octsub2.color = { 0, 0, 0 }
                                    vbwp.octadd2.color = { 0, 0, 0 }
                                    setupChordPainter()
                                end
                            },
                            vbp:button {
                                id = "octadd1",
                                text = "+1",
                                width = 40,
                                color = { 0, 0, 0 },
                                notifier = function()
                                    if vbwp.octadd1.color[1] == 0 then
                                        vbwp.octadd1.color = colorStepOn
                                    else
                                        vbwp.octadd1.color = { 0, 0, 0 }
                                    end
                                    setupChordPainter()
                                end
                            },
                            vbp:button {
                                id = "octadd2",
                                text = "+2",
                                width = 40,
                                color = { 0, 0, 0 },
                                notifier = function()
                                    if vbwp.octadd2.color[1] == 0 then
                                        vbwp.octadd2.color = colorStepOn
                                    else
                                        vbwp.octadd2.color = { 0, 0, 0 }
                                    end
                                    setupChordPainter()
                                end
                            },
                        },
                    },
                    vbp:horizontal_aligner {
                        mode = "justify",
                        vbp:text {
                            text = "Add perfect 5th:",
                        },
                        vbp:row {
                            spacing = -3,
                            vbp:button {
                                id = "p5sub2",
                                text = "-2",
                                width = 40,
                                color = { 0, 0, 0 },
                                notifier = function()
                                    if vbwp.p5sub2.color[1] == 0 then
                                        vbwp.p5sub2.color = colorStepOn
                                    else
                                        vbwp.p5sub2.color = { 0, 0, 0 }
                                    end
                                    setupChordPainter()
                                end
                            },
                            vbp:button {
                                id = "p5sub1",
                                text = "-1",
                                width = 40,
                                color = { 0, 0, 0 },
                                notifier = function()
                                    if vbwp.p5sub1.color[1] == 0 then
                                        vbwp.p5sub1.color = colorStepOn
                                    else
                                        vbwp.p5sub1.color = { 0, 0, 0 }
                                    end
                                    setupChordPainter()
                                end
                            },
                            vbp:button {
                                text = "None",
                                width = 40,
                                notifier = function()
                                    vbwp.p5sub1.color = { 0, 0, 0 }
                                    vbwp.p5add1.color = { 0, 0, 0 }
                                    vbwp.p5sub2.color = { 0, 0, 0 }
                                    vbwp.p5add2.color = { 0, 0, 0 }
                                    setupChordPainter()
                                end
                            },
                            vbp:button {
                                id = "p5add1",
                                text = "+1",
                                width = 40,
                                color = { 0, 0, 0 },
                                notifier = function()
                                    if vbwp.p5add1.color[1] == 0 then
                                        vbwp.p5add1.color = colorStepOn
                                    else
                                        vbwp.p5add1.color = { 0, 0, 0 }
                                    end
                                    setupChordPainter()
                                end
                            },
                            vbp:button {
                                id = "p5add2",
                                text = "+2",
                                width = 40,
                                color = { 0, 0, 0 },
                                notifier = function()
                                    if vbwp.p5add2.color[1] == 0 then
                                        vbwp.p5add2.color = colorStepOn
                                    else
                                        vbwp.p5add2.color = { 0, 0, 0 }
                                    end
                                    setupChordPainter()
                                end
                            },
                        },
                    },
                    vbp:space {
                        height = 8,
                    },
                    vbp:horizontal_aligner {
                        mode = "justify",
                        vbp:text {
                            text = "Set max upper note:",
                        },
                        vbp:valuebox {
                            id = "chordupperlimit",
                            width = 60,
                            min = 11,
                            max = 120,
                            value = chordPainterUpperNoteLimit,
                            tooltip = "Set the maximum allowable note value. Any note\n" ..
                                    "value above this threshold is transposed down.",
                            notifier = function(v)
                                chordPainterUpperNoteLimit = v
                            end,
                            tostring = function(v)
                                local text = ""
                                if v == 120 then
                                    text = "No"
                                else
                                    text = text .. notesTable[(v % 12) + 1]
                                    text = text .. math.floor((v / 12))
                                end
                                return text
                            end,
                            tonumber = function(v)
                                local note, oct
                                v = string.upper(v)
                                note, oct = string.match(v, '^([CDEFGAB])([0-9])$')
                                if not note then
                                    note, oct = string.match(v, '^([CDEFGAB]#)([0-9])$')
                                end
                                if note and oct then
                                    v = nil
                                    for i = 1, #notesTable do
                                        if notesTable[i] == note then
                                            v = i - 1
                                            break
                                        end
                                    end
                                    if v then
                                        v = v + (12 * tonumber(oct))
                                    else
                                        v = 120
                                    end
                                else
                                    v = 120
                                end
                                return tonumber(v)
                            end
                        },
                    },
                    vbp:row {
                        vbp:checkbox {
                            id = "chordinscale",
                            notifier = function(b)
                                chordPainterForceInScale = b
                            end
                        },
                        vbp:text {
                            text = "Keep notes in scale",
                        },
                    },
                    vbp:horizontal_aligner {
                        mode = "center",
                        vbp:button {
                            text = "Reset chord stamping settings",
                            height = vbc.DEFAULT_DIALOG_BUTTON_HEIGHT,
                            width = 100,
                            notifier = function()
                                vbwp.chordinscale.value = false
                                vbwp.chordupperlimit.value = 120
                                vbwp.octsub1.color = { 0, 0, 0 }
                                vbwp.octadd1.color = { 0, 0, 0 }
                                vbwp.octsub2.color = { 0, 0, 0 }
                                vbwp.octadd2.color = { 0, 0, 0 }
                                vbwp.p5sub1.color = { 0, 0, 0 }
                                vbwp.p5add1.color = { 0, 0, 0 }
                                vbwp.p5sub2.color = { 0, 0, 0 }
                                vbwp.p5add2.color = { 0, 0, 0 }
                                vbwp.dupchrddown.color = { 0, 0, 0 }
                                vbwp.dupchrdup.color = { 0, 0, 0 }
                                vbwp.chordpreset.value = 1
                                vbwp.chrdinvers.value = 0
                                setupChordPainter()
                            end
                        },
                        vbp:button {
                            text = "Preview chord",
                            height = vbc.DEFAULT_DIALOG_BUTTON_HEIGHT,
                            pressed = function()
                                for i = 1, #chordPainter do
                                    triggerNoteOfCurrentInstrument(48 + chordPainter[i], true)
                                end
                            end,
                            released = function()
                                for i = 1, #chordPainter do
                                    triggerNoteOfCurrentInstrument(48 + chordPainter[i], false)
                                end
                            end
                        }
                    },
                    vbp:text {
                        text = "IMPORTANT: Please note that Renoise has a note column\n" ..
                                "limit of 12. So there is only space for 12 notes per line."
                    },
                    vbp:space {
                        height = 8,
                    },
                    vbp:text {
                        text = "Other settings",
                        font = "big",
                        style = "strong",
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
                            bind = preferences.moveNoteInPenMode,
                        },
                        vbp:text {
                            text = "Allow move, scale and duplication of notes in pen mode",
                        },
                    },
                    vbp:row {
                        vbp:checkbox {
                            bind = preferences.useChordStampingForNotePreview,
                        },
                        vbp:text {
                            text = "Use chord stamping also for note preview",
                        },
                    },

                }
            },
            vbp:horizontal_aligner {
                mode = "center",
                margin = vbc.DEFAULT_DIALOG_MARGIN,
                spacing = vbc.DEFAULT_CONTROL_SPACING,
                vbp:button {
                    text = "Ok",
                    height = vbc.DEFAULT_DIALOG_BUTTON_HEIGHT,
                    width = 100,
                    notifier = function()
                        refreshPianoRollNeeded = true
                        dialogVars.penSettingsObj:close()
                        restoreFocus()
                    end
                },
            },
        }
    end
    if not dialogVars.penSettingsObj or not dialogVars.penSettingsObj.visible then
        --cleanup preset table
        chordPainterPresets.chordgun.name = {}
        chordPainterPresets.chordgun.notes = {}
        --check for chordgun chords file
        if preferences.chordGunPreset.value then
            local f = io.open("../com.pandabot.ChordGun.xrnx/chords.lua", "r")
            if f then
                local chords
                local luacontent = f:read("*all")
                f:close()
                luacontent = loadstring(luacontent .. ";return chords")
                --load presets
                chords = luacontent()
                table.insert(chordPainterPresets.chordgun.name, "None")
                table.insert(chordPainterPresets.chordgun.notes, { 0 })
                for i = 1, #chords do
                    local notes = {}
                    table.insert(chordPainterPresets.chordgun.name, "[" .. chords[i].code .. "] " .. chords[i].name)
                    for j = 1, #chords[i].pattern do
                        if chords[i].pattern:sub(j, j) == "1" then
                            table.insert(notes, j - 1)
                        end
                    end
                    table.insert(chordPainterPresets.chordgun.notes, notes)
                end
            end
        end
        --no chordgun presets? hide
        if #chordPainterPresets.chordgun.notes > 1 then
            vbwp.chordpresettbl.visible = true
            vbwp.chordpresettbl.value = preferences.chordPainterPresetTbl.value
        else
            vbwp.chordpresettbl.visible = false
            vbwp.chordpresettbl.value = 1
        end
        --
        dialogVars.penSettingsObj = app:show_custom_dialog("Pen settings - " .. "Simple Pianoroll v" .. manifest:property("Version").value,
                dialogVars.penSettingsContent, function(_, key)
                    if key.name == "esc" then
                        refreshPianoRollNeeded = true
                        dialogVars.penSettingsObj:close()
                        restoreFocus()
                    end
                    return key
                end)

    else
        dialogVars.penSettingsObj:show()
    end
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

    --renoise bug? using value boxes sometimes set wrong focus so key events will be fired doubled?
    --restoreFocus()

    --convert number keys from azerty to qwerty
    if preferences.azertyMode.value then
        key = azertyMode(keyEvent)
    else
        key = keyEvent
    end

    --swap left ctrl and alt key
    if preferences.swapCtrlAlt.value then
        if key.name == "lalt" then
            key.name = "lcontrol"
        elseif key.name == "lcontrol" then
            key.name = "lalt"
        end
        if key.modifiers == "alt" then
            key.modifiers = "control"
        elseif key.modifiers == "control" then
            key.modifiers = "alt"
        end
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
        modifier.keyControl = true
        handled = true
    elseif key.name == "lcontrol" and key.state == "released" then
        modifier.keyControl = false
        --reset loop mini slider state
        xypadpos.loopslider = nil
        handled = true
    end
    if key.name == "rcontrol" and key.state == "pressed" then
        modifier.keyRControl = true
        handled = true
    elseif key.name == "rcontrol" and key.state == "released" then
        modifier.keyRControl = false
        handled = true
    end
    if key.name == "lalt" and key.state == "pressed" then
        modifier.keyAlt = true
        handled = true
        refreshControls = true
    elseif key.name == "lalt" and key.state == "released" then
        modifier.keyAlt = false
        handled = true
        refreshControls = true
    end
    if key.name == "lshift" and key.state == "pressed" then
        modifier.keyShift = true
        handled = true
        refreshControls = true
    elseif key.name == "lshift" and key.state == "released" then
        modifier.keyShift = false
        handled = true
        --reset loop mini slider state
        xypadpos.loopslider = nil
        refreshControls = true
    end
    if key.name == "rshift" and key.state == "pressed" then
        modifier.keyRShift = true
        handled = true
    elseif key.name == "rshift" and key.state == "released" then
        modifier.keyRShift = false
        handled = true
    end

    --prepare midi in events
    if key.name == "midi in" then
        key.repeated = false
        key.modifiers = ""
        key.isMidi = true
        handled = true
        --extend key name
        key.name = key.name .. " - Note " .. tostring(key.note)
    end

    --convert scrollwheel events
    if key.name == "scrollup" or key.name == "scrolldown" then
        key.state = "pressed"
        key.modifiers = ""
        if modifier.keyShift or modifier.keyRShift then
            key.modifiers = "shift"
        end
        if modifier.keyAlt then
            if key.modifiers ~= "" then
                key.modifiers = key.modifiers .. " + "
            end
            key.modifiers = key.modifiers .. "alt"
        end
        if modifier.keyControl then
            if key.modifiers ~= "" then
                key.modifiers = key.modifiers .. " + "
            end
            key.modifiers = key.modifiers .. "control"
        end
        restoreFocus()
    end

    if key.name == "del" or key.name == "back" then
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
                updateNoteSelection(nil, true)
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
            if modifier.keyControl then
                keyInfoText = "Open Pen mode settings."
                showPenSettingsDialog()
            else
                keyInfoText = "Pen mode"
                penMode = true
                audioPreviewMode = false
                refreshControls = true
            end
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
    if key.name == "r" and key.modifiers == "shift + control" then
        if key.state == "pressed" then
            if #noteSelection > 0 then
                showStatus("Randomly deselect halve of the selected notes.")
                keyInfoText = "Randomly deselect halve of the selected notes"
                table.sort(noteSelection, sortFunc.sortLeftOneFirst)
                local newSelection = {}
                local skip = 0
                local removed = 0
                math.randomseed(os.clock() * 100000000000)
                for i = 1, #noteSelection do
                    if skip == 2 or (math.random(0, 1) == 1 and removed < 2) then
                        table.insert(newSelection, noteSelection[i])
                        skip = 0
                        removed = removed + 1
                    else
                        skip = skip + 1
                        removed = 0
                    end
                end
                updateNoteSelection(newSelection, true)
            end
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
                updateNoteSelection(newSelection, true)
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
                    updateNoteSelection(nil, true)
                else
                    showStatus((#noteSelection / 2) .. " notes chopped.")
                    keyInfoText = "Chop selected notes"
                end
            end
        end
        handled = true
    end
    if key.name == "h" and key.modifiers == "alt" then
        if key.state == "pressed" then
            keyInfoText = "Open histogram ..."
            if #noteSelection == 0 then
                updateNoteSelection("all", true)
            end
            showHistogram()
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
                changePropertiesOfSelectedNotes(nil, nil, nil, nil, nil, nil, nil, "matchingnotes")
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
                updateNoteSelection("all", true)
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
                table.sort(clipboard, sortFunc.sortLeftOneFirst)
                pasteCursor = { clipboard[1].line, clipboard[1].note }
                --set status
                showStatus(#noteSelection .. " notes cut.", true)
                --remove selected notes
                removeSelectedNotes(true)
            end
        end
        handled = true
    end
    if key.name == "p" and key.modifiers == "control" then
        if key.state == "pressed" then
            keyInfoText = "Show preferences ..."
            showPreferences()
        end
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
            updateNoteSelection("all", true)
            keyInfoText = "Select all notes"
            showStatus(#noteSelection .. " notes selected.", true)
        end
        handled = true
    end
    if (key.name == "scrollup" or key.name == "scrolldown") then
        if key.state == "pressed" then
            local steps = preferences.scrollWheelSpeed.value
            if key.name == "scrolldown" then
                steps = steps * -1
            end
            if (modifier.keyAlt or modifier.keyShift or modifier.keyRShift) and not modifier.keyControl then
                if #noteSelection > 0 and modifier.keyAlt and not modifier.keyShift and not modifier.keyControl then
                    if steps > 0 then
                        keyInfoText = "Increase velocity of selected notes"
                    else
                        keyInfoText = "Decrease velocity of selected notes"
                    end
                    changePropertiesOfSelectedNotes(steps, nil, nil, nil, nil, nil, nil, "add")
                    --play new velocity
                    triggerNoteOfCurrentInstrument(noteSelection[1].note, nil, noteSelection[1].vel, true, noteSelection[1].ins)
                elseif #noteSelection > 0 and modifier.keyShift and not modifier.keyAlt and not modifier.keyControl then
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
            elseif not modifier.keyAlt and modifier.keyControl and not modifier.keyShift and not modifier.keyRShift then
                keyInfoText = "Move through the grid"
                steps = steps * -1
                stepSlider.value = forceValueToRange(stepSlider.value + steps, stepSlider.min, stepSlider.max)
            elseif not modifier.keyAlt and not modifier.keyControl and not modifier.keyShift and not modifier.keyRShift then
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
            if modifier.keyShift or modifier.keyRShift then
                transpose = 12
            end
            if (modifier.keyShift or modifier.keyRShift) and modifier.keyControl then
                transpose = 7
            end
            if key.name == "down" then
                transpose = transpose * -1
            end
            if #noteSelection > 0 and not modifier.keyAlt then
                transposeSelectedNotes(transpose, (modifier.keyControl or modifier.keyRControl) and not (modifier.keyShift or modifier.keyRShift))
                keyInfoText = "Transpose selected notes by " .. getSingularPlural(transpose, "semitone", "semitones", true)
                if (modifier.keyControl or modifier.keyRControl) and not (modifier.keyShift or modifier.keyRShift) then
                    keyInfoText = keyInfoText .. ", keep in scale"
                end
            else
                if modifier.keyAlt then
                    moveSelectionThroughNotes(0, transpose, modifier.keyShift)
                    if modifier.keyShift then
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
            if modifier.keyShift or modifier.keyRShift then
                steps = 4
            end
            if key.name == "left" then
                steps = steps * -1
            end
            if #noteSelection > 0 and not modifier.keyAlt then
                if modifier.keyControl then
                    steps = steps / math.abs(steps)
                    if modifier.keyShift or modifier.keyRShift then
                        if isDelayColumnActive(true) then
                            changeSizeSelectedNotesByMicroSteps(steps)
                        end
                        keyInfoText = "Change note length of selected notes by microsteps"
                    else
                        changeSizeSelectedNotes(steps, true)
                        keyInfoText = "Change note length of selected notes"
                    end
                else
                    moveSelectedNotes(steps)
                    keyInfoText = "Move selected notes by " .. getSingularPlural(steps, "step", "steps", true)
                end
            else
                if modifier.keyAlt then
                    if modifier.keyControl then
                        if isDelayColumnActive(true) then
                            moveSelectedNotesByMicroSteps(steps)
                        end
                        keyInfoText = "Move note selection by microsteps to the " .. key.name
                    else
                        moveSelectionThroughNotes(steps, 0, modifier.keyShift)
                        if modifier.keyShift then
                            keyInfoText = "Add a note from left/right to selection"
                        else
                            keyInfoText = "Move note selection to the " .. key.name
                        end
                    end
                else
                    keyInfoText = "Move edit cursor position"
                    --move cursor
                    if currentEditPos + steps >= 1 and currentEditPos + steps <= song.selected_pattern.number_of_lines + 1 then
                        --do step sequencing
                        if not song.transport.playing and math.abs(steps) == 1 then
                            if stepSequencing(currentEditPos, steps) then
                                keyInfoText = keyInfoText .. ", do step sequencing ..."
                            end
                        end
                        --move
                        if currentEditPos + steps <= song.selected_pattern.number_of_lines then
                            local npos = renoise.SongPos()
                            npos.line = currentEditPos + steps
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
                        currentEditPos = currentEditPos + steps
                    end
                end
            end
        end
        handled = true
    end
    --play selection
    if key.name == "space" and not key.repeated then
        if (key.modifiers == "control" or key.modifiers == "shift") then
            if key.state == "pressed" then
                if lastEditPos then
                    if song.transport.follow_player then
                        wasFollowPlayer = song.transport.follow_player
                        song.transport.follow_player = false
                    end
                    playPatternFromLine(lastEditPos + stepOffset)
                    keyInfoText = "Start song from cursor position"
                else
                    playPatternFromLine()
                end
            end
        elseif key.state == "pressed" then
            if song.transport.playing then
                song.transport:stop()
            else
                playPatternFromLine()
            end
        end
        handled = true
    end
    --loving tracker computer keyboard note playing <3 (returning it back to host is buggy, so do your own)
    if key.note then
        local row
        local chord = { 0 }
        local othernote
        local note
        local last_note
        --use chord stamping chord as preview, too
        if preferences.useChordStampingForNotePreview.value then
            chord = chordPainter
        end
        for i = 1, #chord do
            othernote = false
            if not key.repeated and key.state == "released" and lastKeyboardNote[key.name .. i] ~= nil then
                note = lastKeyboardNote[key.name .. i]
                lastKeyboardNote[key.name .. i] = nil
                --check if other key playing this note
                for k in pairs(lastKeyboardNote) do
                    if lastKeyboardNote[k] == note then
                        othernote = true
                        break
                    end
                end
                if not othernote then
                    row = noteValue2GridRowOffset(note)
                    triggerNoteOfCurrentInstrument(note, false)
                    if row ~= nil then
                        setKeyboardKeyColor(row, false, false)
                        highlightNoteRow(row, false)
                    end
                end
                if key.modifiers == "" then
                    handled = true
                end
            elseif not key.repeated and key.state == "pressed" and key.modifiers == "" then
                note = key.note
                if not key.isMidi then
                    note = note + (12 * song.transport.octave)
                end
                note = note + chord[i]
                note = modifyNoteValueChord(note, last_note)
                last_note = note
                --check if other key playing this note
                for k in pairs(lastKeyboardNote) do
                    if lastKeyboardNote[k] == note then
                        othernote = true
                        break
                    end
                end
                lastKeyboardNote[key.name .. i] = note
                row = noteValue2GridRowOffset(lastKeyboardNote[key.name .. i])
                if not othernote then
                    triggerNoteOfCurrentInstrument(lastKeyboardNote[key.name .. i], true, key.velocity)
                end
                if row ~= nil then
                    setKeyboardKeyColor(row, true, false)
                    highlightNoteRow(row, true)
                end
                if #chord > 1 then
                    keyInfoText = "Play a chord"
                else
                    keyInfoText = "Play a note"
                end
                handled = true
            end
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

--process incoming midi data
local function midiInCallback(message)
    --only handle note events
    if message[1] >= 0x90 and message[1] <= 0x9f then
        --pass them as key events
        if message[3] > 0 then
            handleKeyEvent({
                name = "midi in",
                note = message[2],
                velocity = message[3],
                state = "pressed",
            })
        else
            handleKeyEvent({
                name = "midi in",
                note = message[2],
                velocity = message[3],
                state = "released",
            })
        end
    elseif message[1] >= 0x80 and message[1] <= 0x8f then
        handleKeyEvent({
            name = "midi in",
            note = message[2],
            velocity = message[3],
            state = "released",
        })
    end
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
    local newNotes = {}
    local newNotes_length = 0
    local noteString
    local rowIndex

    for key = 1, #noteSelection do
        if l_vbw["bc" .. noteSelection[key].idx] then
            l_vbw["bc" .. noteSelection[key].idx].visible = false
        end
        for i = 1, 0xf do
            if l_vbw["br" .. noteSelection[key].idx .. "_" .. i] then
                l_vbw["br" .. noteSelection[key].idx .. "_" .. i].visible = false
            else
                break
            end
        end
        rowIndex = noteValue2GridRowOffset(noteSelection[key].note, true)
        noteSelection[key].idx = tostring(noteSelection[key].step) .. "_" .. tostring(rowIndex) .. "_" .. tostring(noteSelection[key].column)
        noteString = lineValues[noteSelection[key].line]:note_column(noteSelection[key].column).note_string
        newNotes_length = newNotes_length + 1
        newNotes[newNotes_length] = {
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
            noteSelection[key].ins,
            noteSelection[key].noteoff
        }
    end
    if newNotes_length > 0 then
        drawNotesToGrid(newNotes)
    end
    refreshPianoRollNeeded = true
end

--handle xy pad events
local function handleXypad(val)
    local quickRefresh
    local forceFullRefresh
    --reenabled disable elements
    if #xypadpos.disabled > 0 then
        for i = 1, #xypadpos.disabled do
            local el = vbw[xypadpos.disabled[i]]
            if el then
                el.active = true
            end
        end
        xypadpos.disabled = {}
    end
    --snap back
    if (val.x == snapBackVal.x or val.y == snapBackVal.y) then
        if val.x == snapBackVal.x and val.y == snapBackVal.y and xypadpos.leftClick then
            xypadpos.leftClick = false
            drawRectangle(false)
            --stop old notes
            if xypadpos.previewmode then
                for key in pairs(xypadpos.preview) do
                    local note_data = xypadpos.preview[key]
                    xypadpos.preview[note_data.note .. "_" .. note_data.column .. "_" .. note_data.ins] = nil
                    triggerNoteOfCurrentInstrument(note_data.note, false, false, note_data.vel, note_data.ins)
                    local row = noteValue2GridRowOffset(note_data.note)
                    if row ~= nil then
                        setKeyboardKeyColor(row, false, false)
                        highlightNoteRow(row, false)
                    end
                end
            end
        end
        return
    end
    if xypadpos.previewmode then
        local playNotes = {}
        --stop old notes
        for key in pairs(xypadpos.preview) do
            local note_data = xypadpos.preview[key]
            if not posInNoteRange(val.x + stepOffset, note_data) then
                xypadpos.preview[note_data.note .. "_" .. note_data.column .. "_" .. note_data.ins] = nil
                triggerNoteOfCurrentInstrument(note_data.note, false, note_data.vel, false, note_data.ins)
                local row = noteValue2GridRowOffset(note_data.note)
                if row ~= nil then
                    setKeyboardKeyColor(row, false, false)
                    highlightNoteRow(row, false)
                end
            end
        end
        --play new notes
        for key in pairs(noteData) do
            local note_data = noteData[key]
            if posInNoteRange(val.x + stepOffset, note_data) and xypadpos.preview[note_data.note .. "_" .. note_data.column .. "_" .. note_data.ins] == nil then
                xypadpos.preview[note_data.note .. "_" .. note_data.column .. "_" .. note_data.ins] = note_data
                table.insert(playNotes, note_data)
            end
        end
        --resort notes
        table.sort(playNotes, sortFunc.sortLeftOneFirst)
        --play notes, but first column first
        for i = 1, #playNotes do
            triggerNoteOfCurrentInstrument(playNotes[i].note, true, playNotes[i].vel, false, playNotes[i].ins)
            local row = noteValue2GridRowOffset(playNotes[i].note)
            if row ~= nil then
                setKeyboardKeyColor(row, true, false)
                highlightNoteRow(row, true)
            end
        end
        --draw cursor
        drawRectangle(true, val.x)
    elseif xypadpos.notemode then
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
                    changePropertiesOfSelectedNotes(nil, nil, 0, 0, nil, nil, nil, "removecut")
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
                    if modifier.keyAlt and isDelayColumnActive() then
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
                if val.scroll then
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
                end
                if modifier.keyAlt and isDelayColumnActive(true) then
                    local v = math.floor((val.x - xypadpos.x) * 0x100)
                    if v ~= 0 then
                        blockLineModifier = true
                        quickRefresh = true
                        v = moveSelectedNotesByMicroSteps(v, modifier.keyShift)
                        if v ~= false then
                            xypadpos.x = xypadpos.x + (v / 0x100)
                        end
                    end
                else
                    xypadpos.x = math.floor(xypadpos.x)
                    xypadpos.y = math.floor(xypadpos.y)
                    if xypadpos.x - math.floor(val.x) > 0 and math.floor(val.x) ~= xypadpos.lastx then
                        if xypadpos.duplicate then
                            if modifier.keyControl and xypadpos.idx then
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
                            if modifier.keyControl and xypadpos.idx then
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
                        if modifier.keyControl and xypadpos.idx then
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
                        if modifier.keyControl and xypadpos.idx then
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
                if not preferences.mouseWarpingCompatibilityMode.value then
                    drawRectangle(true, xypadpos.x, xypadpos.y, xypadpos.nx, xypadpos.ny)
                end
                selectRectangle(xypadpos.x, xypadpos.y, xypadpos.nx, xypadpos.ny, modifier.keyShift)
            end
        end
    end
    if forceFullRefresh then
        blockLineModifier = false
        fillPianoRoll()
    elseif quickRefresh then
        refreshSelectedNotes()
    end
end

--app idle
local function appIdleEvent()
    --only process when window is created and visible
    if windowObj and windowObj.visible then
        --scroll via idle, more instant
        if xypadpos.leftClick then
            local val = vbw["xypad"].value
            if val.y == 1 or val.y - 1 == gridHeight or val.x == 1 or val.x - 1 == gridWidth then
                val.scroll = true
                handleXypad(val)
            end
        end
        --refresh modifier states, when keys are pressed outside focus
        local keyState = app.key_modifier_states
        --swap alt and control?
        if preferences.swapCtrlAlt.value then
            if (keyState["alt"] == "pressed" and modifier.keyControl == false) or (keyState["alt"] == "released" and modifier.keyControl == true) then
                modifier.keyControl = not modifier.keyControl
                refreshControls = true
            end
            if (keyState["control"] == "pressed" and modifier.keyAlt == false) or (keyState["control"] == "released" and modifier.keyAlt == true) then
                modifier.keyAlt = not modifier.keyAlt
                --reset loop mini slider state
                if modifier.keyAlt == false then
                    xypadpos.loopslider = nil
                end
                refreshControls = true
            end
        else
            if (keyState["alt"] == "pressed" and modifier.keyAlt == false) or (keyState["alt"] == "released" and modifier.keyAlt == true) then
                modifier.keyAlt = not modifier.keyAlt
                refreshControls = true
            end
            if (keyState["control"] == "pressed" and modifier.keyControl == false) or (keyState["control"] == "released" and modifier.keyControl == true) then
                modifier.keyControl = not modifier.keyControl
                --reset loop mini slider state
                if modifier.keyControl == false then
                    xypadpos.loopslider = nil
                end
                refreshControls = true
            end
        end

        if (keyState["shift"] == "pressed" and modifier.keyShift == false) or (keyState["shift"] == "released" and modifier.keyShift == true) then
            modifier.keyShift = not modifier.keyShift
            --reset loop mini slider state
            if modifier.keyShift == false then
                xypadpos.loopslider = nil
            end
            refreshControls = true
        end
        --process after edit features
        if afterEditProcessTime ~= nil and afterEditProcessTime < os.clock() - 0.1 then
            afterEditProcess()
        end
        --refresh control, when needed
        if refreshControls then
            refreshNoteControls()
        end
        --refresh pianoroll, when needed
        if refreshPianoRollNeeded then
            fillPianoRoll()
        end
        --refresh timeline, when needed
        if refreshTimeline then
            fillTimeline()
        end
        --refresh chord states
        if refreshChordDetection and preferences.chordDetection.value then
            refreshDetectedChord()
        end
        --if needed refresh histogram
        if refreshHistogram then
            refreshHistogram = false
            if dialogVars.histogramObj and dialogVars.histogramObj.visible then
                refreshHistogramWindow()
            end
        end
        --key info state
        if lastKeyInfoTime and lastKeyInfoTime + preferences.keyInfoTime.value < os.clock() then
            vbw["key_state"].text = ""
        end
        --refresh playback pos indicator
        refreshPlaybackPosIndicator()
        --edit pos render
        refreshEditPosIndicator()
        --check loop stats
        local currentloopingrange
        local transport = song.transport
        if ((transport.edit_pos.sequence == transport.loop_start.sequence and transport.edit_pos.sequence == transport.loop_end.sequence - 1 and transport.loop_end.line == 1) or
                (transport.edit_pos.sequence == transport.loop_start.sequence and transport.edit_pos.sequence == transport.loop_end.sequence) or
                transport.loop_sequence_start > 0 or
                song.transport.loop_pattern
        ) and not (
                transport.edit_pos.sequence == transport.loop_start.sequence and transport.edit_pos.sequence == transport.loop_end.sequence and
                        transport.loop_start.line == 1 and transport.loop_end.line == song.selected_pattern.number_of_lines + 1 and
                        transport.loop_sequence_start == 0 and not transport.loop_pattern
        )
        then
            currentloopingrange = tostring(transport.loop_start) .. tostring(transport.loop_end) ..
                    tostring(transport.loop_pattern) .. tostring(transport.loop_block_enabled) ..
                    tostring(transport.loop_sequence_start)
        end
        if loopingrange ~= currentloopingrange then
            loopingrange = currentloopingrange
            refreshTimeline = true
            refreshControls = true
        end
        --instrument scale obs
        if preferences.scaleHighlightingType.value == 4 and currentInstrument and song.instruments[currentInstrument + 1] then
            local temp = tostring(song.instruments[currentInstrument + 1].trigger_options.scale_key) ..
                    tostring(song.instruments[currentInstrument + 1].trigger_options.scale_mode)
            if temp ~= instrumentScaleMode then
                instrumentScaleMode = temp
                refreshPianoRollNeeded = true
            end
        end
        --midi in init handling
        if preferences.midiIn.value and not midiDevice and preferences.midiDevice.value ~= "" then
            --check if the device is present
            local temp = renoise.Midi.available_input_devices()
            for i = 1, #temp do
                if temp[i] == preferences.midiDevice.value then
                    --init device
                    midiDevice = renoise.Midi.create_input_device(preferences.midiDevice.value, midiInCallback)
                    break
                end
            end
            if not midiDevice then
                showStatus("Error: Cant initialize midi in device: " .. preferences.midiDevice.value)
                --disable midi in
                preferences.midiIn.value = false
                midiDevice = nil
            end
        elseif not preferences.midiIn.value and midiDevice then
            if midiDevice.is_open then
                midiDevice:close()
            end
            midiDevice = nil
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
        --refresh after prefernces changes
        if dialogVars.preferencesWasShown and dialogVars.preferencesObj and not dialogVars.preferencesObj.visible then
            restoreFocus()
            if oscClient then
                oscClient:close()
                oscClient = nil
            end
            refreshControls = true
            refreshPianoRollNeeded = true
            --when invisible is enabled, no snapback needed
            if vbw and vbw["xypad"] then
                if not preferences.mouseWarpingCompatibilityMode.value then
                    vbw["xypad"].snapback = snapBackVal
                else
                    vbw["xypad"].snapback = nil
                end
            end
            --apply new highlighting colors
            initColors()
            refreshPianoRollNeeded = true
            dialogVars.preferencesWasShown = false
        end
    else
        --set follow player back
        if wasFollowPlayer ~= nil then
            song.transport.follow_player = wasFollowPlayer
            wasFollowPlayer = nil
        end
        --close editing windows
        if dialogVars.setScaleObj and dialogVars.setScaleObj.visible then
            dialogVars.setScaleObj:close()
        end
        if dialogVars.histogramObj and dialogVars.histogramObj.visible then
            dialogVars.histogramObj:close()
        end
        if dialogVars.penSettingsObj and dialogVars.penSettingsObj.visible then
            dialogVars.penSettingsObj:close()
        end
    end
end

--function to switch between relative major and minor
local function switchToRelativeScale()
    if preferences.scaleHighlightingType.value == 3 then
        preferences.scaleHighlightingType.value = 2
        preferences.keyForSelectedScale.value = ((preferences.keyForSelectedScale.value + 2) % 12) + 1
        refreshPianoRollNeeded = true
    elseif preferences.scaleHighlightingType.value == 2 then
        preferences.scaleHighlightingType.value = 3
        preferences.keyForSelectedScale.value = ((preferences.keyForSelectedScale.value - 4) % 12) + 1
        refreshPianoRollNeeded = true
    end
end

--setscale window
local function showSetScaleDialog()
    if dialogVars.setScaleContent == nil then
        dialogVars.setScaleContent = vbp:column {
            spacing = -8,
            vbp:row {
                uniform = true,
                margin = 5,
                spacing = 5,
                vbp:column {
                    style = "group",
                    margin = 5,
                    uniform = true,
                    spacing = 4,
                    width = 462,
                    vbp:text {
                        text = "Scale highlighting:",
                    },
                    vbp:switch {
                        width = "100%",
                        items = scaleTypes,
                        bind = preferences.scaleHighlightingType,
                        notifier = function()
                            refreshPianoRollNeeded = true
                        end
                    },
                    vbp:horizontal_aligner {
                        mode = "center",
                        vbp:button {
                            text = "Switch to relative minor or major key",
                            notifier = function()
                                switchToRelativeScale()
                            end
                        },
                    },
                    vbp:text {
                        text = "Key for selected scale:",
                    },
                    vbp:switch {
                        width = "100%",
                        items = notesTable,
                        bind = preferences.keyForSelectedScale,
                        notifier = function()
                            refreshPianoRollNeeded = true
                        end
                    },

                }
            },
            vbp:horizontal_aligner {
                mode = "center",
                margin = vbc.DEFAULT_DIALOG_MARGIN,
                spacing = vbc.DEFAULT_CONTROL_SPACING,
                vbp:button {
                    text = "Ok",
                    height = vbc.DEFAULT_DIALOG_BUTTON_HEIGHT,
                    width = 100,
                    notifier = function()
                        refreshPianoRollNeeded = true
                        dialogVars.setScaleObj:close()
                        restoreFocus()
                    end
                },
            },
        }
    end
    if not dialogVars.setScaleObj or not dialogVars.setScaleObj.visible then
        dialogVars.setScaleObj = app:show_custom_dialog("Scale highlighting - " .. "Simple Pianoroll v" .. manifest:property("Version").value,
                dialogVars.setScaleContent, function(_, key)
                    if key.name == "esc" then
                        refreshPianoRollNeeded = true
                        dialogVars.setScaleObj:close()
                        restoreFocus()
                    end
                    return key
                end)
    else
        dialogVars.setScaleObj:show()
    end
end

--preferences window
showPreferences = function()
    dialogVars.preferencesWasShown = true
    if dialogVars.preferencesContent == nil then
        --preinit colors, when piano roll wasn't opened before
        if not vbw then
            initColors()
        end
        dialogVars.preferencesContent = vbp:column {
            spacing = -8,
            vbp:row {
                vbp:row {
                    uniform = true,
                    margin = 5,
                    spacing = 5,
                    vbp:column {
                        style = "group",
                        margin = 5,
                        spacing = 4,
                        vbp:text {
                            text = "Piano roll grid",
                            width = "100%",
                            font = "bold",
                            style = "strong",
                            align = "center",
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
                            vbp:text {
                                text = "Grid size:",
                            },
                            vbp:row {
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
                        },
                        vbp:text {
                            text = "Grid size settings takes effect,\nwhen the piano roll will be reopened.",
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
                            vbp:text {
                                text = "Vertical grid lines:",
                                width = "50%"
                            },
                            vbp:popup {
                                width = "50%",
                                bind = preferences.gridVLines,
                                items = {
                                    "None",
                                    "Per bar",
                                    "Per beat",
                                },
                            },
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
                            vbp:text {
                                text = "Horizontal grid lines:",
                                width = "50%"
                            },
                            vbp:popup {
                                width = "50%",
                                items = {
                                    "None",
                                    "Per octave",
                                    "Per root note",
                                },
                                bind = preferences.gridHLines,
                            },
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
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
                        vbp:horizontal_aligner {
                            mode = "justify",
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
                        vbp:horizontal_aligner {
                            mode = "justify",
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
                        vbp:horizontal_aligner {
                            mode = "justify",
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
                        vbp:horizontal_aligner {
                            mode = "justify",
                            vbp:text {
                                text = "Shading amount of odd beats:",
                            },
                            vbp:valuebox {
                                steps = { 0.01, 0.1 },
                                min = 0,
                                max = 1,
                                bind = preferences.oddBeatShadingAmount,
                                tostring = function(v)
                                    return string.format("%.2f", v)
                                end,
                                tonumber = function(v)
                                    return tonumber(v)
                                end
                            },
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
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
                        vbp:horizontal_aligner {
                            mode = "justify",
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
                        vbp:horizontal_aligner {
                            mode = "justify",
                            vbp:text {
                                text = "Highlighting amount of non pentatonic keys:",
                            },
                            vbp:valuebox {
                                steps = { 0.01, 0.1 },
                                min = 0,
                                max = 1,
                                bind = preferences.outOfPentatonicScaleHighlightingAmount,
                                tostring = function(v)
                                    return string.format("%.2f", v)
                                end,
                                tonumber = function(v)
                                    return tonumber(v)
                                end
                            },
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
                            vbp:text {
                                text = "Base hue shift value (degree):",
                            },
                            vbp:valuebox {
                                min = 0,
                                max = 360,
                                bind = preferences.noteColorShiftDegree,
                                tostring = function(v)
                                    return string.format("%i°", v)
                                end,
                                tonumber = function(v)
                                    return tonumber(v)
                                end
                            },
                        },
                        vbp:row {
                            vbp:checkbox {
                                bind = preferences.applyVelocityColorShading
                            },
                            vbp:text {
                                text = "Shading note color according to velocity",
                            },
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
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
                        vbp:horizontal_aligner {
                            mode = "justify",
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
                        vbp:row {
                            vbp:checkbox {
                                bind = preferences.highlightEntireLineOfPlayingNote
                            },
                            vbp:text {
                                text = "Highlight the entire row of a playing note",
                            },
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
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
                        vbp:space {
                            height = 8,
                        },
                        vbp:text {
                            text = "Scale and virtual piano keyboard",
                            width = "100%",
                            font = "bold",
                            style = "strong",
                            align = "center",
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
                            vbp:text {
                                text = "Scale highlighting:",
                            },
                            vbp:popup {
                                width = 110,
                                items = scaleTypes,
                                bind = preferences.scaleHighlightingType,
                            },
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
                            vbp:text {
                                text = "Key for selected scale:",
                                width = "50%"
                            },
                            vbp:popup {
                                items = notesTable,
                                bind = preferences.keyForSelectedScale,
                            },
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
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
                        vbp:horizontal_aligner {
                            mode = "justify",
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
                        spacing = 4,
                        vbp:text {
                            text = "Color Settings",
                            width = "100%",
                            font = "bold",
                            style = "strong",
                            align = "center",
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
                            vbp:text {
                                text = "Use track color for:",
                                width = "50%"
                            },
                            vbp:popup {
                                width = "50%",
                                items = {
                                    "Nothing",
                                    "Note highlighting",
                                    "Note color",
                                },
                                bind = preferences.useTrackColorFor,
                            },
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
                            vbp:text {
                                text = "Base grid:",
                            },
                            vbp:row {
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
                                }, },
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
                            vbp:text {
                                text = "Ghost track note:",
                            },
                            vbp:row {
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
                                }, },
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
                            vbp:text {
                                text = "Note:",
                            },
                            vbp:row {
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
                                }, },
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
                            vbp:text {
                                text = "Highlighting note:",
                            },
                            vbp:row {
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
                                }, },
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
                            vbp:text {
                                text = "Highlighting note 2:",
                            },
                            vbp:row {
                                vbp:textfield {
                                    id = "colorNoteHighlight2Field",
                                    bind = preferences.colorNoteHighlight2,
                                    notifier = function()
                                        initColors()
                                        vbwp.colorNoteHighlight2.color = colorNoteHighlight2
                                        vbwp.colorNoteHighlight2Field.value = convertColorValueToString(colorNoteHighlight2)
                                    end
                                },
                                vbp:button {
                                    id = "colorNoteHighlight2",
                                    color = colorNoteHighlight2,
                                }, },
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
                            vbp:text {
                                text = "Muted note:",
                            },
                            vbp:row {
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
                                }, },
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
                            vbp:text {
                                text = "Selected note:",
                            },
                            vbp:row {
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
                                }, },
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
                            vbp:text {
                                text = "Step on / Active btn:",
                            },
                            vbp:row {
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
                                }, },
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
                            vbp:text {
                                text = "Step off:",
                            },
                            vbp:row {
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
                                }, },
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
                            vbp:text {
                                text = "Keyboard list:",
                            },
                            vbp:row {
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
                                }, },
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
                            vbp:text {
                                text = "Keyboard white key:",
                            },
                            vbp:row {
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
                                }, },
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
                            vbp:text {
                                text = "Keyboard black key:",
                            },
                            vbp:row {
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
                                }, },
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
                            vbp:text {
                                text = "Vol button:",
                            },
                            vbp:row {
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
                                }, },
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
                            vbp:text {
                                text = "Pan button:",
                            },
                            vbp:row {
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
                                }, },
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
                            vbp:text {
                                text = "Dly button:",
                            },
                            vbp:row {
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
                                }, },
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
                        spacing = 4,
                        vbp:text {
                            text = "Note playback and preview",
                            width = "100%",
                            font = "bold",
                            style = "strong",
                            align = "center",
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
                        vbp:horizontal_aligner {
                            mode = "justify",
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
                            vbp:checkbox {
                                bind = preferences.previewMidiStuckWorkaround,
                                tooltip = "It sends note off events after some delay. This will fix stuck notes in some plugins like VCV Rack 2.",
                            },
                            vbp:text {
                                text = "Use workaround for stuck notes",
                            },
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
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
                            width = "100%",
                        },
                        vbp:text {
                            text = "Please check in the Renoise preferences in the OSC\n" ..
                                    "section that the OSC server has been activated and is\n" ..
                                    "running with the same protocol (UDP, TCP) and port\n" ..
                                    "settings as specified here."
                        },
                        vbp:space {
                            height = 8,
                        },
                        vbp:text {
                            text = "Workflow",
                            width = "100%",
                            font = "bold",
                            style = "strong",
                            align = "center",
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
                                bind = preferences.moveNoteInPenMode,
                            },
                            vbp:text {
                                text = "Allow move, scale and duplication of notes in pen mode",
                            },
                        },
                        vbp:row {
                            vbp:checkbox {
                                bind = preferences.setVelPanDlyLenFromLastNote,
                            },
                            vbp:text {
                                text = "Set vel, pan, dly and len from last drawn note or selection",
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
                                bind = preferences.setComputerKeyboardVelocity,
                            },
                            vbp:text {
                                text = "Set preview velocity also to Renoise computer keyboard velocity",
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
                                text = "Automatically add or remove note columns, when needed",
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
                    },
                    vbp:column {
                        style = "group",
                        margin = 5,
                        spacing = 4,
                        vbp:text {
                            text = "Keyboard",
                            width = "100%",
                            font = "bold",
                            style = "strong",
                            align = "center",
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
                                bind = preferences.swapCtrlAlt,
                            },
                            vbp:text {
                                text = "Swap left ctrl and alt key",
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
                        vbp:horizontal_aligner {
                            mode = "justify",
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
                        vbp:space {
                            height = 8,
                        },
                        vbp:text {
                            text = "Mouse",
                            width = "100%",
                            font = "bold",
                            style = "strong",
                            align = "center",
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
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
                        vbp:horizontal_aligner {
                            mode = "justify",
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
                        vbp:horizontal_aligner {
                            mode = "justify",
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
                                bind = preferences.mouseWarpingCompatibilityMode,
                                notifier = function()
                                    rebuildWindowDialog = true
                                end,
                                tooltip = "Disable select marker and other mouse related functions to prevent mouse jumping."
                            },
                            vbp:text {
                                text = "Mouse warping compatibility mode",
                            },
                        },
                        vbp:text {
                            text = "IMPORTANT: To improve mouse control, please disable\nthe mouse warping option in the Renoise preferences\nin section GUI. This" ..
                                    " will also fix mouse jumping,\nwhen you use the piano roll.\nIf you need mouse warping, you can enable the\nmouse warping compatibility mode."
                        },
                        vbp:space {
                            height = 8,
                        },
                        vbp:text {
                            text = "MIDI In",
                            width = "100%",
                            font = "bold",
                            style = "strong",
                            align = "center",
                        },
                        vbp:row {
                            vbp:checkbox {
                                bind = preferences.midiIn,
                            },
                            vbp:text {
                                text = "Enable MIDI In support",
                            },
                        },
                        vbp:horizontal_aligner {
                            mode = "justify",
                            vbp:text {
                                text = "Input Device:",
                                width = "50%"
                            },
                            vbp:popup {
                                id = "midi",
                                width = "50%",
                                notifier = function(i)
                                    preferences.midiDevice.value = vbwp.midi.items[i]
                                    --reset midi device, when initialized
                                    if midiDevice and midiDevice.is_open then
                                        midiDevice:close()
                                        midiDevice = nil
                                    end
                                end
                            },
                        },
                        vbp:space {
                            height = 8,
                        },
                        vbp:text {
                            text = "Additional features",
                            width = "100%",
                            font = "bold",
                            style = "strong",
                            align = "center",
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
                                bind = preferences.mirroringGhostTrack,
                            },
                            vbp:text {
                                text = "Mirror notes of the current ghost track",
                            },
                        },
                        vbp:row {
                            vbp:checkbox {
                                bind = preferences.useChordStampingForNotePreview,
                            },
                            vbp:text {
                                text = "Use chord stamping also for note preview",
                            },
                        },
                        vbp:row {
                            vbp:checkbox {
                                bind = preferences.chordGunPreset,
                            },
                            vbp:text {
                                text = "Load ChordGun presets for chord stamping",
                            },
                        },
                        vbp:row {
                            vbp:checkbox {
                                bind = preferences.enableAdditonalSampleTools,
                            },
                            vbp:text {
                                text = "Enable optional editing tools (Sample, Mixing, Pattern ...)",
                            },
                        },
                    },
                }
            },
            vbp:horizontal_aligner {
                mode = "center",
                margin = vbc.DEFAULT_DIALOG_MARGIN,
                spacing = vbc.DEFAULT_CONTROL_SPACING * 10,
                vbp:button {
                    text = "Close",
                    height = vbc.DEFAULT_DIALOG_BUTTON_HEIGHT,
                    width = 100,
                    notifier = function()
                        dialogVars.preferencesObj:close()
                        restoreFocus()
                    end
                },
                vbp:button {
                    text = "Reset to default",
                    height = vbc.DEFAULT_DIALOG_BUTTON_HEIGHT,
                    width = 100,
                    notifier = function()
                        if app:show_prompt("Reset to default", "Are you sure you want to reset all settings to their default values?", { "Yes", "No" }) == "Yes" then
                            for key in pairs(defaultPreferences) do
                                preferences[key].value = defaultPreferences[key]
                            end
                            app:show_message("All preferences was set to default values.")
                        end
                    end
                },
                vbp:button {
                    text = "Help / Feedback",
                    height = vbc.DEFAULT_DIALOG_BUTTON_HEIGHT,
                    width = 100,
                    notifier = function()
                        app:open_url("https://forum.renoise.com/t/simple-pianoroll-com-duftetools-simplepianoroll-xrnx/63034")
                        dialogVars.preferencesObj:close()
                    end
                },
            },
        }
    end
    --refresh midi in list
    vbwp.midi.items = renoise.Midi.available_input_devices()
    --set first midi device as default one
    local found = false
    if #vbwp.midi.items > 0 then
        if preferences.midiDevice.value == "" then
            preferences.midiDevice.value = vbwp.midi.items[1]
        else
            --search for midi device in list and preselect it
            for i = 1, #vbwp.midi.items do
                if vbwp.midi.items[i] == preferences.midiDevice.value then
                    vbwp.midi.value = i
                    found = true
                    break
                end
            end
        end
    end
    --add device to the list, when it's still missing
    if not found and preferences.midiDevice.value ~= "" then
        local newList = vbwp.midi.items
        newList[#newList + 1] = preferences.midiDevice.value
        vbwp.midi.items = newList
        vbwp.midi.value = #newList
    end
    if not dialogVars.preferencesObj or not dialogVars.preferencesObj.visible then
        dialogVars.preferencesObj = app:show_custom_dialog("Preferences - " .. "Simple Pianoroll v" .. manifest:property("Version").value, dialogVars.preferencesContent)
    else
        dialogVars.preferencesObj:show()
    end
end

--create main piano roll dialog
local function createPianoRollDialog(gridWidth, gridHeight)
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
                    width = gridStepSizeW - 1,
                    color = colorWhiteKey[1],
                    notifier = loadstring(temp),
                    pressed = loadstring(temp2)
                },
                vb:space {
                    id = "ps" .. tostring(x) .. "_" .. tostring(y),
                    width = 1,
                    height = gridStepSizeH,
                    visible = true,
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
        width = gridStepSizeW * gridWidth - (gridSpacing * (gridWidth)) + 6,
        spacing = -(gridStepSizeW * gridWidth - (gridSpacing * (gridWidth)) + 6),
        vb:minislider {
            width = gridStepSizeW * gridWidth - (gridSpacing * (gridWidth)) + 6,
            height = gridStepSizeH + 2,
            min = 1,
            max = gridWidth,
            value = 1,
            default = 1.1234567,
            tooltip = "Hold ctrl key to set a loop range with your mouse.\nDouble click to remove the loop range.\nUse shift key to move the loop range.",
            notifier = function(n)
                local transport = song.transport
                --reset loop on double click
                if n == 1.1234567 then
                    if transport.loop_pattern == true then
                        transport.loop_pattern = false
                    else
                        xypadpos.loopslider = nil
                        transport.loop_block_enabled = false
                        if transport.loop_sequence_start > 0 then
                            transport.loop_sequence_range = {}
                        end
                    end
                else
                    local looppos = math.floor(n + 0.4) + stepOffset
                    local newloopset = false
                    if modifier.keyControl and not modifier.keyShift then
                        --first start, set new loop range
                        if xypadpos.loopslider == nil then
                            xypadpos.loopslider = looppos
                        elseif looppos >= xypadpos.loopslider and looppos <= song.selected_pattern.number_of_lines then
                            --set loop range
                            song.transport.loop_range = {
                                renoise.SongPos(transport.edit_pos.sequence, xypadpos.loopslider),
                                renoise.SongPos(transport.edit_pos.sequence, looppos + 1)
                            }
                            newloopset = true
                        elseif looppos < xypadpos.loopslider then
                            --set loop range
                            song.transport.loop_range = {
                                renoise.SongPos(transport.edit_pos.sequence, looppos),
                                renoise.SongPos(transport.edit_pos.sequence, xypadpos.loopslider + 1)
                            }
                            newloopset = true
                        end
                    elseif modifier.keyShift and not modifier.keyControl then
                        --only when a looprange is set
                        if loopingrange then
                            local x = transport.loop_start.line
                            local len = transport.loop_end.line - transport.loop_start.line
                            if transport.loop_start.sequence ~= transport.loop_end.sequence then
                                len = song.selected_pattern.number_of_lines + 1 - transport.loop_start.line
                            end

                            --move loop selection
                            if (xypadpos.loopslider == nil and looppos >= x and looppos < x + len) or xypadpos.loopslider then
                                if xypadpos.loopslider == nil then
                                    xypadpos.loopslider = looppos - x
                                end
                                local newlooppos = math.min(song.selected_pattern.number_of_lines - len + 1, math.max(looppos - xypadpos.loopslider, 1))
                                song.transport.loop_range = {
                                    renoise.SongPos(transport.edit_pos.sequence, newlooppos),
                                    renoise.SongPos(transport.edit_pos.sequence, newlooppos + len)
                                }
                                newloopset = true
                            end
                        end
                    else
                        --no control key is holded, so reset loop slider state
                        xypadpos.loopslider = nil
                        jumpToNoteInPattern(math.floor(n + 0.5) + stepOffset)
                    end
                    if newloopset then
                        --when new end loop is before current playback pos, restart from loop start
                        if song.transport.playing
                                and song.transport.playback_pos.sequence == song.transport.loop_start.sequence
                                and song.transport.playback_pos.sequence == song.transport.loop_end.sequence
                                and song.transport.playback_pos.line >= song.transport.loop_end.line
                        then
                            playPatternFromLine()
                        end
                    end
                end
            end
        },
        vb:button {
            width = gridStepSizeW * gridWidth - (gridSpacing * (gridWidth)) + 6,
            height = gridStepSizeH + 4,
            active = false,
            color = colorKeyBlack,
        },
        vb:column {
            vb:space {
                width = gridStepSizeW * gridWidth - (gridSpacing * (gridWidth)) + 6,
            },
            vb:row {
                margin = -1,
                vb:space {
                    id = "blockloopspc",
                    width = gridStepSizeW * 1 - (gridSpacing * 1),
                    height = 5,
                },
                vb:button {
                    id = "blockloop",
                    height = gridStepSizeH + 4,
                    width = gridStepSizeW * 3 - (gridSpacing * 2),
                    active = false,
                    visible = false,
                },
            },
        },
    }
    timeline:add_child(vb:space {
        width = gridStepSizeW * gridWidth - (gridSpacing * (gridWidth)) + 6,
    })
    local timeline_row = vb:row {}
    for i = 1, gridWidth do
        local temp = vb:text {
            id = "timeline" .. i,
            visible = false,
            height = gridStepSizeH + 4,
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
        vb:horizontal_aligner {
            margin = 3,
            spacing = -1,
            width = gridStepSizeW * (math.max(gridWidth, 64) + 5) - (gridSpacing * (math.max(gridWidth, 64) + 5)) + 2,
            mode = "justify",
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
                        playPatternFromLine()
                    end
                },
                vb:button {
                    id = "loopbutton",
                    bitmap = "Icons/Transport_LoopPattern.bmp",
                    width = 24,
                    tooltip = "Loop current pattern",
                    notifier = function()
                        if song.transport.loop_pattern == true then
                            song.transport.loop_pattern = false
                        elseif loopingrange then
                            xypadpos.loopslider = nil
                            song.transport.loop_block_enabled = false
                            if song.transport.loop_sequence_start > 0 then
                                song.transport.loop_sequence_range = {}
                            end
                        else
                            song.transport.loop_pattern = true
                        end
                    end
                },
                vb:button {
                    bitmap = "Icons/Transport_Stop.bmp",
                    width = 24,
                    tooltip = "Stop playing",
                    notifier = function()
                        if song.transport.playing then
                            song.transport:stop()
                        else
                            song.transport:panic()
                        end
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
                    bitmap = "Icons/AutomationList_Empty.bmp",
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
                    tooltip = "Pen mode (F2)\nDouble click or ALT click for pen settings.",
                    id = "mode_pen",
                    notifier = function()
                        if dbclkDetector("penmodeBtn") or modifier.keyAlt then
                            showPenSettingsDialog()
                        else
                            penMode = true
                            audioPreviewMode = false
                            refreshControls = true
                        end
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
                spacing = 1,
                style = "panel",
                vb:row {
                    spacing = -3,
                    vb:popup {
                        id = "ins",
                        width = 146,
                        notifier = function(idx)
                            local val = string.match(
                                    vbw.ins.items[idx],
                                    '%[([0-9A-Z-]+)%]$'
                            )
                            if val and vbw["ins"].active then
                                currentInstrument = fromRenoiseHex(val)
                                if currentInstrument >= 0 and currentInstrument <= #song.instruments then
                                    song.selected_instrument_index = currentInstrument + 1
                                end
                                if #noteSelection > 0 then
                                    changePropertiesOfSelectedNotes(nil, nil, nil, nil, nil, currentInstrument)
                                else
                                    refreshPianoRollNeeded = true
                                end
                            end
                        end
                    },
                    vb:button {
                        tooltip = "Edit instrument / Open plugin editor ...\n(While holding ctrl, midi out target will be opened)",
                        bitmap = "Icons/Options.bmp",
                        notifier = function()
                            if currentInstrument ~= 255 then
                                local plugin = song.instruments[currentInstrument + 1].plugin_properties
                                --check if the current instrument have a midi target
                                if modifier.keyControl and plugin.midi_output_routing_index > 0 then
                                    plugin = song.instruments[plugin.midi_output_routing_index].plugin_properties
                                end
                                --open vst external editor
                                if plugin and plugin.plugin_device and plugin.plugin_device.external_editor_available then
                                    plugin.plugin_device.external_editor_visible = false
                                    plugin.plugin_device.external_editor_visible = true
                                elseif plugin and not plugin.plugin_device then
                                    --switch to instrument settings
                                    app.window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
                                    --close piano roll
                                    if windowObj and windowObj.visible then
                                        windowObj:close()
                                    end
                                end
                            end
                        end,
                    },
                },
                vb:text {
                    text = "Len",
                },
                vb:valuebox {
                    id = "note_len",
                    tooltip = "Note length",
                    steps = { 1, 2 },
                    min = 1,
                    max = 512,
                    value = currentNoteLength,
                    notifier = function(number)
                        if #noteSelection > 0 and currentNoteLength ~= number then
                            changeSizeSelectedNotes(number)
                        end
                        currentNoteLength = number
                        refreshControls = true
                        --fix for bad keyevents of key handler, bug
                        restoreFocus()
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
                vb:row {
                    spacing = -3,
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
                            currentNoteLength = math.min(math.floor(currentNoteLength * 2), 512)
                            refreshControls = true
                        end,
                    },
                },
                vb:button {
                    id = "notecolumn_vel",
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
                        --fix for bad keyevents of key handler, bug
                        restoreFocus()
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
                            if modifier.keyShift then
                                currentNoteEndVelocity = 255
                                changePropertiesOfSelectedNotes(nil, currentNoteEndVelocity)
                            end
                        end
                        refreshControls = true
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
                        --fix for bad keyevents of key handler, bug
                        restoreFocus()
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
                        --fix for bad keyevents of key handler, bug
                        restoreFocus()
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
                    id = "notecolumn_delay",
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
                        --fix for bad keyevents of key handler, bug
                        restoreFocus()
                    end,
                },
                vb:button {
                    id = "note_dly_clear",
                    text = "C",
                    tooltip = "Clear note delay\n(While holding shift: Clear both delay values)",
                    notifier = function()
                        currentNoteDelay = 0
                        changePropertiesOfSelectedNotes(nil, nil, currentNoteDelay)
                        if modifier.keyShift then
                            currentNoteEndDelay = 0
                            changePropertiesOfSelectedNotes(nil, nil, nil, currentNoteEndDelay)
                        end
                        refreshControls = true
                        refreshPianoRollNeeded = true
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
                        --fix for bad keyevents of key handler, bug
                        restoreFocus()
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
                    bitmap = "Icons/Instrument_Volume.bmp",
                    tooltip = "Histogram (Alt+H)",
                    width = 24,
                    notifier = function()
                        if #noteSelection == 0 then
                            updateNoteSelection("all", true)
                        end
                        showHistogram()
                    end,
                },
            },
            vb:row {
                margin = 3,
                spacing = 1,
                style = "panel",
                vb:text {
                    text = "Ghost Track",
                },
                vb:popup {
                    id = "ghosttracks",
                    width = 70,
                    notifier = function(index)
                        if not currentGhostTrack or currentGhostTrack ~= index then
                            currentGhostTrack = index
                            refreshControls = true
                            refreshPianoRollNeeded = true
                        end
                    end,
                },
                vb:row {
                    spacing = -3,
                    vb:button {
                        bitmap = "Icons/Browser_Rescan.bmp",
                        width = 24,
                        tooltip = "Switch to selected ghost track",
                        notifier = function()
                            switchGhostTrack()
                        end
                    },
                    vb:button {
                        id = "ghosttrackmirror",
                        bitmap = "Icons/Clone.bmp",
                        width = 24,
                        tooltip = "Mirror notes of the current ghost track",
                        notifier = function()
                            preferences.mirroringGhostTrack.value = not preferences.mirroringGhostTrack.value
                            refreshPianoRollNeeded = true
                            refreshControls = true
                        end
                    },
                },
            },
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
                                        switchGhostTrack()
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
                                        tooltip = "Scale highlighting\nIf you hold down the Ctrl key while clicking, you switch to relative minor or major.",
                                        notifier = function()
                                            if modifier.keyControl then
                                                switchToRelativeScale()
                                            else
                                                showSetScaleDialog()
                                            end
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
                                    width = gridStepSizeW * gridWidth - (gridSpacing * (gridWidth)) + 2,
                                    vb:horizontal_aligner {
                                        width = gridStepSizeW * gridWidth - (gridSpacing * (gridWidth)) + 2,
                                        mode = "right",
                                        spacing = -2,
                                        vb:row {
                                            id = "chorddetection",
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
                                                        tooltip = "Scale degree and roman numeral\n\n" ..
                                                                "Can help in creating chord progressions. Some common chord progressions used are:\n\n" ..
                                                                "I V IV vi - Axis of Awesome\nvi IV I V - Axis of Awesome\n" ..
                                                                "i bVII bVI V - Andalusian cadence\nI vi IV V - doo-wop progression\n" ..
                                                                "I bVII IV I - Mixolydian Vamp\nIV V7 iii vi - Common japanese chords\n" ..
                                                                "IV V7 vi - Common japanese chords\nii V I - Jazz chord progression / Changing key progression\n\n" ..
                                                                "And there are more ... :)",
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
                                        vb:row {
                                            style = "panel",
                                            margin = 1,
                                            vb:vertical_aligner {
                                                mode = "center",
                                                vb:button {
                                                    bitmap = "Icons/Options.bmp",
                                                    width = 24,
                                                    tooltip = "Preferences ...",
                                                    notifier = function()
                                                        showPreferences()
                                                    end,
                                                },
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
        currentInstrument = nil
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
            createPianoRollDialog(gridWidth, gridHeight)
        end
        --when invisible is enabled, no snapback needed
        if not preferences.mouseWarpingCompatibilityMode.value then
            vbw["xypad"].snapback = snapBackVal
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
        restoreFocus()
    end
end

--add main function to context menu of pattern editor
tool:add_menu_entry {
    name = "Pattern Editor:Edit with Simple Pianoroll ...",
    invoke = function()
        main_function()
    end
}

--add main function to context menu of mixer
tool:add_menu_entry {
    name = "Mixer:Edit with Simple Pianoroll ...",
    invoke = function()
        --focus pattern editor
        app.window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
        main_function()
    end
}

--add main function to context menu of instruments
tool:add_menu_entry {
    name = "Instrument Box:Edit Pattern with Simple Pianoroll ...",
    invoke = function()
        --search track for current instrument
        song = renoise.song()
        local l_song = song
        local patterns = l_song.patterns
        local tracks
        local maxColumns
        local patternTrack
        local lineValues
        local note_column
        local idx = song.selected_instrument_index - 1
        local trackidx
        for i = 1, #patterns do
            tracks = patterns[i].tracks
            for j = 1, #tracks do
                patternTrack = patterns[i]:track(j)
                maxColumns = song.tracks[j].visible_note_columns
                for c = 1, maxColumns do
                    lineValues = patternTrack.lines
                    for line = 1, #lineValues do
                        note_column = lineValues[line]:note_column(c)
                        if note_column.instrument_value == idx then
                            trackidx = j
                            break
                        elseif note_column.instrument_value ~= 255 then
                            break
                        end
                    end
                    if trackidx ~= nil then
                        break
                    end
                end
                if trackidx ~= nil then
                    break
                end
            end
            if trackidx ~= nil then
                break
            end
        end
        --focus pattern editor
        if trackidx then
            song.selected_track_index = trackidx
            app.window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
            main_function()
        else
            showStatus("No pattern found, which is using the selected instrument.")
        end
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
                    --when current sequnce not the editing one, disable follow player, when playing
                    if song.transport.playing and song.transport.follow_player and song.selected_sequence_index ~= s then
                        wasFollowPlayer = song.transport.follow_player
                        song.transport.follow_player = false
                    end
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
            currentInstrument = song.selected_instrument_index - 1
        end
        if currentInstrument and song.instruments[currentInstrument + 1] then
            local plugin = song.instruments[currentInstrument + 1].plugin_properties
            if plugin and plugin.plugin_device and plugin.plugin_device.external_editor_available then
                plugin.plugin_device.external_editor_visible = not plugin.plugin_device.external_editor_visible
                if not plugin.plugin_device.external_editor_visible then
                    --restore focus back to piano roll
                    restoreFocus()
                end
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

tool:add_menu_entry {
    name = "Main Menu:Tools:Simple Pianoroll:Open Simple Pianoroll ...",
    invoke = function()
        if not windowObj or not windowObj.visible then
            main_function()
        end
    end
}

tool:add_menu_entry {
    name = "Main Menu:Tools:Simple Pianoroll:Preferences ...",
    invoke = function()
        showPreferences()
    end
}

--additional tools non piano roll related
if preferences.enableAdditonalSampleTools.value then

    --some values to remember
    local lastValTools = {
        lastRefValue = 0.04,
        lastBPM = 120,
        lastMode = nil,
        lastGlobalPitch = nil
    }

    --search for typical vstfx on master chain to switch reference
    local function switchVSTFxReference(type)
        --search for master track
        for it, track in ipairs(renoise.song().tracks) do
            if track.type == renoise.Track.TRACK_TYPE_MASTER then
                --search for mcompare
                for id, device in ipairs(track.devices) do
                    if type == 3 then
                        if device.name == "VST: Xfer Records: LFOTool_x64" then
                            device.external_editor_visible = not device.external_editor_visible
                        end
                    elseif type == 2 then
                        if device.name == "VST: Voxengo: SPAN" or device.name == "VST: Plugin Alliance: ADPTR MetricAB" then
                            device.external_editor_visible = not device.external_editor_visible
                        end
                    else
                        if device.name == "VST: MeldaProduction: MCompare" then
                            for ip, parameter in ipairs(device.parameters) do
                                if type == 0 then
                                    if parameter.name == "Selected" then
                                        if parameter.value > 0 then
                                            lastValTools.lastRefValue = parameter.value --save latest active reference
                                            renoise.song().tracks[it].devices[id].parameters[ip]:record_value(0)
                                        else
                                            renoise.song().tracks[it].devices[id].parameters[ip]:record_value(lastValTools.lastRefValue)
                                        end
                                    end
                                else
                                    if parameter.name == "Filter - Filter" then
                                        if parameter.value > 0 then
                                            renoise.song().tracks[it].devices[id].parameters[ip]:record_value(0)
                                        else
                                            renoise.song().tracks[it].devices[id].parameters[ip]:record_value(1)
                                        end
                                    end
                                end
                            end
                        end
                        if device.name == "VST: Plugin Alliance: ADPTR MetricAB" then
                            for ip, parameter in ipairs(device.parameters) do
                                if type == 0 then
                                    if parameter.name == "AB Switch" then
                                        if parameter.value > 0 then
                                            renoise.song().tracks[it].devices[id].parameters[ip]:record_value(0)
                                        else
                                            renoise.song().tracks[it].devices[id].parameters[ip]:record_value(1)
                                        end
                                    end
                                else
                                    if parameter.name == "Filter Preset" then
                                        if parameter.value == 1 then
                                            renoise.song().tracks[it].devices[id].parameters[ip]:record_value(0.6)
                                        else
                                            renoise.song().tracks[it].devices[id].parameters[ip]:record_value(1)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    tool:add_keybinding {
        name = "Global:Simple Pianoroll - Workflow Tools:Audio reference switch ...",
        invoke = function()
            switchVSTFxReference(0)
        end
    }

    tool:add_keybinding {
        name = "Global:Simple Pianoroll - Workflow Tools:Sub Filter switch ...",
        invoke = function()
            switchVSTFxReference(1)
        end
    }

    tool:add_keybinding {
        name = "Global:Simple Pianoroll - Workflow Tools:Show / Hide Analyzer ...",
        invoke = function()
            switchVSTFxReference(2)
        end
    }

    tool:add_keybinding {
        name = "Global:Simple Pianoroll - Workflow Tools:Show / Hide Waveform Analyzer ...",
        invoke = function()
            switchVSTFxReference(3)
        end
    }

    local function fitSampleBeatSync(bpm)
        song = renoise.song()
        local sample = song.selected_sample
        local sample_buffer = sample.sample_buffer
        local sample_rate = sample_buffer.sample_rate
        local song_bpm = song.transport.bpm
        local res = 'Percussion'

        if lastValTools.lastMode ~= nil then
            res = lastValTools.lastMode
        end

        if (sample_buffer.has_sample_data) then
            if bpm == nil then
                --when there is a selection, try to calculate the bpm (dirty)
                local samplecount = math.abs(sample_buffer.selection_end - sample_buffer.selection_start)
                if samplecount > 100 then
                    local newbpm = 60.0 * sample_rate / samplecount
                    for i = 0, 10 do
                        if newbpm > 180 then
                            newbpm = newbpm / 2
                        end
                        if newbpm < 60 then
                            newbpm = newbpm * 2
                        end
                        if newbpm > 60 and newbpm < 180 then
                            break
                        end
                    end
                    --check if the doubled value is near the current song bpm
                    if math.abs(newbpm * 2 - song_bpm) < math.abs(newbpm - song_bpm) then
                        newbpm = newbpm * 2
                    end
                    lastValTools.lastBPM = math.floor(newbpm + 0.5)
                end

                local bpm_selector = renoise.ViewBuilder():valuebox { min = 30, max = 250, value = lastValTools.lastBPM }
                local view = renoise.ViewBuilder():vertical_aligner {
                    margin = 10,
                    renoise.ViewBuilder():horizontal_aligner {
                        spacing = 10,
                        renoise.ViewBuilder():vertical_aligner {
                            renoise.ViewBuilder():text { text = 'Calculate and set a fixed Beatsync value for the current sample and set a beat sync mode.' },
                            renoise.ViewBuilder():text { text = 'When you select a range in the sample editor, the bpm value will be calculated.' },
                            renoise.ViewBuilder():text { text = 'BPM of your sample:' },
                            renoise.ViewBuilder():horizontal_aligner {
                                bpm_selector,
                                renoise.ViewBuilder():button {
                                    text = ":2",
                                    tooltip = "Halve BPM number",
                                    notifier = function()
                                        local new = bpm_selector.value / 2
                                        if new >= 30 then
                                            bpm_selector.value = new
                                        end
                                    end,
                                },
                                renoise.ViewBuilder():button {
                                    text = "*2",
                                    tooltip = "Double BPM number",
                                    notifier = function()
                                        local new = bpm_selector.value * 2
                                        if new <= 250 then
                                            bpm_selector.value = new
                                        end
                                    end,
                                },
                            }
                        },
                    },
                }

                res = app:show_custom_prompt(
                        "Set sample BPM - " .. "Simple Pianoroll v" .. manifest:property("Version").value,
                        view,
                        { 'Repitch', 'Percussion', 'Texture', 'Cancel' }
                )
                bpm = bpm_selector.value
            end

            if res ~= 'Cancel' and res ~= '' then
                local num_frames = sample_buffer.number_of_frames
                local num_channels = sample_buffer.number_of_channels
                local bit_depth = sample_buffer.bit_depth
                local sample_data_1 = {}
                local sample_data_2 = {}
                local lpb = song.transport.lpb
                local samples_per_beat = 60.0 / bpm * sample_rate
                local samples_per_line = samples_per_beat / lpb
                local add_samples
                lastValTools.lastBPM = bpm
                lastValTools.lastMode = res

                local lines_in_sample = num_frames / samples_per_line
                local lines_in_sample_mod = num_frames % samples_per_line

                if lines_in_sample < 512 then
                    if lines_in_sample_mod > 0 then
                        lines_in_sample = math.ceil(lines_in_sample)
                        add_samples = lines_in_sample * samples_per_line - sample_buffer.number_of_frames

                        for frame_idx = 1, num_frames do
                            sample_data_1[frame_idx] = sample_buffer:sample_data(1, frame_idx)
                            if (num_channels == 2) then
                                sample_data_2[frame_idx] = sample_buffer:sample_data(2, frame_idx)
                            end
                        end

                        sample_buffer:delete_sample_data()
                        sample_buffer:create_sample_data(sample_rate, bit_depth, num_channels, num_frames + add_samples)
                        sample_buffer:prepare_sample_data_changes()
                        for frame_idx = 1, num_frames do
                            sample_buffer:set_sample_data(1, frame_idx, sample_data_1[frame_idx])
                            if (num_channels == 2) then
                                sample_buffer:set_sample_data(2, frame_idx, sample_data_2[frame_idx])
                            end
                        end
                        sample_buffer:finalize_sample_data_changes()
                    end
                    sample.beat_sync_enabled = true
                    sample.beat_sync_lines = lines_in_sample
                    if res == 'Repitch' then
                        sample.beat_sync_mode = renoise.Sample.BEAT_SYNC_REPITCH
                    elseif res == 'Texture' then
                        sample.beat_sync_mode = renoise.Sample.BEAT_SYNC_TEXTURE
                    else
                        sample.beat_sync_mode = renoise.Sample.BEAT_SYNC_PERCUSSION
                    end
                    sample.autoseek = true
                else
                    app:show_warning("Sample is too long, calculated beat sync value is higher than 512 (" .. math.floor(lines_in_sample + 0.5) .. " calculated)!")
                end
            end
        end
    end

    --tool to fit sample length for beat sync feature
    tool:add_menu_entry {
        name = "Sample Editor:Process:Fit sample to beat sync ...",
        invoke = function()
            fitSampleBeatSync()
        end
    }

    --tool to fit sample length for beat sync feature (use song bpm)
    tool:add_menu_entry {
        name = "Sample Editor:Process:Fit sample to beat sync (Song BPM) ...",
        invoke = function()
            fitSampleBeatSync(renoise.song().transport.bpm)
        end
    }

    --tool to duplicate a pattern so 64 becomes 128
    tool:add_menu_entry {
        name = "Pattern Sequencer:Duplicate content ...",
        invoke = function()
            local current_pattern = renoise.song().selected_pattern
            local pattern_length = current_pattern.number_of_lines
            current_pattern.number_of_lines = pattern_length * 2
            if pattern_length * 2 <= 512 then
                for it, current_patterntrack in ipairs(current_pattern.tracks) do
                    for line_idx = 1, pattern_length do
                        current_patterntrack:line(line_idx + pattern_length):copy_from(current_patterntrack:line(line_idx))
                    end
                end
            end
        end
    }

    -- tool to set transpose value for instruments
    tool:add_menu_entry {
        name = "Instrument Box:Change instrument's global pitch ...",
        invoke = function()
            song = renoise.song()
            --there is current no way to get the selection via api, so search start and end by check for empty instruments
            local from = song.selected_instrument_index
            local to = song.selected_instrument_index
            for i = from, 1, -1 do
                local ins = song.instruments[i]
                if not ins or (#ins.samples == 0 and ins.plugin_properties.plugin_loaded == false) then
                    break
                end
                from = i
                lastValTools.lastGlobalPitch = math.max(ins.transpose)
            end
            --check till next empty one
            for i = to, math.min(from + renoise.Song.MAX_NUMBER_OF_INSTRUMENTS, renoise.Song.MAX_NUMBER_OF_INSTRUMENTS) do
                local ins = song.instruments[i]
                if not ins or (#ins.samples == 0 and ins.plugin_properties.plugin_loaded == false) then
                    break
                end
                to = i
                lastValTools.lastGlobalPitch = math.max(ins.transpose)
            end
            --show dialog
            local global_pitch_box = renoise.ViewBuilder():valuebox { min = -120, max = 1220, value = lastValTools.lastGlobalPitch }
            local view = renoise.ViewBuilder():vertical_aligner {
                margin = 10,
                renoise.ViewBuilder():horizontal_aligner {
                    spacing = 10,
                    renoise.ViewBuilder():vertical_aligner {
                        renoise.ViewBuilder():text { text = 'Because of the API limitations, empty instruments are used for to detect the selection.' },
                        renoise.ViewBuilder():text { text = "New instrument's global pitch:" },
                        global_pitch_box,
                    },
                },
            }
            local res = app:show_custom_prompt(
                    "Change instrument's global pitch (" .. (to - from) .. " instrument's) - " .. "Simple Pianoroll v" .. manifest:property("Version").value,
                    view,
                    { 'Ok', 'Cancel' }
            )
            if res == 'Ok' then
                --apply new transpose value
                for i = from, to do
                    local ins = song.instruments[i]
                    ins.transpose = global_pitch_box.value
                end
            end
        end
    }

    --tool to fit risers a specific line length
    tool:add_menu_entry {
        name = "Sample Editor:Process:Align sample selection to beat ...",
        invoke = function()
            song = renoise.song()
            local sample = song.selected_sample
            local sample_buffer = sample.sample_buffer

            if (sample_buffer.has_sample_data) then
                local bpm = song.transport.bpm
                local lpb = song.transport.lpb
                local align_to_lines

                local mpt = app:show_prompt(
                        "Align sample selection to beat - " .. "Simple Pianoroll v" .. manifest:property("Version").value,
                        "Please choose one of the following sizes to enlarge the sample selection:",
                        { "8", "16", "32", "64", "96", "128", "256", "Cancel" }
                )

                if (mpt == "8") then
                    align_to_lines = 8
                elseif (mpt == "16") then
                    align_to_lines = 16
                elseif (mpt == "32") then
                    align_to_lines = 32
                elseif (mpt == "64") then
                    align_to_lines = 64
                elseif (mpt == "96") then
                    align_to_lines = 96
                elseif (mpt == "128") then
                    align_to_lines = 128
                elseif (mpt == "256") then
                    align_to_lines = 256
                else
                    return
                end

                if align_to_lines > 0 then
                    local num_frames = sample_buffer.number_of_frames
                    local num_channels = sample_buffer.number_of_channels
                    local bit_depth = sample_buffer.bit_depth
                    local sample_rate = sample_buffer.sample_rate
                    local sample_data_1 = {}
                    local sample_data_2 = {}
                    local samples_per_beat = 60.0 / bpm * sample_rate
                    local samples_per_line = samples_per_beat / lpb
                    local selection_end = sample_buffer.selection_end
                    local add_samples = (align_to_lines * samples_per_line) - selection_end

                    for frame_idx = 1, num_frames do
                        sample_data_1[frame_idx] = sample_buffer:sample_data(1, frame_idx)
                        if (num_channels == 2) then
                            sample_data_2[frame_idx] = sample_buffer:sample_data(2, frame_idx)
                        end
                    end

                    if add_samples > 0 then

                        -- add silence before, so impakt will stay in sync with beat
                        sample_buffer:delete_sample_data()
                        sample_buffer:create_sample_data(sample_rate, bit_depth, num_channels, num_frames + add_samples)
                        sample_buffer:prepare_sample_data_changes()
                        for frame_idx = 1, num_frames do
                            sample_buffer:set_sample_data(1, frame_idx + add_samples, sample_data_1[frame_idx])
                            if (num_channels == 2) then
                                sample_buffer:set_sample_data(2, frame_idx + add_samples, sample_data_2[frame_idx])
                            end
                        end
                        sample_buffer:finalize_sample_data_changes()

                        -- enable auto seek
                        sample.autoseek = true
                    else
                        app:show_warning("End selection too long, Sample will not be truncated!")
                    end
                end
            end
        end
    }
end