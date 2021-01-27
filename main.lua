--some basic renoise vars for reuse
local vb = renoise.ViewBuilder()
local vbw = vb.views
local app = renoise.app()
local song
local tool = renoise.tool()

--load manifest for fetching versionnumber
local manifest = renoise.Document.create("RenoiseScriptingTool") {
    Version = "",
}
manifest:load_from("manifest.xml")

--dialog vars
local windowObj
local windowContent
local stepSlider
local noteSlider

--last step position for resetting the last step button
local lastStepOn

--some grid basics
local gridStepSizeH = 18
local gridStepSizeW = 20
--no space and margin, but renoise still add space, its faster in rendering
--local gridSpacing = 0
--local gridMargin = 0
--positive values will be converted to negative ones to reduce margin and spacing, looks better but its slower
local gridSpacing = 4
local gridMargin = 1
--size of pianorollgrid
local gridWidth = 64
local gridHeight = 42

--current note offset and stepoffset (x/y) - sliders (scrollbars)
local noteOffset
local stepOffset = 0

local pianoKeyWidth = gridStepSizeW * 3

--colors
local colorWhiteKey = { 52, 68, 78 }
local colorBlackKey = { 35, 47, 57 }
local colorNote = { 170, 217, 179 }
local colorNoteHighlight = { 232, 204, 110 }
local colorNoteSelected = { 244, 150, 149 }
local colorStepOff = { 30, 6, 0 }
local colorStepOn = { 180, 80, 40 }

--note trigger vars
local oscClient
local oscPort = 8000
local lastTriggerNote
local triggerTimer
local triggerTime = 250

--main flag for refreshing pianoroll
local refreshPianoRollNeeded = false

--table to save note indices per step for highlighting
local noteOnStep = {}

--edit vars
local dblClickTime = 0.4
local lastClickCache = {}
local currentNoteLength = 2
local currentNoteVelocity = 255
local currentNoteVelocityPreview = 127
local currentNoteEndVelocity = 255
local currentInstrument

local noteSelection = {}
local noteSelectionSize = 0
local lastSelectionClick
local lowesetNote
local highestNote

local noteData = {}

--key states
local keyControl = false
local keyRControl = false
local keyShift = false
local keyRShift = false
local keyAlt = false

--
function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

--returns true, when note in scale
local function noteInScale(note)
    note = note % 12
    if note == 1 or note == 3 or note == 6 or note == 8 or note == 10 then
        return false
    end
    return true
end

--remove selected notes
local function removeSelectedNotes()
    local lineValues = song.selected_pattern_track.lines
    --loop through selected notes
    for key, value in pairs(noteSelection) do
        local note_column = lineValues[noteSelection[key].line]:note_column(noteSelection[key].column)
        if note_column ~= nil then
            note_column:clear()
            --check for note on before this note, set note off when needed
            for i = noteSelection[key].line, 1, -1 do
                local temp = lineValues[i]:note_column(noteSelection[key].column)
                if temp.note_value < 120 then
                    note_column.note_value = 120
                    break
                elseif temp.note_value == 120 then
                    break
                end
            end
            --remove end note vel
            if noteSelection[key].len > 1 then
                note_column = lineValues[noteSelection[key].line + noteSelection[key].len - 1]:note_column(noteSelection[key].column)
                note_column:clear()
            end
            --remove note off, when needed
            if noteSelection[key].line + noteSelection[key].len <= song.selected_pattern.number_of_lines then
                note_column = lineValues[noteSelection[key].line + noteSelection[key].len]:note_column(noteSelection[key].column)
                if note_column.note_value == 120 then
                    note_column:clear()
                end
            end
        end
    end
    noteSelection = {}
    noteSelectionSize = 0
    refreshPianoRollNeeded = true
end

--simple function for double click detection for buttons
local function dbclkDetector(index)
    if lastClickCache[index] ~= nil and os.clock() - lastClickCache[index] < dblClickTime then
        return true
    end
    lastClickCache[index] = os.clock()
    return false
end

--refresh all controls
local function refreshNoteControls()
    vbw.note_len.value = currentNoteLength
    vbw.note_vel.value = currentNoteVelocity
    if currentNoteVelocity > 0 and currentNoteVelocity < 128 then
        currentNoteVelocityPreview = currentNoteVelocity
    else
        currentNoteVelocityPreview = 127
    end
    if currentNoteLength == 1 then
        currentNoteEndVelocity = 255
        vbw.note_end_vel.value = currentNoteEndVelocity
        vbw.note_end_vel.active = false
    else
        vbw.note_end_vel.active = true
    end
