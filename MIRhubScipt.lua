--Used library Robojini UI_Template_1 link:https://github.com/Robojini/Tuturial_UI/blob/main/UI_Template_1

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Robojini/Tuturial_UI_Library/main/UI_Template_1"))()

local CurrentTheme = {
    SchemeColor = Color3.fromRGB(91, 94, 176),
    Background = Color3.fromRGB(15, 15, 15),
    Header = Color3.fromRGB(15, 15, 15),
    TextColor = Color3.fromRGB(255, 255, 255),
    ElementColor = Color3.fromRGB(20, 20, 20)
}

local Window = Library.CreateLib("MIRhub 3.0", CurrentTheme)

-- Сервисы Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local LocalPlayer = Players.LocalPlayer
local myName = LocalPlayer.Name


local TabPlayer = Window:NewTab("PLAYER")
local SecMove = TabPlayer:NewSection("Передвижение")

local WalkSpeedValue = 16
local JumpPowerValue = 50
local FlyEnabled = false
local FlySpeed = 60
local NoclipEnabled = false
local GodModeEnabled = false
local FastInteractEnabled = false

SecMove:NewSlider("Скорость бега", "Стандарт: 16", 1000, 16, function(s)
    WalkSpeedValue = s
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = s
    end
end)

SecMove:NewSlider("Сила прыжка", "Стандарт: 50", 1000, 50, function(s)
    JumpPowerValue = s
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.UseJumpPower = true
        LocalPlayer.Character.Humanoid.JumpPower = s
    end
end)

SecMove:NewSlider("Скорость полёта", "Настройка скорости Fly", 1000, 20, function(s)
    FlySpeed = s
end)

SecMove:NewToggle("Полёт (Fly)", "Управление: WASD, Пробел (вверх), Ctrl (вниз)", function(state)
    FlyEnabled = state
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then return end
    
    local hrp = char.HumanoidRootPart
    local hum = char.Humanoid
    
    if FlyEnabled then
        hum.PlatformStand = true
        local bv = Instance.new("BodyVelocity")
        bv.Name = "CustomFlyVel"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.zero
        bv.Parent = hrp
        
        local bg = Instance.new("BodyGyro")
        bg.Name = "CustomFlyGyro"
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.P = 9e4
        bg.CFrame = hrp.CFrame
        bg.Parent = hrp
        
        task.spawn(function()
            local cam = workspace.CurrentCamera
            while FlyEnabled and hrp and hrp.Parent do
                local moveDir = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
                
                if moveDir.Magnitude > 0 then
                    bv.Velocity = moveDir.Unit * FlySpeed
                else
                    bv.Velocity = Vector3.zero
                end
                bg.CFrame = cam.CFrame
                task.wait()
            end
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
            if hum then hum.PlatformStand = false end
        end)
    else
        if hrp:FindFirstChild("CustomFlyVel") then hrp.CustomFlyVel:Destroy() end
        if hrp:FindFirstChild("CustomFlyGyro") then hrp.CustomFlyGyro:Destroy() end
        hum.PlatformStand = false
    end
end)

SecMove:NewToggle("Ноуклип (Noclip)", "Проход сквозь стены и объекты", function(state)
    NoclipEnabled = state
end)

RunService.Stepped:Connect(function()
    if NoclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

local SecOther = TabPlayer:NewSection("Способности")

SecOther:NewToggle("Fast Interact", "Мгновенное взаимодействие с кнопками (E)", function(state)
    FastInteractEnabled = state
end)

ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    if FastInteractEnabled and fireproximityprompt then
        fireproximityprompt(prompt)
    end
end)

SecOther:NewToggle("Бессмертие (GodMode)", "Постоянное восстановление здоровья", function(state)
    GodModeEnabled = state
    task.spawn(function()
        while GodModeEnabled do
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then
                hum.MaxHealth = math.huge
                hum.Health = math.huge
            end
            task.wait(0.1)
        end
    end)
end)


local PlayerName = "SET UP NAME"
local Tab = Window:NewTab("TELEPORT")
local NAMEsec = Tab:NewSection("NAME")

local StatusLabel = NAMEsec:NewLabel(PlayerName)

NAMEsec:NewTextBox("Name", "SetNamePlayerToTp", function(PlayerNam)
    PlayerName = PlayerNam
    StatusLabel:UpdateLabel(PlayerName)
end)

NAMEsec:NewButton("TELEPORT", "TELEPORT TO PLAYER", function()
    local myChar = workspace:FindFirstChild(myName)
    local targetChar = workspace:FindFirstChild(PlayerName)
    
    if myChar and targetChar and myChar:FindFirstChild("HumanoidRootPart") and targetChar:FindFirstChild("HumanoidRootPart") then
        myChar.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    else
        StatusLabel:UpdateLabel("Ошибка: Игрок не найден!")
    end
end)


local TabCoords = Window:NewTab("LOCATIONS")
local SecSaved = TabCoords:NewSection("Сохранённые точки")

local SavedLocations = {
    ["Центр карты (0, 10, 0)"] = CFrame.new(0, 10, 0)
}

local SelectedLocation = "Центр карты (0, 10, 0)"
local NewPointName = ""

local function GetLocationNames()
    local names = {}
    for name, _ in pairs(SavedLocations) do
        table.insert(names, name)
    end
    return names
end

local LocDropdown = SecSaved:NewDropdown("Список позиций", "Выберите точку для телепорта", GetLocationNames(), function(chosen)
    SelectedLocation = chosen
end)

SecSaved:NewButton("Телепортироваться", "Переместиться на выбранную точку", function()
    local myChar = workspace:FindFirstChild(myName)
    local targetCFrame = SavedLocations[SelectedLocation]
    
    if myChar and myChar:FindFirstChild("HumanoidRootPart") and targetCFrame then
        myChar.HumanoidRootPart.CFrame = targetCFrame
    end
end)

