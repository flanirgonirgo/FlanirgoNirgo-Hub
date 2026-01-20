local LP = game:GetService("Players").LocalPlayer
local UI = Instance.new("ScreenGui")
UI.Name = "FlanirgoNirgo_Hub"
UI.Parent = LP:WaitForChild("PlayerGui")

-- Основной фрейм
local Main = Instance.new("Frame")
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Main.Size = UDim2.new(0.5, 0, 0.6, 0)
Main.Position = UDim2.new(0.5, -200, 0.5, -150)
Main.Active = true
Main.Draggable = true
Main.Parent = UI

-- Заголовок
Instance.new("TextLabel", {
	Font = Enum.Font.TitilliumWeb,
	Text = "FlanirgoNirgo Hub - ScriptBlox",
	TextColor3 = Color3.new(1,1,1),
	TextScaled = true,
	BackgroundTransparency = 1,
	Size = UDim2.new(0.9, 0, 0.1, 0),
	Position = UDim2.new(0.05, 0, 0.02, 0),
	Parent = Main
})

-- Кнопка закрыть
Instance.new("TextButton", {
	Text = "X",
	TextColor3 = Color3.new(1,1,1),
	BackgroundColor3 = Color3.fromRGB(60,0,0),
	Size = UDim2.new(0.08, 0, 0.08, 0),
	Position = UDim2.new(0.9, 0, 0.02, 0),
	Parent = Main
}).MouseButton1Click:Connect(function() UI:Destroy() end)

-- Поле поиска
local Search = Instance.new("TextBox", {
	Font = Enum.Font.TitilliumWeb,
	PlaceholderText = "Search scripts...",
	Text = "",
	TextColor3 = Color3.new(1,1,1),
	BackgroundColor3 = Color3.fromRGB(40,40,40),
	Size = UDim2.new(0.8, 0, 0.08, 0),
	Position = UDim2.new(0.1, 0, 0.12, 0),
	Parent = Main
})

-- Скролл для результатов
local Scroll = Instance.new("ScrollingFrame", {
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	ScrollBarThickness = 6,
	BackgroundColor3 = Color3.fromRGB(25,25,25),
	Size = UDim2.new(0.9, 0, 0.75, 0),
	Position = UDim2.new(0.05, 0, 0.22, 0),
	Parent = Main
})

-- Шаблон карточки
local Template = Instance.new("Frame")
Template.Visible = false
Template.Size = UDim2.new(1, -10, 0, 60)
Template.BackgroundColor3 = Color3.fromRGB(50,50,50)
Template.Parent = Scroll

Instance.new("TextLabel", {
	Name = "Info",
	BackgroundTransparency = 1,
	Text = "",
	TextColor3 = Color3.new(1,1,1),
	TextScaled = true,
	Size = UDim2.new(1, -10, 1, 0),
	Position = UDim2.new(0, 5, 0, 0),
	Parent = Template
})

-- Хранилище текущего скрипта
local Current = nil

-- Функция добавления результата
local function AddScript(Output, Name, GameName, Key, Patched, Verified)
	local Clone = Template:Clone()
	local keyTxt = Key and "<b><font color=\"rgb(240,175,0)\">Key</font></b>" or "<b>Free</b>"
	local patchTxt = Patched and "<b><font color=\"rgb(255,0,0)\">PATCHED</font></b>" or "Working"
	local verTxt = Verified and " ✅" or ""
	Clone.Info.Text = "> " .. Name .. "\n> <font color=\"rgb(128,128,255)\">" .. GameName .. "</font>\n> " .. keyTxt .. " | " .. patchTxt .. verTxt
	Clone.Parent = Scroll
	Clone.Visible = true
	
	-- Сохраняем данные
	Clone:SetAttribute("Output", Output)
	Clone:SetAttribute("Name", Name)
	Clone:SetAttribute("Game", GameName)
	
	-- Клик по карточке → открыть опции
	Clone.MouseButton1Click:Connect(function()
		Current = Clone
		warn("Selected: " .. Name .. " (" .. GameName .. ")")
	end)
end

-- Обработка поиска
Search.FocusLost:Connect(function(EnterPressed)
	if not EnterPressed then return end
	if Search.Text == "" then return end
	
	-- Очистка
	for _, v in Scroll:GetChildren() do
		if v ~= Template and v:IsA("Frame") then v:Destroy() end
	end
	
	warn("Searching: " .. Search.Text)
	
	-- Запрос к ScriptBlox API
	local Success, Response = pcall(function()
		return game:HttpGet("https://scriptblox.com/api/script/search?q=" .. Search.Text)
	end)
	
	if not Success then
		warn("Search failed")
		return
	end
	
	local Data = game:GetService("HttpService"):JSONDecode(Response)
	if not Data.result or not Data.result.scripts then
		warn("No results")
		return
	end
	
	for _, v in ipairs(Data.result.scripts) do
		AddScript(v.script, v.title, v.game.name, v.key, v.isPatched, v.verified)
	end
end)

-- Горячая клавиша: запуск последнего выбранного
game:GetService("UserInputService").InputBegan:Connect(function(inp)
	if inp.KeyCode == Enum.KeyCode.R and inp.UserInputState == Enum.UserInputState.Begin then
		if Current then
			warn("Running: " .. Current:GetAttribute("Name"))
			loadstring(Current:GetAttribute("Output"))()
		else
			warn("No script selected")
		end
	end
end)

warn("FlanirgoNirgo ScriptBlox loaded. Type query + Enter. Press R to run selected.")
