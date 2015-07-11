
function SetGetBallDist(val)
	print("In setgetbaldist")
	if val > 50 then
		GET_BALL_DIST = val
		print("Setting get ball dist to "..val)
		Say(Hero[0].u, "Setting get ball dist to "..val, false)
	end
end

function SetGoalScale(val)
	if val > 0 then
		local goal = GameRules.Goals['left']
		goal:SetModelScale(val)
		print("Setting goal scale to "..val)
		Say(Hero[0].u, "Setting goal scale to "..val, false)
	end
end

function GameMode:ExampleConsoleCommand2()
  print( '******* Example Console Command ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      -- Do something here for the player who called this command
      --PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_viper", 1000, 1000)
    end
  end
  print( '*********************************************' )
end

function RegisterCommands()
	Convars:RegisterCommand( "cmd_ex", Dynamic_Wrap(GameMode, 'ExampleConsoleCommand2'), "A console command example", FCVAR_CHEAT )

	Convars:RegisterCommand( "get", function(name, parameter)
	    local cmdPlayer = Convars:GetCommandClient()
	    if cmdPlayer then 
	        return SetGetBallDist( tonumber(parameter) )
	    end
	 end, "Set 'get ball distance' to specified value", 0 )

	Convars:RegisterCommand( "goal", function(name, parameter)
	    local cmdPlayer = Convars:GetCommandClient()
	    if cmdPlayer then 
	        return SetGoalScale( tonumber(parameter) )
	    end
	 end, "Set goal model scale", 0 )
end

function echo(s)
	Say(nil, s, false)
end

function GetRectCenter(rect)
	return Entities:FindByName(nil, rect):GetAbsOrigin()
end

-- (imax-imin) is how many times the line will be placed
function DrawLine(rect, imin, imax, x, y)
	local pos_line = GetRectCenter(rect)
	local line_v = Vector(x,y,0)
	local step = 30
	imin = imin*(20/step)
	imax = imax*(20/step)
	for i = imin, imax do
		local line = CreateUnitByName("npc_line", pos_line + line_v*i*step, false, nil, nil, DOTA_TEAM_NOTEAM)
		line:SetForwardVector(Vector(y,x,0))
		line:SetHullRadius(0.0)
	end
end

function DrawLines()
	local x,y

	x,y = -14,16
	DrawLine("rct_box_LB", x, y, 1, 0)
	DrawLine("rct_box_LT", x, y, 1, 0)
	DrawLine("rct_box_RB", x, y, 1, 0)
	DrawLine("rct_box_RT", x, y, 1, 0)

	x,y = -27,28
	DrawLine("rct_box_LR", x, y, 0, 1)
	DrawLine("rct_box_RL", x, y, 0, 1)

	x,y = -3,3
	DrawLine("post_LT", x, y, 1, 0)
	DrawLine("post_LB", x, y, 1, 0)

	x,y = -57,54
	DrawLine("rct_line_right", x, y, 0, 1)
	DrawLine("rct_line_left", x, y, 0, 1)
	DrawLine("rct_line_center", x, y, 0, 1)

	x,y = -101,87
	DrawLine("rct_line_top", x, y, 1, 0)
	DrawLine("rct_line_btm", x, y, 1, 0)
end

function CreateGoals()
	GameRules.Goals = {[1] = 0, [2] = 0}
	local goals = GameRules.Goals
	goals['left'] = CreateUnitByName("npc_goal", GetRectCenter("rct_goal_left"), false, nil, nil, DOTA_TEAM_NOTEAM)
	goals['right'] = CreateUnitByName("npc_goal", GetRectCenter("rct_goal_right"), false, nil, nil, DOTA_TEAM_NOTEAM)
	goals['right']:SetForwardVector(Vector(-1,0,0))
	goals['left']:SetHullRadius(0.0)
	goals['right']:SetHullRadius(0.0)
end

function SetGameplayConstants()
	G = 2.3

	GET_BALL_DIST 				= 125
	OWN_BALL_DIST				= GET_BALL_DIST/2

	GROUND_FRICTION_SLOWDOWN 	= 10.0
	GROUND_HIT_SLOWDOWN 		= 50.0

	CANT_HOLD_BALL_TIME_DISPOSSESSED  = 1.45
    CANT_HOLD_BALL_TIME_SHOT          = 0.9
end

function GameMode:InitActions()
	echo("Join the discussion at http://dotasoccer.freeforums.net/")

    SetGameplayConstants()
    RegisterCommands()

    Ball:new()
	Flag:new()

	CreateGoals()
	DrawLines()

	Timers:CreateTimer(function()
		GameMode:Ball_Periodic_Actions()
        GameMode:Set_Ball_Owner()
	 	return .1 --.03
	end)
end
