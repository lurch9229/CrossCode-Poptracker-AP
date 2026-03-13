-- this is an example/ default implementation for AP autotracking
-- it will use the mappings defined in item_mapping.lua and location_mapping.lua to track items and locations via thier ids
-- it will also load the AP slot data in the global SLOT_DATA, keep track of the current index of on_item messages in CUR_INDEX
-- addition it will keep track of what items are local items and which one are remote using the globals LOCAL_ITEMS and GLOBAL_ITEMS
-- this is useful since remote items will not reset but local items might
ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/tab_mapping.lua")

CUR_INDEX = -1
SLOT_DATA = nil
LOCAL_ITEMS = {}
GLOBAL_ITEMS = {}

PROG_A_UNLOCK = {}
PROG_D_UNLOCK = {}
PROG_O_UNLOCK = {}

if Highlight then
	HINT_STATUS_MAPPING = {
		[20] = Highlight.Avoid,
		[40] = Highlight.None,
		[10] = Highlight.NoPriority,
		[0]  = Highlight.Unspecified,
		[30] = Highlight.Priority,
	}
end

function dump_table(o, depth)
    if depth == nil then
        depth = 0
    end
    if type(o) == 'table' then
        local tabs = ('\t'):rep(depth)
        local tabs2 = ('\t'):rep(depth + 1)
        local s = '{\n'
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. tabs2 .. '[' .. k .. '] = ' .. dump_table(v, depth + 1) .. ',\n'
        end
        return s .. tabs .. '}'
    else
        return tostring(o)
    end
end

function onClear(slot_data)

    if slot_data['options']["chestClearanceLevels"] then
        getLocksFromSlot(slot_data)
    end

    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onClear, slot_data:\n%s", dump_table(slot_data)))
    end
    SLOT_DATA = slot_data
    CUR_INDEX = -1
    -- reset locations
    for _, v in pairs(LOCATION_MAPPING) do
        if v[1] then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: clearing location %s", v[1]))
            end
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[1]:sub(1, 1) == "@" then
                    obj.AvailableChestCount = obj.ChestCount
                else
                    obj.Active = false
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: could not find object for code %s", v[1]))
            end
        end
    end
    -- reset items
    for _, v in pairs(ITEM_MAPPING) do
        if v[1] and v[2] then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: clearing item %s of type %s", v[1], v[2]))
            end
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[2] == "toggle" then
                    obj.Active = false
                elseif v[2] == "progressive" then
                    obj.CurrentStage = 0
                    obj.Active = false
                elseif v[2] == "consumable" then
                    obj.AcquiredCount = 0
                elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                    print(string.format("onClear: unknown item type %s for code %s", v[2], v[1]))
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: could not find object for code %s", v[1]))
            end
        end
    end
    LOCAL_ITEMS = {}
    GLOBAL_ITEMS = {}
    
    if SLOT_DATA == nil then
        return
    end

    if slot_data['options']['shopSendMode'] then
        local obj = Tracker:FindObjectForCode("op_SS")
        if obj then
            if slot_data['options']['shopSendMode'] == "itemType" then
                obj.CurrentStage = 1
            elseif slot_data['options']['shopSendMode'] == "slot" then
                obj.CurrentStage = 3
            else
                obj.CurrentStage = 0
            end
        end
    else
        local obj = Tracker:FindObjectForCode("op_SS")
        if obj then
            obj.CurrentStage = 0
        end
    end

    if slot_data['options']['shopReceiveMode'] then
        local obj = Tracker:FindObjectForCode("op_SR")
        if obj then
            if slot_data['options']['shopReceiveMode'] == "itemType" then
                obj.CurrentStage = 1
            elseif slot_data['options']['shopReceiveMode'] == "shop" then
                obj.CurrentStage = 2
            elseif slot_data['options']['shopReceiveMode'] == "slot" then
                obj.CurrentStage = 3
            else
                obj.CurrentStage = 0
            end
        end
    else
        local obj = Tracker:FindObjectForCode("op_SR")
        if obj then
            obj.CurrentStage = 0
        end
    end

    if slot_data['options']['vtShadeLock'] then
        local obj = Tracker:FindObjectForCode("op_VT")
        if obj then
            obj.CurrentStage = slot_data['options']['vtShadeLock']
        end
    end

    if slot_data['options']['questRando'] then
        local obj = Tracker:FindObjectForCode("op_QS")
        if obj then
            if slot_data['options']['questRando'] == true then
                obj.CurrentStage = 1
            else
                obj.CurrentStage = 0
            end
        end
    end

    if slot_data['mode'] then
        if slot_data['mode'] == "open" then
            Tracker:FindObjectForCode("op_OM").CurrentStage = 0
        elseif slot_data['mode'] == "linear" then
            Tracker:FindObjectForCode("op_OM").CurrentStage = 1
        end
    end

    if slot_data['options']["keyrings"] then 
        if slot_data['options']["keyrings"][1] ~= nil then 
            Tracker:FindObjectForCode("op_KR").CurrentStage = 1
        else
            Tracker:FindObjectForCode("op_KR").CurrentStage = 0
        end
    else
        Tracker:FindObjectForCode("op_KR").CurrentStage = 0
    end

    if slot_data['options']["meteorPassage"] then 
        Tracker:FindObjectForCode("op_VW").CurrentStage = 1
    else
        Tracker:FindObjectForCode("op_VW").CurrentStage = 0
    end

    if slot_data['options']["chestClearanceLevels"] then 
        Tracker:FindObjectForCode("op_CL").CurrentStage = 1
    else
        Tracker:FindObjectForCode("op_CL").CurrentStage = 0
    end

    if slot_data['options']["rhombusHubUnlock"] then 
        Tracker:FindObjectForCode("op_RH").CurrentStage = 1
    else
        Tracker:FindObjectForCode("op_RH").CurrentStage = 0
    end

    if slot_data['options']['closedGaia'] then
        local obj = Tracker:FindObjectForCode("op_GG")
        if obj then
            if slot_data['options']['closedGaia'] == 0 then
                obj.CurrentStage = 0
            elseif slot_data['options']['closedGaia'] == 1 then
                obj.CurrentStage = 1
            elseif slot_data['options']['closedGaia'] == 2 then
                obj.CurrentStage = 2
            else
                obj.CurrentStage = 0
            end
        end
    else
        local obj = Tracker:FindObjectForCode("op_GG")
        if obj then
            obj.CurrentStage = 0
        end
    end

    if slot_data['options']['closedGaia'] then
        local obj = Tracker:FindObjectForCode("op_G")
        if obj then
            if slot_data['options']['goal'] == "creator" then
                obj.CurrentStage = 0
            elseif slot_data['options']['goal'] == "monkey" then
                obj.CurrentStage = 1
            elseif slot_data['options']['goal'] == "observatory" then
                obj.CurrentStage = 2
            else
                obj.CurrentStage = 0
            end
        end
    else
        local obj = Tracker:FindObjectForCode("op_G")
        if obj then
            obj.CurrentStage = 0
        end
    end
    

    PROG_A_UNLOCK = slot_data['options']["progressiveChains"]["3235824050"]
    PROG_D_UNLOCK = slot_data['options']["progressiveChains"]["3235824052"]
    PROG_O_UNLOCK = slot_data['options']["progressiveChains"]["3235824051"]

    -- get auto tabbing
    if Archipelago.PlayerNumber > -1 then
        local data_storage_list = ({"CrossCode_" ..Archipelago.TeamNumber.. "_" ..Archipelago.PlayerNumber.. "_mapName"})

        Archipelago:SetNotify(data_storage_list)
        Archipelago:Get(data_storage_list)
    end

    -- get hints
    if Archipelago.PlayerNumber > -1 then
        HINTS_ID = "_read_hints_"..Archipelago.TeamNumber.."_"..Archipelago.PlayerNumber

        Archipelago:SetNotify({HINTS_ID})
        Archipelago:Get({HINTS_ID})
    end