end

--simple note trigger
local function triggerNoteOfCurrentInstrument(note_value, pressed)
    --init server connection, when not ready
    local socket_error
    if oscClient == nil then
        oscClient, socket_error = renoise.Socket.create_client("127.0.0.1", oscPort, renoise.Socket.PROTOCOL_UDP)
        if (socket_error) then
            return
        end
    end
    if pressed == true then
        oscClient:send(renoise.Osc.Message("/renoise/trigger/note_on", { { tag = "i", value = currentInstrument },
                                                                         { tag = "i", value = song.selected_track_index },
                                                                         { tag = "i", value = note_value },
                                                                         { tag = "i", value = currentNoteVelocity } }))
    elseif pressed == false then
        oscClient:send(renoise.Osc.Message("/renoise/trigger/note_off", { { tag = "i", value = currentInstrument },
                                                                          { tag = "i", value = song.selected_track_index },
                                                                          { tag = "i", value = note_value } }))
    else
        --when last note is still playing, cut off
        if lastTriggerNote ~= nil then
            renoise.tool():remove_timer(triggerTimer)
            table.remove(lastTriggerNote) --remove velocity
            oscClient:send(renoise.Osc.Message("/renoise/trigger/note_off", lastTriggerNote))
            lastTriggerNote = nil
        end
        --build note event
        lastTriggerNote = { { tag = "i", value = currentInstrument },
                            { tag = "i", value = song.selected_track_index },
                            { tag = "i", value = note_value },
                            { tag = "i", value = currentNoteVelocityPreview } }
        --send note event to osc server
        oscClient:send(renoise.Osc.Message("/renoise/trigger/note_on", lastTriggerNote))
        --create a timer for note off
        triggerTimer = function()
            table.remove(lastTriggerNote) --remove velocity
            oscClient:send(renoise.Osc.Message("/renoise/trigger/note_off", lastTriggerNote))
            lastTriggerNote = nil
            renoise.tool():remove_timer(triggerTimer)
        end
        --start timer
        renoise.tool():add_timer(triggerTimer, triggerTime)
    end
end

--transpose each selected notes
local function transposeSelectedNotes(transpose, keepscale)
    local lineValues = song.selected_pattern_track.lines
    for key, value in pairs(noteSelection) do
        local transposeVal = transpose
        --disable edit mode to prevent side effects
        song.transport.edit_mode = false
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

        --default transpose note
        noteSelection[key].note = noteSelection[key].note + transposeVal
        if noteSelection[key].note < 0 then
            noteSelection[key].note = 0
        elseif noteSelection[key].note >= 120 then
            noteSelection[key].note = 119
        end
        note_column.note_value = noteSelection[key].note
        triggerNoteOfCurrentInstrument(noteSelection[key].note)
    end
    refreshPianoRollNeeded = true
end

--convert the note value to a grid y position
local function noteValue2GridRowOffset(noteValue)
    noteValue = noteValue + (-noteOffset) + 1
    if noteValue >= 1 and noteValue <= gridHeight then
        return noteValue
    end
    return nil
end

--convert grid y value to note value
local function gridOffset2NoteValue(y)
    return y + noteOffset - 1
end

--keyboard preview
function keyClick(y, pressed)
    triggerNoteOfCurrentInstrument(gridOffset2NoteValue(y), pressed)
end

--will be called, when a note was clicked
function noteClick(x, y)
    local index = tostring(x) .. "_" .. tostring(y)
    local dbclk = dbclkDetector("b" .. index)
    if dbclk then
        --note remove
        removeSelectedNotes()
    else
        local note_data = noteData[index]
        if note_data ~= nil then
            --clear selection, when ctrl is not holded
            if not keyControl then
                noteSelection = {}
                noteSelectionSize = 0
            end
            noteSelection[tostring(note_data.line) .. "_" .. tostring(note_data.column)] = note_data
            noteSelectionSize = noteSelectionSize + 1
            currentNoteLength = note_data.len
            currentNoteVelocity = note_data.vel
            refreshNoteControls()
            triggerNoteOfCurrentInstrument(note_data.note)
            refreshPianoRollNeeded = true
        end
    end
