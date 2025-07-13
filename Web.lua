repeat wait() until game.CoreGui:FindFirstChild('RobloxPromptGui')

local lp,po,ts = game:GetService('Players').LocalPlayer,game.CoreGui.RobloxPromptGui.promptOverlay,game:GetService('TeleportService')

po.ChildAdded:connect(function(a)
    if a.Name == 'ErrorPrompt' then
        repeat
            ts:Teleport(game.PlaceId)
            wait(2)
        until false
    end
end)


local bb = game:GetService('VirtualUser')
local Players = game:GetService('Players')

Players.LocalPlayer.Idled:Connect(function()
    bb:CaptureController()
    bb:ClickButton2(Vector2.new())
    if ab then
        ab.Text = "You went idle and ROBLOX tried to kick you but we reflected it!"
        task.wait(2)
        ab.Text = "Script Re-Enabled"
    end
end)

local seedsToMonitor = {
    "Carrot", "Strawberry", "Blueberry", "Orange Tulip", "Tomato", "Daffodil",
    "Watermelon", "Pumpkin", "Apple", "Bamboo", "Coconut", "Cactus", "Dragon Fruit",
    "Mango", "Grape", "Mushroom", "Pepper", "Cacao", "Beanstalk", "Ember Lily",
    "Sugar Apple", "Burning Bud"
}

local gearsToMonitor = {
    "Advanced Sprinkler", "Basic Sprinkler", "Cleaning Spray", "Favorite Tool", "Friendship Pot", "Godly Sprinkler",
    "Harvest Tool", "Levelup Lollipop", "Magnifying Glass", "Master Sprinkler", "Medium Toy", "Medium Treat", "Recall Wrench",
    "Tanning Mirror", "Trowel", "Watering Can"
}

local channelToken = "LJhin0MVfYPA3EsTv8lAAYTVdHAr35ToVtcGFT03ShvByslB5wHXlvEGmuaw0FmthrQQYBvsnRA9CzOCzkKTgqilrcof7+ZZdU+Z+6qUprjZdoYAeBEynjdYGiDZvxgnJwx2jwCsRHopP0OApsbCMgdB04t89/1O/w1cDnyilFU="

local userIds = {
    "Uc04421c89ce6df255a999fac7e25ed0b",
    "Ue4801642cb03ba4b016ddb0d7bf6a371"
}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local seedsToMonitorSet = {}
for _, seedName in ipairs(seedsToMonitor) do
    seedsToMonitorSet[seedName] = true
end

local gearsToMonitorSet = {}
for _, gearName in ipairs(gearsToMonitor) do
    gearsToMonitorSet[gearName] = true
end

local http_request = http_request or request
if not http_request then
    error("HTTP request function not found!")
end

function SendLineMessage(message, imageUrl)
    local headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer " .. channelToken
    }

    for _, userId in ipairs(userIds) do
        local data = {
            to = userId,
            messages = {
                {
                    type = "text",
                    text = message
                }
            }
        }

        if imageUrl then
            table.insert(data.messages, {
                type = "image",
                originalContentUrl = imageUrl,
                previewImageUrl = imageUrl
            })
        end

        local body = HttpService:JSONEncode(data)

        local success, response = pcall(function()
            return http_request({
                Url = "https://api.line.me/v2/bot/message/push",
                Method = "POST",
                Headers = headers,
                Body = body
            })
        end)

        if not success then
            warn("Failed to send message to " .. userId)
        end
    end
end

function CheckAvailableSeeds()
    local player = Players.LocalPlayer
    if not player or not player.PlayerGui then
        return
    end

    local seedShop = player.PlayerGui:FindFirstChild("Seed_Shop")
    if not seedShop then
        return
    end

    local scrollingFrame = seedShop.Frame:FindFirstChild("ScrollingFrame")
    if not scrollingFrame then
        return
    end

    local frames = scrollingFrame:GetChildren()
    local availableSeeds = {}

    for _, item in ipairs(frames) do
        local seedName = item.Name
        if seedsToMonitorSet[seedName] then
            local mainFrame = item:FindFirstChild("Main_Frame")
            local costTextLabel = mainFrame and mainFrame:FindFirstChild("Cost_Text")

            if costTextLabel and costTextLabel.Text ~= "NO STOCK" then
                table.insert(availableSeeds, seedName)
            end
        end
    end

    if #availableSeeds > 0 then
        local message = "🌱 Seed ที่เข้ามาขาย:\n" .. table.concat(availableSeeds, "\n")
        local imageUrl = "https://cdn.discordapp.com/attachments/1255167690645962823/1393904233639841843/content.png?ex=6874ddfa&is=68738c7a&hm=96c3e5a4f8c11e00026e8507b09ef36f1912aa76b617eae128f6fd2e343b3469&"
        SendLineMessage(message, imageUrl)
    end
end

function CheckAvailableGears()
    local player = Players.LocalPlayer
    if not player or not player.PlayerGui then
        return
    end

    local gearShop = player.PlayerGui:FindFirstChild("Gear_Shop")
    if not gearShop then
        return
    end

    local scrollingFrame = gearShop.Frame:FindFirstChild("ScrollingFrame")
    if not scrollingFrame then
        return
    end

    local frames = scrollingFrame:GetChildren()
    local availableGears = {}

    for _, item in ipairs(frames) do
        local gearName = item.Name
        if gearsToMonitorSet[gearName] then
            local mainFrame = item:FindFirstChild("Main_Frame")
            local costTextLabel = mainFrame and mainFrame:FindFirstChild("Cost_Text")

            if costTextLabel and costTextLabel.Text ~= "NO STOCK" then
                table.insert(availableGears, gearName)
            end
        end
    end

    if #availableGears > 0 then
        local message = "🛠️ Gear ที่เข้ามาขาย:\n" .. table.concat(availableGears, "\n")
        local imageUrl = "https://cdn.discordapp.com/attachments/1255167690645962823/1393902125280399410/image.png?ex=6874dc04&is=68738a84&hm=14eda8d6168af6517f5bdaafa4b9ad4321bb56bf3ca5a5297ebcb88c118d5fb3&"
        SendLineMessage(message, imageUrl)
    end
end

function MonitorTimers()
    local player = Players.LocalPlayer
    if not player or not player.PlayerGui then
        return
    end

    local seedShop = player.PlayerGui:FindFirstChild("Seed_Shop")
    local gearShop = player.PlayerGui:FindFirstChild("Gear_Shop")

    if seedShop then
        local seedTimer = seedShop.Frame.Frame:FindFirstChild("Timer")
        if seedTimer then
            if string.match(seedTimer.Text, "New seeds in 4m 59s") then
                CheckAvailableSeeds()
            end
        end
    end

    if gearShop then
        local gearTimer = gearShop.Frame.Frame:FindFirstChild("Timer")
        if gearTimer then
            if string.match(gearTimer.Text, "New gear in 4m 59s") then
                CheckAvailableGears()
            end
        end
    end
end

task.spawn(function()
    while true do
        MonitorTimers()
        task.wait()
    end
end)
