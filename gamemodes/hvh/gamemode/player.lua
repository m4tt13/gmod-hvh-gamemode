DEFINE_BASECLASS( "gamemode_base" )

CreateConVar( "mp_flood_time", "0.75", FCVAR_NONE, "Amount of time allowed between chat messages." )
CreateConVar( "mp_join_grace_time", "15.0", FCVAR_NONE, "Number of seconds after round start to allow a player to join a game.", 0, 30 )
CreateConVar( "mp_teamswitch_cooldown", "10.0", FCVAR_NONE, "Number of seconds between being able to switch team." )
CreateConVar( "sv_noplayercollision", "1", FCVAR_NONE, "Disable player collision." )
CreateConVar( "sv_nodamageforces", "1", FCVAR_NONE, "Disable forces from physics damage." )
CreateConVar( "sv_jump_impulse", "270", FCVAR_NONE, "Initial upward velocity for player jumps; sqrt(2*gravity*height)." )
CreateConVar( "sv_falldamage_scale", "1" )
CreateConVar( "mp_damage_scale_head", "4.0" )
CreateConVar( "mp_damage_scale_chest", "1.0" )
CreateConVar( "mp_damage_scale_stomach", "1.25" )
CreateConVar( "mp_damage_scale_arms", "1.0" )
CreateConVar( "mp_damage_scale_legs", "0.75" )
CreateConVar( "mp_deathsound", "0" )
CreateConVar( "mp_allowtaunts", "0" )

local function IsValidObsTarget( ply, target )

	if ( !IsValid( target ) ) then
		return false
	end
	
	if ( !target:IsPlayer() ) then
		return false
	end
	
	if ( target == ply ) then
		return false
	end
	
	if ( target:GetNoDraw() ) then
		return false
	end
	
	if ( target:Alive() ) then
		return true
	end
	
	if ( target.DeathTime && CurTime() < ( target.DeathTime + 3 ) ) then
		return true
	end
	
	return false

end

local function GetNextObsSearchStartPoint( ply, reverse )

	local curObsTarget = ply:GetObserverTarget()
	
	if ( !IsValid( curObsTarget ) ) then
		curObsTarget = ply
	end
	
	local dir = reverse && -1 || 1
	local startIndex = curObsTarget:EntIndex() + dir
	
	if ( startIndex > game.MaxPlayers() ) then
		startIndex = 1
	elseif ( startIndex < 1 ) then
		startIndex = game.MaxPlayers()
	end

	return startIndex

end

local function FindNextObsTarget( ply, reverse )

	local startIndex = GetNextObsSearchStartPoint( ply, reverse )
	local currentIndex = startIndex
	local dir = reverse && -1 || 1
	
	repeat
	
		local nextObsTarget = Entity( currentIndex )
		
		if ( IsValidObsTarget( ply, nextObsTarget ) ) then
			return nextObsTarget
		end
		
		currentIndex = currentIndex + dir
		
		if ( currentIndex > game.MaxPlayers() ) then
			currentIndex = 1
		elseif ( currentIndex < 1 ) then
			currentIndex = game.MaxPlayers()
		end
		
	until ( currentIndex == startIndex )

	return NULL
	
end

function GM:KeyPress( player, key )

	if ( key == IN_RELOAD ) then
	
		local mode = player:GetObserverMode()
		
		if ( mode > OBS_MODE_FIXED ) then
		
			mode = mode + 1
		
			if ( mode > OBS_MODE_ROAMING ) then
				mode = OBS_MODE_IN_EYE;
			end
			
			player:SetObserverMode( mode )
			player.ObserverLastMode = mode

		end
		
	elseif ( key == IN_ATTACK ) then
	
		if ( player:GetObserverMode() > OBS_MODE_FIXED ) then
		
			local obsTarget = FindNextObsTarget( player, false )
			
			if ( IsValid( obsTarget ) ) then
				player:SpectateEntity( obsTarget )
			end
			
		end
	
	elseif ( key == IN_ATTACK2 ) then
	
		if ( player:GetObserverMode() > OBS_MODE_FIXED ) then
		
			local obsTarget = FindNextObsTarget( player, true )
			
			if ( IsValid( obsTarget ) ) then
				player:SpectateEntity( obsTarget )
			end
			
		end
	
	end
	
