function GameMode:ShotCommonActions()
	--
end

function GetSpellAbilityUnit(keys)
	return keys.caster
end

function GetHero(id)
	--return GameRules.Heroes[id]
	return Hero[id]
end

function Pass_Actions(keys)
	print("Q actions")
	local Ball = GameRules.Ball
	local id = keys.caster:GetPlayerOwnerID()
	local h = GetHero(id)
	print("Q id ="..id)
	print("h.u.id = "..h.u.id)
	print("h.id = "..h.id)
	print("GameRules.Heroes[id].id = "..GameRules.Heroes[id].id)

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
	--GameMode:ShotCommonActions()
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

    elseif not h.IsInAir and not h.SlowDown then
    	direction = keys.target_points[1] - h:getPos()
    	h.Slide_Vx = 40
        h.Slide_Direction = (keys.target_points[1] - h:getPos()):Normalized()
        h:slowDown(2.5)
        
        Timers:CreateTimer(0.1, function()
            if not h.SlowDown then
                --sld.destroy()
                --h.Slide = nil
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

	if not Ball.Owner or Ball.Owner.IsInAir then 
		h:turn(keys.target_points[1] - h:getPos())
		return
	end

	Ball.IsInAir 		= true
	Ball.Vz 			= 30
	Ball.H 				= Ball.DefaultHeight
	--Ball.u:StartGesture(ACT_DOTA_RUN)

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
end

function Jump_Actions(keys)
	local Ball = GameRules.Ball
	local id = keys.caster:GetPlayerOwnerID()
	local h = GetHero(id)
	local u_saved = h.u
    
	if keys.caster:IsHero() then h.u = keys.caster; print("caster is hero!") end

    if h.IsInAir or h.SlowDown then return end

    --h.u:SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
    
	h.IsInAir = true
    h.Vz = (Ball.Owner == h) and 15 or 20
    
	local coef = 1 --0.3 to 1

	Timers:CreateTimer(0.1, function()
    	if h.IsInAir then
    		h:setHeight(h.H)
    		return 0.02
    	end
    	return
    end)

	Timers:CreateTimer(0.1, function()
		if h.H > h.H+coef*h.Vz and math.abs(h.Vz) <= coef*G then
			print((coef/10).." max height: "..h.H)
		end

	  	h.H = h.H + coef*h.Vz
		h:setHeight(h.H) -- Vector(0,0,h.H)
		--h.u:SetAbsOrigin(GetGroundPosition(h.u:GetAbsOrigin(),h.u)+Vector(0,0,h.H))
		h.Vz = h.Vz - coef*G
		--print("h.H="..h.H)

		-- landing check
		if h.H < 0 then
            h.IsInAir = false
            h.H = 0
            h:setHeight( h.H )
            --h.u:SetAbsOrigin(GetGroundPosition(h.u:GetAbsOrigin(),h.u)+Vector(0,0,h.H))
            h.Vz = 0

            --h.u:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
            if h.u:IsHero() then h.u = u_saved end

            return
        end

		return coef/10
	end)
end

function Teleport_Actions(keys)
	local id = keys.caster:GetPlayerOwnerID()
	local h = GetHero(id)
	h:setVector(keys.target_points[1])
	h:stop()
end
