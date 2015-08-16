require('ball')
require('hero')
require('abils')
require('globals')
require('flag')
require('outs')

function GameMode:HAnim()
	local Ball = GameRules.Ball
	local speed = Ball.Speed
	Ball:setVector( Ball:getVector() + 0.03*speed*Ball:fVector() )
end

function VAnim()
	local Ball = GameRules.Ball

	local b1 = Ball.Vz < 0
	local b2 = Ball.H <= Ball.DefaultHeight

	if b1 and b2 then
		--Ball hits ground
		Ball.Speed = math.max(Ball.Speed - GROUND_HIT_SLOWDOWN, 0)
		Ball:resetHeight()
		Ball:playSound("Ball.Land")

		if math.abs(Ball.Vz) < 5.0*G then
			--stop ball
			Flag:hide()
			Ball.IsInAir = false
			Ball.Vz = 0
		else
			Ball.Vz = (-0.6)*Ball.Vz
		end
	else
		--Update ball height
		Ball:setHeight( Ball.H + Ball.Vz )
		Ball.Vz = Ball.Vz - G

		-- smooth ball.h mechanism
		--[[local freq = 0.03
		local time_passed = freq
		Timers:CreateTimer(freq, function()
			if time_passed <= 0.09 then
				--Ball:setHeight( Ball.H + Ball.Vz*freq*10 )
				Ball:setVector(Ball:getPos() + Ball:uVector()*( Ball.H + Ball.Vz*freq*10 ))
				time_passed = time_passed + freq
				return freq
			else
				return
			end
		end)--]]
	end

	local Flag = GameRules.Flag
	Flag:Move()
end

function GameMode:Ball_Periodic_Actions()
	local Ball = GameRules.Ball

	if Ball.Owner == nil then
        --GameMode:HAnim()
        
        if Ball.IsInAir then
            VAnim()
        else
            Ball.Speed = math.max(Ball.Speed - GROUND_FRICTION_SLOWDOWN, 0)
        end
    else -- place ball in front of owner
        local h = Ball.Owner
        Ball.H = Ball.DefaultHeight + h.H
		Ball:setVector( h:getVector() + 50*h:fVector() + Ball.DefaultHeight*Ball:uVector() ) -- (GET_BALL_DIST/2)

		-- throw-in
		if Ball.Mode ~= 0 and Ball.Mode == h:getTeam() and Ball.Location then
			h:setVector(Ball.Location)
			h:stop()
		end
    end
end

function GameMode:Heading_Actions(h) --h
	print 'heading actions'
	local Ball = GameRules.Ball
    local dist = 700
    local time = math.sqrt(2*Ball.H/G)*0.1
    local speed = math.max(Ball.Speed, 350)
    
    if dist < speed*time then
        Ball.Vz = 0
        speed = dist/time
    else
        Ball.Vz = math.min(10, 10*G*dist*0.5/speed)
    end
    Ball.Speed = speed
    Ball.IsInAir = true
    Ball:setfVector(h:fVector())
    --if ( Per_001_Execution )
    h:disableInteraction(0.9) -- 0.95
    Ball:disableInteraction(0.9)
    
    --Flag:show()
    Ball:playSound("Ball.Kick")
end

function Sliding_Actions(h)
	print 'sliding actions'
	local Ball = GameRules.Ball
    --h:disableInteraction(TimerGetRemaining(h.SlowDownTimer));

    if Ball.Owner then
    	local h2 = Ball.Owner
    	h2:dispossess(0.95)
    	h2:slowDown(0.95)
    end
    
    Ball:disableInteraction(0.45)
    Ball.Speed = 400
    Ball:setfVector(h:fVector())
end

function Get_Ball(h)
	local Ball = GameRules.Ball
    if Ball.Owner then
        local h2 = Ball.Owner
        h2:dispossess(CANT_HOLD_BALL_TIME_DISPOSSESSED)
        h2:msg("You've lost the ball...", "blue")
    end
    
    Ball.Owner = h
    h:setSpeed(200)
    h:msg("YOU GOT THE BALL!")
    
    Ball.Speed = 0
    --StartAnimation(Ball.u, {duration=5, activity=ACT_DOTA_RUN, rate=0.2}) --RUN/IDLE
    --EndAnimation(Ball.u)
end

function CanUnitGetBall(h)
	local Ball = GameRules.Ball
	local b1 = not Ball.CantInteract
	local b2 = not h.CantHoldBall
	local b3 = Ball.Owner ~= h
	local b4 = Ball.H >= h.H and Ball.H <= h.H + h.Tallness

	local b5 = true
	if Ball.Owner then
		b5 = Ball.Owner:getTeam() ~= h:getTeam()
	end
	--local b5 = Ball.Owner and (Ball.Owner:getTeam() ~= h:getTeam()) or true
	local dist = (h:getPos() - Ball:getPos()):Length()--CalcDistanceBetweenEntityOBB(Ball.u, h.u)
	local b6 = dist <= GET_BALL_DIST

	local b7 = true
	if Ball.Mode ~= 0 then
		b7 = Ball.Mode == h:getTeam()
	end

	return b1 and b2 and b3 and b4 and b5 and b6 and b7
end

function CanUnitHeadBall(h)
    local b1 = h.IsInAir
    local b2 = h.Vz >= 0
    
    return b1 and b2
end

function GameMode:Set_Ball_Owner()
	local Ball = GameRules.Ball

	--[[ FindUnitsInRadius(int teamNumber, Vector position, handle cacheUnit, float radius, 
		int teamFilter, int typeFilter, int flagFilter, int order, bool canGrowCache) --]]
	--for _,u in pairs(Entities:FindAllInSphere(Ball:getVector(), GET_BALL_DIST) ) do
	for id = 0, 15 do
		local h = GetHero(id)
		if h and CanUnitGetBall(h) then
		    if CanUnitHeadBall(h) then
		        if (Ball.Owner == nil) then
		            GameMode:Heading_Actions(h)
		        end
		    else
		        Flag:hide()
		        if h.Slide_Vx and h.Slide_Vx > 0 then
		            if not (Ball.Owner and Ball.Owner.IsInAir) then
		                Sliding_Actions(h)
		            end
		        elseif not h.SlowDown then --if not Per_003_Execution
		            Get_Ball(h)
		        end
		    end
		end
	end
end