end

local function ValidateCurObsTarget( ply )

	local mode = ply:GetObserverMode()
	
	if ( mode != OBS_MODE_IN_EYE && mode != OBS_MODE_CHASE ) then
		return
	end

	if ( !IsValidObsTarget( ply, ply:GetObserverTarget() ) ) then
	
		local obsTarget = FindNextObsTarget( ply, false )
		
		if ( IsValid( obsTarget ) ) then
			ply:SpectateEntity( obsTarget )
		else
			ply:SetObserverMode( OBS_MODE_ROAMING )
		end
	
	end

end

function GM:PlayerPostThink( ply )

	ValidateCurObsTarget( ply )

end

function GM:PlayerAuthed( ply, steamid, uniqueid )

	Stats_LoadPlayer( ply, steamid )

end

function GM:PlayerDisconnected( ply )

	Stats_SavePlayer( ply )

	ply:SetTeam( TEAM_UNASSIGNED )

	GAMEMODE:CheckWinConditions()

end

local wpn_by_alias = nil

local function GetWeaponByAlias( alias )

	if ( !wpn_by_alias ) then
	
		local tbl = {}
		
		for k, v in pairs( weapons.GetList() ) do
		
			if ( v && v.Alias ) then
				tbl[ v.Alias ] = v
			end
			
		end
		
		wpn_by_alias = tbl
	
	end

	return wpn_by_alias[alias]

end

local function StockPlayerAmmo( pl )

	for id, wpn in pairs( pl:GetWeapons() ) do
	
		local ammoType = wpn:GetPrimaryAmmoType()
	
		if ( ammoType != -1 ) then
		
			pl:GiveAmmo( 9999, ammoType, true )
			wpn:SetClip1( wpn:GetMaxClip1() )
			
		end
		
	end

end

local function GiveWeapon( ply, weapon, translate )

	if ( !IsValid( ply ) || !ply:Alive() ) then 
		return false
	end
	
	local teamid = ply:Team()

	if ( teamid != TEAM_TERRORIST && teamid != TEAM_CT ) then
		return false
	end
	
	local swep = translate && GetWeaponByAlias( weapon ) || weapons.GetStored( weapon )
			
	if ( !swep || !swep.CanBuy ) then 
		return false
	end
	
	for id, wpn in pairs( ply:GetWeapons() ) do
				
		if ( wpn:GetSlot() == swep.Slot ) then
			ply:StripWeapon( wpn:GetClass() )
		end
		
	end
	
	ply:Give( swep.ClassName )
	StockPlayerAmmo( ply )
	
	return true
	
end
concommand.Add( "giveweapon", function( pl, cmd, args ) GiveWeapon( pl, args[1], false ) end )

local function PlayerFloodCheck( ply )

	local maxChat = GetConVar( "mp_flood_time" ):GetFloat()
	
	if ( maxChat <= 0 ) then
		return false
	end

	if ( !ply.FloodLastTime )	then ply.FloodLastTime	 = 0 end
	if ( !ply.FloodTokenCount )	then ply.FloodTokenCount = 0 end
	
	local blocked = false
	local newTime = CurTime() + maxChat

	if ( ply.FloodLastTime >= CurTime() ) then
	
		if ( ply.FloodTokenCount >= 3 ) then
		
			newTime = newTime + 3
			blocked = true
		
		else
		
			ply.FloodTokenCount = ply.FloodTokenCount + 1
		
		end

	elseif ( ply.FloodTokenCount > 0 ) then

		ply.FloodTokenCount = ply.FloodTokenCount - 1
	
	end
	
	ply.FloodLastTime = newTime
	return blocked

end

