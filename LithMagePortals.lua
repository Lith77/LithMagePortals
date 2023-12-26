-- Author: Lith
-- Description: A little frame for your portals
local playerClass = select(2, UnitClass("player"))

if playerClass ~= "MAGE" then
    print("|cFF69CCF0Lith Mage portals: |cFFBCCF02is a Mage only addon, |cFFF0563Dnot loaded")
    return;
end
local LithMagePortalsFrame
local PortalFrame
local TeleportFrame
local teleportButtons = {}
local portalButtons = {}
local knownTeleportButtons = {}
local knownPortalButtons = {}
local knownTeleports = false;
local knownPortals = false;
local colorR, colorG, colorB = GetClassColor("MAGE");

local teleportSpells = {
        ["Teleport_Stormwind"] = 3561,
        ["Teleport_Ironforge"] = 3562,
        ["Teleport_Darnassus"] = 3565,
        ["Teleport_Exodar"] = 32271,
        ["Teleport_Orgrimmar"] = 3567,
        ["Teleport_Undercity"] = 3563,
        ["Teleport_Thunder Bluff"] = 3566,
        ["Teleport_Silvermoon"] = 32266,
        ["Teleport_Shattrath"] = 35715,
        ["Teleport_Dalaran"] = 53140,
    }

local portalSpells = {
        ["Portal_Stormwind"] = 10059,
        ["Portal_Ironforge"] = 11416,
        ["Portal_Darnassus"] = 32266,
        ["Portal_Exodar"] = 32267,
        ["Portal_Orgrimmar"] = 11417,
        ["Portal_Undercity"] = 11418,
        ["Portal_Thunder Bluff"] = 11420,
        ["Portal_Silvermoon"] = 32271,
        ["Portal_Shattrath"] = 35717,
        ["Portal_Dalaran"] = 53142,
    }

-- Function to create a teleport button
local function CreateTeleportButton(name, spellID)
    local _, _, texture = GetSpellInfo(spellID)
    local button = CreateFrame("Button", name, TeleportFrame, "SecureActionButtonTemplate")
    button:SetSize(30, 30)
    local normalTexture = button:CreateTexture(nil, "ARTWORK")
    normalTexture:SetAllPoints()
    normalTexture:SetTexture(texture)
    button:SetNormalTexture(normalTexture)
    button:SetPoint("TOPLEFT", TeleportFrame, "TOPLEFT", 0, 0)

    -- Set the spell to be cast when the button is clicked
    button:SetAttribute("type", "spell")
    button:SetAttribute("spell", GetSpellInfo(spellID))
    
    -- Set the spellID as an attribute of the button
    button.spellID = spellID

    -- Create tooltip for the button
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(GetSpellInfo(spellID))
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return button
end

-- Function to create a portal button
local function CreatePortalButton(name, spellID)
    local _, _, texture = GetSpellInfo(spellID)
    local button = CreateFrame("Button", name, PortalFrame, "SecureActionButtonTemplate")
    button:SetSize(30, 30)
    local normalTexture = button:CreateTexture(nil, "ARTWORK")
    normalTexture:SetAllPoints()
    normalTexture:SetTexture(texture)
    button:SetNormalTexture(normalTexture)
    button:SetPoint("TOPLEFT", PortalFrame, "TOPLEFT", 0, 0)

    -- Set the spell to be cast when the button is clicked
    button:SetAttribute("type", "spell")
    button:SetAttribute("spell", GetSpellInfo(spellID))
    
    -- Set the spellID as an attribute of the button
    button.spellID = spellID

    -- Create tooltip for the button
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(GetSpellInfo(spellID))
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return button
end

-- Function to create teleport buttons for all spells
local function CreateAllTeleportButtons()
    local teleportSpellNames = {}
    for spellName, _ in pairs(teleportSpells) do
        table.insert(teleportSpellNames, spellName)
    end
    table.sort(teleportSpellNames)  -- Sort the spell names alphabetically
    
    for _, spellName in ipairs(teleportSpellNames) do
        local spellID = teleportSpells[spellName]
        local button = CreateTeleportButton(spellName, spellID)
        button:Hide()  -- Initially hide all buttons
        table.insert(teleportButtons, button)
    end
