local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local UI_FOLDER = ReplicatedStorage:WaitForChild("Interface")

local InterfaceController = Knit.CreateController { Name = "InterfaceController" }


function InterfaceController:KnitStart()
end


function InterfaceController:KnitInit()
    self.RoundService = Knit.GetService("RoundService")
    self:InitializeUI()
end

function InterfaceController:UpdateUI(stage)
    local stageFolder = self.gui:WaitForChild("stages")
    for _, child in ipairs(stageFolder:GetChildren()) do
        child.Visible = false
    end

    local stageUi = stageFolder:WaitForChild(stage)
    stageUi.Visible = true

    local uiScriptFolder = Knit.Client:WaitForChild("interface")
    local stageScript = uiScriptFolder:WaitForChild(stage)
    if stageScript then
        local scr = require(stageScript)
        scr:Start()
    end

    if self.previousUi then
        local previousScript = uiScriptFolder:WaitForChild(self.previousUi)
        if previousScript then
            local scr = require(previousScript)
            scr:Destroy()
        end
    end

    self.previousUi = stage
end

function InterfaceController:InitializeUI()
    local mainUI = UI_FOLDER:WaitForChild("Main")
    local playerUi = mainUI:Clone()
    playerUi.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    playerUi.Enabled = true
    self.gui = playerUi

    local stage = self.RoundService:GetStage():expect()
    print("stage", stage)
    self:UpdateUI(stage)
    self:InitializeEvents()
end

function InterfaceController:InitializeEvents()
    self.RoundService.stageChange:Connect(function(stage)
        self:UpdateUI(stage)
    end)
end

return InterfaceController