function GM:PlayerSay( ply, text, teamonly )

	if ( PlayerFloodCheck( ply ) ) then
	
		ply:ChatPrint( "You are flooding the server!" )
		return ""
		
	end

	local hidechat = false
	local prefix = false
	local ltext = string.lower( text )
	
	if ( ltext[1] == "/" || ltext[1] == "!" ) then

		if ( ltext[1] == "/" ) then
			hidechat = true
		end

		prefix = true
		ltext = string.sub( ltext, 2 )
		
	end

	if ( ltext == "nextmap" ) then
	
		local nextmap = GetConVar( "nextlevel" ):GetString()
		
		if ( nextmap == "" ) then
			nextmap = game.GetMapNext()
		end
		
		PrintMessage( HUD_PRINTTALK, "Next Map: " .. nextmap )
	
	elseif ( ltext == "currentmap" ) then
	
		PrintMessage( HUD_PRINTTALK, "The current map is " .. game.GetMap() )
	
	elseif ( ltext == "timeleft" ) then
	
		if ( GetConVar( "mp_timelimit" ):GetInt() > 0 ) then
		
			local TimeLeft = GAMEMODE:GetMapRemainingTime()
			
			if ( TimeLeft <= 0 ) then
				PrintMessage( HUD_PRINTTALK, "This is the last round!" )
			else
				PrintMessage( HUD_PRINTTALK, "Time remaining for map: " .. string.FormattedTime( TimeLeft, "%i:%02i" ) )
			end
			
		else
		
			PrintMessage( HUD_PRINTTALK, "No timelimit for map" )
		
		end
	
	elseif ( ltext == "rank" ) then
		
		Stats_ShowRank( ply )
		
	elseif ( ltext == "top" || ltext == "top10" ) then
		
		Stats_ShowTopPlayers( ply )
		
	elseif ( prefix ) then
	
		if ( ltext == "spec" ) then
		
			ply:ConCommand( "changeteam " .. TEAM_SPECTATOR )
	
		elseif ( ltext == "rs" || ltext == "resetscore" ) then
		
			ply:SetFrags( 0 )
			ply:SetDeaths( 0 )
			PrintMessage( HUD_PRINTTALK, ply:Nick() .. " has reset his score." )
	
		elseif ( !GiveWeapon( ply, ltext, true ) ) then
		
			hidechat = false
		
		end
		
	end

	return hidechat && "" || text

end

function GM:PlayerDeathThink( pl )

	if ( pl:GetObserverMode() != OBS_MODE_DEATHCAM ) then
		return
	end
	
	if ( pl.DeathTime && CurTime() < ( pl.DeathTime + 3 ) ) then
		return
	end
	
	pl:Spectate( pl.ObserverLastMode || OBS_MODE_ROAMING )

end

function GM:PlayerSilentDeath( victim )

	victim.NextSpawnTime = CurTime() + 2
	victim.DeathTime = CurTime()

end

function GM:PlayerDeath( ply, inflictor, attacker )

	ply.NextSpawnTime = CurTime() + 2
	ply.DeathTime = CurTime()

	if ( IsValid( attacker ) && attacker:GetClass() == "trigger_hurt" ) then attacker = ply end

	if ( IsValid( attacker ) && attacker:IsVehicle() && IsValid( attacker:GetDriver() ) ) then
		attacker = attacker:GetDriver()
	end

	if ( !IsValid( inflictor ) && IsValid( attacker ) ) then
		inflictor = attacker
	end

	if ( IsValid( inflictor ) && inflictor == attacker && ( inflictor:IsPlayer() || inflictor:IsNPC() ) ) then

		inflictor = inflictor:GetActiveWeapon()
		if ( !IsValid( inflictor ) ) then inflictor = attacker end

	end
	
	local isHeadshot = ( ply:LastHitGroup() == HITGROUP_HEAD )
	
	Stats_OnPlayerDeath( ply, attacker, isHeadshot )
	
	if ( IsValidObsTarget( ply, attacker ) ) then
		ply:SpectateEntity( attacker )
	end

	if ( attacker == ply ) then

		net.Start( "PlayerKilledSelf" )
			net.WriteEntity( ply )
		net.Broadcast()

		MsgAll( attacker:Nick() .. " suicided!\n" )

		return
		
	end

	if ( attacker:IsPlayer() ) then

		net.Start( "PlayerKilledByPlayer" )

			net.WriteEntity( ply )
			net.WriteString( inflictor:GetClass() )
			net.WriteEntity( attacker )
			net.WriteBool( isHeadshot )

		net.Broadcast()

		MsgAll( attacker:Nick() .. " killed " .. ply:Nick() .. " using " .. inflictor:GetClass() .. "\n" )

		return
		
	end

	net.Start( "PlayerKilled" )

		net.WriteEntity( ply )
		net.WriteString( inflictor:GetClass() )
		net.WriteString( attacker:GetClass() )

	net.Broadcast()

	MsgAll( ply:Nick() .. " was killed by " .. attacker:GetClass() .. "\n" )