end

-- Function to create portal buttons for all spells
local function CreateAllPortalButtons()
    local portalSpellNames = {}
    for spellName, _ in pairs(portalSpells) do
        table.insert(portalSpellNames, spellName)
    end
    table.sort(portalSpellNames)  -- Sort the spell names alphabetically
    
    for _, spellName in ipairs(portalSpellNames) do
        local spellID = portalSpells[spellName]
        local button = CreatePortalButton(spellName, spellID)
        button:Hide()  -- Initially hide all buttons
        table.insert(portalButtons, button)
    end
end
-- Function to show/hide teleport buttons based on known spells
local function UpdateTeleportButtons()
    local numRows = 3  -- Number of rows in the grid
    local numCols = 3  -- Number of columns in the grid
    local buttonSize = 30  -- Size of each button
    local buttonSpacing = 5  -- Spacing between buttons
    
    local shownButtons = 0  -- Count of shown buttons
    for _, button in ipairs(teleportButtons) do
        local spellID = button.spellID
        if spellID and IsSpellKnown(spellID) then
            local row = math.floor(shownButtons / numCols)  -- Calculate the row
            local col = shownButtons % numCols  -- Calculate the column

            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", TeleportFrame, "TOPLEFT", col * (buttonSize + buttonSpacing) +5, -row * (buttonSize + buttonSpacing) -8)
            button:Show()
            shownButtons = shownButtons + 1
            knownTeleports = true;
        else
            button:Hide()
        end
    end
    -- Calculate the frame size based on the number of shown buttons
    local numRows = math.ceil(shownButtons / numCols)
    local frameWidth = numCols * buttonSize + (numCols - 1) * buttonSpacing +10
    local frameHeight = numRows * buttonSize + (numRows - 1) * buttonSpacing +10

    TeleportFrame:SetSize(frameWidth, frameHeight)
end

-- Function to show/hide portal buttons based on known spells
local function UpdatePortalButtons()
    local numRows = 3  -- Number of rows in the grid
    local numCols = 3  -- Number of columns in the grid
    local buttonSize = 30  -- Size of each button
    local buttonSpacing = 5  -- Spacing between buttons

    local shownButtons = 0  -- Count of shown buttons
    for _, button in ipairs(portalButtons) do
        local spellID = button.spellID
        if spellID and IsSpellKnown(spellID) then
            local row = math.floor(shownButtons / numCols)  -- Calculate the row
            local col = shownButtons % numCols  -- Calculate the column

            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", PortalFrame, "TOPLEFT", col * (buttonSize + buttonSpacing) +5, -row * (buttonSize + buttonSpacing) -8)
            button:Show()
            shownButtons = shownButtons + 1
            knownPortals = true;
        else
            button:Hide()
        end
    end
    -- Calculate the frame size based on the number of shown buttons
    local numRows = math.ceil(shownButtons / numCols)
    local frameWidth = numCols * buttonSize + (numCols - 1) * buttonSpacing +13
    local frameHeight = numRows * buttonSize + (numRows - 1) * buttonSpacing +13

    PortalFrame:SetSize(frameWidth, frameHeight)
end

-- Function to toggle the main LithMagePortalsFrame
local function ToggleFrame()
    if LithMagePortalsFrame and LithMagePortalsFrame:IsVisible() then
        LithMagePortalsFrame:Hide()
    else
        LithMagePortalsFrame:Show()
    end
end

-- Function to toggle the teleport LithMagePortalsFrame
local function ToggleTeleportFrame()
    if TeleportFrame and TeleportFrame:IsVisible() then
        TeleportFrame:Hide()
    else
        TeleportFrame:Show()
    end
end

-- Function to toggle the portal LithMagePortalsFrame
local function TogglePortalFrame()
    if PortalFrame and PortalFrame:IsVisible() then
        PortalFrame:Hide()
    else
        PortalFrame:Show()
    end
end