end

--will be called, when an empty grid button was clicked
function pianoGridClick(x, y)
    local dbclk = dbclkDetector("p" .. tostring(x) .. "_" .. tostring(y))
    if dbclk then
        local steps = song.selected_pattern.number_of_lines
        local lineValues = song.selected_pattern_track.lines
        local column
        local note_value
        local noteOff = false
        --move x by stepoffset
        x = x + stepOffset
        --check if current note length is too long for pattern size, reduce len if needed
        if x + currentNoteLength > steps then
            currentNoteLength = steps - x + 1
            refreshNoteControls()
        end
        --disable edit mode because of side effects
        song.transport.edit_mode = false
        --check if enough space for a new note
        for c = 1, song.selected_track.max_note_columns do
            local validSpace = true
            --check for note on before
            if x > 1 then
                for i = x, 1, -1 do
                    if lineValues[i]:note_column(c).note_value < 120 then
                        validSpace = false
                        break
                    elseif lineValues[i]:note_column(c).note_value == 120 then
                        break
                    end
                end
            end
            --check for note on in
            for i = x, x + currentNoteLength - 1 do
                if lineValues[i]:note_column(c).note_value < 120 then
                    validSpace = false
                end
            end
            if validSpace then
                column = c
                break
            end
        end
        --no column found
        if column == nil then
            --no space for this note
            return false
        end
        --show note column if hidden
        if column > song.selected_track.visible_note_columns then
            song.selected_track.visible_note_columns = column
        end
        --add new note
        note_value = gridOffset2NoteValue(y)
        lineValues[x]:note_column(column).note_value = note_value
        lineValues[x]:note_column(column).volume_string = string.format("%X", currentNoteVelocity)
        lineValues[x]:note_column(column).instrument_value = currentInstrument - 1
        if currentNoteLength > 1 then
            lineValues[x + currentNoteLength - 1]:note_column(column).volume_string = string.format("%X", currentNoteEndVelocity)
        end
        --set note off?
        if x + currentNoteLength <= steps then
            if lineValues[x + currentNoteLength]:note_column(column).note_value < 120 then

            else
                noteOff = true
                lineValues[x + currentNoteLength]:note_column(column).note_value = 120
            end
        end
        --trigger preview notes
        triggerNoteOfCurrentInstrument(note_value)
        --clear selection and add new note as new selection
        noteSelection = {}
        noteSelectionSize = 0
        noteSelection[tostring(x) .. "_" .. tostring(column)] = {
            note = note_value,
            column = column,
            line = x,
            len = currentNoteLength,
            noteOff = noteOff,
        }
        noteSelectionSize = noteSelectionSize + 1
        --
        refreshPianoRollNeeded = true
    else
        --when a last click was saved and shift is pressing, than try to seelect notes
        if (keyShift or keyRShift) and lastSelectionClick then
            local lineValues = song.selected_pattern_track.lines
            local columns = song.selected_track.visible_note_columns
            local smin = math.min(x, lastSelectionClick[1])
            local smax = math.max(x, lastSelectionClick[1])
            local nmin = gridOffset2NoteValue(math.min(y, lastSelectionClick[2]))
            local nmax = gridOffset2NoteValue(math.max(y, lastSelectionClick[2]))
            --remove current note selection
            noteSelection = {}
            noteSelectionSize = 0
            --loop through columns
            for c = 1, columns do
                --loop through lines as steps
                for s = smin, smax do
                    local note_column = lineValues[s + stepOffset]:note_column(c)
                    local note = note_column.note_value
                    --note inside the selection rect?
                    if note >= nmin and note <= nmax then
                        local note_data = noteData[tostring(s) .. "_" .. tostring(noteValue2GridRowOffset(note))]
                        --note found?
                        if note_data ~= nil then
                            --add to selection table
                            noteSelection[tostring(note_data.line) .. "_" .. tostring(note_data.column)] = note_data
                            noteSelectionSize = noteSelectionSize + 1
                        end
                    end
                end
            end
            --piano refresh
            lastSelectionClick = { x, y }
            refreshPianoRollNeeded = true
        else
            lastSelectionClick = { x, y }
            --deselect selected notes
            if noteSelectionSize > 0 then
                noteSelection = {}
                noteSelectionSize = 0
                refreshPianoRollNeeded = true
                lastSelectionClick = { x, y }
            end
        end
    end
