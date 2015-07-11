function Ball:fullStopDelayed(time)
	local Flag = GameRules.Flag
	local Ball = GameRules.Ball
	if Ball.Owner then
		Ball.Owner:dispossess(time)
	end
	Ball:disableInteraction(time+0.5)
	Timers:CreateTimer(time, function()
		Ball.Vz 		= 0
		Ball.Speed 		= 0
		Ball.IsInAir 	= false
		Ball:resetHeight()
		Ball:stop()
		Ball:setVector(Ball.Location)
		Flag:hide()
	end)
end

function Line_Crossed_Actions(trigger)
	print("Ball left the pitch!")
	DeepPrintTable(trigger)
	if trigger.caller then
		print("trigger.caller is not nil!")
		print(trigger.activator)
		print(trigger.caller)
	end
	local Ball = GameRules.Ball
	local time = 1
	local loc = Ball:getPos()
	--local rect = trigger.caller:GetName()
	--loc['y'] = GetRectCenter()['y']
	Ball.Location 	= loc
	Ball:fullStopDelayed(time)
end

function Ball_Enters_Goal_Actions(trigger)
	print("Goal triggered!")
	local Ball = GameRules.Ball
	local time = 1
	GameRules.Goals[1] = GameRules.Goals[1] + 1
	Ball.Location = GetRectCenter('pt_center')
	Ball:fullStopDelayed(time)
end
