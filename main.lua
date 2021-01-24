--some basic renoise vars for reuse
local vb = renoise.ViewBuilder()
local vbw = vb.views
local app = renoise.app()
local song
local tool = renoise.tool()

--dialog vars
local windowObj
local windowContent
local stepSlider

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
local gridHeight = 32

--current note offset and stepoffset (x/y) - sliders (scrollbars)
local noteOffset = 28
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
local dblclicktime = 0.4
local lastClickCache = {}
local currentNoteLength = 2
local currentNoteVelocity = 255
local currentNoteVelocityPreview = 127
local currentNoteEndVelocity = 255
local currentInstrument
local noteSelection = {}
local noteData = {}

--key states
local keyControl = false
local keyShift = false
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

--simple function for double blick dbclk detection for buttons
local function dbclkDetector(index)
    if lastClickCache[index] ~= nil and os.clock() - lastClickCache[index] < dblclicktime then
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
    else
        local note_data = noteData[index]
        if note_data ~= nil then
            --clear selection, when ctrl is not holded
            if not keyControl then
                noteSelection = {}
            end
            table.insert(noteSelection, note_data)
            currentNoteLength = note_data.len
            currentNoteVelocity = note_data.vel
            refreshNoteControls()
            triggerNoteOfCurrentInstrument(note_data.note)
            refreshPianoRollNeeded = true
        end
    end
end

--we be called, when an empty grid button was clicked
function pianoGridClick(x, y)
    local dbclk = dbclkDetector("p" .. tostring(x) .. "_" .. tostring(y))
    if dbclk then
        local steps = song.selected_pattern.number_of_lines
        local lineValues = song.selected_pattern_track.lines
        local column = 1
        local note_value
        --disable edit mode because of side effects
        song.transport.edit_mode = false
        --move x by stepoffset
        x = x + stepOffset
        --
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
                lineValues[x + currentNoteLength]:note_column(column).note_value = 120
            end
        end
        if not song.transport.playing then
            triggerNoteOfCurrentInstrument(note_value)
        end
        refreshPianoRollNeeded = true
    end
end

--enable a note button, when its visible, set correct length of the button
local function enableNoteButton(column, current_note_step, current_note_rowIndex, current_note, current_note_len, current_note_string, current_note_vel, noteOff)
    if current_note_rowIndex ~= nil then
        local color = colorNote
        local noteOnStepIndex = current_note_step
        local current_note_index = tostring(current_note_step) .. "_" .. tostring(current_note_rowIndex)
        if current_note_vel == nil then
            current_note_vel = 255
        end
        noteData[current_note_index] = {
            line = current_note_step,
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
        if gridStepSizeW < 34 and current_note_len < 2 then
            b.text = ""
        elseif gridStepSizeH < 18 then
            b.text = ""
        else
            b.text = current_note_string
        end
        for i=1, #noteSelection do
            if noteSelection[i].note == current_note and noteSelection[i].line == current_note_step and noteSelection[i].column == column then
                color = colorNoteSelected
                break
            end
        end
        b.color = color
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
            if s == 1 and stepOffset > 0 then
                for i = stepOffset + 1, 1, -1 do
                    local note_column = lineValues[i]:note_column(c)
                    local note = note_column.note_value
                    local note_string = note_column.note_string
                    local volume_string = note_column.volume_string

                    if note < 120 then
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
                        blackKey = (y + noffset) % 12
                        --color black notes
                        if blackKey == 1 or blackKey == 3 or blackKey == 6 or blackKey == 8 or blackKey == 10 then
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
                    if s <= steps then
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
                            vbw["s" .. stepString].visible = false
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
                    vbw["p" .. stepString .. "_" .. tostring(current_note_rowIndex)].visible = false
                    current_note_len = current_note_len + 1
                end

            end
        end
        --pattern end, no note off, enable last note
        if current_note ~= nil then
            enableNoteButton(c, current_note_step, current_note_rowIndex, current_note, current_note_len, current_note_string, current_note_vel, false)
        end
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
    refreshPianoRollNeeded = true
end

--on each new song, reset pianoroll and setup locals
local function appNewDoc()
    song = renoise.song()
    --set new observers
    song.selected_pattern_track_observable:add_notifier(obsPianoRefresh)
    song.selected_pattern_observable:add_notifier(obsPianoRefresh)
    song.selected_track_observable:add_notifier(obsPianoRefresh)
    refreshPianoRollNeeded = true
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
                vb:minislider {
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
                },
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
        --show dialog
        windowObj = app:show_custom_dialog("Simple Pianoroll", windowContent, function(dialog, key)
            if key.name == "lcontrol" and key.state == "pressed" then
                keyControl = true
            elseif key.name == "lcontrol" and key.state == "released" then
                keyControl = false
            end
            if key.name == "lalt" and key.state == "pressed" then
                keyAlt = true
            elseif key.name == "lalt" and key.state == "released" then
                keyAlt = false
            end
            if key.name == "lshift" and key.state == "pressed" then
                keyShift = true
            elseif key.name == "lshift" and key.state == "released" then
                keyShift = false
            end
            if key.name == "del" and key.state == "released" and #noteSelection > 0 then
                print("kill notes")
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