end

-- called when an item gets collected
function onItem(index, item_id, item_name, player_number)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onItem: %s, %s, %s, %s, %s", index, item_id, item_name, player_number, CUR_INDEX))
    end
    if index <= CUR_INDEX then
        return
    end
    local is_local = player_number == Archipelago.PlayerNumber
    CUR_INDEX = index;
    local v = ITEM_MAPPING[item_id]
    if not v then
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onItem: could not find item mapping for id %s", item_id))
        end
        return
    end
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onItem: code: %s, type %s", v[1], v[2]))
    end
    if not v[1] then
        return
    end
    local obj = Tracker:FindObjectForCode(v[1])
    if obj then
        if v[2] == "toggle" then
            obj.Active = true
        elseif v[2] == "progressive" then
            if obj.Active then
                obj.CurrentStage = obj.CurrentStage + 1
            else
                obj.Active = true
            end
        elseif v[2] == "consumable" then
            obj.AcquiredCount = obj.AcquiredCount + obj.Increment
            if item_id == 3235824052 then
                local objItem = Tracker:FindObjectForCode(ITEM_MAPPING[PROG_D_UNLOCK[obj.AcquiredCount]][1])
                if objItem then
                    objItem.Active = true
                end
            elseif item_id == 3235824051 then
                local objItem = Tracker:FindObjectForCode(ITEM_MAPPING[PROG_O_UNLOCK[obj.AcquiredCount]][1])
                if objItem then
                    objItem.Active = true
                end
            elseif item_id == 3235824050 then
                local objItem = Tracker:FindObjectForCode(ITEM_MAPPING[PROG_A_UNLOCK[obj.AcquiredCount]][1])
                if objItem then
                    objItem.Active = true
                end
            end
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onItem: unknown item type %s for code %s", v[2], v[1]))
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onItem: could not find object for code %s", v[1]))
    end

    -- track local items via snes interface
    if is_local then
        if LOCAL_ITEMS[v[1]] then
            LOCAL_ITEMS[v[1]] = LOCAL_ITEMS[v[1]] + 1
        else
            LOCAL_ITEMS[v[1]] = 1
        end
    else
        if GLOBAL_ITEMS[v[1]] then
            GLOBAL_ITEMS[v[1]] = GLOBAL_ITEMS[v[1]] + 1
        else
            GLOBAL_ITEMS[v[1]] = 1
        end
    end
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("local items: %s", dump_table(LOCAL_ITEMS)))
        print(string.format("global items: %s", dump_table(GLOBAL_ITEMS)))
    end
    if PopVersion < "0.20.1" or AutoTracker:GetConnectionState("SNES") == 3 then
        -- add snes interface functions here for local item tracking
    end
end

--called when a location gets cleared
function onLocation(location_id, location_name)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onLocation: %s, %s", location_id, location_name))
    end

    local v = LOCATION_MAPPING[location_id]
    
    if not v then
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onLocation: could not find location mapping for id %s", location_id))
        end

        return
    end

    if not v[1] then
        return
    end

    local obj = Tracker:FindObjectForCode(v[1])
    
    if obj then
        manualHostedItems(location_id)
        manualShopTypes(location_id)
        if v[1]:sub(1, 1) == "@" then
            obj.AvailableChestCount = obj.AvailableChestCount - 1
        else
            obj.Active = true
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: could not find object for code %s", v[1]))
    end
end

-- Get dict of chests from Slot Data
slotIds = {}

function getLocksFromSlot(slot_data)
    for id, info in pairs(slot_data["options"]["chestClearanceLevels"]) do
        slotIds[id]=info
    end
    -- print("slotIDs", dump_table(slotIds))
    idCheck(slotIds)
end

-- Match Slot IDs to Location Mapping
function idCheck(slotIds)
    for id, locationTable in pairs(LOCATION_MAPPING) do
        for location,_ in pairs(locationTable) do
            if string.find(location, "chest") then
                if slotIds[id] == nil then
                    print("No Match for ID:", id)
                end
            end
        end
    end
    print("ID Check Finished")
end

-- Mapping for Key types
keyMapping = {
    -- ["Default"],
    ["Bronze"] = "ThiefKey",
    ["Silver"] = "WhiteKey",
    ["Gold"] = "RadiantKey"
}
-- Change clearanceLevel for id
function newLock(location_id, defaultKey)
    -- If tracker is in stage 0
    if Tracker:FindObjectForCode("op_CL").CurrentStage == 0 then
        if defaultKey == nil then
            return true
        else
            return Tracker:FindObjectForCode(defaultKey).Active
        end
    -- If tracker is in stage 1
    elseif Tracker:FindObjectForCode("op_CL").CurrentStage == 1 then
        if slotIds[location_id] == nil then
            if defaultKey == nil then
                -- print(location_id,"setting on, no slot ID and no default key")
                return true
            else
                -- print(location_id,"setting on, Returning active status for default key, no slot ID:", defaultKey)
                return Tracker:FindObjectForCode(defaultKey).Active
            end
        else
            if slotIds[location_id] == "Default" then
                -- print(location_id,"setting on, slot ID is default lock")
                return true
            else
                -- print(location_id, "setting on, Returning active status for key mapping:", keyMapping[slotIds[location_id]])
                return Tracker:FindObjectForCode(keyMapping[slotIds[location_id]]).Active
            end
        end
    end