-- Function to create the teleport frame with specified dimensions
local function CreateTeleportFrame(frameWidth, frameHeight)
    TeleportFrame = CreateFrame("Frame", "LithMageTeleportFrame", LithMagePortalsFrame, "BackdropTemplate")
    TeleportFrame:SetSize(frameWidth, frameHeight)
    TeleportFrame:SetPoint("TOPRIGHT", LithMagePortalsFrame, "TOPLEFT", 0, 0)

    -- Create teleport buttons within the frame
    CreateAllTeleportButtons()

    -- Determine the frame size based on the number of buttons
    local numButtons = #teleportButtons
    local frameWidth = 30 -- Initial width
    local frameHeight = numButtons * 30 + (numButtons - 1) * 5 -- 30x30 buttons with 5px spacing

    TeleportFrame:SetSize(frameWidth, frameHeight)

    -- Add a black background and border to LithMageTeleportFrame
    TeleportFrame:SetBackdrop(nil)
    TeleportFrame:SetBackdropColor(0, 0, 0, .75) -- 80% black background
    local topLine = TeleportFrame:CreateTexture(nil, "OVERLAY")
    topLine:SetHeight(3)
    topLine:SetPoint("TOPLEFT", TeleportFrame, "TOPLEFT", 1,-1)
    topLine:SetPoint("TOPRIGHT", TeleportFrame, "TOPRIGHT",-1,-1)
    topLine:SetColorTexture(colorR, colorG, colorB, .75)
    local background = TeleportFrame:CreateTexture(nil, "BACKGROUND")
    background:SetPoint("TOPLEFT", TeleportFrame, "TOPLEFT", 1,-1)
    background:SetPoint("BOTTOMRIGHT", TeleportFrame, "BOTTOMRIGHT",-1,1)
    --background:SetAllPoints(TeleportFrame)
    background:SetColorTexture(0, 0, 0, .5)
end

-- Function to create the portal frame with specified dimensions
local function CreatePortalFrame(frameWidth, frameHeight)
    PortalFrame = CreateFrame("Frame", "LithMagePortalFrame", LithMagePortalsFrame, "BackdropTemplate")
    PortalFrame:SetSize(frameWidth, frameHeight)
    PortalFrame:SetPoint("TOPLEFT", LithMagePortalsFrame, "TOPRIGHT", 0, 0)

    -- Create portal buttons within the frame
    CreateAllPortalButtons()

    -- Determine the frame size based on the number of buttons
    local numButtons = #portalButtons
    local frameWidth = 30 -- Initial width
    local frameHeight = numButtons * 30 + (numButtons - 1) * 5 -- 30x30 buttons with 5px spacing

    PortalFrame:SetSize(frameWidth, frameHeight)

    -- Add a black background and border to LithMagePortalFrame
    PortalFrame:SetBackdrop(nil)
    PortalFrame:SetBackdropColor(0, 0, 0, .75) -- 80% black background
    local topLine = PortalFrame:CreateTexture(nil, "OVERLAY")
    topLine:SetHeight(3)
    topLine:SetPoint("TOPLEFT", PortalFrame, "TOPLEFT", 1,-1)
    topLine:SetPoint("TOPRIGHT", PortalFrame, "TOPRIGHT",-1,-1)
    topLine:SetColorTexture(colorR, colorG, colorB, .75)
    local background = PortalFrame:CreateTexture(nil, "BACKGROUND")
    background:SetPoint("TOPLEFT", PortalFrame, "TOPLEFT", 1,-1)
    background:SetPoint("BOTTOMRIGHT", PortalFrame, "BOTTOMRIGHT",-1,1)
    --background:SetAllPoints(PortalFrame)
    background:SetColorTexture(0, 0, 0, .5)
end

-- Create a LithMagePortalsFrame to hold the buttons
LithMagePortalsFrame = CreateFrame("Frame", "LithMagePortalsFrame", UIParent, "BackdropTemplate")
LithMagePortalsFrame:SetSize(75, 42)
LithMagePortalsFrame:SetPoint("CENTER")

