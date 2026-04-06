if not game:IsLoaded() then game.Loaded:Wait() end

if not syn or not protectgui then
    getgenv().protectgui = function() end
end

local SilentAimSettings = {
    Enabled = false,
    ClassName = "hnhtlong.10th3 - Đẳng Cấp VKL",
    ToggleKey = "RightAlt",
    TeamCheck = false,
    VisibleCheck = false, 
    TargetPart = "HumanoidRootPart",
    SilentAimMethod = "Raycast",
    FOVRadius = 130,
    FOVVisible = false,
    ShowSilentAimTarget = false, 
    MouseHitPrediction = false,
    MouseHitPredictionAmount = 0.165,
    HitChance = 100
}

getgenv().SilentAimSettings = SilentAimSettings

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local FindFirstChild = game.FindFirstChild

local ValidTargetParts = {"Head", "HumanoidRootPart"}

local mouse_box = Drawing.new("Square")
mouse_box.Visible = false 
mouse_box.ZIndex = 999 
mouse_box.Color = Color3.fromRGB(54, 57, 241)
mouse_box.Thickness = 2 
mouse_box.Size = Vector2.new(20, 20)
mouse_box.Filled = true 

local fov_circle = Drawing.new("Circle")
fov_circle.Thickness = 1
fov_circle.NumSides = 100
fov_circle.Radius = 180
fov_circle.Filled = false
fov_circle.Visible = false
fov_circle.ZIndex = 999
fov_circle.Transparency = 1
fov_circle.Color = Color3.fromRGB(54, 57, 241)

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles

local function CalculateChance(Percentage)
    Percentage = math.floor(Percentage)
    local chance = math.floor(Random.new().NextNumber(Random.new(), 0, 1) * 100) / 100
    return chance <= Percentage / 100
end

local function getPositionOnScreen(Vector)
    local Vec3, OnScreen = Camera:WorldToScreenPoint(Vector)
    return Vector2.new(Vec3.X, Vec3.Y), OnScreen
end

local function getDirection(Origin, Position) 
    return (Position - Origin).Unit * 1000 
end

local function getMousePosition() 
    return UserInputService:GetMouseLocation() 
end

local function IsPlayerVisible(Player)
    local PlayerCharacter = Player.Character
    local LocalPlayerCharacter = LocalPlayer.Character
    if not (PlayerCharacter or LocalPlayerCharacter) then return end 
    local PlayerRoot = FindFirstChild(PlayerCharacter, Options.TargetPart.Value) or FindFirstChild(PlayerCharacter, "HumanoidRootPart")
    if not PlayerRoot then return end 
    local CastPoints, IgnoreList = {PlayerRoot.Position, LocalPlayerCharacter, PlayerCharacter}, {LocalPlayerCharacter, PlayerCharacter}
    local ObscuringObjects = #Camera:GetPartsObscuringTarget(CastPoints, IgnoreList)
    return ObscuringObjects == 0
end

