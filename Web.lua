-- Improved Roblox Script for Monitoring Seeds and Gears Availability
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local SeedShopFrame = nil
local GearShopFrame = nil
local seedTimer, gearTimer

-- Constants
local CHANNEL_TOKEN = "LJhin0MVfYPA3EsTv8lAAYTVdHAr35ToVtcGFT03ShvByslB5wHXlvEGmuaw0FmthrQQYBvsnRA9CzOCzkKTgqilrcof7+ZZdU+Z+6qUprjZdoYAeBEynjdYGiDZvxgnJwx2jwCsRHopP0OApsbCMgdB04t89/1O/w1cDnyilFU="
local USER_IDS = {
    "Uc04421c89ce6df255a999fac7e25ed0b", "Ue4801642cb03ba4b016ddb0d7bf6a371", 
    "U41dab69261906d9caffa4c89509c34a2", "U44009be1d8fb1a100833e0200dd049b0"
}
local SEEDS_TO_MONITOR = { "Carrot", "Strawberry", "Blueberry", "Orange Tulip", "Tomato", "Daffodil", "Watermelon", "Pumpkin", "Apple", "Bamboo", "Coconut", "Cactus", "Dragon Fruit", "Mango", "Grape", "Mushroom", "Pepper", "Cacao", "Beanstalk", "Ember Lily", "Sugar Apple", "Burning Bud" }
local GEARS_TO_MONITOR = { "Advanced Sprinkler", "Basic Sprinkler", "Cleaning Spray", "Favorite Tool", "Friendship Pot", "Godly Sprinkler", "Harvest Tool", "Levelup Lollipop", "Magnifying Glass", "Master Sprinkler", "Medium Toy", "Medium Treat", "Recall Wrench", "Tanning Mirror", "Trowel", "Watering Can" }

-- Function to monitor seed and gear availability
local function monitorAvailability()
    local function checkAvailability(shop, itemsToMonitor, messageType, imageUrl)
        if not shop then return end
        local scrollingFrame = shop:FindFirstChild("ScrollingFrame")
        if not scrollingFrame then return end
        
        local availableItems = {}
        for _, item in ipairs(scrollingFrame:GetChildren()) do
            local itemName = item.Name
            if itemsToMonitor[itemName] then
                local mainFrame = item:FindFirstChild("Main_Frame")
                local costTextLabel = mainFrame and mainFrame:FindFirstChild("Cost_Text")
                if costTextLabel and costTextLabel.Text ~= "NO STOCK" then
                    table.insert(availableItems, itemName)
                end
            end
        end

        if #availableItems > 0 then
            local message = messageType .. ": \n" .. table.concat(availableItems, "\n")
            SendLineMessage(message, imageUrl)
        end
    end

    checkAvailability(SeedShopFrame, SEEDS_TO_MONITOR, "🌱 Seed ที่เข้ามาขาย", "https://cdn.discordapp.com/attachments/1255167690645962823/1393904233639841843/content.png?ex=6874ddfa&is=68738c7a&hm=96c3e5a4f8c11e00026e8507b09ef36f1912aa76b617eae128f6fd2e343b3469&")
    checkAvailability(GearShopFrame, GEARS_TO_MONITOR, "🛠️ Gear ที่เข้ามาขาย", "https://cdn.discordapp.com/attachments/1255167690645962823/1393902125280399410/image.png?ex=6874dc04&is=68738a84&hm=14eda8d6168af6517f5bdaafa4b9ad4321bb56bf3ca5a5297ebcb88c118d5fb3&")
end

-- Function to send Line message
local function sendLineMessage(message, imageUrl)
    local headers = { ["Content-Type"] = "application/json", ["Authorization"] = "Bearer " .. CHANNEL_TOKEN }
    for _, userId in ipairs(USER_IDS) do
        local data = { to = userId, messages = { { type = "text", text = message } } }
        if imageUrl then
            table.insert(data.messages, { type = "image", originalContentUrl = imageUrl, previewImageUrl = imageUrl })
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

-- Function to handle idle event (prevents kicking)
local function handleIdle()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    -- Prevent kick message if needed
    if ab then
        ab.Text = "You went idle and ROBLOX tried to kick you but we reflected it!"
        task.wait(2)
        ab.Text = "Script Re-Enabled"
    end
end

-- Main loop for monitoring timers and availability
task.spawn(function()
    while true do
        monitorAvailability()
        task.wait() -- Adjust wait time as necessary
    end
end)

-- Event to handle idle
Players.LocalPlayer.Idled:Connect(handleIdle)