local SecCreate = TabCoords:NewSection("Добавить новую точку")
local CreateStatus = SecCreate:NewLabel("Введите название и нажмите сохранить")

SecCreate:NewTextBox("Название точки", "Напишите имя и нажмите Enter", function(txt)
    NewPointName = txt
    CreateStatus:UpdateLabel("Готово к сохранению: " .. NewPointName)
end)

SecCreate:NewButton("Сохранить мою позицию", "Записывает ваши текущие координаты", function()
    local myChar = workspace:FindFirstChild(myName)
    
    if NewPointName == "" then
        CreateStatus:UpdateLabel("Ошибка: Сначала введите название!")
        return
    end
    
    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
        SavedLocations[NewPointName] = myChar.HumanoidRootPart.CFrame
        SelectedLocation = NewPointName
        
        LocDropdown:Refresh(GetLocationNames())
        CreateStatus:UpdateLabel("Сохранено: " .. NewPointName)
        NewPointName = ""
    else
        CreateStatus:UpdateLabel("Ошибка: Персонаж не найден!")
    end
end)


local TabSettings = Window:NewTab("SETTINGS")
local SecPresets = TabSettings:NewSection("Готовые темы")

local PresetThemes = {
    ["Синяя (RJTheme3)"] = {Scheme = Color3.fromRGB(91, 94, 176), Bg = Color3.fromRGB(15, 15, 15), Head = Color3.fromRGB(15, 15, 15), El = Color3.fromRGB(20, 20, 20), Txt = Color3.fromRGB(255, 255, 255)},
    ["Серая (RJTheme1)"] = {Scheme = Color3.fromRGB(112, 112, 112), Bg = Color3.fromRGB(15, 15, 15), Head = Color3.fromRGB(15, 15, 15), El = Color3.fromRGB(20, 20, 20), Txt = Color3.fromRGB(255, 255, 255)},
    ["Розовая (RJTheme4)"] = {Scheme = Color3.fromRGB(128, 77, 112), Bg = Color3.fromRGB(15, 15, 15), Head = Color3.fromRGB(15, 15, 15), El = Color3.fromRGB(20, 20, 20), Txt = Color3.fromRGB(255, 255, 255)},
    ["Золотая (RJTheme5)"] = {Scheme = Color3.fromRGB(150, 141, 71), Bg = Color3.fromRGB(15, 15, 15), Head = Color3.fromRGB(15, 15, 15), El = Color3.fromRGB(20, 20, 20), Txt = Color3.fromRGB(255, 255, 255)},
    ["Зелёная (RJTheme6)"] = {Scheme = Color3.fromRGB(86, 128, 61), Bg = Color3.fromRGB(15, 15, 15), Head = Color3.fromRGB(15, 15, 15), El = Color3.fromRGB(20, 20, 20), Txt = Color3.fromRGB(255, 255, 255)},

["Фиолетовая (RJTheme7)"] = {Scheme = Color3.fromRGB(95, 81, 168), Bg = Color3.fromRGB(15, 15, 15), Head = Color3.fromRGB(15, 15, 15), El = Color3.fromRGB(20, 20, 20), Txt = Color3.fromRGB(255, 255, 255)},
["Пурпурная (RJTheme8)"] = {Scheme = Color3.fromRGB(150, 72, 148), Bg = Color3.fromRGB(15, 15, 15), Head = Color3.fromRGB(15, 15, 15), El = Color3.fromRGB(20, 20, 20), Txt = Color3.fromRGB(255, 255, 255)},
["Стандартная Kavo"] = {Scheme = Color3.fromRGB(74, 99, 135), Bg = Color3.fromRGB(36, 37, 43), Head = Color3.fromRGB(28, 29, 34), El = Color3.fromRGB(32, 32, 38), Txt = Color3.fromRGB(255, 255, 255)}
}
local PresetNames = {}
for name, _ in pairs(PresetThemes) do
table.insert(PresetNames, name)
end
SecPresets:NewDropdown("Выбор готовой темы", "Мгновенно применяет палитру", PresetNames, function(selected)
local t = PresetThemes[selected]
if t then
Library:ChangeColor("SchemeColor", t.Scheme)
Library:ChangeColor("Background", t.Bg)
Library:ChangeColor("Header", t.Head)
Library:ChangeColor("ElementColor", t.El)
Library:ChangeColor("TextColor", t.Txt)
end
end)
local SecCustom = TabSettings:NewSection("Свои цвета (Палитра)")
SecCustom:NewColorPicker("Акцентный цвет (SchemeColor)", "Цвет шапок секций и иконок", CurrentTheme.SchemeColor, function(color)
Library:ChangeColor("SchemeColor", color)
end)
SecCustom:NewColorPicker("Основной фон (Background)", "Фон правой части окна", CurrentTheme.Background, function(color)
Library:ChangeColor("Background", color)
end)
SecCustom:NewColorPicker("Шапка и панель (Header)", "Фон левой панели и верха", CurrentTheme.Header, function(color)
Library:ChangeColor("Header", color)
end)
SecCustom:NewColorPicker("Фон кнопок (ElementColor)", "Цвет виджетов и кнопок", CurrentTheme.ElementColor, function(color)
Library:ChangeColor("ElementColor", color)
end)
SecCustom:NewColorPicker("Цвет текста (TextColor)", "Цвет всех надписей в меню", CurrentTheme.TextColor, function(color)
Library:ChangeColor("TextColor", color)
end)
local SecMenu = TabSettings:NewSection("Управление окном")
SecMenu:NewKeybind("Скрыть / Показать меню", "Клавиша для сворачивания окна", Enum.KeyCode.H, function()
Library:ToggleUI()
end)
