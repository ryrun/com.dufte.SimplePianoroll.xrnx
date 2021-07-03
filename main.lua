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

--default values, can be used to reset to default
local defaultPreferences = {
    gridStepSizeW = 20,
    gridStepSizeH = 18,
    gridSpacing = 4,
    gridMargin = 1,
    gridWidth = 64,
    gridHeight = 42,
    triggerTime = 250,
    keyInfoTime = 5000,
    enableKeyInfo = false,
    dblClickTime = 400,
    forcePenMode = false,
    notePreview = true,
    enableOSCClient = true,
    oscConnectionString = "udp://127.0.0.1:8000",
    applyVelocityColorShading = true,
    velocityColorShadingAmount = 0.4,
    followPlayCursor = true,
    showNoteHints = true,
    scaleHighlightingType = 2,
    keyForSelectedScale = 1,
    addNoteOffToEmptyNoteColumns = true,
    addNoteColumnsIfNeeded = true,
    keyboardStyle = 1,
    noNotePreviewDuringSongPlayback = false,
}

--tool preferences
local preferences = renoise.Document.create("ScriptingToolPreferences") {
    --default grid button size
    gridStepSizeW = defaultPreferences.gridStepSizeW,
    gridStepSizeH = defaultPreferences.gridStepSizeH,
    --positive values will be converted to negative ones to reduce margin and spacing, looks better but its slower
    gridSpacing = defaultPreferences.gridSpacing,
    gridMargin = defaultPreferences.gridMargin,
    --size of pianorollgrid
    gridWidth = defaultPreferences.gridWidth,
    gridHeight = defaultPreferences.gridHeight,
    --note preview
    triggerTime = defaultPreferences.triggerTime,
    enableOSCClient = defaultPreferences.enableOSCClient,
    noNotePreviewDuringSongPlayback = defaultPreferences.noNotePreviewDuringSongPlayback,
    --doubleclick time
    dblClickTime = defaultPreferences.dblClickTime,
    --button states
    forcePenMode = defaultPreferences.forcePenMode,
    notePreview = defaultPreferences.notePreview,
    --oscsettingstring
    oscConnectionString = defaultPreferences.oscConnectionString,
    --velocity rendering
    applyVelocityColorShading = defaultPreferences.applyVelocityColorShading,
    velocityColorShadingAmount = defaultPreferences.velocityColorShadingAmount,
    --misc settings
    followPlayCursor = defaultPreferences.followPlayCursor,
    showNoteHints = defaultPreferences.showNoteHints,
    addNoteOffToEmptyNoteColumns = defaultPreferences.addNoteOffToEmptyNoteColumns,
    addNoteColumnsIfNeeded = defaultPreferences.addNoteColumnsIfNeeded,
    keyboardStyle = defaultPreferences.keyboardStyle,
    keyInfoTime = defaultPreferences.keyInfoTime,
    enableKeyInfo = defaultPreferences.enableKeyInfo,
    --scale highlighting settings
    scaleHighlightingType = defaultPreferences.scaleHighlightingType,
    keyForSelectedScale = defaultPreferences.keyForSelectedScale,
}
tool.preferences = preferences

--dialog vars
local windowObj
local windowContent
local stepSlider
local noteSlider

--last step position for resetting the last step button
local lastStepOn
local lastPlaySelectionLine

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
local colorWhiteKey = { { 44, 59, 68 }, { 52, 68, 78 } }
local colorBlackKey = { { 30, 42, 52 }, { 35, 47, 57 } }
local colorGhostNote = { 80, 97, 107 }
local colorList = { 70, 79, 84 }
local colorNote = { 170, 217, 179 }
local colorNoteGhost = { 194, 177, 226 }
local colorNoteHighlight = { 232, 204, 110 }
local colorNoteMuted = { 171, 187, 198 }
local colorNoteSelected = { 244, 150, 149 }
local colorStepOff = { 30, 6, 0 }
local colorStepOn = { 180, 80, 40 }
local colorKeyWhite = { 255, 255, 255 }
local colorKeyBlack = { 20, 20, 20 }
local colorVelocity = { 212, 188, 36 }
local colorPan = { 138, 187, 122 }
local colorDelay = { 71, 194, 236 }
local colorDisableButton = { 66, 66, 66 }

--note trigger vars
local oscClient
local lastTriggerNote
local triggerTimer

--missing block loop observable? use a variable for check there was a change
local blockloopidx

--main flag for refreshing pianoroll
local refreshPianoRollNeeded = false
local refreshControls = false
local refreshTimeline = false

--table to save note indices per step for highlighting
local noteOnStep = {}

--table for save used notes for faster overlapping detection
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
local currentNoteVelocityPreview = 127
local currentNoteEndVelocity = 255
local currentNoteGhost
local currentInstrument
local currentGhostTrack
local currentScale = 2
local currentScaleOffset = 1

local noteSelection = {}
local lastSelectionClick
local lowesetNote
local highestNote

local noteData = {}
local usedNoteIndices = {}

local lastKeyInfoTime
local lastKeyAction

--key states
local keyControl = false
local keyRControl = false
local keyShift = false
local keyRShift = false
local keyAlt = false

--pen mode
local penMode = false
local audioPreviewMode = false

--step preview
local stepPreview = false

--table to save last playingh note for qwerty playing
local lastKeyboardNote = {}

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

--simple function for coloring velocity
local function colorNoteVelocity(vel)
    local color = {}
    if vel < 0x7f and preferences.applyVelocityColorShading.value then
        local shade = (preferences.velocityColorShadingAmount.value / 0x7f * (0x7f - vel))
        color[1] = colorNote[1] * (1 - shade)
        color[2] = colorNote[2] * (1 - shade)
        color[3] = colorNote[3] * (1 - shade)
    else
        color = colorNote
    end
    return color
end

--jump to the note position in pattern
local function jumpToNoteInPattern(notedata)
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
end

--check if a note index is in MajorScale
local function noteIndexInMajorScale(noteIndex)
    if noteIndex == 1 or noteIndex == 3 or noteIndex == 6 or noteIndex == 8 or noteIndex == 10 then
        return false
    end
    return true
end

--returns note index of scale
local function noteIndexInScale(note, forceMajorC)
    if not forceMajorC then
        note = note - (currentScaleOffset - 1)
        if currentScale == 1 then
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

--returns true, when note in scale
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

--returns index, when note is in seleciton
local function noteInSelection(notedata)
    local ret
    for i = 1, #noteSelection do
        local note_data = noteSelection[i]
        if note_data.note == notedata.note and note_data.line == notedata.line and note_data.len == notedata.len and note_data.column == notedata.column then
            ret = i
            break
        end
    end
    return ret
end

--return true, when a noteOff was set
local function addNoteToPattern(column, line, len, note, vel, end_vel, pan, dly, ghst)
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
        if lineValues[line + len]:note_column(column).note_value < 120 then

        else
            noteoff = true
            lineValues[line + len]:note_column(column).note_value = 120
        end
    elseif line + len - 1 == song.selected_pattern.number_of_lines then
        --set note off to the beginning of a pattern for looping purpose
        if lineValues[1]:note_column(column).note_value < 120 then

        else
            noteoff = true
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
local function returnColumnWhenEnoughSpaceForNote(line, len)
    local lineValues = song.selected_pattern_track.lines
    local column
    --note outside the grid?
    if line < 1 or line + len - 1 > song.selected_pattern.number_of_lines then
        return column
    end
    --check if enough space for a new note
    local maxColumns = song.selected_track.visible_note_columns
    if preferences.addNoteColumnsIfNeeded.value then
        maxColumns = song.selected_track.max_note_columns
    end
    for c = 1, maxColumns do
        local validSpace = true
        --check for note on before
        if line > 1 then
            for i = line, 1, -1 do
                if lineValues[i]:note_column(c).note_value < 120 then
                    validSpace = false
                    break
                elseif lineValues[i]:note_column(c).note_value == 120 then
                    break
                end
            end
        end
        --check for note on in
        for i = line, line + len - 1 do
            if lineValues[i]:note_column(c).note_value < 120 then
                validSpace = false
            end
        end
        --found valid space, break the loop
        if validSpace then
            column = c
            break
        end
    end
    return column
end

