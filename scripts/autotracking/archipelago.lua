-- this is an example/ default implementation for AP autotracking
-- it will use the mappings defined in item_mapping.lua and location_mapping.lua to track items and locations via thier ids
-- it will also load the AP slot data in the global SLOT_DATA, keep track of the current index of on_item messages in CUR_INDEX
-- addition it will keep track of what items are local items and which one are remote using the globals LOCAL_ITEMS and GLOBAL_ITEMS
-- this is useful since remote items will not reset but local items might
ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")

CUR_INDEX = -1
SLOT_DATA = nil
LOCAL_ITEMS = {}
GLOBAL_ITEMS = {}


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
            obj.CurrentStage = slot_data['options']['questRando']
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
        if slot_data['options']["keyrings"][0] then 
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
    if not v and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: could not find location mapping for id %s", location_id))
    end
    if not v[1] then
        return
    end
    local obj = Tracker:FindObjectForCode(v[1])
    if obj then
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
        print(string.format("called onScout: %s, %s, %s, %s, %s", location_id, location_name, item_id, item_name,
            item_player))
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

-- add AP callbacks
-- un-/comment as needed
Archipelago:AddClearHandler("clear handler", onClear)
Archipelago:AddItemHandler("item handler", onItem)
Archipelago:AddLocationHandler("location handler", onLocation)
-- Archipelago:AddScoutHandler("scout handler", onScout)
-- Archipelago:AddBouncedHandler("bounce handler", onBounce)