end


-- called when a locations is scouted
function onScout(location_id, location_name, item_id, item_name, item_player)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onScout: %s, %s, %s, %s, %s", location_id, location_name, item_id, item_name, item_player))
    end
    -- not implemented yet :(
end

-- called when a bounce message is received 
function onBounce(json)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onBounce: %s", dump_table(json)))
    end
    -- your code goes here
end

function onSetReply(key, value, old_value)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called retrieved: %s, %s", key, value))
    end

    if value ~= old_value and key == HINTS_ID then
        for _, hint in ipairs(value) do
            if hint.finding_player == Archipelago.PlayerNumber then        
                --updateHintsLocation(hint)
                UpdateHintsHighlight(hint)
            end
        end
    elseif key == "CrossCode_" ..Archipelago.TeamNumber.. "_" ..Archipelago.PlayerNumber.. "_mapName" then
        local objItem = Tracker:FindObjectForCode("auto_tab")
        if objItem and not objItem.Active then return end

        local splitedArea = {}
        local index = 1

        for splited in string.gmatch(value, '([^.]+)') do 
            splitedArea[index] = splited
            index = index + 1
        end

        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("split is done: %s", dump_table(splitedArea)))
        end

        Overworld = splitedArea[1]
        Region = splitedArea[1]
        Floor = splitedArea[1] .. "." .. splitedArea[2]

        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("area splited: overworld is %s, region is %s, floor is %s", Overworld, Region, Floor))
        end

        if OVERWORLD_MAPPING[Overworld] then
            CURRENT_ROOM = OVERWORLD_MAPPING[Overworld]
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print("Overworld %s", CURRENT_ROOM)
            end
            Tracker:UiHint("ActivateTab", CURRENT_ROOM)
    
            if REGION_MAPPING[Region] then
                CURRENT_ROOM = REGION_MAPPING[Region]
                if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                    print("Region %s", CURRENT_ROOM)
                end
                Tracker:UiHint("ActivateTab", CURRENT_ROOM)
    
                if DUNGEON_MAPPING[Floor] then
                    CURRENT_ROOM = DUNGEON_MAPPING[Floor]
                    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                        print("Dungeon %s", CURRENT_ROOM)
                    end
                    Tracker:UiHint("ActivateTab", CURRENT_ROOM)
                end
            end
        else
            CURRENT_ROOM = "Connections"
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print("Overworld %s", CURRENT_ROOM)
            end
            Tracker:UiHint("ActivateTab", CURRENT_ROOM)
            
            CURRENT_ROOM = "World Map"
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print("Region %s", CURRENT_ROOM)
            end
            Tracker:UiHint("ActivateTab", CURRENT_ROOM)
        end
    end
end

function retrieved(key, value)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called retrieved: %s, %s", key, value))
    end

    if key == HINTS_ID then
        for _, hint in ipairs(value) do
            if hint.finding_player == Archipelago.PlayerNumber then        
            --updateHintsLocation(hint)
               UpdateHintsHighlight(hint)
            end
        end
    elseif key == "CrossCode_" ..Archipelago.TeamNumber.. "_" ..Archipelago.PlayerNumber.. "_mapName" then
        local objItem = Tracker:FindObjectForCode("auto_tab")
        if objItem and not objItem.Active then return end

        local splitedArea = {}
        local index = 1

        for splited in string.gmatch(value, '([^.]+)') do 
            splitedArea[index] = splited
            index = index + 1
        end

        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("split is done: %s", dump_table(splitedArea)))
        end

        Overworld = splitedArea[1]
        Region = splitedArea[1]
        Floor = splitedArea[1] .. "." .. splitedArea[2]

        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("area splited: overworld is %s, region is %s, floor is %s", Overworld, Region, Floor))
        end

        if OVERWORLD_MAPPING[Overworld] then
            CURRENT_ROOM = OVERWORLD_MAPPING[Overworld]
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print("Overworld %s", CURRENT_ROOM)
            end
            Tracker:UiHint("ActivateTab", CURRENT_ROOM)
    
            if REGION_MAPPING[Region] then
                CURRENT_ROOM = REGION_MAPPING[Region]
                if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                    print("Region %s", CURRENT_ROOM)
                end
                Tracker:UiHint("ActivateTab", CURRENT_ROOM)
    
                if DUNGEON_MAPPING[Floor] then
                    CURRENT_ROOM = DUNGEON_MAPPING[Floor]
                    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                        print("Dungeon %s", CURRENT_ROOM)
                    end
                    Tracker:UiHint("ActivateTab", CURRENT_ROOM)
                end
            end
        else
            CURRENT_ROOM = "Connections"
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print("Overworld %s", CURRENT_ROOM)
            end
            Tracker:UiHint("ActivateTab", CURRENT_ROOM)
            
            CURRENT_ROOM = "World Map"
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print("Region %s", CURRENT_ROOM)
            end
            Tracker:UiHint("ActivateTab", CURRENT_ROOM)
        end
    end
end

function UpdateHintsHighlight(hint)
    if PopVersion < "0.32.0" then
        return
    end

    -- get the highlight enum value for the hint status
    local item_flags = hint.item_flags
    local hint_status = hint.status
    local highlight_code = nil

    if hint.found then
        highlight_code = Highlight.None
    elseif item_flags == 0 then
        highlight_code = Highlight.Unspecified
    elseif item_flags == 1 then
        highlight_code = Highlight.Priority
    elseif item_flags == 2 then
        highlight_code = Highlight.NoPriority
    elseif hint_status then
        highlight_code = HINT_STATUS_MAPPING[hint_status]
    end

    if not highlight_code then
        -- try to "recover" by checking hint.found (older AP versions without hint.status)
        if hint.found then
            highlight_code = Highlight.None
        elseif not hint.found then
            highlight_code = Highlight.Unspecified
        else
            return
        end
    end

    -- get the location mapping for the location id
    local mapping_entry = LOCATION_MAPPING[hint.location]

    if not mapping_entry then
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("updateHint: could not find location mapping for id %s", hint.location))
        end

        return
    end

    for _, location_code in pairs(mapping_entry) do
        if location_code and location_code:sub(1, 1) == "@" then
            local obj = Tracker:FindObjectForCode(location_code)

            if obj and obj.Highlight then                
                obj.Highlight = highlight_code

                hostedLocationsHighlight(location_code, highlight_code)

            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING then
                print(string.format("updateHint: could update section %s (obj doesn't support Highlight)", location_code))
            end
        end
    end