--adds note offs to all note columns where no note is at line 1, for looping porpuse
local function addMissingNoteOffForColumns()
    if preferences.addNoteOffToEmptyNoteColumns.value then
        local track = song.selected_track
        local columns = track.visible_note_columns
        local lineValues = song.selected_pattern_track.lines

        for c = 1, columns do
            local note_column = lineValues[1]:note_column(c)
            if note_column.note_value == 121 then
                note_column.note_value = 120
            end
        end
    end
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
    for key in pairs(noteSelection) do
        removeNoteInPattern(noteSelection[key].column, noteSelection[key].line, noteSelection[key].len)
    end
    noteSelection = {}
    addMissingNoteOffForColumns()
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
    vbw.note_len.value = currentNoteLength

    if currentNoteGhost == true then
        vbw.note_ghost.color = colorNoteGhost
    else
        vbw.note_ghost.color = colorDisableButton
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
        vbw.notecolumn_vel.color = colorDisableButton
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
        vbw.notecolumn_pan.color = colorDisableButton
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
        if #noteSelection > 0 then
            vbw.note_dly_humanize.active = true
        else
            vbw.note_dly_humanize.active = false
        end
    else
        vbw.notecolumn_delay.color = colorDisableButton
        vbw.note_dly.value = 0
        vbw.note_dly.active = false
        vbw.note_dly_clear.active = false
        vbw.note_dly_humanize.active = false
    end

    local ghostTracks = {}
    for i = 1, song.sequencer_track_count do
        if i == song.selected_track_index then
            ghostTracks[i] = "---"
        else
            ghostTracks[i] = song:track(i).name
        end
    end
    vbw.ghosttracks.items = ghostTracks
    if not currentGhostTrack or currentGhostTrack > song.sequencer_track_count then
        currentGhostTrack = song.selected_track_index
        vbw.ghosttracks.value = currentGhostTrack
    end

    if preferences.notePreview.value then
        vbw.notepreview.color = colorNoteHighlight
    else
        vbw.notepreview.color = colorDisableButton
    end
    if penMode or (keyAlt and not keyControl and not keyShift and not audioPreviewMode) then
        vbw.mode_pen.color = colorNoteHighlight
        vbw.mode_select.color = colorDisableButton
        vbw.mode_audiopreview.color = colorDisableButton
    elseif audioPreviewMode or (keyControl and keyShift and not keyAlt) then
        vbw.mode_pen.color = colorDisableButton
        vbw.mode_select.color = colorDisableButton
        vbw.mode_audiopreview.color = colorNoteHighlight
    else
        vbw.mode_pen.color = colorDisableButton
        vbw.mode_select.color = colorNoteHighlight
        vbw.mode_audiopreview.color = colorDisableButton
    end
end

--simple note trigger
local function triggerNoteOfCurrentInstrument(note_value, pressed, velocity, newOrChanged)
    --if osc client is enabled
    if not preferences.enableOSCClient.value then
        return
    end
    --special handling of preview notes, won new notes or changed notes (transpose)
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
    --init server connection, when not ready
    local socket_error
    if oscClient == nil then
        local protocol, host, port = string.match(preferences.oscConnectionString.value, '([a-zA-Z]+)://([0-9a-zA-Z.]+):([0-9]+)')
        if protocol and host and port then
            socket_error = nil
            if string.lower(protocol) == "udp" then
                oscClient, socket_error = renoise.Socket.create_client(host, tonumber(port), renoise.Socket.PROTOCOL_UDP)
            elseif string.lower(protocol) == "tcp" then
                oscClient, socket_error = renoise.Socket.create_client(host, tonumber(port), renoise.Socket.PROTOCOL_TCP)
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
        oscClient:send(renoise.Osc.Message("/renoise/trigger/note_on", { { tag = "i", value = instrument },
                                                                         { tag = "i", value = song.selected_track_index },
                                                                         { tag = "i", value = note_value },
                                                                         { tag = "i", value = velocity } }))
    elseif pressed == false then
        oscClient:send(renoise.Osc.Message("/renoise/trigger/note_off", { { tag = "i", value = instrument },
                                                                          { tag = "i", value = song.selected_track_index },
                                                                          { tag = "i", value = note_value } }))
    else
        --when last note is still playing, cut off
        if lastTriggerNote ~= nil then
            tool:remove_timer(triggerTimer)
            table.remove(lastTriggerNote) --remove velocity
            oscClient:send(renoise.Osc.Message("/renoise/trigger/note_off", lastTriggerNote))
            lastTriggerNote = nil
        end
        --build note event
        lastTriggerNote = { { tag = "i", value = instrument },
                            { tag = "i", value = song.selected_track_index },
                            { tag = "i", value = note_value },
                            { tag = "i", value = velocity } }
        --send note event to osc server
        oscClient:send(renoise.Osc.Message("/renoise/trigger/note_on", lastTriggerNote))
        --create a timer for note off
        triggerTimer = function()
            table.remove(lastTriggerNote) --remove velocity
            oscClient:send(renoise.Osc.Message("/renoise/trigger/note_off", lastTriggerNote))
            lastTriggerNote = nil
            tool:remove_timer(triggerTimer)
        end
        --start timer
        tool:add_timer(triggerTimer, preferences.triggerTime.value)
    end
end

--starts playing from specific line in pattern
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
    --resort note selection table, so when one note in selection cant be moved, the whole move will be ignored
    if steps < 0 then
        --left one notes first
        table.sort(noteSelection, function(a, b)
            return a.line < b.line
        end)
    else
        --right one notes first
        table.sort(noteSelection, function(a, b)
            return a.line > b.line
        end)
    end
    --disable edit mode to prevent side effects
    song.transport.edit_mode = false
    --
    setUndoDescription("Move notes ...")
    --go through selection
    for key in pairs(noteSelection) do
        --remove note
        removeNoteInPattern(noteSelection[key].column, noteSelection[key].line, noteSelection[key].len)
        --search for valid column
        column = returnColumnWhenEnoughSpaceForNote(noteSelection[key].line + steps, noteSelection[key].len)
        if column then
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
                noteSelection[key].ghst
        )
        if not column then
            break
        end
    end
    refreshPianoRollNeeded = true
end

--transpose each selected notes
local function transposeSelectedNotes(transpose, keepscale)
    local lineValues = song.selected_pattern_track.lines
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
    --disable edit mode to prevent side effects
    song.transport.edit_mode = false
    --
    setUndoDescription("Transpose notes ...")
    --go through selection
    for key in pairs(noteSelection) do
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
            break
        elseif transposeVal >= 120 then
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
        triggerNoteOfCurrentInstrument(noteSelection[key].note, nil, nil, true)
    end
    refreshPianoRollNeeded = true
end

--paste notes from clipboard
local function pasteNotesFromClipboard()
    local column
    local noteoffset = 0
    local lineoffset = 0
    --disable edit mode to prevent side effects
    song.transport.edit_mode = false
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
        noteoffset = pasteCursor[2] - clipboard[1].note
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
        column = returnColumnWhenEnoughSpaceForNote(clipboard[key].line + lineoffset, clipboard[key].len)
        if column then
            clipboard[key].column = column
            clipboard[key].line = clipboard[key].line + lineoffset
            clipboard[key].note = clipboard[key].note + noteoffset
        else
            showStatus("Not enough space to paste notes here.")
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
    addMissingNoteOffForColumns()
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
    for key in pairs(noteSelection) do
        removeNoteInPattern(noteSelection[key].column, noteSelection[key].line, noteSelection[key].len)
        --change len and position
        local len = math.max(math.floor(noteSelection[key].len * times), 1)
        local line = math.floor((noteSelection[key].line - first_line) * times) + first_line
        local column = returnColumnWhenEnoughSpaceForNote(line, len)
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
                noteSelection[key].ghst
        )
        if not column then
            showStatus("Not enough space to scale selection.")
            return false
        end
    end
    addMissingNoteOffForColumns()
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
    for key in pairs(noteSelection) do
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
                local column = returnColumnWhenEnoughSpaceForNote(v.line, v.len)
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
                        note_data.ghst
                )
                table.insert(newSelection, note_data)
            end
        else
            table.insert(newSelection, noteSelection[key])
        end
    end
    noteSelection = newSelection
    addMissingNoteOffForColumns()
    refreshPianoRollNeeded = true
    return true
end

--duplicate content
local function duplicateSelectedNotes()
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
    --disable edit mode to prevent side effects
    song.transport.edit_mode = false
    --
    setUndoDescription("Duplicate notes to right ...")
    --go through selection
    for key in pairs(noteSelection) do
        --search for valid column
        column = returnColumnWhenEnoughSpaceForNote(noteSelection[key].line + offset, noteSelection[key].len)
        if column then
            noteSelection[key].column = column
            noteSelection[key].line = noteSelection[key].line + offset
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
                noteSelection[key].ghst
        )
    end
    addMissingNoteOffForColumns()
    refreshPianoRollNeeded = true
    return true
end