end

function GM:PostPlayerDeath( ply )

	ply:StripWeapons()

	ply:Spectate( OBS_MODE_DEATHCAM )
	ply:RemoveEffects( EF_NODRAW )

	GAMEMODE:CheckWinConditions()

end

function GM:PlayerInitialSpawn( pl, transiton )

	pl:SetTeam( TEAM_UNASSIGNED )
	pl:ConCommand( "gm_showteam" )

end

function GM:PlayerSpawnAsSpectator( pl )

	pl:StripWeapons()

	if ( pl:Team() == TEAM_UNASSIGNED ) then

		pl:Spectate( OBS_MODE_FIXED )
		return

	end

	pl:SetTeam( TEAM_SPECTATOR )
	pl:Spectate( pl.ObserverLastMode || OBS_MODE_ROAMING )

end

local function SetUpPlayerVars( ply )

	ply:SetSlowWalkSpeed( 100 )
	ply:SetWalkSpeed( 250 )
	ply:SetRunSpeed( 250 )
	ply:SetCrouchedWalkSpeed( 0.3 )
	ply:SetDuckSpeed( 0.3 )
	ply:SetUnDuckSpeed( 0.2 )
	ply:SetJumpPower( GetConVar( "sv_jump_impulse" ):GetFloat() )
	ply:AllowFlashlight( true )
	ply:SetMaxHealth( 100 )
	ply:SetMaxArmor( 100 )
	ply:SetHealth( 100 )
	ply:SetArmor( 100 )
	ply:ShouldDropWeapon( false )
	ply:SetNoCollideWithTeammates( false )
	ply:SetAvoidPlayers( false )
	
	if ( GetConVar( "sv_noplayercollision" ):GetBool() ) then
		ply:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	end
	
	if ( GetConVar( "sv_nodamageforces" ):GetBool() ) then
		ply:AddEFlags( EFL_NO_DAMAGE_FORCES ) 
	end

end

function GM:PlayerSpawn( pl, transiton )

	if ( pl:Team() == TEAM_SPECTATOR || pl:Team() == TEAM_UNASSIGNED ) then

		self:PlayerSpawnAsSpectator( pl )
		return

	end
	
	pl:UnSpectate()
	
	pl.SpawnedThisRound = true

	SetUpPlayerVars( pl )
	
	hook.Call( "PlayerLoadout", GAMEMODE, pl )
	hook.Call( "PlayerSetModel", GAMEMODE, pl )
	
	pl:SetupHands()

end

