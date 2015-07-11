Ball = {}

function Ball:new()
	Ball.DefaultHeight = 10.0
	local newObj = { u = nil, DefaultHeight = 10.0, H = 0.0, Vz = 0.0, Speed = 0.0, Owner = nil, CantInteract = false, IsInAir = false }
	self.__index = self

	local pos_ball = GetRectCenter("pt_center")
	self.u = CreateUnitByName("npc_ball", pos_ball, false, nil, nil, DOTA_TEAM_NOTEAM)
	self.H = self.DefaultHeight
	self.u:SetHullRadius(0.0)

	GameRules.Ball = setmetatable(newObj, self)
	Ball[0] = GameRules.Ball
	return GameRules.Ball
end

function Ball:disableInteraction(time)
	self.CantInteract = true
	Timers:CreateTimer(time, function()
		self.CantInteract = false
	end)
end

function Ball:playSound(snd)
	EmitSoundOn(snd, self.u)
end

function Ball:stop()
	self.u:Stop()
end

function Ball:getPos()
	return GetGroundPosition(self.u:GetAbsOrigin(), self.u)
end

function Ball:getVector()
	return self.u:GetAbsOrigin()
end

function Ball:setVector(pos)
	self.u:SetAbsOrigin(pos)
end

function Ball:setHeight(h)
	local Ball = GameRules.Ball
	self.H = h
	self:setVector(self:getPos() + self:uVector()*h)
end

function Ball:resetHeight()
	self:setHeight(Ball.DefaultHeight)
end

function Ball:uVector()
	return self.u:GetUpVector()
end

function Ball:fVector()
	return self.u:GetForwardVector():Normalized()
end

function Ball:setfVector(v)
	self.u:SetForwardVector(v:Normalized())
end