--change note size
local function changeSizeSelectedNotes(len, add)
    local column
    local newLen = len
    --first notes first
    table.sort(noteSelection, function(a, b)
        return a.line < b.line
    end)
    --disable edit mode to prevent side effects
    song.transport.edit_mode = false
    --
    setUndoDescription("Change note lengths ...")
    --go through selection
    for key in pairs(noteSelection) do
        --remove note
        removeNoteInPattern(noteSelection[key].column, noteSelection[key].line, noteSelection[key].len)
        --add mode
        if add then
            newLen = math.max(noteSelection[key].len + len, 1)
        end
        --search for valid column
        column = returnColumnWhenEnoughSpaceForNote(noteSelection[key].line, newLen)
        if column then
            if noteSelection[key].len == 1 and newLen > 1 then
                if toRenoiseHex(noteSelection[key].vel):sub(1, 1) == "C" then
                    noteSelection[key].end_vel = noteSelection[key].vel
                    noteSelection[key].vel = 255
                end
            end
            noteSelection[key].len = newLen
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
                noteSelection[key].ghst
        )
        if not column then
            break
        end
    end
    addMissingNoteOffForColumns()
    refreshPianoRollNeeded = true
    return true
end

--change note properties
local function changePropertiesOfSelectedNotes(vel, end_vel, dly, pan, special)
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
    --disable edit mode to prevent side effects
    song.transport.edit_mode = false
    --go through selection
    for key in pairs(noteSelection) do
        local selection = noteSelection[key]
        local note = lineValues[selection.line]:note_column(selection.column)
        local note_end = lineValues[selection.line + selection.len - 1]:note_column(selection.column)
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
                note.volume_string = toRenoiseHex(vel)
                selection.vel = vel
            end
        end
        if end_vel ~= nil then
            selection.end_vel = end_vel
            if selection.len > 1 then
                note_end.volume_string = toRenoiseHex(selection.end_vel)
            else
                note.volume_string = toRenoiseHex(selection.end_vel)
            end
        end
        if pan ~= nil then
            if tostring(vel) == "h" then
                if note.panning_volume <= 127 then
                    note.panning_volume = randomizeValue(note.panning_volume, 2, 1, 127)
                    selection.pan = note.panning_volume
                end
            else
                note.panning_string = toRenoiseHex(pan)
                selection.pan = pan
            end
        end
        if dly ~= nil then
            if tostring(dly) == "h" then
                if note.delay_value <= 127 then
                    note.delay_value = randomizeValue(note.delay_value, 2, 0, 127)
                    selection.dly = note.delay_value
                end
            else
                note.delay_string = toRenoiseHex(dly)
                selection.dly = dly
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
    addMissingNoteOffForColumns()
    refreshPianoRollNeeded = true
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
local function setKeyboardKeyColor(row, note, pressed, highlighted)
    if highlighted then
        vbw["k" .. row].color = colorNoteHighlight
    elseif not pressed then
        if preferences.keyboardStyle.value == 2 then
            vbw["k" .. row].color = colorList
        elseif noteInScale(note, true) then
            vbw["k" .. row].color = colorKeyWhite
        else
            vbw["k" .. row].color = colorKeyBlack
        end
    else
        vbw["k" .. row].color = colorStepOn
    end
end

--keyboard preview
function keyClick(y, pressed)
    local note = gridOffset2NoteValue(y)
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
        addMissingNoteOffForColumns()
        refreshPianoRollNeeded = true
    else
        triggerNoteOfCurrentInstrument(note, pressed)
    end
end

--will be called, when a note was clicked
function noteClick(x, y, c)
    local index = tostring(x) .. "_" .. tostring(y) .. "_" .. tostring(c)
    local dbclk = dbclkDetector("b" .. index)
    local note_data = noteData[index]
    --always set note date for the next new note
    if note_data ~= nil then
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
        refreshControls = true
        --always jump to the note
        jumpToNoteInPattern(note_data)
    end
    --remove on dblclk or when in penmode
    if (dbclk or keyAlt or penMode) and not audioPreviewMode then
        --set clicked note as selected for remove function
        if note_data ~= nil then
            noteSelection = {}
            table.insert(noteSelection, note_data)
            removeSelectedNotes()
        end
    else
        if note_data ~= nil then
            if not audioPreviewMode then
                local deselect = false
                --clear selection, when ctrl is not holded
                if not keyControl then
                    noteSelection = {}
                elseif #noteSelection > 0 then
                    --check if the note is in selection, then just deselect
                    for i = 1, #noteSelection do
                        if noteSelection[i].line == note_data.line and noteSelection[i].len == note_data.len and noteSelection[i].column == note_data.column then
                            deselect = true
                            table.remove(noteSelection, i)
                            break
                        end
                    end
                end
                --when note was not deselected, then add this note to selection
                if not deselect then
                    table.insert(noteSelection, note_data)
                end
                refreshPianoRollNeeded = true
            end
            triggerNoteOfCurrentInstrument(note_data.note, nil, nil, true)
        end
    end
end