local function getClosestPlayer()
    if not Options.TargetPart.Value then return end
    local Closest, DistanceToMouse
    for _, Player in next, Players:GetPlayers() do
        if Player == LocalPlayer then continue end
        if Toggles.TeamCheck.Value and Player.Team == LocalPlayer.Team then continue end
        local Character = Player.Character
        if not Character then continue end
        if Toggles.VisibleCheck.Value and not IsPlayerVisible(Player) then continue end
        local HumanoidRootPart = FindFirstChild(Character, "HumanoidRootPart")
        local Humanoid = FindFirstChild(Character, "Humanoid")
        if not HumanoidRootPart or not Humanoid or Humanoid.Health <= 0 then continue end
        local ScreenPosition, OnScreen = getPositionOnScreen(HumanoidRootPart.Position)
        if not OnScreen then continue end
        local Distance = (getMousePosition() - ScreenPosition).Magnitude
        if Distance <= (DistanceToMouse or Options.Radius.Value or 2000) then
            Closest = ((Options.TargetPart.Value == "Random" and Character[ValidTargetParts[math.random(1, #ValidTargetParts)]]) or Character[Options.TargetPart.Value])
            DistanceToMouse = Distance
        end
    end
    return Closest
end

Library:SetWatermark("hnhtlong.10th3 | Đẳng Cấp VKL")
local Window = Library:CreateWindow({Title = 'hnhtlong.10th3 | Private System', Center = true, AutoShow = true, TabPadding = 8})
local GeneralTab = Window:AddTab("General")

local MainBOX = GeneralTab:AddLeftTabbox("Main")
local Main = MainBOX:AddTab("Main")
Main:AddToggle("aim_Enabled", {Text = "Enabled"}):AddKeyPicker("SA_Key", {Default = "RightAlt", SyncToggleState = true, Mode = "Toggle", Text = "Enabled"})
Main:AddToggle("TeamCheck", {Text = "Team Check", Default = false})
Main:AddToggle("VisibleCheck", {Text = "Visible Check", Default = false})
Main:AddDropdown("TargetPart", {Text = "Target Part", Default = "HumanoidRootPart", Values = {"Head", "HumanoidRootPart", "Random"}})
Main:AddDropdown("Method", {Text = "Silent Aim Method", Default = "Raycast", Values = {"Raycast","FindPartOnRay","FindPartOnRayWithWhitelist","FindPartOnRayWithIgnoreList","Mouse.Hit/Target"}})
Main:AddSlider('HitChance', {Text = 'Hit chance', Default = 100, Min = 0, Max = 100, Rounding = 1})

local VisualsBOX = GeneralTab:AddLeftTabbox("Field Of View")
local Vis = VisualsBOX:AddTab("Visuals")
Vis:AddToggle("Visible", {Text = "Show FOV Circle"}):AddColorPicker("Color", {Default = Color3.fromRGB(54, 57, 241)})
Vis:AddSlider("Radius", {Text = "FOV Radius", Min = 0, Max = 500, Default = 130})
Vis:AddToggle("MousePosition", {Text = "Show Target Square"})

local MiscBOX = GeneralTab:AddLeftTabbox("Miscellaneous")
local Pred = MiscBOX:AddTab("Prediction")
Pred:AddToggle("Prediction", {Text = "Movement Prediction"})
Pred:AddSlider("Amount", {Text = "Prediction Amount", Min = 0.165, Max = 1, Default = 0.165, Rounding = 3})

local InfoTab = Window:AddTab("Information")
local InfoGroup = InfoTab:AddLeftGroupbox("Developer")
InfoGroup:AddLabel("Owner: Hà Nhất Long")
InfoGroup:AddButton("Copy Contact", function() setclipboard("https://konect.gg/hnhtlong") end)

RunService.RenderStepped:Connect(function()
    if Toggles.Visible.Value then 
        fov_circle.Visible = true
        fov_circle.Color = Options.Color.Value
        fov_circle.Position = getMousePosition()
        fov_circle.Radius = Options.Radius.Value
    else 
        fov_circle.Visible = false 
    end

    if Toggles.MousePosition.Value and Toggles.aim_Enabled.Value then
        local target = getClosestPlayer()
        if target then
            local Root = target.Parent.PrimaryPart or target
            local RootToViewportPoint, IsOnScreen = Camera:WorldToViewportPoint(Root.Position)
            mouse_box.Visible = IsOnScreen
            mouse_box.Position = Vector2.new(RootToViewportPoint.X, RootToViewportPoint.Y) - (mouse_box.Size/2)
        else 
            mouse_box.Visible = false 
        end
    else 
        mouse_box.Visible = false 
    end
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local Method = getnamecallmethod()
    local Arguments = {...}
    local self = Arguments[1]
    if not checkcaller() and Toggles.aim_Enabled.Value and CalculateChance(Options.HitChance.Value) then
        local HitPart = getClosestPlayer()
        if HitPart then
            if Method == "Raycast" and Options.Method.Value == Method then
                Arguments[3] = getDirection(Arguments[2], HitPart.Position)
                return oldNamecall(unpack(Arguments))
            elseif (Method == "FindPartOnRay" or Method == "findPartOnRay") and Options.Method.Value:lower() == Method:lower() then
                Arguments[2] = Ray.new(Arguments[2].Origin, getDirection(Arguments[2].Origin, HitPart.Position))
                return oldNamecall(unpack(Arguments))
            elseif (Method == "FindPartOnRayWithIgnoreList" or Method == "FindPartOnRayWithWhitelist") and Options.Method.Value == Method then
                Arguments[2] = Ray.new(Arguments[2].Origin, getDirection(Arguments[2].Origin, HitPart.Position))
                return oldNamecall(unpack(Arguments))
            end
        end
    end
    return oldNamecall(...)
end))

local oldIndex
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, Index)
    if self == Mouse and not checkcaller() and Toggles.aim_Enabled.Value and Options.Method.Value == "Mouse.Hit/Target" then
        local HitPart = getClosestPlayer()
        if HitPart then
            if Index == "Target" or Index == "target" then return HitPart
            elseif Index == "Hit" or Index == "hit" then 
                return ((Toggles.Prediction.Value and (HitPart.CFrame + (HitPart.Velocity * Options.Amount.Value))) or HitPart.CFrame)
            end
        end
    end
    return oldIndex(self, Index)
end))

Library:Notify("Đẳng Cấp VKL Loaded Successfully!", 3)