end

--enable a note button, when its visible, set correct length of the button
local function enableNoteButton(column, current_note_step, current_note_rowIndex, current_note, current_note_len, current_note_string, current_note_vel, noteOff)
    --save highest and lowest note
    if lowesetNote == nil then
        lowesetNote = current_note
    end
    if highestNote == nil then
        highestNote = current_note
    end
    lowesetNote = math.min(lowesetNote, current_note)
    highestNote = math.max(highestNote, current_note)
    --process only visible ones
    if current_note_rowIndex ~= nil then
        local line = current_note_step + stepOffset
        local noteOnStepIndex = current_note_step
        local current_note_index = tostring(current_note_step) .. "_" .. tostring(current_note_rowIndex)
        if current_note_vel == nil then
            current_note_vel = 255
        end
        noteData[current_note_index] = {
            line = line,
            note = current_note,
            vel = current_note_vel,
            len = current_note_len,
            noteoff = noteOff,
            column = column,
        }
        if noteOnStep[noteOnStepIndex] == nil then
            noteOnStep[noteOnStepIndex] = {}
        end
        table.insert(noteOnStep[noteOnStepIndex], current_note_index)
        local b = vbw["b" .. current_note_index]
        b.width = (gridStepSizeW * current_note_len) - (gridSpacing * (current_note_len - 1))
        if (gridStepSizeW < 34 and current_note_len < 2) or gridStepSizeH < 18 then
            b.text = ""
        else
            b.text = current_note_string
        end
        if noteSelection[tostring(line) .. "_" .. tostring(column)] ~= nil then
            b.color = colorNoteSelected
        else
            b.color = colorNote
        end
        b.visible = true
        if noteOff then
            vbw["p" .. current_note_index].visible = false
        end
    end
end