--will be called, when an empty grid button was clicked
function pianoGridClick(x, y, released)
    if ((keyControl and keyShift and not keyAlt) or audioPreviewMode) or (stepPreview and released) then
        local line = x + stepOffset
        stepPreview = not released
        for key in pairs(noteData) do
            local note_data = noteData[key]
            if line >= note_data.line and line < note_data.line + note_data.len then
                triggerNoteOfCurrentInstrument(note_data.note, not released, note_data.vel)
                local row = noteValue2GridRowOffset(note_data.note)
                if row ~= nil then
                    setKeyboardKeyColor(row, note_data.note, not released, false)
                end
            end
        end
        return
    end
    if released then
        local dbclk = dbclkDetector("p" .. tostring(x) .. "_" .. tostring(y))
        --set paste cursor
        pasteCursor = { x + stepOffset, gridOffset2NoteValue(y) }

        if dbclk or (keyAlt and not keyControl and not keyShift) or penMode then
            local steps = song.selected_pattern.number_of_lines
            local column
            local note_value
            local noteoff = false
            --move x by stepoffset
            x = x + stepOffset
            --check if current note length is too long for pattern size, reduce len if needed
            if x + currentNoteLength > steps then
                currentNoteLength = steps - x + 1
                refreshControls = true
            end
            --disable edit mode because of side effects
            song.transport.edit_mode = false
            column = returnColumnWhenEnoughSpaceForNote(x, currentNoteLength)
            --no column found
            if column == nil then
                --no space for this note
                return false
            end
            --
            setUndoDescription("Draw a note ...")
            --add new note
            note_value = gridOffset2NoteValue(y)
            noteoff = addNoteToPattern(column, x, currentNoteLength, note_value, currentNoteVelocity, currentNoteEndVelocity, currentNotePan, currentNoteDelay, currentNoteGhost)
            --
            local note_data = {
                line = x,
                note = note_value,
                vel = currentNoteVelocity,
                end_vel = currentNoteEndVelocity,
                dly = currentNoteDelay,
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
            addMissingNoteOffForColumns()
            refreshPianoRollNeeded = true
        else
            --when a last click was saved and shift is pressing, than try to select notes
            if (keyShift or keyRShift) and lastSelectionClick then
                local lineValues = song.selected_pattern_track.lines
                local columns = song.selected_track.visible_note_columns
                local smin = math.min(x, lastSelectionClick[1])
                local smax = math.max(x, lastSelectionClick[1])
                local nmin = gridOffset2NoteValue(math.min(y, lastSelectionClick[2]))
                local nmax = gridOffset2NoteValue(math.max(y, lastSelectionClick[2]))
                --remove current note selection
                noteSelection = {}
                --loop through columns
                for c = 1, columns do
                    --loop through lines as steps
                    for s = smin, smax do
                        local note_column = lineValues[s + stepOffset]:note_column(c)
                        local note = note_column.note_value
                        --note inside the selection rect?
                        if note >= nmin and note <= nmax then
                            local note_data = noteData[tostring(s) .. "_" .. tostring(noteValue2GridRowOffset(note)) .. "_" .. tostring(c)]
                            --note found?
                            if note_data ~= nil then
                                --add to selection table
                                table.insert(noteSelection, note_data)
                            end
                        end
                    end
                end
                --piano refresh
                lastSelectionClick = { x, y }
                addMissingNoteOffForColumns()
                refreshPianoRollNeeded = true
            else
                --fast play from cursor
                if keyControl and not keyAlt and not keyShift then
                    lastPlaySelectionLine = x + stepOffset
                    playPatternFromLine(lastPlaySelectionLine)
                end
                lastSelectionClick = { x, y }
                --deselect selected notes
                if #noteSelection > 0 then
                    noteSelection = {}
                    refreshPianoRollNeeded = true
                    lastSelectionClick = { x, y }
                end
            end
        end
    end
end

--enable a note button, when its visible, set correct length of the button
local function enableNoteButton(column, current_note_line, current_note_step, current_note_rowIndex, current_note, current_note_len, current_note_string, current_note_vel, current_note_end_vel, current_note_pan, current_note_dly, noteoff, ghost)
    --save highest and lowest note
    if lowesetNote == nil then
        lowesetNote = current_note
    end
    if highestNote == nil then
        highestNote = current_note
    end
    lowesetNote = math.min(lowesetNote, current_note)
    highestNote = math.max(highestNote, current_note)
    if current_note_rowIndex ~= nil then
        local noteOnStepIndex = current_note_step
        local current_note_index = tostring(current_note_step) .. "_" .. tostring(current_note_rowIndex) .. "_" .. tostring(column)
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
        noteData[current_note_index] = {
            line = current_note_line,
            note = current_note,
            vel = current_note_vel,
            end_vel = current_note_end_vel,
            dly = current_note_dly,
            pan = current_note_pan,
            len = current_note_len,
            noteoff = noteoff,
            column = column,
            ghst = ghost
        }

        --only process notes on steps and visibility, when there is a valid row
        if vbw["row" .. current_note_rowIndex] then
            --fill noteOnStep not just note start, also the full length
            if noteOnStepIndex then
                for i = 0, current_note_len - 1 do
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
                    end
                end
            end

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
                local color = {}
                local temp = "noteClick(" .. tostring(current_note_step) .. "," .. tostring(current_note_rowIndex) .. "," .. tostring(column) .. ")"
                local spaceWidth = 0
                local delayWidth = 0
                local cutValue = 0

                if song.selected_track.volume_column_visible and current_note_end_vel >= 192 and current_note_end_vel <= 207 then
                    cutValue = current_note_end_vel
                end

                if song.selected_track.panning_column_visible and current_note_pan >= 192 and current_note_pan <= 207 then
                    current_note_len = 1
                    cutValue = current_note_pan
                end

                if song.selected_track.volume_column_visible and current_note_vel >= 192 and current_note_vel <= 207 then
                    current_note_len = 1
                    cutValue = current_note_vel
                    --wenn note is cut and outside, dont render it
                    if stepOffset >= current_note_line then
                        return
                    end
                end

                local buttonWidth = (gridStepSizeW) * current_note_len
                local buttonSpace = gridSpacing * (current_note_len - 1)

                if cutValue > 0 then
                    cutValue = cutValue - 192
                    if cutValue < song.transport.tpl then
                        buttonWidth = buttonWidth - ((gridStepSizeW - gridSpacing) / 100 * (100 / song.transport.tpl * (song.transport.tpl - cutValue)))
                    end
                end

                if current_note_vel == 0 then
                    color = colorNoteMuted
                elseif ghost == true then
                    color = colorNoteGhost
                else
                    color = colorNoteVelocity(current_note_vel)
                end
                for key in pairs(noteSelection) do
                    if noteSelection[key].line == current_note_line and noteSelection[key].column == column then
                        color = colorNoteSelected
                        --show note hints, when option is enabled
                        if preferences.showNoteHints.value then
                            --set select color to key sub state button
                            vbw["ks" .. current_note_rowIndex].color = color
                            vbw["ks" .. current_note_rowIndex].visible = true
                            vbw["kss" .. current_note_rowIndex].visible = false
                            for i = 1, 3, 1 do
                                local idx
                                for t = 1, 4, 1 do
                                    if t == 1 then
                                        --octaves
                                        idx = (current_note_rowIndex + (i * 12))
                                    elseif t == 2 then
                                        --octaves
                                        idx = (current_note_rowIndex - (i * 12))
                                    elseif t == 3 then
                                        --fifths
                                        idx = (current_note_rowIndex + (i * 12) - 5)
                                    elseif t == 4 then
                                        --fifths
                                        idx = (current_note_rowIndex - (i * 12) + 7)
                                    end
                                    if vbw["ks" .. idx] ~= nil and not vbw["ks" .. idx].visible then
                                        vbw["ks" .. idx].color = colorKeyWhite
                                        vbw["ks" .. idx].visible = true
                                        vbw["kss" .. idx].visible = false
                                    end
                                end
                            end
                        end
                        break
                    end
                end

                local btn = vb:row {
                    margin = -gridMargin,
                    spacing = -gridSpacing,
                }

                if current_note_step > 1 then
                    spaceWidth = (gridStepSizeW * (current_note_step - 1)) - (gridSpacing * (current_note_step - 2))
                end

                if song.selected_track.delay_column_visible and current_note_dly > 0 and stepOffset < current_note_line then
                    delayWidth = math.max(math.floor((gridStepSizeW - gridSpacing) / 0xff * current_note_dly), 1)
                    spaceWidth = spaceWidth + delayWidth
                    buttonWidth = buttonWidth - delayWidth
                    if current_note_step < 2 then
                        spaceWidth = spaceWidth + gridSpacing
                    end
                end

                if spaceWidth > 0 then
                    btn:add_child(vb:space {
                        width = spaceWidth,
                    });
                end

                --no note labels when to short
                if buttonWidth - buttonSpace - 1 < 30 then
                    current_note_string = ""
                end

                vbw["b" .. current_note_index] = nil
                btn:add_child(vb:button {
                    id = "b" .. current_note_index,
                    height = gridStepSizeH,
                    width = math.max(buttonWidth - buttonSpace - 1, 1),
                    visible = true,
                    color = color,
                    notifier = loadstring(temp),
                    text = current_note_string,
                });

                if not noteButtons[current_note_rowIndex] then
                    noteButtons[current_note_rowIndex] = {}
                end

                table.insert(noteButtons[current_note_rowIndex], btn);
                vbw["row" .. current_note_rowIndex]:add_child(btn)
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
            vbw.blockloop.width = gridStepSizeW * len - (gridSpacing * (len - 1)) - 4
            vbw.blockloopspc.width = math.max(gridStepSizeW * (pos - 1) - (gridSpacing * (pos - 1)), 1)
            vbw.blockloop.visible = true
        end
    end
    --hide blockmode loop indicator
    if hideblockloop and vbw.blockloop.visible then
        vbw.blockloop.visible = false
        vbw.blockloopspc.width = 1
    end
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
                    p.color = colorGhostNote
                end
            end
        end
    end
end

--set scale highlighting, none, manual modes, instrument scale, automatic mode
local function setScaleHighlighting(afterPianoRollRefresh)
    --simple scale highlighting
    if preferences.scaleHighlightingType.value == 1 and
            (currentScale ~= 1 or currentScaleOffset ~= 1) then
        currentScale = 1
        currentScaleOffset = 1
        return true
    elseif (preferences.scaleHighlightingType.value == 2 or preferences.scaleHighlightingType.value == 3) and
            (currentScale ~= preferences.scaleHighlightingType.value or currentScaleOffset ~= preferences.keyForSelectedScale.value)
    then
        currentScale = preferences.scaleHighlightingType.value
        currentScaleOffset = preferences.keyForSelectedScale.value
        return true
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
                return true
            end
        elseif scale_mode == "Natural Minor" then
            if currentScale ~= 3 or currentScaleOffset ~= scale_key then
                currentScale = 3
                currentScaleOffset = scale_key
                return true
            end
        elseif currentScale ~= 2 or currentScaleOffset ~= 1 then
            --switch to c major as default, when no scale is set
            currentScale = 2
            currentScaleOffset = 1
            return true
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
                    local ret = false
                    if currentScale ~= 2 then
                        currentScale = 2
                        ret = true
                    end
                    if currentScaleOffset ~= (foundScaleKey + 1) then
                        currentScaleOffset = (foundScaleKey + 1)
                        ret = true
                    end
                    return ret
                end
            else
                if (currentScale ~= 1 or currentScaleOffset ~= 1) then
                    currentScale = 1
                    currentScaleOffset = 1
                    return true
                end
            end
        end
    end
    return false
end

--reset pianoroll and enable notes
local function fillPianoRoll()
    local track = song.selected_track
    local steps = song.selected_pattern.number_of_lines
    local lineValues = song.selected_pattern_track.lines
    local columns = track.visible_note_columns
    local stepsCount = math.min(steps, gridWidth)
    local noffset = noteOffset - 1
    local blackKey
    local lastColumnWithNotes

    --remove old notes
    for y = 1, gridHeight do
        if noteButtons[y] then
            for key in pairs(noteButtons[y]) do
                vbw["row" .. y]:remove_child(noteButtons[y][key])
            end
        end
    end

    --reset vars
    noteButtons = {}
    noteOnStep = {}
    noteData = {}
    usedNoteIndices = {}
    currentInstrument = nil
    refreshPianoRollNeeded = false

    --show keyboard info bar
    vbw["key_state_panel"].visible = preferences.enableKeyInfo.value

    --set scale for piano roll
    setScaleHighlighting()

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
        local current_note_dly = 255
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
            if c == 1 and stepString then
                local bar = calculateBarBeat(s + stepOffset)

                for y = 1, gridHeight do
                    local ystring = tostring(y)
                    local index = stepString .. "_" .. ystring
                    local p = vbw["p" .. index]
                    local color = colorWhiteKey[bar % 2 + 1]
                    blackKey = not noteInScale((y + noffset) % 12)
                    --color black notes
                    if blackKey then
                        color = colorBlackKey[bar % 2 + 1]
                    end
                    if s <= stepsCount then
                        p.color = color
                        p.visible = true
                        --refresh step indicator
                        if y == 1 then
                            vbw["s" .. stepString].visible = true
                        end
                        --refresh keyboad
                        if s == 1 then
                            local key = vbw["k" .. ystring]
                            setKeyboardKeyColor(ystring, (y + noffset) % 12, false, false)
                            --set root label
                            if ((currentScale == 1 or preferences.scaleHighlightingType.value == 5) and noteIndexInScale((y + noffset) % 12, true) == 0) or
                                    (preferences.scaleHighlightingType.value ~= 5 and currentScale == 2 and noteIndexInScale((y + noffset) % 12) == 0) or
                                    (preferences.scaleHighlightingType.value ~= 5 and currentScale == 3 and noteIndexInScale((y + noffset) % 12) == 9)
                            then
                                if preferences.keyboardStyle.value == 2 then
                                    key.text = notesTable[(y + noffset) % 12 + 1] .. tostring(math.floor((y + noffset) / 12)) .. "         "
                                else
                                    key.text = "         " .. notesTable[(y + noffset) % 12 + 1] .. tostring(math.floor((y + noffset) / 12))
                                end
                            else
                                key.text = ""
                            end
                            --reset key sub state button color
                            vbw["ks" .. ystring].visible = false
                            vbw["kss" .. ystring].visible = true
                        end
                    else
                        p.visible = false
                        --refresh step indicator
                        if y == 1 then
                            vbw["s" .. stepString].visible = false
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
                    currentInstrument = note_column.instrument_value + 1
                end
                if current_note ~= nil then
                    enableNoteButton(c, current_note_line, current_note_step, current_note_rowIndex, current_note, current_note_len, current_note_string, current_note_vel, current_note_end_vel, current_note_pan, current_note_dly, false, current_note_ghost)
                end
                lastColumnWithNotes = c
                current_note = note
                current_note_string = note_string
                current_note_len = 0
                current_note_end_vel = nil
                current_note_step = s
                current_note_line = line
                current_note_vel = fromRenoiseHex(volume_string)
                current_note_pan = fromRenoiseHex(panning_string)
                current_note_dly = fromRenoiseHex(delay_string)
                current_note_rowIndex = noteValue2GridRowOffset(current_note, true)
                if instrument == 255 then
                    current_note_ghost = true
                else
                    current_note_ghost = false
                end
                --add current note to note index table for scale detection
                usedNoteIndices[line .. "_" .. c] = note % 12
            elseif note == 120 and current_note ~= nil then
                if not current_note_step and s then
                    current_note_step = current_note_line - stepOffset
                end
                enableNoteButton(c, current_note_line, current_note_step, current_note_rowIndex, current_note, current_note_len, current_note_string, current_note_vel, current_note_end_vel, current_note_pan, current_note_dly, true, current_note_ghost)
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
            enableNoteButton(c, current_note_line, current_note_step, current_note_rowIndex, current_note, current_note_len, current_note_string, current_note_vel, current_note_end_vel, current_note_pan, current_note_dly, false, current_note_ghost)
        end
    end

    --hide non used elements of the piano roll grid
    for i = steps + 1, gridWidth do
        vbw["s" .. i].visible = false
        for y = 1, gridHeight do
            vbw["p" .. i .. "_" .. y].visible = false
        end
    end

    --quirk? i need to visible and hide a note button to get fast vertical scroll
    if not vbw["dummy" .. tostring(4) .. "_" .. tostring(4)].visible then
        vbw["dummy" .. tostring(4) .. "_" .. tostring(4)].visible = true
        vbw["dummy" .. tostring(4) .. "_" .. tostring(4)].visible = false
    end

    --switch to instrument which is used in pattern
    if currentInstrument and currentInstrument ~= song.selected_instrument_index then
        song.selected_instrument_index = currentInstrument
    end

    --for automatic mode or empty patterns, set scale highlighting again, if needed
    if setScaleHighlighting(true) then
        refreshPianoRollNeeded = true
    end

    --enable buttons when something selected
    if #noteSelection > 0 then
        vbw.note_vel_humanize.active = vbw.note_vel_clear.active
        vbw.note_pan_humanize.active = vbw.note_pan_clear.active
        vbw.note_dly_humanize.active = vbw.note_dly_clear.active
    else
        vbw.note_vel_humanize.active = false
        vbw.note_pan_humanize.active = false
        vbw.note_dly_humanize.active = false
    end

    --render ghost notes, only when index is not the current track
    if currentGhostTrack and currentGhostTrack ~= song.selected_track_index then
        vbw.ghosttrackswitch.active = true
        ghostTrack(currentGhostTrack)
    else
        vbw.ghosttrackswitch.active = false
    end
end

--highlight each note on the current playback pos
local function highlightNotesOnStep(step, highlight)
    if noteOnStep[step] ~= nil and #noteOnStep[step] > 0 then
        for i = 1, #noteOnStep[step] do
            --when notes are on current step and not selected
            if noteOnStep[step][i] ~= nil then
                local note = noteOnStep[step][i]
                if highlight then
                    if vbw["b" .. note.index].color[1] ~= colorNoteSelected[1] then
                        vbw["b" .. note.index].color = colorNoteHighlight
                    end
                    setKeyboardKeyColor(note.row, note.note, false, true)
                else
                    if vbw["b" .. note.index].color[1] ~= colorNoteSelected[1] then
                        if note.ghst then
                            vbw["b" .. note.index].color = colorNoteGhost
                        else
                            vbw["b" .. note.index].color = colorNoteVelocity(note.vel)
                        end
                    end
                    setKeyboardKeyColor(note.row, note.note, false, false)
                end
            end
        end
    end
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
        addMissingNoteOffForColumns()
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
            --print("fillPianoRoll time: " .. os.clock() - start)
        end

        --refresh control, when needed
        if refreshControls then
            refreshNoteControls()
            refreshControls = false
        end

        --refresh timeline, when needed
        if refreshTimeline then
            fillTimeline()
            refreshTimeline = false
        end

        --key info state
        if lastKeyInfoTime and lastKeyInfoTime + preferences.keyInfoTime.value < os.clock() then
            vbw["key_state"].text = ""
        end

        --refresh playback pos indicator
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
        elseif lastStepOn and song.selected_pattern_index ~= seq then
            vbw["s" .. tostring(lastStepOn)].color = colorStepOff
            highlightNotesOnStep(lastStepOn, false)
            lastStepOn = nil
        end

        --block loop, create an index for comparison, because obserable's are missing here
        local currentblockloop = tostring(song.transport.loop_block_enabled)
                .. tostring(song.transport.loop_block_start_pos)
                .. tostring(song.transport.loop_block_range_coeff)
        if blockloopidx ~= currentblockloop then
            blockloopidx = currentblockloop
            refreshTimeline = true
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
end

--will be called when something in the pattern will be changed
local function lineNotifier()
    refreshPianoRollNeeded = true
end

--on each new song, reset pianoroll and setup locals
local function appNewDoc()
    --close window, when a new song was opened
    if windowObj and windowObj.visible then
        windowObj:close()
    end

    song = renoise.song()
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
        pasteCursor = {}
        stepSlider.value = 0
        refreshPianoRollNeeded = true
        refreshTimeline = true
    end)
    song.selected_pattern:add_line_notifier(lineNotifier)
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
    --add some observers for the current track
    song.selected_pattern.number_of_lines_observable:add_notifier(function()
        refreshTimeline = true
        obsPianoRefresh()
    end)
    song.selected_track.volume_column_visible_observable:add_notifier(obsColumnRefresh)
    song.selected_track.panning_column_visible_observable:add_notifier(obsColumnRefresh)
    song.selected_track.delay_column_visible_observable:add_notifier(obsColumnRefresh)
    --clear selection and refresh piano roll
    obsPianoRefresh()
    obsColumnRefresh()
    refreshTimeline = true