end

function hostedLocationsHighlight(location_code, highlight_code)
    local objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Sandwich Type - 100 Credits")

    if location_code == "@Shop Types/Sandwich Type/Buy A 'Sandwich' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Sandwich Type - 100 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Sandwich Type - 100 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Sandwich Type - 100 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Sandwich Type - 100 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Sandwich Type - 100 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Sandwich Type - 100 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Sandwich Type - 100 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Sandwich Type - 100 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Tara's Shop/Sandwich Type - 2500 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Hi-Sandwich Type/Buy A 'Hi-Sandwich' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Hi-Sandwich Type - 300 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Hi-Sandwich Type - 300 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Hi-Sandwich Type - 300 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Hi-Sandwich Type - 300 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Hi-Sandwich Type - 300 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Hi-Sandwich Type - 300 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Hi-Sandwich Type - 300 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Hi-Sandwich Type - 300 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Green Leaf Tea Type/Buy A 'Green Leaf Tea' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Green Leaf Tea Type - 250 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Green Leaf Tea Type - 250 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Green Leaf Tea Type - 250 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Green Leaf Tea Type - 250 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Green Leaf Tea Type - 250 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Green Leaf Tea Type - 250 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Green Leaf Tea Type - 250 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Green Leaf Tea Type - 250 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Just Water Type/Buy A 'Just Water' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Just Water Type - 222 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Just Water Type - 222 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Just Water Type - 222 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Just Water Type - 222 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Just Water Type - 222 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Just Water Type - 222 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Just Water Type - 222 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Just Water Type - 222 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Spicy Bun Type/Buy A 'Spicy Bun' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Spicy Bun Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Spicy Bun Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Spicy Bun Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Spicy Bun Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Spicy Bun Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Spicy Bun Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Spicy Bun Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Spicy Bun Type - 200 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Fruit Drink Type/Buy A 'Fruit Drink' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Fruit Drink Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Fruit Drink Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Fruit Drink Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Fruit Drink Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Fruit Drink Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Fruit Drink Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Fruit Drink Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Fruit Drink Type - 200 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Rice Cracker Type/Buy A 'Rice Cracker' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Rice Cracker Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Rice Cracker Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Rice Cracker Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Rice Cracker Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Rice Cracker Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Rice Cracker Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Rice Cracker Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Rice Cracker Type - 200 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Veggie Sticks Type/Buy A 'Veggie Sticks' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Veggie Sticks Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Veggie Sticks Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Veggie Sticks Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Veggie Sticks Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Veggie Sticks Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Veggie Sticks Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Veggie Sticks Type - 200 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Veggie Sticks Type - 200 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Kebab Roll Type/Buy A 'Kebab Roll' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Kebab Roll Type - 650 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Kebab Roll Type - 650 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Kebab Roll Type - 650 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Kebab Roll Type - 650 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Kebab Roll Type - 650 Credits Have Blue Ice")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Kebab Roll Type - 650 Credits Have Blue Ice")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Kebab Roll Type - 650 Credits Have Blue Ice")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Meaty Risotto Type/Buy A 'Meaty Risotto' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Meaty Risotto Type - 650 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Meaty Risotto Type - 650 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Meaty Risotto Type - 650 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Meaty Risotto Type - 650 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Meaty Risotto Type - 650 Credits Have Blue Ice")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Meaty Risotto Type - 650 Credits Have Blue Ice")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Meaty Risotto Type - 650 Credits Have Blue Ice")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Bergen Ice Cream Type/Buy A 'Bergen Ice Cream' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Bergen Ice Cream Type - 450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Bergen Ice Cream Type - 450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Bergen Ice Cream Type - 450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Bergen Ice Cream Type - 450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Bergen Ice Cream Type - 450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Bergen Ice Cream Type - 450 Credits Have Red Flame")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Bergen Ice Cream Type - 450 Credits Have Red Flame")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Sweet Lemonjuice Type/Buy A 'Sweet Lemonjuice' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Sweet Lemonjuice Type - 450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Sweet Lemonjuice Type - 450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Sweet Lemonjuice Type - 450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Sweet Lemonjuice Type - 450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Sweet Lemonjuice Type - 450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Sweet Lemonjuice Type - 450 Credits Have Red Flame")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Sweet Lemonjuice Type - 450 Credits Have Red Flame")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Bergen Trail/Bergen Trail - Hermit Shop \n(Discounts if 'Heating the Hermit' Finished)/Sweet Lemonjuice Type - 2199 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Salted Peanuts Type/Buy A 'Salted Peanuts' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Salted Peanuts Type - 450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Salted Peanuts Type - 450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Salted Peanuts Type - 450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Salted Peanuts Type - 450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Salted Peanuts Type - 450 Credits Have Green Seed")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Salted Peanuts Type - 450 Credits Have Green Seed")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Salted Peanuts Type - 450 Credits Have Green Seed")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Cup o' Coffee Type/Buy A 'Cup o' Coffee' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Cup o' Coffee Type - 450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Cup o' Coffee Type - 450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Cup o' Coffee Type - 450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Cup o' Coffee Type - 450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Cup o' Coffee Type - 450 Credits Have Green Seed")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Cup o' Coffee Type - 450 Credits Have Green Seed")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Cup o' Coffee Type - 450 Credits Have Green Seed")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Snack Mix Type/Buy A 'Snack Mix' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Snack Mix Type - 450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Snack Mix Type - 450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Snack Mix Type - 450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Snack Mix Type - 450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Snack Mix Type - 450 Credits Have Green Seed")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Snack Mix Type - 450 Credits Have Green Seed")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Snack Mix Type - 450 Credits Have Green Seed")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Bronze Goggles Type/Buy A 'Bronze Goggles' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Weapon Shop/Bronze Goggles Type - 850 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Bronze Edge Type/Buy A 'Bronze Edge' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Weapon Shop/Bronze Edge Type - 800 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Bronze Mail Type/Buy A 'Bronze Mail' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Weapon Shop/Bronze Mail Type - 900 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Bronze Boots Type/Buy A 'Bronze Boots' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Weapon Shop/Bronze Boots Type - 850 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Iron Goggles Type/Buy A 'Iron Goggles' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Weapon Shop/Iron Goggles Type - 4700 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Weapon Shop/Iron Goggles Type - 4700 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Iron Goggles Type - 4700 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Iron Edge Type/Buy A 'Iron Edge' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Weapon Shop/Iron Edge Type - 4500 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Weapon Shop/Iron Edge Type - 4500 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Iron Edge Type - 4500 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Iron Mail Type/Buy A 'Iron Mail' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Weapon Shop/Iron Mail Type - 4800 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Weapon Shop/Iron Mail Type - 4800 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Iron Mail Type - 4800 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Iron Boots Type/Buy A 'Iron Boots' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Weapon Shop/Iron Boots Type - 4700 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Weapon Shop/Iron Boots Type - 4700 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Iron Boots Type - 4700 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Silver Goggles Type/Buy A 'Silver Goggles' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Silver Goggles Type - 29450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Silver Goggles Type - 29450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Silver Goggles Type - 29450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Weapon Shop/Silver Goggles Type - 29450 Credits Have Red Flame")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Silver Edge Type/Buy A 'Silver Edge' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Silver Edge Type - 29375 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Silver Edge Type - 29375 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Silver Edge Type - 29375 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Weapon Shop/Silver Edge Type - 29375 Credits Have Red Flame")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Silver Mail Type/Buy A 'Silver Mail' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Silver Mail Type - 29725 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Silver Mail Type - 29725 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Silver Mail Type - 29725 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Weapon Shop/Silver Mail Type - 29725 Credits Have Red Flame")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Silver Boots Type/Buy A 'Silver Boots' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Silver Boots Type - 29450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Silver Boots Type - 29450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Silver Boots Type - 29450 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Weapon Shop/Silver Boots Type - 29450 Credits Have Red Flame")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Steel Goggles Type/Buy A 'Steel Goggles' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Steel Goggles Type - 15850 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Steel Goggles Type - 15850 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Steel Goggles Type - 15850 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Steel Edge Type/Buy A 'Steel Edge' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Steel Edge Type - 15800 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Steel Edge Type - 15800 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Steel Edge Type - 15800 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Steel Mail Type/Buy A 'Steel Mail' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Steel Mail Type - 16100 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Steel Mail Type - 16100 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Steel Mail Type - 16100 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Steel Boots Type/Buy A 'Steel Boots' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Steel Boots Type - 15950 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Steel Boots Type - 15950 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Steel Boots Type - 15950 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Rising Super Star Type/Buy A 'Rising Super Star' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Rising Super Star Type - 7777 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Backer Chef Shop/Rising Super Star Type - 7777 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Dk Pepper Type/Buy A 'Dk Pepper' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Dk Pepper Type - 7777 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Backer Chef Shop/Dk Pepper Type - 7777 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Cheese Spaetzle Type/Buy A 'Cheese Spaetzle' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Cheese Spaetzle Type - 7777 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Backer Chef Shop/Cheese Spaetzle Type - 7777 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Maultasche Type/Buy A 'Maultasche' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Maultasche Type - 7777 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Backer Chef Shop/Maultasche Type - 7777 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Durian Type/Buy A 'Durian' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Durian Type - 7777 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Backer Chef Shop/Durian Type - 7777 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/PengoPop Type/Buy A 'PengoPop' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/PengoPop Type - 7777 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Backer Chef Shop/PengoPop Type - 7777 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Spicy Beat-0-Type Type/Buy A 'Spicy Beat-0-Type' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Spicy Beat-0-Type Type - 7777 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Backer Chef Shop/Spicy Beat-0-Type Type - 7777 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Werewolf Stick Type/Buy A 'Werewolf Stick' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Werewolf Stick Type - 7777 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Backer Chef Shop/Werewolf Stick Type - 7777 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Mooncake Type/Buy A 'Mooncake' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Mooncake Type - 7777 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Backer Chef Shop/Mooncake Type - 7777 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Guacamole Toast Type/Buy A 'Guacamole Toast' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Guacamole Toast Type - 9999 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Backer Chef Shop/Guacamole Toast Type - 9999 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Willis Waldmahl Type/Buy A 'Willis Waldmahl' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Willis Waldmahl Type - 7777 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Backer Chef Shop/Willis Waldmahl Type - 7777 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Pumpkin Spiced Coffee Type/Buy A 'Pumpkin Spiced Coffee' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Pumpkin Spiced Coffee Type - 7777 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Backer Chef Shop/Pumpkin Spiced Coffee Type - 7777 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Chili Con Carne Type/Buy A 'Chili Con Carne' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Bergen Trail/Bergen Trail - Hermit Shop \n(Discounts if 'Heating the Hermit' Finished)/Chili Con Carne Type - 1099 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Sweet Berry Tea Type/Buy A 'Sweet Berry Tea' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Bergen Trail/Bergen Trail - Hermit Shop \n(Discounts if 'Heating the Hermit' Finished)/Sweet Berry Tea Type - 3299 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Titan Goggles Type/Buy A 'Titan Goggles' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Titan Goggles Type - 46750 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Weapon Shop/Titan Goggles Type - 46750 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Titan Edge Type/Buy A 'Titan Edge' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Titan Edge Type - 46475 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Weapon Shop/Titan Edge Type - 46475 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Titan Mail Type/Buy A 'Titan Mail' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Titan Mail Type - 46925 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Weapon Shop/Titan Mail Type - 46925 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Titan Boots Type/Buy A 'Titan Boots' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Titan Boots Type - 46750 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Weapon Shop/Titan Boots Type - 46750 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/One Up Type/Buy A 'One Up' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Calzone Shop After 'Mushroom Kingdom'/One Up Type - 60000 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Cobalt Goggles Type/Buy A 'Cobalt Goggles' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Weapon Shop/Cobalt Goggles Type - 71350 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Weapon Shop/Cobalt Goggles Type - 71350 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Cobalt Edge Type/Buy A 'Cobalt Edge' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Weapon Shop/Cobalt Edge Type - 70975 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Weapon Shop/Cobalt Edge Type - 70975 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Cobalt Mail Type/Buy A 'Cobalt Mail' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Weapon Shop/Cobalt Mail Type - 71925 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Weapon Shop/Cobalt Mail Type - 71925 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Cobalt Boots Type/Buy A 'Cobalt Boots' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Weapon Shop/Cobalt Boots Type - 71350 Credits")
        objItem.Highlight = highlight_code
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Weapon Shop/Cobalt Boots Type - 71350 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Laser Goggles Type/Buy A 'Laser Goggles' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Weapon Shop/Laser Goggles Type - 104750 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Laser Edge Type/Buy A 'Laser Edge' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Weapon Shop/Laser Edge Type - 104500 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Laser Mail Type/Buy A 'Laser Mail' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Weapon Shop/Laser Mail Type - 105000 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Laser Boots Type/Buy A 'Laser Boots' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Weapon Shop/Laser Boots Type - 104750 Credits")
        objItem.Highlight = highlight_code
    elseif location_code == "@Shop Types/Chest Detector Type/Buy A 'Chest Detector' From Any Item Shop" then
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Curio Shop/Chest Detector Type - 33333 Credits")
        objItem.Highlight = highlight_code
    end
