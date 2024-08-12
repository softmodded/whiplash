local question = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local GameService = Knit.GetService("GameService")

local ui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main").stages.question

local sub = nil

function question:Warn(warning)
    ui.warning.Text = warning
    ui.warning.Visible = true
    task.wait(5)
    ui.warning.Visible = false
end

function question:Start()
    
    local question = GameService:GetQuestion():expect()
    ui.question.Text = question

    local input = ui.input
    local submit = ui.submit

    input.Text = ""
    input.TextEditable = true
    submit.Visible = true

    sub = submit.MouseButton1Click:Connect(function()
        if input.Text == "" then
            self:Warn("Please enter an answer")
            return
        end

        local success, err = GameService:SubmitAnswer(input.Text):expect()
        if not success then
            self:Warn(err)
        else
            ui.warning.Visible = false
            ui.question.Text = "Waiting for other players..."
            input.TextEditable = false
            submit.Visible = false
        end
    end)
end

function question:Destroy()
    sub:Disconnect()
end

return question