end

--function for all keyboard shortcuts
local function handleKeyEvent(key)
    local handled = false

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
        if not penMode then
            refreshControls = true
        end
    elseif key.name == "lalt" and key.state == "released" then
        keyAlt = false
        handled = true
        if not penMode then
            refreshControls = true
        end
    end
    if key.name == "lshift" and key.state == "pressed" then
        keyShift = true
        handled = true
        if not audioPreviewMode then
            refreshControls = true
        end
    elseif key.name == "lshift" and key.state == "released" then
        keyShift = false
        handled = true
        if not audioPreviewMode then
            refreshControls = true
        end
    end
    if key.name == "rshift" and key.state == "pressed" then
        keyRShift = true
        handled = true
    elseif key.name == "rshift" and key.state == "released" then
        keyRShift = false
        handled = true
    end
    if key.name == "del" then
        if key.state == "released" then
            if #noteSelection > 0 then
                showStatus(#noteSelection .. " notes deleted.")
                removeSelectedNotes()
            end
        end
        handled = true
    end
    if key.name == "esc" then
        if key.state == "released" then
            if #noteSelection > 0 then
                noteSelection = {}
                refreshPianoRollNeeded = true
            end
        end
        handled = true
    end
    if key.name == "i" and key.modifiers == "shift" then
        if key.state == "released" then
            if #noteSelection > 0 then
                showStatus("Inverted note selection.")
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
        if key.state == "released" then
            vbw.note_len.value = tonumber(key.name)
        end
        handled = true
    end

    if key.state == "pressed" then
        lastKeyInfoTime = nil
        lastKeyAction = nil
        local keystatetext = ""
        if key.modifiers ~= "" then
            keystatetext = key.modifiers
        end
        if key.name == "lalt" or key.name == "lshift" or key.name == "lcontrol" or key.name == "ralt" or key.name == "rshift" or key.name == "rcontrol" then
            --nothing
        else
            if keystatetext ~= "" then
                keystatetext = keystatetext .. " + "
            end
            keystatetext = keystatetext .. key.name
            lastKeyInfoTime = os.clock()
        end
        vbw["key_state"].text = string.upper(keystatetext)
    elseif key.state == "released" then
        if not lastKeyInfoTime then
            vbw["key_state"].text = ""
        end
    end

    if key.name == "0" then
        if key.state == "released" then
            if key.modifiers == "control" then
                if #noteSelection > 0 then
                    scaleNoteSelection(2)
                end
                currentNoteLength = math.min(math.floor(currentNoteLength * 2), 256)
            elseif key.modifiers == "shift + control" then
                if #noteSelection > 0 then
                    scaleNoteSelection(0.5)
                end
                currentNoteLength = math.max(math.floor(currentNoteLength / 2), 1)
            end
            refreshControls = true
        end
        handled = true
    end
    if key.name == "u" and key.modifiers == "control" then
        if key.state == "released" then
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
                end
            end
        end
        handled = true
    end
    if key.name == "m" and key.modifiers == "alt" then
        if key.state == "released" then
            local selectall = false
            if #noteSelection == 0 then
                for k in pairs(noteData) do
                    local note_data = noteData[k]
                    table.insert(noteSelection, note_data)
                end
                selectall = true
            end
            if #noteSelection > 0 then
                changePropertiesOfSelectedNotes("mute", nil, nil, nil)
                showStatus(#noteSelection .. " notes was muted.")
                --when all was automatically selected, deselect it
                if selectall then
                    noteSelection = {}
                end
            end
        end
        handled = true
    end
    if key.name == "n" and key.modifiers == "alt" then
        if key.state == "released" then
            if #noteSelection > 0 then
                changePropertiesOfSelectedNotes(nil, nil, nil, nil, "matchingnotes")
                showStatus(#noteSelection .. " notes was matched.")
            end
        end
        handled = true
    end
    if key.name == "m" and key.modifiers == "shift + alt" then
        if key.state == "released" then
            local selectall = false
            if #noteSelection == 0 then
                for k in pairs(noteData) do
                    local note_data = noteData[k]
                    table.insert(noteSelection, note_data)
                end
                selectall = true
            end
            if #noteSelection > 0 then
                changePropertiesOfSelectedNotes("unmute", nil, nil, nil)
                showStatus(#noteSelection .. " notes was unmuted.")
                --when all was automatically selected, deselect it
                if selectall then
                    noteSelection = {}
                end
            end
        end
        handled = true
    end
    if key.name == "b" and key.modifiers == "control" then
        if key.state == "released" then
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
                    showStatus(#noteSelection .. " notes duplicated.")
                end
            end
        end
        handled = true
    end
    if key.name == "c" and key.modifiers == "control" then
        if key.state == "released" then
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
                    return a.note < b.note
                end)
                pasteCursor = { pasteCursor[1], clipboard[1].note }
                showStatus(#noteSelection .. " notes copied.", true)
            end
        end
        handled = true
    end
    if key.name == "x" and key.modifiers == "control" then
        if key.state == "released" then
            if #noteSelection > 0 then
                clipboard = {}
                for k in pairs(noteSelection) do
                    local note_data = noteSelection[k]
                    table.insert(clipboard, note_data)
                end
                --set paste cursor
                table.sort(clipboard, function(a, b)
                    return a.line < b.line
                end)
                pasteCursor = { clipboard[1].line, 0 }
                table.sort(clipboard, function(a, b)
                    return a.note < b.note
                end)
                pasteCursor = { pasteCursor[1], clipboard[1].note }
                --set status
                showStatus(#noteSelection .. " notes cut.", true)
                --remove selected notes
                removeSelectedNotes(true)
            end
        end
        handled = true
    end
    if key.name == "v" and key.modifiers == "control" then
        if key.state == "released" then
            if #clipboard > 0 then
                showStatus(#clipboard .. " notes pasted.", true)
                pasteNotesFromClipboard()
            end
            handled = true
        end
    end
    if key.name == "a" and key.modifiers == "control" then
        if key.state == "released" then
            --clear current selection
            noteSelection = {}
            --step through all current notes and add them to noteSelection, TODO select all notes, not only the visible ones
            for k in pairs(noteData) do
                local note_data = noteData[k]
                table.insert(noteSelection, note_data)
            end
            showStatus(#noteSelection .. " notes selected.", true)
            refreshPianoRollNeeded = true
        end
        handled = true
    end
    if (key.name == "up" or key.name == "down") then
        if key.state == "released" then
            local transpose = 1
            if keyAlt then
                transpose = 7
            end
            if keyShift or keyRShift then
                transpose = 12
            end
            if key.name == "down" then
                transpose = transpose * -1
            end
            if #noteSelection > 0 then
                transposeSelectedNotes(transpose, keyControl or keyRControl)
            elseif noteSlider.value + transpose <= noteSlider.max and noteSlider.value + transpose >= noteSlider.min then
                noteSlider.value = noteSlider.value + transpose
            end
        end
        handled = true
    end
    if (key.name == "left" or key.name == "right") then
        if key.state == "released" then
            local steps = 1
            if keyShift or keyRShift then
                steps = 4
            end
            if key.name == "left" then
                steps = steps * -1
            end
            if #noteSelection > 0 then
                if keyControl then
                    steps = steps / math.abs(steps)
                    changeSizeSelectedNotes(steps, true)
                else
                    moveSelectedNotes(steps)
                end
            elseif stepSlider.value + steps <= stepSlider.max and stepSlider.value + steps >= stepSlider.min then
                stepSlider.value = stepSlider.value + steps
            end
        end
        handled = true
    end
    --play selection
    if key.name == "space" and key.modifiers == "control" then
        if key.state == "released" then
            if #noteSelection > 0 then
                table.sort(noteSelection, function(a, b)
                    return a.line < b.line
                end)
                lastPlaySelectionLine = noteSelection[1].line
            end
            if lastPlaySelectionLine then
                playPatternFromLine(lastPlaySelectionLine)
            else
                playPatternFromLine(1)
            end
        end
        handled = true
    end
    --loving tracker computer keyboard note playing <3 (returning it back to host is buggy, so do your own)
    if key.note then
        local row
        if key.state == "released" and lastKeyboardNote[key.name] ~= nil then
            row = noteValue2GridRowOffset(lastKeyboardNote[key.name])
            triggerNoteOfCurrentInstrument(lastKeyboardNote[key.name], false)
            if row ~= nil then
                setKeyboardKeyColor(row, lastKeyboardNote[key.name], false, false)
            end
        elseif not handled and key.modifiers == "" then
            local note = key.note + (12 * song.transport.octave)
            lastKeyboardNote[key.name] = note
            row = noteValue2GridRowOffset(lastKeyboardNote[key.name])
            triggerNoteOfCurrentInstrument(lastKeyboardNote[key.name], true)
            if row ~= nil then
                setKeyboardKeyColor(row, lastKeyboardNote[key.name], true, false)
            end
        end
        handled = true
    end
    return handled
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
        vb = renoise.ViewBuilder()
        vbw = vb.views

        --setup grid settings
        gridStepSizeW = defaultPreferences.gridStepSizeW
        gridStepSizeH = defaultPreferences.gridStepSizeH
        gridSpacing = preferences.gridSpacing.value
        gridMargin = preferences.gridMargin.value
        gridWidth = preferences.gridWidth.value
        gridHeight = preferences.gridHeight.value
        pianoKeyWidth = preferences.gridStepSizeW.value * 3

        lastStepOn = nil
        stepOffset = 0
        lastSelectionClick = nil
        noteOffset = 28 -- default offset
        currentGhostTrack = nil
        noteButtons = {}
        --reset lowest / highest note for center view
        lowesetNote = nil
        highestNote = nil
        --reset note selection
        noteSelection = {}
        --when needed set enable penmode
        penMode = preferences.forcePenMode.value

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
                vb:button {
                    id = "s" .. tostring(x),
                    height = 9,
                    width = gridStepSizeW - 4,
                    color = colorStepOff,
                    visible = false,
                    notifier = loadstring(temp),
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
                vb_temp = vb:button {
                    id = "p" .. tostring(x) .. "_" .. tostring(y),
                    height = gridStepSizeH,
                    width = gridStepSizeW,
                    color = colorWhiteKey[1],
                    visible = false,
                    notifier = loadstring(temp),
                    pressed = loadstring(temp2)
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
        }
        for i = 1, gridWidth do
            local temp = vb:text {
                id = "timeline" .. i,
                visible = false,
            }
            timeline:add_child(temp)
        end
        timeline:add_child(vb:space {
            width = 6,
        })

        windowContent = vb:column {
            vb:row {
                margin = 3,
                spacing = 6,
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
                        text = "Dbl",
                        tooltip = "Double current note length number",
                        notifier = function()
                            if #noteSelection > 0 then
                                scaleNoteSelection(2)
                            end
                            currentNoteLength = math.min(math.floor(currentNoteLength * 2), 256)
                            refreshControls = true
                        end,
                    },
                    vb:button {
                        text = "Hlv",
                        tooltip = "Halve current note length number",
                        notifier = function()
                            if #noteSelection > 0 then
                                scaleNoteSelection(0.5)
                            end
                            currentNoteLength = math.max(math.floor(currentNoteLength / 2), 1)
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
                        color = colorDisableButton,
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
                                changePropertiesOfSelectedNotes(currentNoteVelocity, nil, nil, nil)
                            end
                            refreshControls = true
                        end,
                    },
                    vb:button {
                        id = "note_vel_clear",
                        text = "C",
                        tooltip = "Clear note velocity",
                        notifier = function()
                            currentNoteVelocity = 255
                            if #noteSelection > 0 then
                                changePropertiesOfSelectedNotes(currentNoteVelocity, nil, nil, nil)
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
                                changePropertiesOfSelectedNotes("h", nil, nil, nil)
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
                                changePropertiesOfSelectedNotes(nil, currentNoteEndVelocity, nil, nil)
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
                                changePropertiesOfSelectedNotes(nil, currentNoteEndVelocity, nil, nil)
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
                        color = colorDisableButton,
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
                                changePropertiesOfSelectedNotes(nil, nil, nil, currentNotePan)
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
                            changePropertiesOfSelectedNotes(nil, nil, nil, currentNotePan)
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
                                changePropertiesOfSelectedNotes(nil, nil, nil, "h")
                            end
                        end,
                    },
                    vb:button {
                        id = "notecolumn_delay",
                        --text = "Dly",
                        bitmap = "Icons/Transport_ViewDelayColumn.bmp",
                        width = 24,
                        tooltip = "Enable / disable note delay column",
                        color = colorDisableButton,
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
                                changePropertiesOfSelectedNotes(nil, nil, currentNoteDelay, nil)
                            end
                            refreshControls = true
                        end,
                    },
                    vb:button {
                        id = "note_dly_clear",
                        text = "C",
                        tooltip = "Clear note delay",
                        notifier = function()
                            currentNoteDelay = 0
                            changePropertiesOfSelectedNotes(nil, nil, currentNoteDelay, nil)
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
                                changePropertiesOfSelectedNotes(nil, nil, "h", nil)
                            end
                        end,
                    },
                    vb:button {
                        id = "note_ghost",
                        text = "Ghost note",
                        tooltip = "Enable / disable to draw ghost notes",
                        color = colorDisableButton,
                        notifier = function()
                            if currentNoteGhost then
                                currentNoteGhost = false
                                if #noteSelection > 0 then
                                    changePropertiesOfSelectedNotes(nil, nil, nil, nil, "noghost")
                                end
                            else
                                currentNoteGhost = true
                                if #noteSelection > 0 then
                                    changePropertiesOfSelectedNotes(nil, nil, nil, nil, "ghost")
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
                    vb:button {
                        id = "ghosttrackswitch",
                        --text = "Switch",
                        bitmap = "Icons/Transport_PlaybackSync.bmp",
                        width = 24,
                        tooltip = "Switch to selected ghost track",
                        notifier = function()
                            if currentGhostTrack and currentGhostTrack ~= song.selected_track_index then
                                local temp = currentGhostTrack
                                vbw.ghosttracks.value = song.selected_track_index
                                song.selected_track_index = temp
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
                            local btn = app:show_custom_prompt("Preferences", vb:row {
                                uniform = true,
                                margin = 5,
                                spacing = 5,
                                vb:column {
                                    style = "group",
                                    margin = 5,
                                    uniform = true,
                                    spacing = 4,
                                    vb:text {
                                        text = "Piano roll grid",
                                        font = "big",
                                        style = "strong",
                                    },
                                    vb:row {
                                        vb:text {
                                            text = "Grid size:",
                                        },
                                        vb:valuebox {
                                            steps = { 1, 2 },
                                            min = 16,
                                            max = 256,
                                            bind = preferences.gridWidth,
                                        },
                                        vb:text { text = "x", align = "center", },
                                        vb:valuebox {
                                            steps = { 1, 2 },
                                            min = 16,
                                            max = 256,
                                            bind = preferences.gridHeight,
                                        },
                                    },
                                    --[[
                                    vb:text {
                                        text = "Grid step size:",
                                    },
                                    vb:row {
                                        uniform = true,
                                        vb:valuebox {
                                            steps = { 1, 2 },
                                            min = 10,
                                            max = 40,
                                            bind = preferences.gridStepSizeW,
                                        },
                                        vb:text { text = "x", align = "center", },
                                        vb:valuebox {
                                            steps = { 1, 2 },
                                            min = 10,
                                            max = 40,
                                            bind = preferences.gridStepSizeH,
                                        },
                                    },
                                    ]]--
                                    vb:text {
                                        text = "Grid size settings takes effect,\nwhen the piano roll will be reopened.",
                                    },
                                    vb:space { height = 8 },
                                    vb:row {
                                        vb:checkbox {
                                            bind = preferences.applyVelocityColorShading
                                        },
                                        vb:text {
                                            text = "Shade note color according to velocity",
                                        },
                                    },
                                    vb:row {
                                        vb:text {
                                            text = "Shade amount:",
                                        },
                                        vb:valuebox {
                                            steps = { 0.01, 0.1 },
                                            min = 0.1,
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
                                    vb:space { height = 8 },
                                    vb:row {
                                        uniform = true,
                                        vb:text {
                                            text = "Scale highlighting:",
                                        },
                                        vb:popup {
                                            width = 110,
                                            items = {
                                                "None",
                                                "Major scale",
                                                "Minor scale",
                                                "Instrument scale",
                                                "Automatic scale",
                                            },
                                            bind = preferences.scaleHighlightingType,
                                        },
                                    },
                                    vb:row {
                                        vb:text {
                                            text = "Key for selected scale:",
                                            width = "50%"
                                        },
                                        vb:popup {
                                            items = notesTable,
                                            bind = preferences.keyForSelectedScale,
                                        },
                                    },
                                    vb:row {
                                        vb:text {
                                            text = "Keyboard style:",
                                            width = "50%"
                                        },
                                        vb:popup {
                                            items = {
                                                "Flat",
                                                "List",
                                            },
                                            bind = preferences.keyboardStyle,
                                        },
                                    },
                                },
                                vb:column {
                                    style = "group",
                                    margin = 5,
                                    uniform = true,
                                    spacing = 4,
                                    vb:text {
                                        text = "Note playback and preview",
                                        font = "big",
                                        style = "strong",
                                    },
                                    vb:row {
                                        vb:checkbox {
                                            bind = preferences.enableOSCClient
                                        },
                                        vb:text {
                                            text = "Enable OSC client",
                                        },
                                    },
                                    vb:row {
                                        vb:checkbox {
                                            bind = preferences.notePreview
                                        },
                                        vb:text {
                                            text = "Enable note preview",
                                        },
                                    },
                                    vb:row {
                                        vb:checkbox {
                                            bind = preferences.noNotePreviewDuringSongPlayback,
                                        },
                                        vb:text {
                                            text = "No note preview during song playback",
                                        },
                                    },
                                    vb:row {
                                        vb:text {
                                            text = "Note preview length (ms):",
                                        },
                                        vb:valuebox {
                                            steps = { 1, 2 },
                                            min = 50,
                                            max = 2000,
                                            bind = preferences.triggerTime,
                                        },
                                    },
                                    vb:text {
                                        text = "OSC connection string: [protocol]://[ip]:[port]",
                                    },
                                    vb:textfield {
                                        bind = preferences.oscConnectionString,
                                    },
                                    vb:text {
                                        text = "Please check in the Renoise preferences in\nthe OSC section that the OSC server has\nbeen activated and is running with the same\nprotocol (UDP, TCP) and port settings\nas specified here."
                                    },
                                },
                                vb:column {
                                    style = "group",
                                    margin = 5,
                                    uniform = true,
                                    spacing = 4,
                                    vb:text {
                                        text = "Misc",
                                        font = "big",
                                        style = "strong",
                                    },
                                    vb:row {
                                        vb:text {
                                            text = "Max double click time (ms):",
                                        },
                                        vb:valuebox {
                                            steps = { 1, 2 },
                                            min = 50,
                                            max = 2000,
                                            bind = preferences.dblClickTime,
                                        },
                                    },
                                    vb:row {
                                        vb:checkbox {
                                            bind = preferences.forcePenMode,
                                        },
                                        vb:text {
                                            text = "Enable pen mode by default",
                                        },
                                    },
                                    vb:row {
                                        vb:checkbox {
                                            bind = preferences.followPlayCursor,
                                        },
                                        vb:text {
                                            text = "Follow play cursor, when enabled in Renoise",
                                        },
                                    },
                                    vb:row {
                                        vb:checkbox {
                                            bind = preferences.showNoteHints,
                                        },
                                        vb:text {
                                            text = "Show octaves and fifths of selected notes",
                                        },
                                    },
                                    vb:row {
                                        vb:checkbox {
                                            bind = preferences.addNoteColumnsIfNeeded,
                                        },
                                        vb:text {
                                            text = "Automatically add note columns, when needed",
                                        },
                                    },
                                    vb:row {
                                        vb:checkbox {
                                            bind = preferences.addNoteOffToEmptyNoteColumns,
                                        },
                                        vb:text {
                                            text = "Automatically add NoteOff's in empty note columns",
                                        },
                                    },
                                    vb:row {
                                        vb:checkbox {
                                            bind = preferences.enableKeyInfo,
                                        },
                                        vb:text {
                                            text = "Enable keyboard status bar",
                                        },
                                    },
                                    vb:row {
                                        vb:text {
                                            text = "Max keyboard status bar display time (s):",
                                        },
                                        vb:valuebox {
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
                                },
                            }, { "Close", "Reset to default", "Help / Feedback" })
                            if btn == "Reset to default" then
                                if app:show_prompt("Reset to default", "Are you sure you want to reset all settings to their default values?", { "Yes", "No" }) == "Yes" then
                                    preferences.gridStepSizeW.value = defaultPreferences.gridStepSizeW
                                    preferences.gridStepSizeH.value = defaultPreferences.gridStepSizeH
                                    preferences.gridSpacing.value = defaultPreferences.gridSpacing
                                    preferences.gridMargin.value = defaultPreferences.gridMargin
                                    preferences.gridWidth.value = defaultPreferences.gridWidth
                                    preferences.gridHeight.value = defaultPreferences.gridHeight
                                    preferences.triggerTime.value = defaultPreferences.triggerTime
                                    preferences.dblClickTime.value = defaultPreferences.dblClickTime
                                    preferences.forcePenMode.value = defaultPreferences.forcePenMode
                                    preferences.notePreview.value = defaultPreferences.notePreview
                                    preferences.enableOSCClient.value = defaultPreferences.enableOSCClient
                                    preferences.oscConnectionString.value = defaultPreferences.oscConnectionString
                                    preferences.applyVelocityColorShading.value = defaultPreferences.applyVelocityColorShading
                                    preferences.velocityColorShadingAmount.value = defaultPreferences.velocityColorShadingAmount
                                    preferences.followPlayCursor.value = defaultPreferences.followPlayCursor
                                    preferences.showNoteHints.value = defaultPreferences.showNoteHints
                                    preferences.scaleHighlightingType.value = defaultPreferences.scaleHighlightingType
                                    preferences.keyForSelectedScale.value = defaultPreferences.keyForSelectedScale
                                    preferences.addNoteOffToEmptyNoteColumns.value = defaultPreferences.addNoteOffToEmptyNoteColumns
                                    preferences.addNoteColumnsIfNeeded.value = defaultPreferences.addNoteColumnsIfNeeded
                                    preferences.keyboardStyle.value = defaultPreferences.keyboardStyle
                                    preferences.noNotePreviewDuringSongPlayback.value = defaultPreferences.noNotePreviewDuringSongPlayback
                                    preferences.keyInfoTime.value = defaultPreferences.keyInfoTime
                                    preferences.enableKeyInfo.value = defaultPreferences.enableKeyInfo
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
                        end,
                    },
                }
            },
            vb:row {
                vb:column {
                    vb:row {
                        height = (gridStepSizeH * 2) - gridSpacing + 2,
                        spacing = 1,
                        margin = 4,
                        vb:row {
                            spacing = -3,
                            vb:button {
                                text = "↖",
                                tooltip = "Select mode",
                                id = "mode_select",
                                notifier = function()
                                    penMode = false
                                    audioPreviewMode = false
                                    refreshControls = true
                                end,
                            },
                            vb:button {
                                --text = "✎",
                                bitmap = "Icons/SampleEd_DrawTool.bmp",
                                tooltip = "Pen mode",
                                id = "mode_pen",
                                notifier = function()
                                    penMode = true
                                    audioPreviewMode = false
                                    refreshControls = true
                                end,
                            },
                            vb:button {
                                bitmap = "Icons/Browser_AudioFile.bmp",
                                tooltip = "Audio preview mode",
                                id = "mode_audiopreview",
                                notifier = function()
                                    audioPreviewMode = true
                                    penMode = false
                                    refreshControls = true
                                end,
                            },
                        },
                        vb:button {
                            text = "♬",
                            tooltip = "Enable / disable note preview",
                            id = "notepreview",
                            notifier = function()
                                preferences.notePreview.value = not preferences.notePreview.value
                                refreshControls = true
                            end,
                        },
                    },
                    vb:row {
                        noteSlider,
                        whiteKeys,
                    }
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
                        pianorollColumns,
                    },
                },
            },
            vb:row {
                vb:space {
                    width = math.max(16, gridStepSizeW / 2) + (gridStepSizeW * 3)
                },
                stepSlider,
            },
            vb:column {
                id = "key_state_panel",
                visible = false,
                vb:space {
                    height = 2,
                },
                vb:row {
                    margin = 1,
                    uniform = true,
                    vb:bitmap {
                        bitmap = "Icons/Transport_ComputerKeyboard.bmp",
                        mode = "transparent",
                        width = 20,
                        height = 12,
                    },
                    vb:text {
                        id = "key_state",
                        text = "",
                        font = "bold",
                        style = "strong",
                    },
                }
            }
        }
        --fill new created pianoroll, timeline and refresh controls
        refreshNoteControls()
        fillTimeline()
        fillPianoRoll()
        --center note view
        if lowesetNote ~= nil then
            local nOffset = math.floor((lowesetNote + highestNote) / 2) - (gridHeight / 2)
            if nOffset < 0 then
                nOffset = 0
            elseif nOffset > noteSlider.max then
                nOffset = noteSlider.max
            end
            noteSlider.value = nOffset
            noteOffset = nOffset
        end
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
            send_key_repeat = false,
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
                    song.transport.follow_player = false
                    song.selected_sequence_index  = s
                    song.selected_track_index = t
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
    name = "Global:Tools:Edit with Simple Pianoroll ...",
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