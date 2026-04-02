local CONFIG = {
    RetryCount = 1,           -- How many times to retry if it fails
    RetryDelay = 1,           -- Seconds to wait before retry
    Timeout = 8,              -- Max time to wait for HttpGet
    Verbose = true            -- Set to false to hide messages
}

local SUPPORTED_GAMES = {
    {
        Name = "bLockerman's Minesweeper",
        PlaceIDs = {7871169780},
        ScriptURL = "https://raw.githubusercontent.com/DozeIsOkLol/WHP/refs/heads/main/G/7871169780.lua"
    },
    {
        Name = "Silent Assassins",
        PlaceIDs = {103854444055060},
        ScriptURL = "https://raw.githubusercontent.com/DozeIsOkLol/WHP/refs/heads/main/G/103854444055060.lua"
    },
    {
        Name = "RAGEBAIT and waddle away",
        PlaceIDs = {128287244953761},
        ScriptURL = "https://raw.githubusercontent.com/DozeIsOkLol/WHP/refs/heads/main/G/128287244953761.lua"
    },
    {
        Name = "Universal",
        IsUniversal = true,
        ScriptURL = ""
    }
}

-- Simple function to get script with retry
local function fetchScript(url)
    for attempt = 1, CONFIG.RetryCount + 1 do
        if CONFIG.Verbose then
            print("➡️ Trying to load from: " .. url .. " (Attempt " .. attempt .. ")")
        end
        
        local success, result = pcall(function()
            return game:HttpGet(url, true)
        end)
        
        if success then
            if CONFIG.Verbose then
                print("✅ Script Loaded successfully!")
            end
            return result
        else
            if CONFIG.Verbose then
                warn("⚠️ Attempt " .. attempt .. " failed: " .. tostring(result))
            end
            if attempt <= CONFIG.RetryCount then
                task.wait(CONFIG.RetryDelay)
            end
        end
    end
    
    return nil
end

-- Find which game we're in
local function getGameData()
    local placeId = game.PlaceId
    
    for _, game in ipairs(SUPPORTED_GAMES) do
        if game.IsUniversal then
            return game
        end
        
        local ids = typeof(game.PlaceIDs) == "table" and game.PlaceIDs or {game.PlaceIDs}
        for _, id in ipairs(ids) do
            if id == placeId then
                return game
            end
        end
    end
    
    return nil
end

-- Main loader
local function loadScript()
    local gameData = getGameData()
    
    if not gameData then
        if CONFIG.Verbose then
            print("🔹 This game is not supported.")
        end
        return
    end
    
    if CONFIG.Verbose then
        print("🎮 Supported game found: " .. gameData.Name)
    end
    
    local scriptContent = fetchScript(gameData.ScriptURL)
    
    if scriptContent then
        local success, err = pcall(loadstring(scriptContent))
        if success then
            if CONFIG.Verbose then
                print("✔️ " .. gameData.Name .. " loaded successfully!")
            end
        else
            warn("❌ Failed to execute script: " .. tostring(err))
        end
    else
        warn("❌ Could not download the script for " .. gameData.Name)
    end
end

-- Start the loader
task.spawn(loadScript)
