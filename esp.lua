-- Скрипт для StarterPlayerScripts
local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Создаем ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ToolManagementGUI"
screenGui.Parent = PlayerGui

-- Создаем фрейм для кнопок
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 300)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50))
frame.Parent = screenGui

-- Список инструментов для исключения
local excludedTools = {
    "Oil Cup",
    "Blood Cup",
    "Acid Cup",
    "Light Cup",
    "Gold",
    "Leather",
    "Meat",
    "Rope"
}

-- Создаем переменную для режима удаления
local deleteMode = false

-- Функция для проверки, нужно ли удалять инструмент
local function shouldRemoveTool(toolName)
    for _, name in ipairs(excludedTools) do
        if name == toolName then
            return true
        end
    end
    return false
end

-- Создаем кнопку для переключения режима удаления
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 180, 0, 50)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.Text = "Режим удаления: ВЫКЛ"
toggleButton.Parent = frame

toggleButton.MouseButton1Click:Connect(function()
    deleteMode = not deleteMode
    if deleteMode then
        toggleButton.Text = "Режим удаления: ВКЛ"
    else
        toggleButton.Text = "Режим удаления: ВЫКЛ"
    end
end)

-- Создаем список кнопок для исключительных инструментов
local buttonHeight = 40
for i, toolName in ipairs(excludedTools) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 180, 0, buttonHeight))
    btn.Position = UDim2.new(0, 10, 0, 70 + (i - 1) * (buttonHeight + 5))
    btn.Text = "Включить " .. toolName
    btn.Parent = frame

    local enabled = true -- переменная состояния кнопки

    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            btn.Text = "Отключить " .. toolName
        else
            btn.Text = "Включить " .. toolName
        end
        -- Можно добавить функционал для исключения из удаления, если нужно
    end)
end

-- Основной цикл для удаления инструментов по мере их появления
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local backpack = player:WaitForChild("Backpack")
        local function onToolAdded(tool)
            if deleteMode and shouldRemoveTool(tool.Name) then
                -- Удаляем инструмент
                wait(0.1) -- небольшая задержка, чтобы инструмент полностью добавился
                if tool and tool.Parent then
                    tool:Destroy()
                end
            end
        end
        -- Подписываемся на добавление инструментов
        backpack.ChildAdded:Connect(onToolAdded)
        -- Обрабатываем уже имеющиеся инструменты
        for _, tool in ipairs(backpack:GetChildren()) do
            onToolAdded(tool)
        end
    end)
end)