function GM:PlayerSetModel( pl )

	local modelName = "models/player/kleiner.mdl"
	local teamModels = PlayerModels[ pl:Team() ]
	
	if ( teamModels ) then
	
		if ( !teamModels[ pl.PlayerModel ] ) then
			pl.PlayerModel = math.random( #teamModels )
		end

		modelName = teamModels[ pl.PlayerModel ].MDL
		
	end
	
	util.PrecacheModel( modelName )
	pl:SetModel( modelName )

end

function GM:PlayerSetHandsModel( pl, ent )

	local playermodel = player_manager.TranslateToPlayerModelName( pl:GetModel() )
	local info = player_manager.TranslatePlayerHands( playermodel )

	if ( info ) then
	
		ent:SetModel( info.model )
		ent:SetSkin( info.skin )
		ent:SetBodyGroups( info.body )
		
	end

end

function GM:PlayerLoadout( pl )

	local loadouts = {

		[WPNSLOT_PRIMARY] 	= pl:GetInfo( "cl_loadout_primary" ),
		[WPNSLOT_SECONDARY] = pl:GetInfo( "cl_loadout_secondary" )
		
	}

	for id, wpn in pairs( pl:GetWeapons() ) do
		loadouts[ wpn:GetSlot() ] = nil
	end
	
	for slot, name in pairs( loadouts ) do
	
		local swep = weapons.GetStored( name )
			
		if ( swep && swep.CanBuy && slot == swep.Slot ) then 
			pl:Give( name )
		end
	
	end

	StockPlayerAmmo( pl )

end

function GM:PlayerDeathSound()

	return !GetConVar( "mp_deathsound" ):GetBool()
	
end

function GM:PlayerSwitchFlashlight( ply, enabled )

	if ( enabled && !GetConVar( "mp_flashlight" ):GetBool() ) then
		return false
	end

	return BaseClass.PlayerSwitchFlashlight( self, ply, enabled )

end

function GM:PlayerCanJoinTeam( ply, teamid )
	
	if ( !team.Joinable( teamid ) ) then
	
		ply:ChatPrint( "You can't join that team" )
		return false
		
	end
	
	local TimeBetweenSwitches = GetConVar( "mp_teamswitch_cooldown" ):GetFloat()

	if ( TimeBetweenSwitches > 0 && ply.LastTeamSwitch ) then
	
		local NextSwitchTime = ply.LastTeamSwitch + TimeBetweenSwitches
	
		if ( NextSwitchTime >= CurTime() ) then
	
			ply:ChatPrint( Format( "Please wait %i more seconds before trying to change team again.", ( NextSwitchTime - CurTime() ) ) )
			return false
			
		end
		
	end
	
	return true

end

function GM:PlayerRequestTeam( ply, teamid, modelid )

	if ( ply:Team() == teamid ) then 
	
		ply.PlayerModel = modelid
		return
		
	end

	if ( !GAMEMODE:PlayerCanJoinTeam( ply, teamid ) ) then
		return 
	end
	
	ply.PlayerModel = modelid
	
	GAMEMODE:PlayerJoinTeam( ply, teamid )

end

function GM:PlayerJoinTeam( ply, teamid )

	local iOldTeam = ply:Team()

	if ( ply:Alive() ) then
	
		if ( iOldTeam == TEAM_SPECTATOR || iOldTeam == TEAM_UNASSIGNED ) then
			ply:KillSilent()
		else
			ply:Kill()
		end
		
	end

	ply:SetTeam( teamid )
	ply.LastTeamSwitch = CurTime()
	
	GAMEMODE:OnPlayerChangedTeam( ply, iOldTeam, teamid )

end

local function PlayerCanRespawn( ply )

	if ( CurTime() < GAMEMODE.RestartRoundTime ) then
		return false
	end

	if ( GAMEMODE.FirstConnected ) then
		
		if ( ply.SpawnedThisRound ) then
			return false
		end
		
		if ( CurTime() > ( GAMEMODE:GetRoundStartTime() + GetConVar( "mp_join_grace_time" ):GetFloat() ) ) then
			return false
		end
		
	end

	return true

end

function GM:OnPlayerChangedTeam( ply, oldteam, newteam )

	if ( newteam == TEAM_SPECTATOR ) then

		local pos = ply:EyePos()
		ply:Spawn()
		ply:SetPos( pos )

	elseif ( newteam == TEAM_TERRORIST || newteam == TEAM_CT ) then

		if ( PlayerCanRespawn( ply ) ) then
			ply:Spawn()
		else
			ply:Spectate( ply.ObserverLastMode || OBS_MODE_ROAMING )
		end

	end
	
	GAMEMODE:CheckWinConditions()

	PrintMessage( HUD_PRINTTALK, ply:Nick() .. " is joining the " .. team.GetName( newteam ) )

end

function GM:GetFallDamage( ply, flFallSpeed )

	return BaseClass.GetFallDamage( self, ply, flFallSpeed ) * GetConVar( "sv_falldamage_scale" ):GetFloat()

end

function GM:PlayerShouldTaunt( ply, actid )

	return GetConVar( "mp_allowtaunts" ):GetBool()

end

function GM:PlayerTraceAttack( ply, dmginfo, dir, trace )

	local attacker = dmginfo:GetAttacker()
	
	if ( IsValid( attacker ) && attacker:IsPlayer() ) then
	
		local weapon = attacker:GetActiveWeapon()
		
		if ( IsValid( weapon ) && weapon.Primary && weapon.Primary.Range && weapon.Primary.RangeModifier ) then
		
			local rangeModifier = weapon.Primary.RangeModifier
			
			if ( weapon:GetClass() == "hvh_glock" && weapon:GetBurstMode() ) then
			
				rangeModifier = 0.9
			
			elseif ( weapon:GetClass() == "hvh_m4a1" && weapon:GetSilencerOn() ) then
			
				rangeModifier = 0.95
			
			end

			local travelledDistance = trace.Fraction * weapon.Primary.Range
			local damageScale = math.pow( rangeModifier, ( travelledDistance / 500 ) )
			
			dmginfo:ScaleDamage( damageScale )
		
		end
	
	end

	return false

end

local hitgroup_dmgscale = {

	[HITGROUP_HEAD]		= "mp_damage_scale_head",
	[HITGROUP_CHEST]	= "mp_damage_scale_chest",
	[HITGROUP_STOMACH]	= "mp_damage_scale_stomach",
	[HITGROUP_LEFTARM]	= "mp_damage_scale_arms",
	[HITGROUP_RIGHTARM]	= "mp_damage_scale_arms",
	[HITGROUP_LEFTLEG]	= "mp_damage_scale_legs",
	[HITGROUP_RIGHTLEG]	= "mp_damage_scale_legs"

}

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )

	if ( hitgroup != HITGROUP_HEAD && GetConVar( "mp_damage_headshot_only" ):GetBool() ) then
		return true
	end

	local dmgscale = hitgroup_dmgscale[hitgroup]
	
	if ( dmgscale ) then
		dmginfo:ScaleDamage( GetConVar( dmgscale ):GetFloat() )
	end

	return false

