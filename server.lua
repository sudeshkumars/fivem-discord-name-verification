local BotToken = "" 
local GuildId = "" 
local webhookUrl = "" 

-- Define bypass roles by their IDs
local bypassRoles = { ""} -- Replace with actual role IDs

-- Define bypass users by their Discord IDs
local bypassUsers = { "123456789012345678"} -- Replace with actual Discord IDs

-- Function to normalize names (remove spaces and convert to lowercase)
local function normalizeName(name)
    return name:gsub("%s+", ""):lower()
end

-- Function to fetch Discord data (roles and nickname)
local function fetchDiscordData(discordId)
    local response = nil

    -- Perform HTTP request to Discord API
    PerformHttpRequest("https://discord.com/api/v10/guilds/" .. GuildId .. "/members/" .. discordId, function(statusCode, data, headers)
        if statusCode == 200 then
            local success, result = pcall(json.decode, data) -- Safely decode JSON
            if success and result then
                local roles = result.roles or {}
                local nickname = result.nick or result.user.username
                response = { nickname = nickname, roles = roles }
            else
                print("Error: Failed to decode Discord API response.")
                response = { error = "Failed to decode Discord API response." }
            end
        else
            print("HTTP Request to Discord API failed with status code: " .. statusCode)
            response = { error = "HTTP Request failed with status code: " .. statusCode }
        end
    end, "GET", "", { ["Authorization"] = "Bot " .. BotToken })

    -- Wait for the response
    while response == nil do
        Wait(0)
    end

    return response
end

-- Function to check if the user has a bypass role by ID
local function hasBypassRole(userRoles)
    for _, role in ipairs(userRoles) do
        for _, bypassRole in ipairs(bypassRoles) do
            if role == bypassRole then
                return true
            end
        end
    end
    return false
end

-- Function to check if the user is in the bypass list by Discord ID
local function isBypassUser(discordId)
    for _, bypassUserId in ipairs(bypassUsers) do
        if discordId == bypassUserId then
            return true
        end
    end
    return false
end

-- Function to send logs to Discord
local function sendDiscordLog(title, description, color, discordId)
    local embed = {
        title = title,
        description = description,
        color = color or 16711680, 
        footer = {
            text = "Made by Dubblu | " .. os.date("%Y-%m-%d %H:%M:%S"), 
            icon_url = "" 
        }
    }

    if discordId then
        embed.description = ("<@%s>\n%s"):format(discordId, description)
    end

    PerformHttpRequest(webhookUrl, function(statusCode, data, headers)
        if statusCode ~= 204 then
            print("Failed to send log to Discord. Status code: " .. statusCode)
        end
    end, "POST", json.encode({ embeds = { embed } }), { ["Content-Type"] = "application/json" })
end

-- Event handler for player connecting
AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    deferrals.defer()
    local src = source
    local discordId
    local identifiers = GetPlayerIdentifiers(src)

    -- Extract Discord ID from player identifiers
    for _, id in ipairs(identifiers) do
        if string.find(id, "discord:") then
            discordId = string.sub(id, 9) 
            break
        end
    end

    -- If Discord ID is not found, reject the connection
    if not discordId then
        local reason = "Make sure your Discord is running in the background and linked to FiveM."
        deferrals.done(reason)
        sendDiscordLog("❌ Connection Rejected", ("**Player:** %s\n**Endpoint:** %s\n**Reason:** %s"):format(playerName, GetPlayerEndpoint(src), reason), 16711680) 
        return
    end

    -- Check if the user is in the bypass list
    if isBypassUser(discordId) then
        deferrals.done() 
        sendDiscordLog("✅ Connection Approved (Bypass)", ("**Player:** %s\n**Endpoint:** %s\n**Reason:** User Bypass"):format(playerName, GetPlayerEndpoint(src)), 65280, discordId) 
        return
    end

    -- Fetch Discord data (nickname and roles)
    local discordData = fetchDiscordData(discordId)

    -- If Discord data contains an error, reject the connection
    if discordData.error then
        local reason = "Failed to fetch your Discord data. Contact support."
        deferrals.done(reason)
        sendDiscordLog("❌ Connection Rejected", ("**Player:** %s\n**Endpoint:** %s\n**Reason:** %s"):format(playerName, GetPlayerEndpoint(src), reason), 16711680, discordId) 
        return
    end

    local discordNickname = discordData.nickname
    local discordRoles = discordData.roles

    -- Check if the user has a bypass role by ID
    if hasBypassRole(discordRoles) then
        deferrals.done() 
        sendDiscordLog("✅ Connection Approved (Bypass)", ("**Player:** %s\n**Endpoint:** %s\n**Reason:** Role Bypass"):format(playerName, GetPlayerEndpoint(src)), 65280, discordId) 
        return
    end

    -- Normalize names and check if they match
    if normalizeName(playerName) ~= normalizeName(discordNickname) then
        local reason = ("Your Fivem name (%s) does not match your Discord nickname (%s). --Copy this name [Select and Ctrl + C]"):format(playerName, discordNickname)
        deferrals.done(reason)
        sendDiscordLog("❌ Connection Rejected", ("**Player:** %s\n**Endpoint:** %s\n**Reason:** %s"):format(playerName, GetPlayerEndpoint(src), reason), 16711680, discordId) 
        return
    end

    -- Allow the connection
    deferrals.done()
    sendDiscordLog("✅ Connection Approved", ("**Player:** %s\n**Endpoint:** %s"):format(playerName, GetPlayerEndpoint(src)), 65280, discordId) 
end)