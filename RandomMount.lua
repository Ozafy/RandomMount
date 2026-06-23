local AddonName, AddonNS = ...

local mountFrame = CreateFrame("Frame",nil,UIParent);

local debug = false

local Mounts = {
    2411, --Black Stallion Bridle
    2414, --Pinto Bridle
    5655, --Chestnut Mare Bridle
    5656, -- Brown Horse Bridle
    18776, --Swift Palomino
    18777, --Swift Brown Steed
    18778, --Swift White Steed
    5864, --Gray Ram
    5872, --Brown Ram
    5873, --White Ram
    18785, --Swift White Ram
    18786, --Swift Brown Ram
    18787, --Swift Gray Ram
    8629, -- Reins of the Striped Nightsaber
    8631, -- Reins of the Striped Frostsaber
    8632, -- Reins of the Spotted Frostsaber
    18766, -- Reins of the Swift Frostsaber
    18767, -- Reins of the Swift Mistsaber
    18902, -- Reins of the Swift Stormsaber
    8595, -- Blue Mechanostrider
    8563, -- Red Mechanostrider
    13321, -- Green Mechanostrider
    13322, -- Unpainted Mechanostrider
    18772, -- Swift Green Mechanostrider
    18773, -- Swift White Mechanostrider
    18774, -- Swift Yellow Mechanostrider
    18241, -- Black War Steed Bridle
    18242, -- Reins of the Black War Tiger
    18243, -- Black Battlestrider
    18244, -- Black War Ram
    19030, -- Stormpike Battle Charger
    13086, -- Reins of the Winterspring Frostsaber
    5668, -- Horn of the Brown Wolf
    5665, -- Horn of the Dire Wolf
    1132, -- Horn of the Timber Wolf
    18796, -- Horn of the Swift Brown Wolf
    18797, -- Horn of the Swift Timber Wolf
    18798, -- Horn of the Swift Gray Wolf
    13331, -- Red Skeletal Horse
    13332, -- Blue Skeletal Horse
    13333, -- Brown Skeletal Horse
    13334, -- Green Skeletal Warhorse
    18791, -- Purple Skeletal Warhorse
    15277, -- Gray Kodo
    15290, -- Brown Kodo
    18793, -- Great White Kodo
    18794, -- Great Brown Kodo
    18795, -- Great Gray Kodo
    8588, -- Whistle of the Emerald Raptor
    8591, -- Whistle of the Turquoise Raptor
    8592, -- Whistle of the Violet Raptor
    18788, -- Swift Blue Raptor
    18789, -- Swift Olive Raptor
    18790, -- Swift Orange Raptor
    13335, -- Deathcharger's Reins
    19872, -- Swift Razzashi Raptor
    19902, -- Swift Zulian Tiger
    21176, -- Black Qiraji Resonating Crystal
}

local AQ_Mounts = {
    21218, --Blue Qiraji Resonating Crystal
    21323, --Green Qiraji Resonating Crystal
    21324, --Yellow Qiraji Resonating Crystal
    21321, --Red Qiraji Resonating Crystal
}


local playerMounts = {

}
local playerAQMounts = {
    
}

local function printDebug(...)
    if debug then
        print(...)
    end
end

local function tableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

local function GetRandomMount(mounts)
    local numberOfMounts = tableLength(mounts)
    if numberOfMounts > 0 then
        return mounts[math.random(numberOfMounts)]
    end
    return nil
end

local function UpdateMacro(dismount)
    if dismount and IsMounted() then
        Dismount()
        return
    end
    printDebug("Updating macro with player mounts...")
    local aqMountMacro = ""
    local aqMountId = GetRandomMount(playerAQMounts)
    if aqMountId~=nil then
        local name, _, _, _, _, _, _, _, _, _, _, classId, subclassID = GetItemInfo(tonumber(aqMountId))
        aqMountMacro = "\n/cast [@player,group:raid] " .. name
    end

    local mountMacro = ""
    local mountId = GetRandomMount(playerMounts)
    if mountId~=nil then
        local name, _, _, _, _, _, _, _, _, _, _, classId, subclassID = GetItemInfo(tonumber(mountId))
        mountMacro = "\n/cast [@player] " .. name
    end

    local body = "#showtooltip\n/randommount m" .. aqMountMacro .. mountMacro
    EditMacro("RandomMount", "RandomMount", "ability_mount_charger", body, 1, 1)
end

local function FindInBagSlot(bags, itemId)
   for _, bag in ipairs(bags) do
      for slot=1, C_Container.GetContainerNumSlots(bag) do
         local itemID = C_Container.GetContainerItemID(bag, slot)
         if itemID == itemId then
            return true
         end
      end
   end
   return false
end

local function FindMountsInBags()
    playerMounts = {}
    playerAQMounts = {}
    local bagSlots = {
    }
    for bag=0, NUM_BAG_SLOTS do
        table.insert(bagSlots, bag)
    end
    for i, mount in ipairs(Mounts) do
        if FindInBagSlot(bagSlots, mount) then
            printDebug("Found mount in bag: " .. mount)
            table.insert(playerMounts, mount)
        end
    end
    for i, mount in ipairs(AQ_Mounts) do
        if FindInBagSlot(bagSlots, mount) then
            printDebug("Found AQ mount in bag: " .. mount)
            table.insert(playerAQMounts, mount)
        end
    end
end

local function PrintMounts()
    print("Player Mounts:")
    for i, mount in ipairs(playerMounts) do
        print(mount)
    end
    print("Player AQ Mounts:")
    for i, mount in ipairs(playerAQMounts) do
        print(mount)
    end
end

function CreateMacroIfNotExists()
    if GetMacroIndexByName("RandomMount") == 0 then
        CreateMacro("RandomMount", "INV_Misc_QuestionMark")
    end
    UpdateMacro()
end

mountFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(2, function()
            FindMountsInBags()
            CreateMacroIfNotExists()
        end)
    end
end)

mountFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

SLASH_RANDOMMOUNT1 = "/randommount"
SlashCmdList.RANDOMMOUNT = function(msg, ...)
    if msg == "l" then
        PrintMounts()
    elseif msg == "u" then
        print("Updating mounts...")
        FindMountsInBags()
    elseif msg == "m" then
        UpdateMacro(true)
    else
        print("Usage: /randommount l to list mounts, /randommount u to update mounts, /randommount m to update macro")
    end
end
