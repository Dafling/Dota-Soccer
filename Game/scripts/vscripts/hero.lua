Hero = {}

function Hero:new(hero)
  	local newObj = { u = nil, H = 0.0, Vz = 0.0, Slide_Vx = 0.0, Tallness = 100, CantHoldBall = false, SlowDown = false, IsInAir = false }
  	self.__index = self

  	local pos = GetRectCenter("rct_left_spawn")
	self.u = CreateUnitByName("Kobold", pos, true, hero, hero, hero:GetTeam())
	local id = hero:GetPlayerOwner():GetPlayerID()
	self.u:SetControllableByPlayer(id, true)
	self.u:SetHullRadius(0.0)
	print("New hero id ="..id)
	print("Hero's team  ="..self.u:GetTeam())

	Hero[id] = setmetatable(newObj, self)
	Hero[self.u] = Hero[id]

	hero:SetHullRadius(0.0)
	--hero:AddNoDraw()
  	return Hero[id]
end

function Hero:turn(v)
	self.u:AddNewModifier(self.u, nil, "modifier_rooted", {})
	self.u:MoveToPosition(self:getPos() + v:Normalized())
	Timers:CreateTimer(0.03, function()
		self.u:RemoveModifierByName("modifier_rooted")
	end)
end

function Hero:getTeam()
	return self.u:GetTeam()
end

function Hero:msg(s, clr)
	if not s then return end
	local id = self.u:GetPlayerOwnerID()
	if not clr then clr = "orange" end
	Notifications:Top(id, {text=s, duration=4, style={color=clr}, continue=false})
	--UTIL_MessageText(id, s, 50, 50, 50, 50) -- n/a
	--Msg(s) -- n/a
	--Say(nil, s, false) -- console msg
	--Notifications:Bottom(id, {text=s, duration=5, style={color="orange"}, continue=false})
	--ShowCustomHeaderMessage(s, id, 1, 5) -- n/a
	--GameRules:SendCustomMessage(s, self.u:GetTeam(), 1) -- left bottom msg
	--ShowMessage(s) -- n/a
	--Say(self.u, s, false) -- console msg
	--Notifications:Bottom(PlayerResource:GetPlayer(id), {text=s, duration=5, style={color="red", ["font-size"]="110px", border="10px solid blue"}})
end

function Hero:disableInteraction(time)
	self.CantHoldBall = true
	Timers:CreateTimer(time, function()
		self.CantHoldBall = false
	end)
end

function Hero:dispossess(time)
	local Ball = GameRules.Ball
    self:setSpeed(290)
    if time > 0 then
        self:disableInteraction(time)
    end
    Ball.Owner = nil
end

function Hero:slowDown(time)
    self:setSpeed(0.5*290)
    self.SlowDown = true
    
    Timers:CreateTimer(time, function()
		self.SlowDown = false
		self:setSpeed(290)
	end)
end

function Hero:stop()
	self.u:Stop()
end

function Hero:setFacing(v)
	--Hero:setfVector(v)
	self:turn(v)
end

function Hero:setSpeed(speed)
	self.u:SetBaseMoveSpeed(speed)
end

function Hero:setHeight(h)
	Hero:setVector(Hero:getPos() + Vector(0,0,h)) -- Hero:uVector()*h
end

function Hero:getVector()
	return self.u:GetAbsOrigin()
end

function Hero:setVector(pos)
	return self.u:SetAbsOrigin(pos)
end

function Hero:getPos()
	return GetGroundPosition(self.u:GetAbsOrigin(), self.u)
end

function Hero:fVector()
	return self.u:GetForwardVector():Normalized()
end

function Hero:setfVector(v)
	self.u:SetForwardVector(v:Normalized())
end

function Hero:uVector()
	return self.u:GetUpVector()
end

function Hero:dist(h)
	return CalcDistanceBetweenEntityOBB(self.u, h)
end
