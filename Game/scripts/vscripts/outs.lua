function Roof_Hit(trigger)
	local Ball = GameRules.Ball
	Ball.Vz = Ball.Vz*(-0.6)
end

function Line_Crossed_Actions(trigger)
	local Ball = GameRules.Ball
	
	if Ball.Mode ~= 0 then return end

	print("Ball left the pitch!")
	print(trigger.activator:GetName())
	print(trigger.caller:GetName())
	echo("Ball is out of play!")

	local rect_name = trigger.caller:GetName()
	local s = rect_name
	local loc
	if s:find("BR") or s:find("BL") or s:find("TR") or s:find("TL") then
		rect_name = string.gsub(rect_name, "rct_out", "pt_corner")
		loc = GetRectCenter(rect_name)
	else
		rect_name = string.gsub(rect_name, "out", "line")
		loc = Ball:getPos()
		loc.y = GetRectCenter(rect_name).y -- ['y']
	end
	
	print(rect_name)
	local time = 1
	Ball:fullStopDelayed(time)

	Ball.Location 	= loc
	Ball.Mode 		= Ball.LastUser:getTeam()
end

function Ball_Enters_Goal_Actions(trigger)
	print("Goal triggered!")
	local goal_name = trigger.caller:GetName()
	local team
	if goal_name:find("left") then
		team = 1
	else
		team = 2
	end
	echo("Goal for team "..team.."!")
	local Ball = GameRules.Ball
	GameRules.Goals[team] = GameRules.Goals[team] + 1
	GameRules:GetGameModeEntity():SetTopBarTeamValue(team+1, GameRules.Goals[team]) --DOTA_TEAM_GOODGUYS
	
	local time = 1
	Ball:fullStopDelayed(time)

	Ball.Location 	= GetRectCenter('pt_center')
	Ball.Mode 		= Ball.LastUser:getTeam()
end
