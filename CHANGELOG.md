# Changelog
0.4.2
    Locations

        - Added Vermillion Wasteland Storage Basement Chest (Removed visibility_rule that had been in place forever)

    Interface

        - Pathhacker Quest icon image corrected

        - Omni-Gliders Basement Chest icon image corrected

        - Lost Shrine now uses U1/U2 instead of B1/B2 to match maps

        - Fixed discrepencies with Faj'ro Test of Memory Rooms. Now clearly named Left/Right Room.

        - Added a period to some characters titles (Mrs. Summers)

    Logic

        - Outside Grand Krys'kajo Chest now requires correct Shades

        - Outside So'najiz Chest no longer requires Wave

        - Omni-Gliders Basement Chest now requires access to Mines and either Heat or a key

        - Sprouting Business Quest now requires Wave

        - Infested Caverns Left Chest now requires correct key

        - Fixed requirements for Training with the Master Quest. Now only needs Flame Shade and Quest Rando

    Known (Being Investigated)

        - Some quests sometimes aren't being auto-tracked on slot release. Typically only the last quests in quest-trains are being tracked

        - Some Location Icons and Text not behaving correctly on slot release

0.4.1

    Fixed Location IDs

    Added Keyring Setting

    Changed Boss Reward icons to match new icons on VTGate

    Fixed Logic for some Dungeons and Quests

    Added Vermillion Wasteland Lock Setting

    Added SP Upgrade Locations and Chest related to Pushing Bases Quest

    Fixed PNG issues for Linux users

    Fixed Faj'ro Temple having 2 checks reversed (GF Test of Memory)

    Added setup for Linux users to Readme

0.4.0

    Fixed Frobbit Quest Autotracking

    Added Quest Shuffle Support 

        - Added Quest Locations

        - Added Quest Setting

        - Added Quest Logic

        - Added Hosted Items related to quests

        - Added Broken Items to item grid for D'Kar questline

        - Moved some locations to better fit for quests

        - Added mapping for quest locations to autotracking script

    Added new locations related to "always on" quests  

        - Added locations for Cursed Temple in Maroon Valley

        - Added locations for Lost Shrine in Gaia's Garden

        - Made Quest "Sprouting Business" always enabled due to requirement for "Mushroom Kingdom"

        - Added locations for chests unlocked during " Mushroom Kingdom" 

    Logic Fixes 

        - Added Heat Requirement for Maroon Cave

        - Added Shock Requirement for Carved Pathway Lower

        - Added Wave requirement for Royal Grove Lower Right

    Fixed some chests having mismatched IDs

    Added Images for Chests, Statues, Elements and Quests

    Changed Gaia Garden Map to include extra locations

0.3.5

    Fixed Logic for areas below 
    
    - Sapphire Ridge 

        - Carved pathway south section - added shock requirement for bronze chest and silver chest

        - High Ground - added shock for both checks

        - The Bellow - Added Wave requirement

        - Wheel Passage - Removed Shock requirement for gold chest

    - Vermillion Wasteland -

        - Spiral Cliff - Added Heat and Cold requirements for Virus fights to gain access to both chests

    - Rhombus Square -

        - Arena Exterior - Added Wave requirement for silver chest

    - Temple Mine

        - U4 logic updated to require Thief Key and Heat
    
    - Gaia's Garden

        - Added requirement for Heat and Cold to get past the entrances of So'najiz and Zir'vitar

        - Fixed logic for Peridot Approach Silver Chest needing Wave

    - Zir'vitar

        Changed logic for Moving Transmit Left to require Wave

    Fixed hosted items not clearing with autotracking

    Fixed World Map Variant not having settings and new dungeon layouts

0.3.4

    Added hosted items for bosses to work with VT Gate Option

    Added settings field and place Open Mode and VT Gate labels

    Added shades to dungeons to indicate completion of dungeon

    Fixed some locations in autotracker script

    Added autotracking for settings through slot_data

0.3.3Dev

    Fixed missing region for Vermillion Wastes

0.3.2Dev

    Added Map and locations for Vermillion Wasteland

    Updated Location IDs for autotracker mapping

    Made Residential District viewable now it is included in the location pool

0.3.1Dev

    Added hosted items for dungeon completion

    Added Vermillion Tower to world map for visibility of Go Mode

    Added logic for Vermillion Tower

    Fixed some locations not using Open Mode logic

0.3.0Dev

    Added map for chamber of ice and moved it from Faj'ro 1f - Right Chamber 1

    Added open Mode Logic

    Move Overrides to correct locations

    Switched Marshes South Upper locations as they were postioned opposite

    Fixed some locations not showing on world map

    Added placeholder locations for Quest Shuffle (not viewable on tracker until needed)

    Misc Cleanup

0.2.1

    Fixed So'najiz Keys not Autotracking

    Fixed Locations on Autumn's Rise not Autotracking

    Fixed Krys'kajo Master Key not Autotracking

    Made Residential District Chests hidden as Rando currently does not shuffle them

0.2.0

    Added AP Autotracking

0.1.1

    Fixed Temple Mine being in logic with just Mine Keys

    Made Falling Exit Chest require Flame Shade

    Fixed logic for Lofty Heights, now requires Element Heat

0.1.0

    Initial Release