end

function manualHostedItems(location_id)
    if location_id == 3235824345 then
        local objItem = Tracker:FindObjectForCode("botanics-1")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824377 then
        local objItem = Tracker:FindObjectForCode("AR-First")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824386 then
        local objItem = Tracker:FindObjectForCode("AR-parkour")
        if objItem then
            objItem.Active = true
        end        

    elseif location_id == 3235824381 then
        local objItem = Tracker:FindObjectForCode("AR-TB-done")
        if objItem then
            objItem.Active = true
        end
        
    elseif location_id == 3235824382 then
        local objItem = Tracker:FindObjectForCode("AR-TB-collect")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824383 then
        local objItem = Tracker:FindObjectForCode("AR-TB-defeat")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824384 then
        local objItem = Tracker:FindObjectForCode("AR-TB-poi")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824385 then
        local objItem = Tracker:FindObjectForCode("AR-TB-probe")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824391 then
        local objItem = Tracker:FindObjectForCode("BT-TB-done")
        if objItem then
            objItem.Active = true
        end        

    elseif location_id == 3235824392 then
        local objItem = Tracker:FindObjectForCode("BT-TB-collect")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824393 then
        local objItem = Tracker:FindObjectForCode("BT-TB-defeat")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824394 then
        local objItem = Tracker:FindObjectForCode("BT-TB-poi")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824395 then
        local objItem = Tracker:FindObjectForCode("BT-TB-probe")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824398 then
        local objItem = Tracker:FindObjectForCode("BT-bunny")
        if objItem then
            objItem.Active = true
        end        

    elseif location_id == 3235824518 then
        local objItem = Tracker:FindObjectForCode("RH-steaks-1")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824520 then
        local objItem = Tracker:FindObjectForCode("RH-steaks-2")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824496 then
        local objItem = Tracker:FindObjectForCode("RH-petty")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824498 then
        local objItem = Tracker:FindObjectForCode("RH-smuggle-1")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824487 then
        local objItem = Tracker:FindObjectForCode("RH-master")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824488 then
        local objItem = Tracker:FindObjectForCode("RH-vrp")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824489 then
        local objItem = Tracker:FindObjectForCode("RH-vpi")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824494 then
        local objItem = Tracker:FindObjectForCode("RH-power-points")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824500 then
        local objItem = Tracker:FindObjectForCode("RH-smuggle-2")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824507 then
        local objItem = Tracker:FindObjectForCode("RH-metal")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824514 then
        local objItem = Tracker:FindObjectForCode("RH-fire-bull")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824521 then
        local objItem = Tracker:FindObjectForCode("RH-steaks-3")
        if objItem then
            objItem.Active = true
        end       

    elseif location_id == 3235824517 then
        local objItem = Tracker:FindObjectForCode("dkar1")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824502 then
        local objItem = Tracker:FindObjectForCode("RH-delivery")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824504 then
        local objItem = Tracker:FindObjectForCode("RH-Bull")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824491 then
        local objItem = Tracker:FindObjectForCode("RH-data-digging")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824492 then
        local objItem = Tracker:FindObjectForCode("RH-hillkat")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824509 then
        local objItem = Tracker:FindObjectForCode("RH-tree-1")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824511 then
        local objItem = Tracker:FindObjectForCode("RH-tree-2")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824440 then
        local objItem = Tracker:FindObjectForCode("MV-tree-done")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824375 then
        local objItem = Tracker:FindObjectForCode("botanics-3")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824441 then
        local objItem = Tracker:FindObjectForCode("MV-blasting")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824443 then
        local objItem = Tracker:FindObjectForCode("MV-hot-trail")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824446 then
        local objItem = Tracker:FindObjectForCode("MV-thief")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824450 then
        local objItem = Tracker:FindObjectForCode("MV-crate")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824452 then
        local objItem = Tracker:FindObjectForCode("MV-booze-1")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824453 then
        local objItem = Tracker:FindObjectForCode("MV-booze-2")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824454 then
        local objItem = Tracker:FindObjectForCode("dkar3")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824459 then
        local objItem = Tracker:FindObjectForCode("GG-hostage")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824473 then
        local objItem = Tracker:FindObjectForCode("GG-mush-1")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824474 then
        local objItem = Tracker:FindObjectForCode("GG-mush-2")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824463 then
        local objItem = Tracker:FindObjectForCode("GG-chill")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824467 then
        local objItem = Tracker:FindObjectForCode("GG-escort")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824455 then
        local objItem = Tracker:FindObjectForCode("GG-turret-1")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824457 then
        local objItem = Tracker:FindObjectForCode("GG-turret-2")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824475 then
        local objItem = Tracker:FindObjectForCode("GG-halloween")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824476 then
        local objItem = Tracker:FindObjectForCode("dkar4")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824376 then
        local objItem = Tracker:FindObjectForCode("botanics-4")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824374 then
        local objItem = Tracker:FindObjectForCode("botanics-2")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824418 then
        local objItem = Tracker:FindObjectForCode("BV-asp-trial")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824423 then
        local objItem = Tracker:FindObjectForCode("BV-asp-challenge")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824420 then
        local objItem = Tracker:FindObjectForCode("BV-prog-trial")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824426 then
        local objItem = Tracker:FindObjectForCode("BV-prog-challenge")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824403 then
        local objItem = Tracker:FindObjectForCode("BV-frobbits")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824405 then
        local objItem = Tracker:FindObjectForCode("BV-EX-mine")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824407 then
        local objItem = Tracker:FindObjectForCode("BV-pre-mine")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824409 then
        local objItem = Tracker:FindObjectForCode("BV-kidding")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824413 then
        local objItem = Tracker:FindObjectForCode("BV-hat")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824429 then
        local objItem = Tracker:FindObjectForCode("BV-omni-build")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824430 then
        local objItem = Tracker:FindObjectForCode("BV-omni-push")
        if objItem then
            objItem.Active = true
        end        

    elseif location_id == 3235824431 then
        local objItem = Tracker:FindObjectForCode("dkar2")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824352 then
        local objItem = Tracker:FindObjectForCode("fajroWon")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824477 then
        local objItem = Tracker:FindObjectForCode("GG-TB-done")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824478 then
        local objItem = Tracker:FindObjectForCode("GG-TB-collect")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824479 then
        local objItem = Tracker:FindObjectForCode("GG-TB-defeat")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824480 then
        local objItem = Tracker:FindObjectForCode("GG-TB-poi")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824481 then
        local objItem = Tracker:FindObjectForCode("GG-TB-probe")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824481 then
        local objItem = Tracker:FindObjectForCode("GG-TB-probe")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824461 then
        local objItem = Tracker:FindObjectForCode("GG-high-crating")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824466 then
        local objItem = Tracker:FindObjectForCode("GG-snowman")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824470 then
        local objItem = Tracker:FindObjectForCode("GG-rooting")
        if objItem then
            objItem.Active = true
        end
        
    elseif location_id == 3235824357 then
        local objItem = Tracker:FindObjectForCode("kryskajoWon")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824358 then
        local objItem = Tracker:FindObjectForCode("sonajizWon")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824356 then
        local objItem = Tracker:FindObjectForCode("zirvitarWon")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824349 then
        local objItem = Tracker:FindObjectForCode("minesWon")
        if objItem then
            objItem.Active = true
        end
        
    elseif location_id == 3235824435 then
        local objItem = Tracker:FindObjectForCode("MV-TB-done")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824436 then
        local objItem = Tracker:FindObjectForCode("MV-TB-collect")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824437 then
        local objItem = Tracker:FindObjectForCode("MV-TB-defeat")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824438 then
        local objItem = Tracker:FindObjectForCode("MV-TB-poi")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824439 then
        local objItem = Tracker:FindObjectForCode("MV-TB-probe")
        if objItem then
            objItem.Active = true
        end

    elseif location_id == 3235824484 then
        local objItem = Tracker:FindObjectForCode("dkar5")
        if objItem then
            objItem.Active = true
        end
    end
