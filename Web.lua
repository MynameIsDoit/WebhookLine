-- Wait for the Roblox Prompt GUI to be available
repeat task.wait() until game:GetService('CoreGui'):FindFirstChild('RobloxPromptGui')

-- Services
local Players = game:GetService('Players')
local TeleportService = game:GetService('TeleportService')
local VirtualUser = game:GetService('VirtualUser')
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService('CoreGui')

-- Local Player
local LocalPlayer = Players.LocalPlayer

-- Anti-AFK Kick
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    
    -- Create a simple notification on screen
    local notifyGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    local notifyLabel = Instance.new("TextLabel", notifyGui)
    notifyLabel.Size = UDim2.new(1, 0, 0, 50)
    notifyLabel.Position = UDim2.new(0, 0, 0, -50)
    notifyLabel.BackgroundColor3 = Color3.new(0, 0, 0)
    notifyLabel.BackgroundTransparency = 0.5
    notifyLabel.TextColor3 = Color3.new(1, 1, 1)
    notifyLabel.FontSize = Enum.FontSize.Size24
    notifyLabel.Text = "You went idle, but we prevented the kick!"
    
    task.wait(3)
    notifyGui:Destroy()
end)

-- Error Handling (e.g., disconnected from server)
local promptOverlay = CoreGui.RobloxPromptGui.promptOverlay
promptOverlay.ChildAdded:connect(function(child)
    if child.Name == 'ErrorPrompt' then
        -- Teleport once to the same place to attempt reconnection. Avoid infinite loops.
        TeleportService:Teleport(game.PlaceId)
    end
end)

-- Configuration for LINE Notify
local channelToken = "LJhin0MVfYPA3EsTv8lAAYTVdHAr35ToVtcGFT03ShvByslB5wHXlvEGmuaw0FmthrQQYBvsnRA9CzOCzkKTgqilrcof7+ZZdU+Z+6qUprjZdoYAeBEynjdYGiDZvxgnJwx2jwCsRHopP0OApsbCMgdB04t89/1O/w1cDnyilFU="
local userIds = {
    "Uc04421c89ce6df255a999fac7e25ed0b",
    "Ue4801642cb03ba4b016ddb0d7bf6a371",
    "U41dab69261906d9caffa4c89509c34a2",
    "U44009be1d8fb1a100833e0200dd049b0"
}

-- Items to Monitor
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

-- Convert arrays to sets for faster lookups
local seedsToMonitorSet = {}
for _, seedName in ipairs(seedsToMonitor) do seedsToMonitorSet[seedName] = true end

local gearsToMonitorSet = {}
for _, gearName in ipairs(gearsToMonitor) do gearsToMonitorSet[gearName] = true end

-- Function to send LINE message
function SendLineMessage(message, imageUrl)
    local headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer " .. channelToken
    }

    for _, userId in ipairs(userIds) do
        local messages = { { type = "text", text = message } }
        if imageUrl then
            table.insert(messages, {
                type = "image",
                originalContentUrl = imageUrl,
                previewImageUrl = imageUrl
            })
        end

        local data = { to = userId, messages = messages }
        local body = HttpService:JSONEncode(data)

        local success, response = pcall(function()
            return HttpService:RequestAsync({
                Url = "https://api.line.me/v2/bot/message/push",
                Method = "POST",
                Headers = headers,
                Body = body
            })
        end)

        if not success then
            warn("Failed to send LINE message to " .. userId .. ": " .. tostring(response))
        end
    end
end

-- Function to check available seeds in the shop
function CheckAvailableSeeds()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local seedShop = playerGui:WaitForChild("Seed_Shop")
    local scrollingFrame = seedShop.Frame:WaitForChild("ScrollingFrame")
    
    local availableSeeds = {}
    for _, item in ipairs(scrollingFrame:GetChildren()) do
        if item:IsA("Frame") and seedsToMonitorSet[item.Name] then
            local costTextLabel = item:FindFirstChild("Main_Frame", true) and item.Main_Frame:FindFirstChild("Cost_Text")
            if costTextLabel and costTextLabel.Text ~= "NO STOCK" then
                table.insert(availableSeeds, item.Name)
            end
        end
    end

    if #availableSeeds > 0 then
        local message = "🌱 Seed ที่เข้ามาขาย:\n" .. table.concat(availableSeeds, "\n")
        local imageUrl = "https://cdn.discordapp.com/attachments/1255167690645962823/1393904233639841843/content.png?ex=6874ddfa&is=68738c7a&hm=96c3e5a4f8c11e00026e8507b09ef36f1912aa76b617eae128f6fd2e343b3469&"
        SendLineMessage(message, imageUrl)
    end
end

-- Function to check available gears in the shop
function CheckAvailableGears()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local gearShop = playerGui:WaitForChild("Gear_Shop")
    local scrollingFrame = gearShop.Frame:WaitForChild("ScrollingFrame")
    
    local availableGears = {}
    for _, item in ipairs(scrollingFrame:GetChildren()) do
        if item:IsA("Frame") and gearsToMonitorSet[item.Name] then
            local costTextLabel = item:FindFirstChild("Main_Frame", true) and item.Main_Frame:FindFirstChild("Cost_Text")
            if costTextLabel and costTextLabel.Text ~= "NO STOCK" then
                table.insert(availableGears, item.Name)
            end
        end
    end

    if #availableGears > 0 then
        local message = "🛠️ Gear ที่เข้ามาขาย:\n" .. table.concat(availableGears, "\n")
        local imageUrl = "https://cdn.discordapp.com/attachments/1255167690645962823/1393902125280399410/image.png?ex=6874dc04&is=68738a84&hm=14eda8d6168af6517f5bdaafa4b9ad4321bb56bf3ca5a5297ebcb88c118d5fb3&"
        SendLineMessage(message, imageUrl)
    end
end

-- Main monitoring loop
task.spawn(function()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    while true do
        task.wait(1) -- Check every second, which is much more efficient
        
        local seedShop = playerGui:FindFirstChild("Seed_Shop")
        if seedShop and seedShop.Enabled then
            local seedTimer = seedShop.Frame.Frame:FindFirstChild("Timer")
            if seedTimer and string.find(seedTimer.Text, "4m 49s") then
                task.wait(0.1) -- Short delay to ensure shop items have updated
                CheckAvailableSeeds()
            end
        end

        local gearShop = playerGui:FindFirstChild("Gear_Shop")
        if gearShop and gearShop.Enabled then
            local gearTimer = gearShop.Frame.Frame:FindFirstChild("Timer")
            if gearTimer and string.find(gearTimer.Text, "4m 49s") then
                task.wait(0.1) -- Short delay to ensure shop items have updated
                CheckAvailableGears()
            end
        end
    end
end)
