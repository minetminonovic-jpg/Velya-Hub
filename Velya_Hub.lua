local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Main",
   Icon = 12053823662, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Velya hub",
   LoadingSubtitle = "by BoVbOCHKA",
   ShowText = "Velya Hub", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "G", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = true, -- Set this to true to use our key system
   KeySettings = {
      Title = "Velya Hub Key System",
      Subtitle = "Key System",
      Note = "Write your key / Введите ключ", -- Use this to tell the user how to get a key
      FileName = "Velya_key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"1245", "1535", "1209"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local Tab = Window:CreateTab("Main", nil) -- Title, Image

Rayfield:Notify({
   Title = "Script succesfully executed!",
   Content = "Script has been executed and ready to work",
   Duration = 3,
   Image = nil,
})

local Button = Tab:CreateButton({
   Name = "ESP",
   Callback = function()
        local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local ESPs = {}

-- Настройки
local MAX_DISTANCE = 300 -- после этого расстояния цвет всегда голубой
local BOX_TRANSPARENCY = 0.6
local HIGHLIGHT_FILL = Color3.fromRGB(0, 150, 255)
local HIGHLIGHT_FILL_TRANSP = 0.6
local HIGHLIGHT_OUTLINE = Color3.fromRGB(255, 255, 255)

-- Удаление ESP
local function clearESP(player)
	if ESPs[player] then
		for _, obj in pairs(ESPs[player]) do
			if typeof(obj) == "Instance" and obj.Parent then
				obj:Destroy()
			end
		end
		ESPs[player] = nil
	end
end

--- Billboard с именем
local function createNameTag(head, player)
	local bb = Instance.new("BillboardGui")
	bb.Name = "ESP_NameTag"
	bb.Adornee = head
	bb.AlwaysOnTop = true
	bb.Size = UDim2.new(0, 100, 0, 25) -- уменьшено в 2 раза
	bb.StudsOffset = Vector3.new(0, 2.5, 0)
	bb.Parent = head

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1,1)
	label.BackgroundTransparency = 1
	label.Text = player.DisplayName ~= "" and player.DisplayName or player.Name
	label.TextScaled = true
	label.Font = Enum.Font.SourceSansBold
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.25
	label.Parent = bb

	return bb
end

-- Highlight вокруг модели
local function createHighlight(character)
	local hl = Instance.new("Highlight")
	hl.Name = "ESP_Highlight"
	hl.Adornee = character
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.FillColor = HIGHLIGHT_FILL
	hl.FillTransparency = HIGHLIGHT_FILL_TRANSP
	hl.OutlineColor = HIGHLIGHT_OUTLINE
	hl.OutlineTransparency = 0
	hl.Parent = CoreGui
	return hl
end

-- Бокс под ником
local function createBoxUnderName(head, player)
	local part = Instance.new("Part")
	part.Name = "ESP_BoxAnchor"
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new(4, 6, 4)
	part.Parent = Workspace

	local box = Instance.new("BoxHandleAdornment")
	box.Name = "ESP_Box"
	box.Adornee = part
	box.Size = part.Size
	box.AlwaysOnTop = true
	box.ZIndex = 0
	box.Transparency = BOX_TRANSPARENCY
	box.Parent = part

	-- Апдейтер позиции и цвета
	RunService.RenderStepped:Connect(function()
		if head and head.Parent and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
			-- позиция под ником
			local pos = head.Position + Vector3.new(0, -2, 0)
			part.CFrame = CFrame.new(pos)

			-- считаем расстояние
			local distance = (head.Position - LocalPlayer.Character.Head.Position).Magnitude
			local t = math.clamp(distance / MAX_DISTANCE, 0, 1)

			-- плавный градиент: красный → жёлтый → голубой
			if t < 0.5 then
				-- красный → жёлтый
				local ratio = t / 0.5
				box.Color3 = Color3.new(1, ratio, 0) -- (1,0,0) → (1,1,0)
			else
				-- жёлтый → голубой
				local ratio = (t - 0.5) / 0.5
				local r = 1 - ratio
				local g = 1 - ratio * 1
				local b = ratio
				box.Color3 = Color3.new(r, g, b) -- (1,1,0) → (0,0,1)
			end
		end
	end)

	return part, box
end

-- Создание ESP
local function createESP(player)
	if player == LocalPlayer then return end
	if not player.Character or not player.Character:FindFirstChild("Head") then return end

	clearESP(player)

	local head = player.Character:WaitForChild("Head")

	local hl = createHighlight(player.Character)
	local tag = createNameTag(head, player)
	local boxPart, box = createBoxUnderName(head, player)

	ESPs[player] = { highlight = hl, nameTag = tag, boxPart = boxPart, box = box }
end

-- Обработка персонажа
local function onCharacterAdded(player, character)
	character:WaitForChild("Head")
	task.wait(0.5)
	createESP(player)
end

-- Игроки
for _, plr in ipairs(Players:GetPlayers()) do
	if plr ~= LocalPlayer then
		if plr.Character then
			createESP(plr)
		end
		plr.CharacterAdded:Connect(function(char)
			onCharacterAdded(plr, char)
		end)
		plr.CharacterRemoving:Connect(function()
			clearESP(plr)
		end)
	end
end

Players.PlayerAdded:Connect(function(plr)
	if plr ~= LocalPlayer then
		plr.CharacterAdded:Connect(function(char)
			onCharacterAdded(plr, char)
		end)
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	clearESP(plr)
end)


   end,
})

local Button = Tab:CreateButton({
   Name = "High Jump",
   Callback = function()
        -- LocalScript в StarterPlayerScripts
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- создаём переменную для управления прыжком
-- можно вынести её в ReplicatedStorage, чтобы менять во время игры
local JumpValue = Instance.new("NumberValue")
JumpValue.Name = "JumpValue"
JumpValue.Value = 50 -- базовое значение, можно менять во время игры
JumpValue.Parent = LocalPlayer

-- функция для применения высоты прыжка
local function applyJumpValue(humanoid)
	if humanoid and humanoid:IsDescendantOf(workspace) then
		-- Roblox поддерживает JumpPower (если UseJumpPower = true)
		humanoid.UseJumpPower = true
		humanoid.JumpPower = JumpValue.Value
	end
end

-- следим за персонажем
local function onCharacterAdded(character)
	local humanoid = character:WaitForChild("Humanoid")
	applyJumpValue(humanoid)

	-- если переменная меняется — обновляем
	JumpValue.Changed:Connect(function()
		applyJumpValue(humanoid)
	end)
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
if LocalPlayer.Character then
	onCharacterAdded(LocalPlayer.Character)
end

   end,
})