end

function manualShopTypes(location_id)
    local objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Sandwich Type - 100 Credits")

    if location_id == 3235824525 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Sandwich Type - 100 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Sandwich Type - 100 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Sandwich Type - 100 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Sandwich Type - 100 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Sandwich Type - 100 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Sandwich Type - 100 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Sandwich Type - 100 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Sandwich Type - 100 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Tara's Shop/Sandwich Type - 2500 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824527 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Hi-Sandwich Type - 300 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Hi-Sandwich Type - 300 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Hi-Sandwich Type - 300 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Hi-Sandwich Type - 300 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Hi-Sandwich Type - 300 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Hi-Sandwich Type - 300 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Hi-Sandwich Type - 300 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Hi-Sandwich Type - 300 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824529 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Green Leaf Tea Type - 250 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Green Leaf Tea Type - 250 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Green Leaf Tea Type - 250 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Green Leaf Tea Type - 250 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Green Leaf Tea Type - 250 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Green Leaf Tea Type - 250 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Green Leaf Tea Type - 250 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Green Leaf Tea Type - 250 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824531 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Just Water Type - 222 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Just Water Type - 222 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Just Water Type - 222 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Just Water Type - 222 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Just Water Type - 222 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Just Water Type - 222 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Just Water Type - 222 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Just Water Type - 222 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824533 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Spicy Bun Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Spicy Bun Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Spicy Bun Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Spicy Bun Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Spicy Bun Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Spicy Bun Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Spicy Bun Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Spicy Bun Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824535 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Fruit Drink Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Fruit Drink Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Fruit Drink Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Fruit Drink Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Fruit Drink Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Fruit Drink Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Fruit Drink Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Fruit Drink Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824537 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Rice Cracker Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Rice Cracker Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Rice Cracker Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Rice Cracker Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Rice Cracker Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Rice Cracker Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Rice Cracker Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Rice Cracker Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824539 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Veggie Sticks Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Veggie Sticks Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Veggie Sticks Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Veggie Sticks Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Veggie Sticks Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Veggie Sticks Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Veggie Sticks Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Veggie Sticks Type - 200 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824541 then
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Kebab Roll Type - 650 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Kebab Roll Type - 650 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Kebab Roll Type - 650 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Kebab Roll Type - 650 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Kebab Roll Type - 650 Credits Have Blue Ice")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Kebab Roll Type - 650 Credits Have Blue Ice")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Kebab Roll Type - 650 Credits Have Blue Ice")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824543 then
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Meaty Risotto Type - 650 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Meaty Risotto Type - 650 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Meaty Risotto Type - 650 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Meaty Risotto Type - 650 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Meaty Risotto Type - 650 Credits Have Blue Ice")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Meaty Risotto Type - 650 Credits Have Blue Ice")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Meaty Risotto Type - 650 Credits Have Blue Ice")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824545 then
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Bergen Ice Cream Type - 450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Bergen Ice Cream Type - 450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Bergen Ice Cream Type - 450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Bergen Ice Cream Type - 450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Bergen Ice Cream Type - 450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Bergen Ice Cream Type - 450 Credits Have Red Flame")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Bergen Ice Cream Type - 450 Credits Have Red Flame")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824547 then
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Sweet Lemonjuice Type - 450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Sweet Lemonjuice Type - 450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Sweet Lemonjuice Type - 450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Sweet Lemonjuice Type - 450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Sweet Lemonjuice Type - 450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Sweet Lemonjuice Type - 450 Credits Have Red Flame")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Sweet Lemonjuice Type - 450 Credits Have Red Flame")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Bergen Trail/Bergen Trail - Hermit Shop \n(Discounts if 'Heating the Hermit' Finished)/Sweet Lemonjuice Type - 2199 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824549 then
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Salted Peanuts Type - 450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Salted Peanuts Type - 450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Salted Peanuts Type - 450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Salted Peanuts Type - 450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Salted Peanuts Type - 450 Credits Have Green Seed")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Salted Peanuts Type - 450 Credits Have Green Seed")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Salted Peanuts Type - 450 Credits Have Green Seed")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824551 then
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Cup o' Coffee Type - 450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Cup o' Coffee Type - 450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Cup o' Coffee Type - 450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Cup o' Coffee Type - 450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Cup o' Coffee Type - 450 Credits Have Green Seed")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Cup o' Coffee Type - 450 Credits Have Green Seed")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Cup o' Coffee Type - 450 Credits Have Green Seed")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824553 then
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Snack Mix Type - 450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Vending Machine/Snack Mix Type - 450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Item Shop/Snack Mix Type - 450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Item Shop/Snack Mix Type - 450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Item Shop/Snack Mix Type - 450 Credits Have Green Seed")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Item Shop/Snack Mix Type - 450 Credits Have Green Seed")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Snack Mix Type - 450 Credits Have Green Seed")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824555 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Weapon Shop/Bronze Goggles Type - 850 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824557 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Weapon Shop/Bronze Edge Type - 800 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824559 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Weapon Shop/Bronze Mail Type - 900 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824561 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Weapon Shop/Bronze Boots Type - 850 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824563 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Weapon Shop/Iron Goggles Type - 4700 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Weapon Shop/Iron Goggles Type - 4700 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Iron Goggles Type - 4700 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824565 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Weapon Shop/Iron Edge Type - 4500 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Weapon Shop/Iron Edge Type - 4500 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Iron Edge Type - 4500 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824567 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Weapon Shop/Iron Mail Type - 4800 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Weapon Shop/Iron Mail Type - 4800 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Iron Mail Type - 4800 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824569 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Weapon Shop/Iron Boots Type - 4700 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Bergen Village/Bergen Village - Weapon Shop/Iron Boots Type - 4700 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Iron Boots Type - 4700 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824571 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Silver Goggles Type - 29450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Silver Goggles Type - 29450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Silver Goggles Type - 29450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Weapon Shop/Silver Goggles Type - 29450 Credits Have Red Flame")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824573 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Silver Edge Type - 29375 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Silver Edge Type - 29375 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Silver Edge Type - 29375 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Weapon Shop/Silver Edge Type - 29375 Credits Have Red Flame")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824575 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Silver Mail Type - 29725 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Silver Mail Type - 29725 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Silver Mail Type - 29725 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Weapon Shop/Silver Mail Type - 29725 Credits Have Red Flame")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824577 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Silver Boots Type - 29450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Silver Boots Type - 29450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Silver Boots Type - 29450 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Weapon Shop/Silver Boots Type - 29450 Credits Have Red Flame")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824579 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Steel Goggles Type - 15850 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Steel Goggles Type - 15850 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Steel Goggles Type - 15850 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824581 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Steel Edge Type - 15800 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Steel Edge Type - 15800 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Steel Edge Type - 15800 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824583 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Steel Mail Type - 16100 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Steel Mail Type - 16100 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Steel Mail Type - 16100 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824585 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Steel Boots Type - 15950 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Ba'kii Kum/Ba'kii Kum - Weapon & Item Shop/Steel Boots Type - 15950 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Vermillion Wasteland/Vermillion Wasteland - Weapon & Item Shop/Steel Boots Type - 15950 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824592 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Rising Super Star Type - 7777 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Backer Chef Shop/Rising Super Star Type - 7777 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824594 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Dk Pepper Type - 7777 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Backer Chef Shop/Dk Pepper Type - 7777 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824596 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Cheese Spaetzle Type - 7777 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Backer Chef Shop/Cheese Spaetzle Type - 7777 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824598 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Maultasche Type - 7777 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Backer Chef Shop/Maultasche Type - 7777 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824600 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Durian Type - 7777 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Backer Chef Shop/Durian Type - 7777 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824602 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/PengoPop Type - 7777 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Backer Chef Shop/PengoPop Type - 7777 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824604 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Spicy Beat-0-Type Type - 7777 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Backer Chef Shop/Spicy Beat-0-Type Type - 7777 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824606 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Werewolf Stick Type - 7777 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Backer Chef Shop/Werewolf Stick Type - 7777 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824608 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Mooncake Type - 7777 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Backer Chef Shop/Mooncake Type - 7777 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824610 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Guacamole Toast Type - 9999 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Backer Chef Shop/Guacamole Toast Type - 9999 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824612 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Willis Waldmahl Type - 7777 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Backer Chef Shop/Willis Waldmahl Type - 7777 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824614 then
        objItem = Tracker:FindObjectForCode("@Rookie Harbor/Rookie Harbor - Backer Weapon & Chef Shop/Pumpkin Spiced Coffee Type - 7777 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Backer Chef Shop/Pumpkin Spiced Coffee Type - 7777 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824635 then
        objItem = Tracker:FindObjectForCode("@Bergen Trail/Bergen Trail - Hermit Shop \n(Discounts if 'Heating the Hermit' Finished)/Chili Con Carne Type - 1099 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824638 then
        objItem = Tracker:FindObjectForCode("@Bergen Trail/Bergen Trail - Hermit Shop \n(Discounts if 'Heating the Hermit' Finished)/Sweet Berry Tea Type - 3299 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824697 then
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Titan Goggles Type - 46750 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Weapon Shop/Titan Goggles Type - 46750 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824699 then
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Titan Edge Type - 46475 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Weapon Shop/Titan Edge Type - 46475 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824701 then
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Titan Mail Type - 46925 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Weapon Shop/Titan Mail Type - 46925 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824703 then
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Weapon & Item Shop/Titan Boots Type - 46750 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Weapon Shop/Titan Boots Type - 46750 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824705 then
        objItem = Tracker:FindObjectForCode("@Basin Keep/Basin Keep - Calzone Shop After 'Mushroom Kingdom'/One Up Type - 60000 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824711 then
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Weapon Shop/Cobalt Goggles Type - 71350 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Weapon Shop/Cobalt Goggles Type - 71350 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824713 then
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Weapon Shop/Cobalt Edge Type - 70975 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Weapon Shop/Cobalt Edge Type - 70975 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824715 then
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Weapon Shop/Cobalt Mail Type - 71925 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Weapon Shop/Cobalt Mail Type - 71925 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824717 then
        objItem = Tracker:FindObjectForCode("@Sapphire Ridge/Sapphire Ridge - Cave Inn Weapon Shop/Cobalt Boots Type - 71350 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Weapon Shop/Cobalt Boots Type - 71350 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824734 then
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Weapon Shop/Laser Goggles Type - 104750 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824736 then
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Weapon Shop/Laser Edge Type - 104500 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824738 then
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Weapon Shop/Laser Mail Type - 105000 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824740 then
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Weapon Shop/Laser Boots Type - 104750 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    elseif location_id == 3235824757 then
        objItem = Tracker:FindObjectForCode("@Rhombus Square/Rhombus Square - Curio Shop/Chest Detector Type - 33333 Credits")
        objItem.AvailableChestCount = objItem.AvailableChestCount - 1
    end
end

-- add AP callbacks
-- un-/comment as needed
Archipelago:AddClearHandler("clear handler", onClear)
Archipelago:AddItemHandler("item handler", onItem)
Archipelago:AddLocationHandler("location handler", onLocation)
-- Archipelago:AddScoutHandler("scout handler", onScout)
-- Archipelago:AddBouncedHandler("bounce handler", onBounce)
Archipelago:AddSetReplyHandler("set reply handler", onSetReply)
Archipelago:AddRetrievedHandler("retrieved", retrieved)