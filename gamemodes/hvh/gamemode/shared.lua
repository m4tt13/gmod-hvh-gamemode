include( "util.lua" )
include( "ammo.lua" )
include( "animations.lua" )
include( "player_shd.lua" )

GM.Name = "Hack vs Hack"
GM.Author = "MattDoggie"
GM.Version = "1.2.18"

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
WPNTYPE_KNIFE		= 7
WPNTYPE_UNKNOWN		= 8

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

	return GetGlobal2Bool( "FreezePeriod", false )
	
end

local mp_timelimit = GetConVar( "mp_timelimit" )

function GM:GetMapRemainingTime()

	local timelimit = mp_timelimit:GetInt()

	if ( timelimit <= 0 ) then
		return -1
	end

	local TimeLeft = ( GetGlobal2Float( "GameStartTime", 0 ) + timelimit * 60 ) - CurTime()

	if ( TimeLeft < 0 ) then
		TimeLeft = 0
	end

	return TimeLeft
	
end

local mp_roundtime = CreateConVar( "mp_roundtime", "2.5", { FCVAR_NOTIFY, FCVAR_REPLICATED }, "How many minutes each round takes.", 1, 60 )

function GM:GetRoundRemainingTime()

	return ( GetGlobal2Float( "RoundStartTime", 0 ) + math.floor( mp_roundtime:GetFloat() * 60 ) ) - CurTime()
	
end

function GM:GetRoundStartTime()

	return GetGlobal2Float( "RoundStartTime", 0 )
	
end

g_PlayerModels = {

	[TEAM_TERRORIST] = {

		[MODEL_T_PHOENIX] 	= { Name = "Phoenix",	Model = "models/player/phoenix.mdl",	Image = "vgui/gfx/vgui/terror"  },
		[MODEL_T_L33T] 		= { Name = "Elite",		Model = "models/player/leet.mdl", 		Image = "vgui/gfx/vgui/leet" },
		[MODEL_T_ARCTIC] 	= { Name = "Arctic",	Model = "models/player/arctic.mdl", 	Image = "vgui/gfx/vgui/arctic" },
		[MODEL_T_GUERILLA] 	= { Name = "Guerilla",	Model = "models/player/guerilla.mdl", 	Image = "vgui/gfx/vgui/guerilla" }
		
	},

	[TEAM_CT] = {
		
		[MODEL_CT_SEAL] 	= { Name = "SEAL",		Model = "models/player/urban.mdl", 		Image = "vgui/gfx/vgui/urban" },
		[MODEL_CT_GSG9] 	= { Name = "GSG9",		Model = "models/player/riot.mdl", 		Image = "vgui/gfx/vgui/gsg9" },
		[MODEL_CT_SAS] 		= { Name = "SAS",		Model = "models/player/gasmask.mdl",	Image = "vgui/gfx/vgui/sas" },	
		[MODEL_CT_GIGN] 	= { Name = "GIGN",		Model = "models/player/swat.mdl", 		Image = "vgui/gfx/vgui/gign" }
		
	}
}
