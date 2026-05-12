local variant = Tracker.ActiveVariantUID

--LOADED SCRIPTS
ScriptHost:LoadScript("scripts/logic.lua")

--LOAD ITEMS
Tracker:AddItems("items/items.json")
Tracker:AddItems("items/hosted_quests.json")

-- Open Maps, Then Layouts, Then Locations

if (string.find(Tracker.ActiveVariantUID, "items_only")) then
    Tracker:AddLayouts("layouts/items_only.json")
    Tracker:AddLayouts("layouts/broadcast_horizontal.json")
elseif (string.find(Tracker.ActiveVariantUID, "world_map")) then
    Tracker:AddMaps("maps/maps.json")
    Tracker:AddLayouts("layouts/tracker_worldmap.json")
    Tracker:AddLayouts("layouts/broadcast_horizontal.json")
    Tracker:AddLocations("locations/bergenTrail.json")
    Tracker:AddLocations("locations/bergenVillage.json")
    Tracker:AddLocations("locations/gaiaGarden.json")
    Tracker:AddLocations("locations/maroonValley.json")
    Tracker:AddLocations("locations/bakiiKum.json")
    Tracker:AddLocations("locations/basinKeep.json")
    Tracker:AddLocations("locations/rhombusSquare.json")
    Tracker:AddLocations("locations/autumnsRise.json")
    Tracker:AddLocations("locations/sapphireRidge.json")
    Tracker:AddLocations("locations/autumnsFall.json")
    Tracker:AddLocations("locations/rookieHarbor.json")
    Tracker:AddLocations("locations/templeMine.json")
    Tracker:AddLocations("locations/fajroTemple.json")
    Tracker:AddLocations("locations/sonajizTemple.json")
    Tracker:AddLocations("locations/zirvitarTemple.json")
    Tracker:AddLocations("locations/grandKryskajo.json")
    Tracker:AddLocations("locations/vermillionWastes.json")
    Tracker:AddLocations("locations/homestedt.json")
    Tracker:AddLocations("locations/azureArchipelago.json")
    Tracker:AddLocations("locations/kuleroTemple.json")
    Tracker:AddLocations("locations/botanics.json")
elseif (string.find(Tracker.ActiveVariantUID,"map_tracker")) then
    Tracker:AddMaps("maps/maps.json")
    Tracker:AddLayouts("layouts/tracker_standard.json")
    Tracker:AddLayouts("layouts/broadcast_horizontal.json")
    Tracker:AddLayouts("layouts/shop_layout.json")
    Tracker:AddLocations("locations/bergenTrail.json")
    Tracker:AddLocations("locations/bergenVillage.json")
    Tracker:AddLocations("locations/gaiaGarden.json")
    Tracker:AddLocations("locations/maroonValley.json")
    Tracker:AddLocations("locations/bakiiKum.json")
    Tracker:AddLocations("locations/basinKeep.json")
    Tracker:AddLocations("locations/rhombusSquare.json")
    Tracker:AddLocations("locations/autumnsRise.json")
    Tracker:AddLocations("locations/sapphireRidge.json")
    Tracker:AddLocations("locations/autumnsFall.json")
    Tracker:AddLocations("locations/rookieHarbor.json")
    Tracker:AddLocations("locations/templeMine.json")
    Tracker:AddLocations("locations/fajroTemple.json")
    Tracker:AddLocations("locations/sonajizTemple.json")
    Tracker:AddLocations("locations/zirvitarTemple.json")
    Tracker:AddLocations("locations/grandKryskajo.json")
    Tracker:AddLocations("locations/vermillionWastes.json")
    Tracker:AddLocations("locations/shopSlots.json")
    Tracker:AddLocations("locations/shopTypes.json")
    Tracker:AddLocations("locations/homestedt.json")
    Tracker:AddLocations("locations/azureArchipelago.json")
    Tracker:AddLocations("locations/kuleroTemple.json")
    Tracker:AddLocations("locations/botanics.json")
end

-- Autotracking AP
if PopVersion and PopVersion >= "0.25.0" then
    ScriptHost:LoadScript("scripts/autotracking.lua")
end