--reset pianoroll and enable notes
local function fillPianoRoll()
    local track = song.selected_track
    local steps = song.selected_pattern.number_of_lines
    local lineValues = song.selected_pattern_track.lines
    local columns = track.visible_note_columns
    local stepsCount = math.min(steps, gridWidth)
    local blackKeyIndex = {}
    local noffset = noteOffset - 1
    local blackKey
    local lastColumnWithNotes
    local hideEl = {}

    --reset vars
    noteOnStep = {}
    noteData = {}
    currentInstrument = nil

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
        local current_note_len = 0
        local current_note_vel = 255
        local current_note_step
        local current_note_rowIndex

        --loop through lines as steps
        for s = 1, gridWidth do
            local stepString = tostring(s)

            --check for notes outside the grid on left side
            if s == 1 then
                for i = stepOffset + 1, 1, -1 do
                    local note_column = lineValues[i]:note_column(c)
                    local note = note_column.note_value
                    local note_string = note_column.note_string
                    local volume_string = note_column.volume_string

                    if note < 120 then
                        lastColumnWithNotes = c
                        current_note = note
                        current_note_string = note_string
                        current_note_len = 0
                        current_note_step = s
                        current_note_vel = tonumber(volume_string, 16)
                        current_note_rowIndex = noteValue2GridRowOffset(current_note)
                        break
                    elseif note == 120 then
                        break
                    end
                end
            end

            --only reset column on first step
            if c == 1 then
                for y = 1, gridHeight do
                    local ystring = tostring(y)
                    local index = stepString .. "_" .. ystring
                    local p = vbw["p" .. index]
                    if blackKeyIndex[y] == nil then
                        blackKey = not noteInScale((y + noffset) % 12)
                        --color black notes
                        if blackKey then
                            blackKeyIndex[y] = colorBlackKey
                        else
                            blackKeyIndex[y] = colorWhiteKey
                        end
                    end
                    if s == 1 then
                        local key = vbw["k" .. ystring]
                        if blackKeyIndex[y][1] == colorBlackKey[1] then
                            key.color = { 20, 20, 20 }
                            key.text = ""
                        else
                            key.color = { 255, 255, 255 }
                            if (y + noffset) % 12 == 0 then
                                key.text = "         C" .. tostring(math.floor((y + noffset) / 12))
                            else
                                key.text = ""
                            end
                        end
                    end
                    vbw["b" .. index].visible = false
                    if s <= stepsCount then
                        p.color = blackKeyIndex[y]
                        p.visible = true
                        --refresh step indicator
                        if y == 1 then
                            vbw["s" .. stepString].visible = true
                        end
                    else
                        p.visible = false
                        --refresh step indicator
                        if y == 1 then
                            --vbw["s" .. stepString].visible = false
                            --not sure, but its faster do it outside the loop
                            table.insert(hideEl, "s" .. stepString)
                        end
                    end
                end
            end

            --render notes
            if s <= stepsCount then

                local note_column = lineValues[s + stepOffset]:note_column(c)
                local note = note_column.note_value
                local note_string = note_column.note_string
                local volume_string = note_column.volume_string

                if note < 120 then
                    if currentInstrument == nil and note_column.instrument_value < 255 then
                        currentInstrument = note_column.instrument_value + 1
                    end
                    if current_note ~= nil then
                        enableNoteButton(c, current_note_step, current_note_rowIndex, current_note, current_note_len, current_note_string, current_note_vel, false)
                    end
                    lastColumnWithNotes = c
                    current_note = note
                    current_note_string = note_string
                    current_note_len = 0
                    current_note_step = s
                    current_note_vel = tonumber(volume_string, 16)
                    current_note_rowIndex = noteValue2GridRowOffset(current_note)
                elseif note == 120 and current_note ~= nil then
                    enableNoteButton(c, current_note_step, current_note_rowIndex, current_note, current_note_len, current_note_string, current_note_vel, true)
                    current_note = nil
                    current_note_len = 0
                    current_note_rowIndex = nil
                end

                if current_note_rowIndex ~= nil then
                    --vbw["p" .. stepString .. "_" .. tostring(current_note_rowIndex)].visible = false
                    --not sure, but its faster outside the loop
                    table.insert(hideEl, "p" .. stepString .. "_" .. tostring(current_note_rowIndex))
                    current_note_len = current_note_len + 1
                end

            end
        end
        --pattern end, no note off, enable last note
        if current_note ~= nil then
            enableNoteButton(c, current_note_step, current_note_rowIndex, current_note, current_note_len, current_note_string, current_note_vel, false)
        end
    end

    --go through the hide table to hide buttons, its faster doing this way instead inside the loop
    for i = 1, #hideEl do
        vbw[hideEl[i]].visible = false
    end

    --hide unused note columns
    if lastColumnWithNotes ~= nil and lastColumnWithNotes < columns then
        track.visible_note_columns = lastColumnWithNotes
    end

    --no instrument found, use the current selected one
    if currentInstrument == nil then
        currentInstrument = song.selected_instrument_index
    end
end

--highlight each note on the current playback pos
local function highlightNotesOnStep(step, highlight)
    if noteOnStep[step] ~= nil and #noteOnStep[step] > 0 then
        for i = 1, #noteOnStep[step] do
            --when notes are on current step and not selected
            if noteOnStep[step][i] ~= nil and vbw["b" .. noteOnStep[step][i]].color[1] ~= colorNoteSelected[1] then
                if highlight then
                    vbw["b" .. noteOnStep[step][i]].color = colorNoteHighlight
                else
                    vbw["b" .. noteOnStep[step][i]].color = colorNote
                end
            end
        end
    end
end

--set playback pos via playback pos indicator
function setPlaybackPos(pos)
    song.transport:start_at(pos + stepOffset)
end

--app idle
local function appIdleEvent()
    --only proces when window is created and visible
    if windowObj and windowObj.visible then

        --refresh pianoroll, when needed
        if refreshPianoRollNeeded then
            local start = os.clock()
            fillPianoRoll()
            print("fillPianoRoll time: " .. os.clock() - start)
            refreshPianoRollNeeded = false
        end

        --refresh playback pos indicator
        local line = song.transport.playback_pos.line
        if song.selected_pattern_index == song.transport.playback_pos.sequence and lastStepOn ~= line and song.transport.playing then
            if lastStepOn then
                vbw["s" .. tostring(lastStepOn)].color = colorStepOff
                highlightNotesOnStep(lastStepOn, false)
                lastStepOn = nil
            end
            lastStepOn = line - stepOffset

            if lastStepOn > 0 and lastStepOn <= gridWidth then
                vbw["s" .. tostring(lastStepOn)].color = colorStepOn
                highlightNotesOnStep(lastStepOn, true)
            else
                lastStepOn = nil
            end
        elseif lastStepOn and song.selected_pattern_index ~= song.transport.playback_pos.sequence then
            vbw["s" .. tostring(lastStepOn)].color = colorStepOff
            highlightNotesOnStep(lastStepOn, false)
            lastStepOn = nil
        end
    end
