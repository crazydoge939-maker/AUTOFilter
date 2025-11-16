-- Скрипт для StarterPlayerScripts
local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Создаем ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ToolManagementGUI"
screenGui.Parent = PlayerGui

-- Создаем фрейм для кнопок
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 340)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
frame.Active = true
frame.Draggable = false -- сделаем кастомное перетаскивание
frame.Parent = screenGui

-- Украшение: добавляем заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.BorderSizePixel = 0
title.Text = "Инструменты"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

-- Создаем область для кнопок
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(1, 0, 1, -30)
buttonContainer.Position = UDim2.new(0, 0, 0, 30)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = frame

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

-- Переменная режима удаления
local deleteMode = false

-- Создаем кнопку для переключения режима удаления
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 200, 0, 30)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.Text = "Режим удаления: ВЫКЛ"
toggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSans
toggleButton.TextSize = 16
toggleButton.Parent = buttonContainer

toggleButton.MouseButton1Click:Connect(function()
    deleteMode = not deleteMode
    if deleteMode then
        toggleButton.Text = "Режим удаления: ВКЛ"
        toggleButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    else
        toggleButton.Text = "Режим удаления: ВЫКЛ"
        toggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end
end)

-- Создаем кнопки для исключительных инструментов
local buttonHeight = 40
local buttons = {}

for i, toolName in ipairs(excludedTools) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 200, 0, buttonHeight)
    btn.Position = UDim2.new(0, 10, 0, 50 + (i - 1) * (buttonHeight + 5))
    btn.Text = "Включить " .. toolName
    btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    btn.Parent = buttonContainer

    local enabled = true
    buttons[toolName] = {button = btn, enabled = enabled}

    btn.MouseButton1Click:Connect(function()
        buttons[toolName].enabled = not buttons[toolName].enabled
        if buttons[toolName].enabled then
            btn.Text = "Отключить " .. toolName
            btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        else
            btn.Text = "Включить " .. toolName
            btn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        end
    end)
end

-- Перемещаемую логику реализуем через Mouse events
local dragging = false
local dragStartPosition
local frameStartPosition

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStartPosition = input.Position
        frameStartPosition = frame.Position
    end
end)

frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartPosition
        frame.Position = UDim2.new(
            math.clamp(frameStartPosition.X.Scale + delta.X / screenGui.AbsoluteSize.X, 0, 1),
            frameStartPosition.X.Offset + delta.X,
            math.clamp(frameStartPosition.Y.Scale + delta.Y / screenGui.AbsoluteSize.Y, 0, 1),
            frameStartPosition.Y.Offset + delta.Y
        )
    end
end)

-- Основной цикл для удаления инструментов
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local backpack = player:WaitForChild("Backpack")
        local function onToolAdded(tool)
            if deleteMode and shouldRemoveTool(tool.Name) then
                wait(0.1)
                if tool and tool.Parent then
                    -- Проверяем, включена ли опция для этого инструмента
                    local info = buttons[tool.Name]
                    if info and info.enabled then
                        -- В случае если инструмент в списке и включена его опция
                        -- или просто по умолчанию удаляем
                        -- (если нужен другой механизм, его можно реализовать)
                        -- В данном примере удаляем только если режим включен и инструмент в списке
                        -- (для расширения можно добавить флаг)
                        -- Простая проверка: если инструмент в списке и режим активен
                        -- то удаляем
                        -- Но сейчас, чтобы было по условию, удаляем любой инструмент в списке
                        tool:Destroy()
                    end
                end
            end
        end
        -- Подписка на появление инструментов
        backpack.ChildAdded:Connect(onToolAdded)
        -- Обработка уже имеющихся инструментов
        for _, tool in ipairs(backpack:GetChildren()) do
            onToolAdded(tool)
        end
    end)
end)
