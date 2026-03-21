--================================================================================--
-- CONFIGURATION
--================================================================================--

local CONFIG = {
    RetryCount = 2,
    BaseRetryDelay = 0.5,
    HttpGetTimeout = 5,
    Verbose = true
}

local SUPPORTED_GAMES = {
    {
        Name = "Flick",
        PlaceIDs = 136801880565837
        ScriptURLs = {
            "https://raw.githubusercontent.com/DozeIsOkLol/SouljaWare/refs/heads/main/129119196465909/Main.lua"
        }
    },
    {
        Name = "N/A",
        IsUniversal = true,
        ScriptURLs = {
            "N/A"
        }
    }
}

--================================================================================--
-- CORE FUNCTIONS
--================================================================================--

local function fetchScript(urls, retries, timeout, baseDelay)
    local errors = {}

    for i = 1, #urls do
        local url = urls[i]

        for attempt = 1, retries + 1 do
            local success, result = pcall(function()
                return game:HttpGet(url)
            end)

            if success and type(result) == "string" then
                _G.SOULJAWARE_LAST_URL = url
                return result
            else
                table.insert(errors, "Attempt " .. attempt .. " failed on URL #" .. i)

                if attempt <= retries then
                    wait(baseDelay * (2 ^ (attempt - 1)))
                end
            end
        end
    end

    return nil, table.concat(errors, "\n")
end

local function findGameByPlaceId(placeId)
    local universal = nil

    for _, data in ipairs(SUPPORTED_GAMES) do
        if data.IsUniversal then
            universal = data
        else
            local ids = type(data.PlaceIDs) == "table" and data.PlaceIDs or { data.PlaceIDs }
            for _, id in ipairs(ids) do
                if id == placeId then
                    return data
                end
            end
        end
    end

    return universal
end

local function loadScript()
    local gameData = findGameByPlaceId(game.PlaceId)
    if not gameData then return end

    local urls = type(gameData.ScriptURLs) == "table" and gameData.ScriptURLs or { gameData.ScriptURLs }
    local source = fetchScript(urls, CONFIG.RetryCount, CONFIG.HttpGetTimeout, CONFIG.BaseRetryDelay)
    if not source then return end

    _G.SOULJAWARE_EXECUTION = {
        ScriptName = gameData.Name,
        PlaceId = game.PlaceId,
        ScriptURL = urls[1],
        IsUniversal = gameData.IsUniversal == true
    }

    local fn = loadstring(source)
    if fn then
        fn()
    end
end

--================================================================================--
-- EXECUTION
--================================================================================--

spawn(loadScript)