end

--refresh notifier for observers
local function obsPianoRefresh()
    --clear note selection
    noteSelection = {}
    noteSelectionSize = 0
    --set refresh flag
    refreshPianoRollNeeded = true
end

--on each new song, reset pianoroll and setup locals
local function appNewDoc()
    song = renoise.song()
    --set new observers
    song.selected_pattern_track_observable:add_notifier(obsPianoRefresh)
    song.selected_pattern_observable:add_notifier(obsPianoRefresh)
    song.selected_track_observable:add_notifier(obsPianoRefresh)
    song.selected_pattern.number_of_lines_observable:add_notifier(obsPianoRefresh)
    --clear selection and refresh piano roll
    obsPianoRefresh()
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

    --only create pianoroll grid, when window is not created and not visible
    if not windowObj or not windowObj.visible then
        lastStepOn = nil
        lastSelectionClick = nil
        noteOffset = 28 -- default offset
        vbw.note_len = nil
        vbw.note_vel = nil
        vbw.note_end_vel = nil

        local vb_temp
        local playCursor = vb:row {
            margin = -gridMargin,
            spacing = -gridSpacing,
        }
        for x = 1, gridWidth do
            vbw["s" .. tostring(x)] = nil
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
            local row = vb:row {
                margin = -gridMargin,
                spacing = -gridSpacing,
            }
            for x = 1, gridWidth do
                vbw["p" .. tostring(x) .. "_" .. tostring(y)] = nil
                vbw["b" .. tostring(x) .. "_" .. tostring(y)] = nil
                local temp = "pianoGridClick(" .. tostring(x) .. "," .. tostring(y) .. ")"
                vb_temp = vb:button {
                    id = "p" .. tostring(x) .. "_" .. tostring(y),
                    height = gridStepSizeH,
                    width = gridStepSizeW,
                    color = colorWhiteKey,
                    visible = false,
                    notifier = loadstring(temp),
                }
                row:add_child(vb_temp)
                temp = "noteClick(" .. tostring(x) .. "," .. tostring(y) .. ")"
                vb_temp = vb:button {
                    id = "b" .. tostring(x) .. "_" .. tostring(y),
                    height = gridStepSizeH,
                    width = gridStepSizeW,
                    visible = false,
                    color = colorNote,
                    notifier = loadstring(temp),
                }
                row:add_child(vb_temp)
            end
            pianorollColumns:add_child(row)
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
            vbw["k" .. tostring(y)] = nil
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
                            width = 6,
                        }
                    }
            )
        end

        windowContent = vb:column {
            vb:row {
                margin = 3,
                spacing = 3,
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
                        currentNoteLength = number
                        refreshNoteControls()
                    end,
                },
                vb:button {
                    text = "double",
                    tooltip = "Double current note length number",
                    notifier = function()
                        currentNoteLength = math.floor(currentNoteLength * 2)
                        refreshNoteControls()
                    end,
                },
                vb:button {
                    text = "half",
                    tooltip = "Halve current note length number",
                    notifier = function()
                        currentNoteLength = math.floor(currentNoteLength / 2)
                        refreshNoteControls()
                    end,
                },
                vb:text {
                    text = "Vel:",
                },
                vb:valuebox {
                    id = "note_vel",
                    tooltip = "Note velocity",
                    steps = { 1, 2 },
                    min = 0,
                    max = 255,
                    value = currentNoteVelocity,
                    tostring = function(number)
                        if number == 255 then
                            return "--"
                        end
                        return string.format("%X", number)
                    end,
                    tonumber = function(string)
                        if string == "--" then
                            return 255
                        end
                        return tonumber(string, 16)
                    end,
                    notifier = function(number)
                        currentNoteVelocity = number
                        refreshNoteControls()
                    end,
                },
                vb:text {
                    text = "End-Vel:",
                },
                vb:valuebox {
                    id = "note_end_vel",
                    tooltip = "End note velocity",
                    steps = { 1, 2 },
                    min = 0,
                    max = 255,
                    value = currentNoteEndVelocity,
                    tostring = function(number)
                        if number == 255 then
                            return "--"
                        end
                        return string.format("%X", number)
                    end,
                    tonumber = function(string)
                        if string == "--" then
                            return 255
                        end
                        return tonumber(string, 16)
                    end,
                    notifier = function(number)
                        currentNoteEndVelocity = number
                        refreshNoteControls()
                    end,
                },
            },
            vb:row {
                vb:space {
                    width = math.max(16, gridStepSizeW / 2) + (gridStepSizeW * 3)
                },
                vb:column {
                    vb:space {
                        height = 3,
                    },
                    playCursor,
                    vb:space {
                        height = 3,
                    },
                }
            },
            vb:row {
                noteSlider,
                vb:row {
                    whiteKeys,
                },
                pianorollColumns,
            },
            vb:row {
                vb:space {
                    width = math.max(16, gridStepSizeW / 2) + (gridStepSizeW * 3)
                },
                stepSlider,
            },
        }
        --refresh note controls
        refreshNoteControls()
        --fill new created pianoroll
        fillPianoRoll()
        --center note view
        if lowesetNote ~= nil then
            local nOffset = math.floor((lowesetNote + highestNote) / 2) - (gridHeight / 2)
            if nOffset < 0 then
                noteOffset = 0
            elseif nOffset > noteSlider.max then
                noteOffset = noteSlider.max
            end
            noteSlider.value = math.floor((lowesetNote + highestNote) / 2) - (gridHeight / 2)
        end
        --show dialog
        windowObj = app:show_custom_dialog("Simple Pianoroll v" .. manifest:property("Version").value, windowContent, function(dialog, key)
            local handled = false
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
            elseif key.name == "lalt" and key.state == "released" then
                keyAlt = false
                handled = true
            end
            if key.name == "lshift" and key.state == "pressed" then
                keyShift = true
                handled = true
            elseif key.name == "lshift" and key.state == "released" then
                keyShift = false
                handled = true
            end
            if key.name == "rshift" and key.state == "pressed" then
                keyRShift = true
                handled = true
            elseif key.name == "rshift" and key.state == "released" then
                keyRShift = false
                handled = true
            end
            if key.name == "del" and key.state == "released" then
                removeSelectedNotes()
                handled = true
            end
            if key.name == "esc" and key.state == "released" then
                if noteSelectionSize > 0 then
                    noteSelection = {}
                    noteSelectionSize = 0
                    refreshPianoRollNeeded = true
                end
                handled = true
            end
            if key.name == "a" and key.state == "released" and (keyControl or keyRControl) then
                --clear current selection
                noteSelection = {}
                noteSelectionSize = 0
                --step through all current notes and add them to noteSelection, TODO select all notes, not only the visible ones
                for key, value in pairs(noteData) do
                    local note_data = noteData[key]
                    noteSelection[tostring(note_data.line) .. "_" .. tostring(note_data.column)] = note_data
                    noteSelectionSize = noteSelectionSize + 1
                end
                refreshPianoRollNeeded = true
                handled = true
            end
            if key.name == "up" and key.state == "released" then
                local transpose = 1
                if keyShift or keyRShift then
                    transpose = 12
                end
                if noteSelectionSize > 0 then
                    transposeSelectedNotes(transpose, keyControl or keyRControl)
                elseif noteSlider.value + transpose <= noteSlider.max and noteSlider.value + transpose >= noteSlider.min then
                    noteSlider.value = noteSlider.value + transpose
                end
                handled = true
            end
            if key.name == "down" and key.state == "released" then
                local transpose = -1
                if keyShift or keyRShift then
                    transpose = -12
                end
                if noteSelectionSize > 0 then
                    transposeSelectedNotes(transpose, keyControl or keyRControl)
                elseif noteSlider.value + transpose <= noteSlider.max and noteSlider.value + transpose >= noteSlider.min then
                    noteSlider.value = noteSlider.value + transpose
                end
                handled = true
            end
            --return key to host
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

--add main function to context menu
tool:add_menu_entry {
    name = "Pattern Editor:Edit with Pianoroll ...",
    invoke = function()
        main_function()
    end
}