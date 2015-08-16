function GameMode:ShotCommonActions()
	local Ball = GameRules.Ball
	Ball.Mode = 0
	--Ball.Location = nil
end

function GetSpellAbilityUnit(keys)
	return keys.caster
end

function GetHero(id)
	return Hero[id]
end

function Pass_Actions(keys)
	print("Q actions")
	local Ball = GameRules.Ball
	local id = keys.caster:GetPlayerOwnerID()
	local h = GetHero(id)

	if not (Ball.Owner and Ball.Owner.IsInAir) then
		h:dispossess(CANT_HOLD_BALL_TIME_SHOT)
		Ball:resetHeight()
		return
	end

	Ball.Vz 			= 0
	Ball.H 				= Ball.DefaultHeight + h.H
	Ball.IsInAir 		= h.IsInAir
	Ball.Speed 			= 522

	Ball:disableInteraction(0.7)
	Ball:setfVector(h:fVector())

	h:dispossess(CANT_HOLD_BALL_TIME_SHOT)
	GameMode:ShotCommonActions()
end

function Kick_Actions(keys)
	local Ball = GameRules.Ball
	local id = keys.caster:GetPlayerOwnerID()
	local h = GetHero(id)
	local direction

	if h == Ball.Owner then
		direction = keys.target_points[1] - Ball:getPos()
        Ball.IsInAir 		= true
		Ball.Vz 			= 20
		Ball.Speed			= 362
		--Ball.H 				= Ball.DefaultHeight + h.H

		Ball:setfVector(direction)
		Ball:disableInteraction(0.7)
		Flag:show()

		h:dispossess(CANT_HOLD_BALL_TIME_SHOT)
		--h:stop()

		Ball:playSound("Ball.Kick")
		GameMode:ShotCommonActions()

    elseif not h.IsInAir and not h.SlowDown then
    	direction = keys.target_points[1] - h:getPos()
    	h.Slide_Vx = 40
        h.Slide_Direction = (keys.target_points[1] - h:getPos()):Normalized()
        h:slowDown(2.5)
        
        Timers:CreateTimer(0.1, function()
            if not h.SlowDown then
                h.Slide_Vx = nil
                h.Slide_Direction = nil
                return
            elseif h.Slide_Vx > 0 then
                h:setVector(h:getVector()+h.Slide_Direction*h.Slide_Vx)
                h.Slide_Vx = h.Slide_Vx - 3
                return 0.1
            end
        end)
	end

	h:turn(direction)
end

function LongPass_Actions(keys)
	local Ball = GameRules.Ball
	local id = keys.caster:GetPlayerOwnerID()
	local h = GetHero(id)

	if not Ball.Owner or Ball.Owner ~= h or Ball.Owner.IsInAir then 
		h:turn(keys.target_points[1] - h:getPos())
		return
	end

	Ball.IsInAir 		= true
	Ball.Vz 			= 30 --30
	Ball.H 				= Ball.DefaultHeight

	local direction = keys.target_points[1] - Ball:getPos()
	Ball:setfVector(direction)

	local dist = direction:Length()
	Ball.Speed = 10 * G * dist * 0.5 / Ball.Vz
	Ball.Speed = math.min(Ball.Speed, 522)
	Ball:disableInteraction(0.7)
	Flag:show()

	h:stop()
	h:dispossess(CANT_HOLD_BALL_TIME_SHOT)
	h:slowDown(1.0)
	h:turn(direction)

	Ball:playSound("Ball.Kick")
	GameMode:ShotCommonActions()
end

function Jump_Actions(keys)
	local Ball = GameRules.Ball
	local id = keys.caster:GetPlayerOwnerID()
	local h = GetHero(id)

	print("Jump id ="..id)
	print("h.id = "..h.id)
	print("h.u.id = "..h.u.id)
	print("Hero[id].id = "..Hero[id].id)

    if h.IsInAir or h.SlowDown then return end
    
	h.IsInAir = true
    h.Vz = (Ball.Owner == h) and 15 or 20

	Timers:CreateTimer(0.1, function()
    	if h.IsInAir then
    		h:setHeight(h.H)
    		return 0.02
    	end
    	return
    end)

	Timers:CreateTimer(0.1, function()
		if h.H > h.H+h.Vz and math.abs(h.Vz) <= G then
			print((0.1).." max height: "..h.H)
		end

	  	h.H = h.H + h.Vz
		h:setHeight(h.H)
		h.Vz = h.Vz - G

		-- landing check
		if h.H < 0 then
            h.IsInAir = false
            h.H = 0
            h:setHeight( h.H )
            h.Vz = 0
            return
        end

		return 0.1
	end)
end

function Teleport_Actions(keys)
	local id = keys.caster:GetPlayerOwnerID()
	local h = GetHero(id)
	local Ball = GameRules.Ball
	Ball.Mode = 0
	h:setVector(keys.target_points[1])
	h:stop()
end