end

function GM:PlayerShouldTakeDamage( ply, attacker )

	if ( !GetConVar( "mp_friendlyfire" ):GetBool() ) then
	
		if ( IsValid( attacker ) && attacker:IsPlayer() && attacker:Team() == ply:Team() ) then
			return false
		end
		
	end

	return true
	
end

local hitgroup_armored = {

	[HITGROUP_GENERIC] 	= true,
	[HITGROUP_HEAD] 	= true,
	[HITGROUP_CHEST] 	= true,
	[HITGROUP_STOMACH] 	= true,
	[HITGROUP_LEFTARM] 	= true,
	[HITGROUP_RIGHTARM] = true

}

local NEW_ARMOR = nil

function GM:EntityTakeDamage( target, dmg )

	if ( target:IsPlayer() &&
		target:Alive() &&
		!target:HasGodMode() &&
		target:Armor() > 0 && 
		hitgroup_armored[ target:LastHitGroup() ] &&
		dmg:GetDamage() > 0 && 
		!( dmg:IsDamageType( DMG_FALL ) || dmg:IsDamageType( DMG_DROWN ) ) ) then
		
		local attacker = dmg:GetAttacker()
		
		if ( IsValid( attacker ) && attacker:IsPlayer() && hook.Run( "PlayerShouldTakeDamage", target, attacker ) ) then
		
			local weapon = attacker:GetActiveWeapon()
			
			if ( IsValid( weapon ) && weapon.Primary && weapon.Primary.ArmorRatio ) then
			
				local armorBonus = 0.5
				local armorRatio = 0.5 * weapon.Primary.ArmorRatio
				local damage = dmg:GetDamage()
				local damageToHealth = damage * armorRatio
				local damageToArmor = ( damage - damageToHealth ) * armorBonus
				local armor = target:Armor()

				if ( damageToArmor > armor ) then

					damageToHealth = damage - ( armor / armorBonus )
					damageToArmor = armor
					armor = 0

				else

					if ( damageToArmor < 0 ) then
						damageToArmor = 1
					end

					armor = armor - damageToArmor
				
				end
				
				NEW_ARMOR = math.floor( armor )
				target:SetArmor( 0 )
				
				damage = damageToHealth
				dmg:SetDamage( damage )
				
			end
		
		end
		
	end

	return false

end

function GM:PostEntityTakeDamage( ent, dmg, took )

	if ( ent:IsPlayer() && ent:Alive() && NEW_ARMOR != nil ) then
		ent:SetArmor( NEW_ARMOR )
	end
	
	NEW_ARMOR = nil

end

concommand.Add( "changeteam2", function( pl, cmd, args ) hook.Call( "PlayerRequestTeam", GAMEMODE, pl, tonumber( args[ 1 ] ), tonumber( args[ 2 ] ) ) end )
