-- Скрипт для удаления определённых инструментов и управления консолью

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Список инструментов для удаления
local toolsToRemove = {
    "Oil Cup",
    "Blood Cup",
    "Acid Cup",
    "Laight Cup",
    "Gold",
    "Leather",
    "Meat",
    "Rope"
}

-- Создаем GUI фрейм
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ToolRemovalConsole"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0.5, -150, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.new(1, 1, 1)
frame.Parent = screenGui

-- Сделать окно перетаскиваемым
local dragging = false
local dragInput, dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
    end
end)

-- Создаем заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "Tool Removal Console"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

-- Создаем кнопку для удаления/включения режима
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, -20, 0, 30)
toggleButton.Position = UDim2.new(0, 10, 0, 40)
toggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggleButton.Text = "Режим: Удалять все"
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.Font = Enum.Font.SourceSans
toggleButton.TextSize = 18
toggleButton.Parent = frame

local deleteMode = true -- true - удалять выбранные инструменты, false - отключить удаление

toggleButton.MouseButton1Click:Connect(function()
    deleteMode = not deleteMode
    if deleteMode then
        toggleButton.Text = "Режим: Удалять все"
        toggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    else
        toggleButton.Text = "Режим: Отключено"
        toggleButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    end
end)

-- Создаем список кнопок для выбора инструмента
local buttonSize = UDim2.new(1, -20, 0, 30)
local startY = 80
local buttons = {}

for i, toolName in ipairs(toolsToRemove) do
    local btn = Instance.new("TextButton")
    btn.Size = buttonSize
    btn.Position = UDim2.new(0, 10, 0, startY + (i - 1) * 35)
    btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    btn.Text = toolName
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Parent = frame
    buttons[toolName] = btn
end

-- Обработчик для удаления инструментов
game:GetService("RunService").Stepped:Connect(function()
    if deleteMode then
        local backpack = player.Backpack
        local character = player.Character

        -- Проверка и удаление инструментов из рюкзака
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and table.find(toolsToRemove, tool.Name) then
                tool:Destroy()
            end
        end

        -- Проверка и удаление инструментов из руки
        if character then
            for _, tool in ipairs(character:GetChildren()) do
                if tool:IsA("Tool") and table.find(toolsToRemove, tool.Name) then
                    tool:Destroy()
                end
            end
        end
    end
end)

-- Можно добавить визуальное оформление, например, тень или изменение цвета, по желанию.
