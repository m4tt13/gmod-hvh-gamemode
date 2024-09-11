AddCSLuaFile( "ammo.lua" )
AddCSLuaFile( "animations.lua" )
AddCSLuaFile( "cl_deathnotice.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_menu.lua" )
AddCSLuaFile( "cl_pickteam.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "cl_targetid.lua" )
AddCSLuaFile( "cl_weapons.lua" )
AddCSLuaFile( "player_shd.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )
include( "menu.lua" )
include( "stats.lua" )
include( "votemap.lua" )
include( "player_ext.lua" )
include( "player.lua" )

WINNER_NONE = 1
WINNER_DRAW = 2
WINNER_TER	= 3
WINNER_CT	= 4

REASON_TER_WIN 			= 1
REASON_CT_WIN 			= 2
REASON_ROUND_DRAW 		= 3
REASON_GAME_COMMENCING	= 4

CreateConVar( "mp_round_restart_delay", "5.0", FCVAR_NONE, "Number of seconds to delay before restarting a round after a win.", 0, 10 )
CreateConVar( "mp_roundtime", "2.5", FCVAR_NONE, "How many minutes each round takes.", 1, 9 )
CreateConVar( "mp_freezetime", "6", FCVAR_NONE, "How many seconds to keep players frozen when the round starts.", 0, 60 )
CreateConVar( "mp_maxrounds", "0", FCVAR_NONE, "Max number of rounds to play before server changes maps.", 0 )
CreateConVar( "mp_winlimit", "0", FCVAR_NONE, "Max number of rounds one team can win before server changes maps.", 0 )
CreateConVar( "mp_ignore_round_win_conditions", "0", FCVAR_NONE, "Ignore conditions which would end the current round." )

util.AddNetworkString( "HvH_PlaySound" )
util.AddNetworkString( "HvH_ShowMenu" )

local round_end_info = {

	[REASON_TER_WIN] = {
	
		Winner = WINNER_TER,
		Sound  = Sound( "radio/terwin.wav" ),
		Msg	   = "Terrorists Win!"
	
	},
	
	[REASON_CT_WIN] = {
	
		Winner = WINNER_CT,
		Sound  = Sound( "radio/ctwin.wav" ),
		Msg	   = "Counter-Terrorists Win!"
	
	},
	
	[REASON_ROUND_DRAW] = {
	
		Winner = WINNER_DRAW,
		Sound  = Sound( "radio/rounddraw.wav" ),
		Msg	   = "Round Draw!"
	
	},
	
	[REASON_GAME_COMMENCING] = {
	
		Winner = WINNER_DRAW,
		Sound  = Sound( "radio/rounddraw.wav" ),
		Msg	   = "Game Commencing!"
	
	}

}

local round_start_snds = {

	Sound( "radio/go.wav" ),
	Sound( "radio/letsgo.wav" ),
	Sound( "radio/locknload.wav" ),
	Sound( "radio/moveout.wav" )

}

local function ReadMultiplayCvars()

	GAMEMODE.FreezeTime = GetConVarNumber( "mp_freezetime" )
	SetGlobalInt( "RoundTime", math.floor( GetConVarNumber( "mp_roundtime" ) * 60 ) )

end

function GM:Initialize()

	GAMEMODE.GameOver				= false
	GAMEMODE.FirstConnected 		= false
	GAMEMODE.CompleteReset 			= false
	GAMEMODE.RoundWinStatus 		= WINNER_NONE
	GAMEMODE.RestartRoundTime 		= 0.1
	GAMEMODE.IntermissionEndTime	= 0
	GAMEMODE.FreezeTime				= 0
	GAMEMODE.NumTerroristWins 		= 0
	GAMEMODE.NumCTWins 				= 0
	GAMEMODE.TotalRoundsPlayed		= -1
	
	SetGlobalBool( "FreezePeriod", true )
	SetGlobalInt( "RoundTime", 0 )
	SetGlobalFloat( "RoundStartTime", 0 )
	SetGlobalFloat( "GameStartTime", 0 )
	
	ReadMultiplayCvars()
	
	Stats_Load()
	
	VoteMap_Init()
	
end

local function UpdateTeamScores()

	team.SetScore( TEAM_TERRORIST, GAMEMODE.NumTerroristWins )
	team.SetScore( TEAM_CT, GAMEMODE.NumCTWins )

end

local function GoToIntermission()

	if ( GAMEMODE.GameOver ) then
		return
	end
	
	Msg( "Going to intermission...\n" )

	GAMEMODE.GameOver = true
	
	GAMEMODE.IntermissionEndTime = CurTime() + GetConVarNumber( "mp_chattime" )
	
	SetGlobalBool( "FreezePeriod", true )

	for id, pl in pairs( player.GetAll() ) do

		pl:Freeze( true )
		pl:SendLua( "GAMEMODE:ScoreboardShow()" )

	end

end

local function PlaySound( snd )

	net.Start( "HvH_PlaySound" )
		
		net.WriteString( snd )
	
	net.Broadcast()

end

local function TerminateRound( delay, reason )

	local winnerTeam = WINNER_NONE
	
	local reason_info = round_end_info[reason]
	
	if ( reason_info ) then
	
		winnerTeam = reason_info.Winner
		
		PrintMessage( HUD_PRINTCENTER, reason_info.Msg )
		
		PlaySound( reason_info.Sound )
	
	end

	GAMEMODE.RoundWinStatus 	= winnerTeam;
	GAMEMODE.RestartRoundTime 	= CurTime() + delay
	
	if ( GAMEMODE:GetMapRemainingTime() == 0 ) then
		GoToIntermission()
	end

end

function GM:CheckWinConditions()

	if ( GetConVarNumber( "mp_ignore_round_win_conditions" ) != 0 ) then
		return
	end

	local numTerrorist 		= 0
	local numAliveTerrorist	= 0
	local numCT 			= 0
	local numAliveCT		= 0

	for id, pl in pairs( player.GetAll() ) do
	
		if ( pl:Team() == TEAM_TERRORIST ) then
		
			numTerrorist = numTerrorist + 1
			
			if ( pl:Alive() ) then
				numAliveTerrorist = numAliveTerrorist + 1
			end
			
		elseif ( pl:Team() == TEAM_CT ) then
		
			numCT = numCT + 1
			
			if ( pl:Alive() ) then
				numAliveCT = numAliveCT + 1
			end
			
		end
		
	end

	if ( numTerrorist == 0 || numCT == 0 ) then
	
		Msg( "Game will not start until both teams have players.\n" )
		PrintMessage( HUD_PRINTCONSOLE, "Scoring will not start until both teams have players" )
		
		GAMEMODE.FirstConnected = false
		
	elseif ( !GAMEMODE.FirstConnected ) then

		GAMEMODE.FirstConnected = true
		GAMEMODE.CompleteReset = true
	
		SetGlobalBool( "FreezePeriod", false )
	
		TerminateRound( 3, REASON_GAME_COMMENCING )
	
		return
		
	end
	
	if ( GAMEMODE.RoundWinStatus != WINNER_NONE ) then
		return
	end
	
	if ( numTerrorist > 0 && numCT > 0 ) then
	
		if ( numAliveTerrorist == 0 ) then
			
			GAMEMODE.NumCTWins = GAMEMODE.NumCTWins + 1
			UpdateTeamScores()
			
			TerminateRound( GetConVarNumber( "mp_round_restart_delay" ), REASON_CT_WIN )
			
		elseif ( numAliveCT == 0 ) then
	
			GAMEMODE.NumTerroristWins = GAMEMODE.NumTerroristWins + 1
			UpdateTeamScores()
	
			TerminateRound( GetConVarNumber( "mp_round_restart_delay" ), REASON_TER_WIN )
	
		end
		
	elseif ( numAliveTerrorist == 0 && numAliveCT == 0 && ( numTerrorist > 0 || numCT > 0 ) ) then
	
		TerminateRound( GetConVarNumber( "mp_round_restart_delay" ), REASON_ROUND_DRAW )
	
	end

end

local function CheckGameOver()

	if ( GAMEMODE.GameOver ) then

		if ( GAMEMODE.IntermissionEndTime < CurTime() ) then
			game.LoadNextMap()
		end

		return true
		
	end

	return false
	
end

local function CheckFragLimit()

	local fraglimit = GetConVarNumber( "mp_fraglimit" )

	if ( fraglimit <= 0 ) then
		return false
	end
	
	for id, pl in pairs( player.GetAll() ) do

		if ( pl:Frags() >= fraglimit ) then
		
			GoToIntermission()
			return true
			
		end

	end
	
	return false

end

local function CheckMaxRounds()

	local maxrounds = GetConVarNumber( "mp_maxrounds" )

	if ( maxrounds != 0 ) then
	
		if ( GAMEMODE.TotalRoundsPlayed >= maxrounds ) then
		
			GoToIntermission()
			return true
			
		end
	
	end
	
	return false

end

local function CheckWinLimit()

	local winlimit = GetConVarNumber( "mp_winlimit" )

	if ( winlimit != 0 ) then
	
		if ( GAMEMODE.NumCTWins >= winlimit ) then
		
			GoToIntermission()
			return true
			
		end
		
		if ( GAMEMODE.NumTerroristWins >= winlimit ) then
		
			GoToIntermission()
			return true
			
		end
		
	end

	return false

end

local function CheckFreezePeriodExpired()

	if ( CurTime() < GAMEMODE:GetRoundStartTime() ) then
		return
	end

	SetGlobalBool( "FreezePeriod", false )
	
	PlaySound( round_start_snds[ math.random( #round_start_snds ) ] )

end

local function CheckRoundTimeExpired()

	if ( GetConVarNumber( "mp_ignore_round_win_conditions" ) != 0 ) then
		return
	end

	if ( GAMEMODE:GetRoundRemainingTime() > 0 || GAMEMODE.RoundWinStatus != WINNER_NONE ) then
		return
	end

	if ( !GAMEMODE.FirstConnected ) then
		return
	end

	TerminateRound( GetConVarNumber( "mp_round_restart_delay" ), REASON_ROUND_DRAW )
	
end

local function RestartRound()
	
	GAMEMODE.TotalRoundsPlayed = GAMEMODE.TotalRoundsPlayed + 1
	
	if ( GAMEMODE.CompleteReset ) then
	
		SetGlobalFloat( "GameStartTime", CurTime() )

		GAMEMODE.TotalRoundsPlayed	= 0
	
		GAMEMODE.NumTerroristWins	= 0
		GAMEMODE.NumCTWins			= 0
		
		UpdateTeamScores()
	
	end
	
	SetGlobalBool( "FreezePeriod", true )

	ReadMultiplayCvars()
	
	SetGlobalFloat( "RoundStartTime", CurTime() + GAMEMODE.FreezeTime )
	
	for id, pl in pairs( player.GetAll() ) do
	
		pl.SpawnedThisRound = false
	
		if ( pl:Team() == TEAM_TERRORIST || pl:Team() == TEAM_CT ) then
			pl:Spawn()
		end
		
	end
	
	game.CleanUpMap()
	
	GAMEMODE.CompleteReset 			= false
	GAMEMODE.RoundWinStatus			= WINNER_NONE
	GAMEMODE.RestartRoundTime 		= 0
	GAMEMODE.IntermissionEndTime	= 0
	
end

function GM:Think()

	if ( CheckGameOver() ) then
		return
	end

	if ( CheckMaxRounds() ) then
		return
	end

	if ( CheckFragLimit() ) then
		return
	end

	if ( CheckWinLimit() ) then
		return
	end

	if ( GAMEMODE:IsFreezePeriod() ) then
		CheckFreezePeriodExpired()
	else
		CheckRoundTimeExpired()
	end

	if ( GAMEMODE.RestartRoundTime > 0 && GAMEMODE.RestartRoundTime <= CurTime() ) then
		RestartRound()
	end
	
end

function GM:ShowHelp( ply )

	ply:ConCommand( "buymenu" )

end

function GM:ShowTeam( ply )

	ply:ConCommand( "teammenu" )

end
