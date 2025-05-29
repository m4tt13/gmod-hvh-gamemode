include( "util.lua" )
include( "ammo.lua" )
include( "animations.lua" )
include( "player_shd.lua" )

GM.Name = "Hack vs Hack"
GM.Author = "MattDoggie"
GM.Version = "1.2.3"

GM.TeamBased = true

TEAM_TERRORIST 	= 1
TEAM_CT 		= 2

MODEL_T_PHOENIX	 = 1
MODEL_T_L33T	 = 2
MODEL_T_ARCTIC	 = 3
MODEL_T_GUERILLA = 4

MODEL_CT_SEAL	= 1
MODEL_CT_GSG9	= 2
MODEL_CT_SAS	= 3
MODEL_CT_GIGN	= 4

WPNTYPE_PITSOL		= 1
WPNTYPE_SHOTGUN		= 2
WPNTYPE_SMG			= 3
WPNTYPE_RIFLE		= 4
WPNTYPE_SNIPER		= 5
WPNTYPE_MACHINEGUN	= 6

WPNSLOT_PRIMARY		= 0
WPNSLOT_SECONDARY	= 1
WPNSLOT_MELEE		= 2

COLOR_NICKNAME		= Color( 127, 255, 127 )
COLOR_MAPNAME		= Color( 185, 220, 85 )

function GM:CreateTeams()

	team.SetUp( TEAM_TERRORIST, "Terrorists", Color( 255, 64, 64, 255 ) )
	team.SetSpawnPoint( TEAM_TERRORIST, "info_player_terrorist" )

	team.SetUp( TEAM_CT, "Counter-Terrorists", Color( 153, 204, 255, 255 ) )
	team.SetSpawnPoint( TEAM_CT, "info_player_counterterrorist" )

	team.SetColor( TEAM_CONNECTING, Color( 204, 204, 204, 255 ) )
	team.SetColor( TEAM_UNASSIGNED, Color( 204, 204, 204, 255 ) )
	team.SetColor( TEAM_SPECTATOR, Color( 204, 204, 204, 255 ) )
	
	team.SetSpawnPoint( TEAM_SPECTATOR, "worldspawn" )

end

function GM:IsFreezePeriod()

	return GetGlobalBool( "FreezePeriod", false )
	
end

local nextlevel = GetConVar( "nextlevel" )
local mp_timelimit = GetConVar( "mp_timelimit" )

function GM:GetMapRemainingTime()

	if ( nextlevel:GetString() != "" ) then
		return 0
	end

	local timelimit = mp_timelimit:GetInt()

	if ( timelimit <= 0 ) then
		return -1
	end

	local TimeLeft = ( GetGlobalFloat( "GameStartTime", 0 ) + timelimit * 60 ) - CurTime()

	if ( TimeLeft < 0 ) then
		TimeLeft = 0
	end

	return TimeLeft
	
end

function GM:GetRoundRemainingTime()

	return ( GetGlobalFloat( "RoundStartTime", 0 ) + GetGlobalInt( "RoundTime", 150 ) ) - CurTime()
	
end

function GM:GetRoundStartTime()

	return GetGlobalFloat( "RoundStartTime", 0 )
	
end

PlayerModels = {

	[TEAM_TERRORIST] = {

		[MODEL_T_PHOENIX] 	= { Name = "Phoenix",	MDL = Model( "models/player/phoenix.mdl" ) },
		[MODEL_T_L33T] 		= { Name = "Elite",		MDL = Model( "models/player/leet.mdl" ) },
		[MODEL_T_ARCTIC] 	= { Name = "Arctic",	MDL = Model( "models/player/arctic.mdl" ) },
		[MODEL_T_GUERILLA] 	= { Name = "Guerilla",	MDL = Model( "models/player/guerilla.mdl" ) }
		
	},

	[TEAM_CT] = {
		
		[MODEL_CT_SEAL] 	= { Name = "SEAL",		MDL = Model( "models/player/urban.mdl" ) },
		[MODEL_CT_GSG9] 	= { Name = "GSG9",		MDL = Model( "models/player/riot.mdl" ) },
		[MODEL_CT_SAS] 		= { Name = "SAS",		MDL = Model( "models/player/gasmask.mdl" ) },	
		[MODEL_CT_GIGN] 	= { Name = "GIGN",		MDL = Model( "models/player/swat.mdl" ) }
		
	}
}
