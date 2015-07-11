Flag = {}

function Flag:new()
	local newObj = { u = nil }
	self.__index = self

	self.u = CreateUnitByName("npc_flag", GetRectCenter("pt_center"), true, nil, nil, DOTA_TEAM_NOTEAM)
	self.u:AddNoDraw()
	self.u:SetHullRadius(0.0)

	GameRules.Flag = setmetatable(newObj, self)
	return GameRules.Flag
end

function Flag:hide()
	self.u:AddNoDraw()
end

function Flag:show()
	self.u:RemoveNoDraw()
end

function Flag:setVector(v)
	self.u:SetAbsOrigin(v)
end

function Flag:Move()
	local Ball = GameRules.Ball
	local Flag = GameRules.Flag
    local h = Ball.H
    local v = Ball.Speed
    local Vz = Ball.Vz
    
    if v > 1 then
        local dist = 0.1*v*(Vz+math.sqrt(Vz*Vz+2*G*h))/G
        Flag:setVector(Ball:getPos() + Ball:fVector()*dist)
        --print("Vz "..Vz.." | h "..h.." | speed "..v)
    else
        Flag:setVector(Ball:getPos())
    end
end