-- Tooltip for the LithMagePortalsFrame
LithMagePortalsFrame:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText("Alt+Drag to Move")
    GameTooltip:Show()
end)

LithMagePortalsFrame:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
LithMagePortalsFrame:SetBackdrop(nil)
LithMagePortalsFrame:SetBackdropColor(nil)
-- Create a blue line at the top
local topLine = LithMagePortalsFrame:CreateTexture(nil, "OVERLAY")
topLine:SetHeight(3)
topLine:SetPoint("TOPLEFT", LithMagePortalsFrame, "TOPLEFT", 1,-1)
topLine:SetPoint("TOPRIGHT", LithMagePortalsFrame, "TOPRIGHT",-1,-1)
topLine:SetColorTexture(colorR, colorG, colorB, .75)
local background = LithMagePortalsFrame:CreateTexture(nil, "BACKGROUND")
background:SetPoint("TOPLEFT", LithMagePortalsFrame, "TOPLEFT", 1,-5)
background:SetPoint("BOTTOMRIGHT", LithMagePortalsFrame, "BOTTOMRIGHT",-1,1)
background:SetColorTexture(0, 0, 0, .5)

LithMagePortalsFrame:SetBackdropBorderColor(0, 0, 0, .25)

-- Create teleport and portal frames with specified dimensions
CreateTeleportFrame(30, 30) -- Set the dimensions you desire for the teleport frame
CreatePortalFrame(30, 30)   -- Set the dimensions you desire for the portal fram
TeleportFrame:Hide()
PortalFrame:Hide()

-- Create teleport button
local teleportButton = CreateFrame("Button", "TeleportButton", LithMagePortalsFrame)
teleportButton:SetSize(30, 30)
teleportButton:SetPoint("LEFT", 5, -2)
teleportButton:SetNormalTexture("Interface\\Icons\\Spell_Arcane_TeleportStormwind")
teleportButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
teleportButton:SetScript("OnClick", function()
    ToggleTeleportFrame()
end)

teleportButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText("Teleports") -- Set the tooltip text
    GameTooltip:Show()
end)

teleportButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Create portal button
local portalButton = CreateFrame("Button", "PortalButton", LithMagePortalsFrame)
portalButton:SetSize(30, 30)
portalButton:SetPoint("RIGHT", -5, -2)
portalButton:SetNormalTexture("Interface\\Icons\\Spell_Arcane_PortalStormwind")
portalButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
portalButton:SetScript("OnClick", function()
    TogglePortalFrame()
end)

portalButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText("Portals") -- Set the tooltip text
    GameTooltip:Show()
end)

portalButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Save the LithMagePortalsFrame's position on move
LithMagePortalsFrame:EnableMouse(true)
LithMagePortalsFrame:SetMovable(true)
LithMagePortalsFrame:RegisterForDrag("LeftButton")
LithMagePortalsFrame:SetScript("OnDragStart", function(self)
    if IsAltKeyDown() then
        self:StartMoving()
    end
end)

LithMagePortalsFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

-- Register for the "LEARNED_SPELL_IN_TAB" event to handle newly learned spells
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("LEARNED_SPELL_IN_TAB")
eventFrame:SetScript("OnEvent", function(self, event, tabIndex, spellID)
    -- Check if the newly learned spell is a teleport or portal spell and show it
    UpdateTeleportButtons()
    UpdatePortalButtons()
    if not (knownPortals and knownTeleports) then
        LithMagePortalsFrame:Hide()
    else
        LithMagePortalsFrame:Show()
    end

end)

local loginFrame = CreateFrame("Frame")
loginFrame:RegisterEvent("PLAYER_LOGIN")
loginFrame:SetScript("OnEvent", function(self, event)
    UpdateTeleportButtons()
    UpdatePortalButtons()
    print("knownPortals", knownPortals, "knownTeleports", knownTeleports)
    if not (knownPortals and knownTeleports) then
        LithMagePortalsFrame:Hide()
    else
        LithMagePortalsFrame:Show()
    end

    print("|cFF69CCF0Lith Mage portals: |cFFBCCF02loaded")
end)
