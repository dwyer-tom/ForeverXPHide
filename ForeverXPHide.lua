local ADDON_NAME = ...

local DEFAULT_ENABLED = true
local hookedFrame

local function Print(message)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99ForeverXPHide|r: " .. message)
    end
end

local function GetExperienceBarFrame()
    local manager = StatusTrackingBarManager
    local barInfo = StatusTrackingBarInfo

    if not manager or not manager.barContainers
        or not barInfo or not barInfo.BarsEnum
        or barInfo.BarsEnum.Experience == nil then
        return nil
    end

    local mainContainer = manager.barContainers[1]
    if not mainContainer or not mainContainer.bars then
        return nil
    end

    local experienceBar = mainContainer.bars[barInfo.BarsEnum.Experience]
    if not experienceBar or not experienceBar.StatusBar then
        return nil
    end

    local statusBarParent = experienceBar.StatusBar:GetParent()
    if not statusBarParent then
        return nil
    end

    -- This is the outer 1192x17 frame verified against the WoW Forever UI.
    return statusBarParent:GetParent()
end

local function ApplyPreference()
    if not ForeverXPHideDB or not ForeverXPHideDB.enabled then
        return false
    end

    local frame = GetExperienceBarFrame()
    if not frame then
        return false
    end

    -- Re-attach if the client replaces the frame during UI initialisation.
    if hookedFrame ~= frame then
        frame:HookScript("OnShow", function(shownFrame)
            if ForeverXPHideDB and ForeverXPHideDB.enabled then
                shownFrame:Hide()
            end
        end)
        hookedFrame = frame
    end

    frame:Hide()
    return true
end

local function SetEnabled(enabled)
    ForeverXPHideDB.enabled = enabled and true or false

    if ForeverXPHideDB.enabled then
        local applied = ApplyPreference()
        if applied then
            Print("XP bar hidden. This preference is saved.")
        else
            Print("Preference saved; waiting for the XP bar to become available.")
        end
    else
        local frame = GetExperienceBarFrame()
        if frame then
            frame:Show()
        end
        Print("XP bar shown. This preference is saved.")
    end
end

local function InitializeDatabase()
    if type(ForeverXPHideDB) ~= "table" then
        ForeverXPHideDB = {}
    end

    if ForeverXPHideDB.enabled == nil then
        ForeverXPHideDB.enabled = DEFAULT_ENABLED
    end
end

local function RegisterSlashCommands()
    SLASH_FOREVERXPHIDE1 = "/xphide"
    SLASH_FOREVERXPHIDE2 = "/foreverxphide"

    SlashCmdList.FOREVERXPHIDE = function(message)
        local command = (message or ""):lower():match("^%s*(.-)%s*$")

        if command == "on" then
            SetEnabled(true)
        elseif command == "off" then
            SetEnabled(false)
        elseif command == "toggle" or command == "" then
            SetEnabled(not ForeverXPHideDB.enabled)
        elseif command == "status" then
            Print("XP bar hiding is " .. (ForeverXPHideDB.enabled and "enabled." or "disabled."))
        elseif command == "help" then
            Print("/xphide on - hide the XP bar")
            Print("/xphide off - show the XP bar")
            Print("/xphide toggle - toggle hiding")
            Print("/xphide status - show the saved setting")
            Print("/xphide help - show this help")
        else
            Print("Unknown command. Use /xphide help.")
        end
    end
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    InitializeDatabase()
    RegisterSlashCommands()

    -- The tracking bar can be created after ADDON_LOADED. Retry briefly
    -- after PLAYER_ENTERING_WORLD until its frame is available.
    local elapsedSinceAttempt = 0
    local retryFrame = CreateFrame("Frame")
    retryFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    retryFrame:SetScript("OnEvent", function(self)
        elapsedSinceAttempt = 0
        self:SetScript("OnUpdate", function(updateFrame, elapsed)
            elapsedSinceAttempt = elapsedSinceAttempt + elapsed
            if elapsedSinceAttempt < 0.25 then
                return
            end
            elapsedSinceAttempt = 0

            if ApplyPreference() then
                updateFrame:SetScript("OnUpdate", nil)
                updateFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
            end
        end)
    end)
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", OnAddonLoaded)
