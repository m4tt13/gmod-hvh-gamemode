local hvhrank_points_start 		= CreateConVar( "hvhrank_points_start", "1000" )
local hvhrank_points_negate		= CreateConVar( "hvhrank_points_negate", "0" )
local hvhrank_points_kill 		= CreateConVar( "hvhrank_points_kill", "2" )
local hvhrank_points_diff 		= CreateConVar( "hvhrank_points_diff", "100" )
local hvhrank_points_headshot 	= CreateConVar( "hvhrank_points_headshot", "1" )
local hvhrank_points_knife_mult	= CreateConVar( "hvhrank_points_knife_mult", "2" )
local hvhrank_show_rank_all		= CreateConVar( "hvhrank_show_rank_all", "1" )

local clr_prefix = Color( 127, 127, 255 )

if ( !sql.TableExists( "hvhrank" ) ) then

	sql.Query( "CREATE TABLE IF NOT EXISTS hvhrank (steamid TEXT NOT NULL PRIMARY KEY, name TEXT, score NUMERIC, kills NUMERIC, deaths NUMERIC, headshots NUMERIC, knifekills NUMERIC, lastplayed NUMERIC);" )

end

function Stats_LoadPlayer( ply, steamid )

	if ( ply:IsBot() ) then
		return
	end

	local result = sql.Query( Format( "SELECT * FROM hvhrank WHERE steamid = %s", sql.SQLStr( steamid ) ) )
	
	if ( result ) then
		
		ply.Stats = { 
		
			Score = tonumber( result[1].score ), 
			Kills = tonumber( result[1].kills ), 
			Deaths = tonumber( result[1].deaths ), 
			Headshots = tonumber( result[1].headshots ),
			KnifeKills = tonumber( result[1].knifekills )
			
		}
		
	elseif ( result == nil ) then
	
		local points_start = hvhrank_points_start:GetInt()
	
		ply.Stats = { 
		
			Score = points_start, 
			Kills = 0, 
			Deaths = 0,
			Headshots = 0,
			KnifeKills = 0
			
		}
		
		sql.Query( Format( "INSERT INTO hvhrank VALUES (%s, %s, %i, 0, 0, 0, 0, %i)", sql.SQLStr( steamid ), sql.SQLStr( ply:Name() ), points_start, os.time() ) )
		
	end

end

function Stats_SavePlayer( ply )

	if ( !ply.Stats ) then
		return
	end

	sql.Query( Format( "UPDATE hvhrank SET name = %s, score = %i, kills = %i, deaths = %i, headshots = %i, knifekills = %i, lastplayed = %i WHERE steamid = %s", sql.SQLStr( ply:Name() ), ply.Stats.Score, ply.Stats.Kills, ply.Stats.Deaths, ply.Stats.Headshots, ply.Stats.KnifeKills, os.time(), sql.SQLStr( ply:SteamID() ) ) )

end

function Stats_OnPlayerDeath( victim, attacker, headshot, knifekill )

	if ( !victim.Stats || !attacker.Stats || victim == attacker ) then
		return
	end
	
	victim.Stats.Deaths		= victim.Stats.Deaths + 1
	attacker.Stats.Kills	= attacker.Stats.Kills + 1

	local points_kill = hvhrank_points_kill:GetInt()
	local points_diff = hvhrank_points_diff:GetInt()

	if ( points_diff > 0 ) then
	
		local score_diff = victim.Stats.Score - attacker.Stats.Score
	
		if ( score_diff > 0 ) then
			points_kill = points_kill + math.floor( score_diff / points_diff )
		end
		
	end

	if ( knifekill ) then
	
		attacker.Stats.KnifeKills = attacker.Stats.KnifeKills + 1
		
		local points_knife_mult = hvhrank_points_knife_mult:GetFloat()
		
		if ( points_knife_mult > 0 ) then
			points_kill = math.ceil( points_kill * points_knife_mult )
		end
		
	end
	
	if ( !hvhrank_points_negate:GetBool() ) then
		points_kill = math.min( points_kill, math.max( 0, victim.Stats.Score ) )
	end
	
	victim.Stats.Score 		= victim.Stats.Score	- points_kill
	attacker.Stats.Score 	= attacker.Stats.Score 	+ points_kill

	victim:ChatPrint( util.ColorizeText( color_white, "[", clr_prefix, "HvH Rank", color_white, "] -", tostring( points_kill ), " points (", tostring( victim.Stats.Score ), ") for being killed by ", COLOR_NICKNAME, attacker:Name(), color_white, " (", tostring( attacker.Stats.Score ), ")" ) )
	attacker:ChatPrint( util.ColorizeText( color_white, "[", clr_prefix, "HvH Rank", color_white, "] +", tostring( points_kill ), " points (", tostring( attacker.Stats.Score ), ") for killing ", COLOR_NICKNAME, victim:Name(), color_white, " (", tostring( victim.Stats.Score ), ")" ) )
	
	if ( headshot ) then

		attacker.Stats.Headshots = attacker.Stats.Headshots + 1

		local points_headshot = hvhrank_points_headshot:GetInt()
		
		if ( points_headshot > 0 ) then
		
			attacker.Stats.Score = attacker.Stats.Score + points_headshot

			attacker:ChatPrint( util.ColorizeText( color_white, "[", clr_prefix, "HvH Rank", color_white, "] +", tostring( points_headshot ), " points (", tostring( attacker.Stats.Score ), ") for headshotting ", COLOR_NICKNAME, victim:Name(), color_white, " (", tostring( victim.Stats.Score ), ")" ) )
		
		end
		
	end

	Stats_SavePlayer( victim )
	Stats_SavePlayer( attacker )

end

function Stats_ShowRank( ply )

	if ( !ply.Stats ) then
		return
	end

	local result = sql.Query( "SELECT * FROM hvhrank ORDER BY score DESC" )
	
	if ( result ) then
	
		for rank, row in ipairs( result ) do
		
			if ( row.steamid == ply:SteamID() ) then
			
				local text = util.ColorizeText( color_white, "[", clr_prefix, "HvH Rank", color_white, "] ", COLOR_NICKNAME, ply:Name(), color_white, " is ranked at ", tostring( rank ), "/", tostring( #result ), " with ", tostring( ply.Stats.Score ), " points, ", tostring( ply.Stats.Kills ), " kills, ", tostring( ply.Stats.Deaths ), " deaths, ", tostring( ply.Stats.Headshots ), " headshots and ", tostring( ply.Stats.KnifeKills ), " knife kills" )
				
				if ( hvhrank_show_rank_all:GetBool() ) then
					PrintMessage( HUD_PRINTTALK, text )
				else
					ply:ChatPrint( text )
				end
				
				break
			
			end
		
		end

	end

end

local ShowMenu = nil

local function HandlePlayerInfoItem( ply, item )

	if ( item == 1 ) then

		ply:PlaySound( "buttons/button14.wav" )

		ShowMenu( ply, ply.MenuSection )
	
	elseif ( item == 10 ) then
	
		ply:PlaySound( "buttons/combine_button7.wav" )
	
		Menu_Close( ply )
	
	end

end

local function HandleMenuItem( ply, item )

	if ( item >= 1 && item <= 7 ) then
	
		local info = ply.DisplayedPlayersInfo[ item ]
		
		local last_played = os.date( "%H:%M:%S - %d/%m/%Y", tonumber( info.lastplayed ) )
		
		ply:PrintMessage( HUD_PRINTCONSOLE, "-------------------------\n" )
		ply:PrintMessage( HUD_PRINTCONSOLE, "[HvH Rank] Player Info:" )
		ply:PrintMessage( HUD_PRINTCONSOLE, "-------------------------\n" )
		ply:PrintMessage( HUD_PRINTCONSOLE, "Name: " .. info.name .. "\n" )
		ply:PrintMessage( HUD_PRINTCONSOLE, "SteamID: " .. info.steamid .. "\n" )
		ply:PrintMessage( HUD_PRINTCONSOLE, "Rank: " .. info.rank .. "\n" )
		ply:PrintMessage( HUD_PRINTCONSOLE, "Points: " .. info.score .. "\n" )
		ply:PrintMessage( HUD_PRINTCONSOLE, Format( "KDR: %.2f\n", info.kdr ) )
		ply:PrintMessage( HUD_PRINTCONSOLE, "Kills: " .. info.kills .. "\n" )
		ply:PrintMessage( HUD_PRINTCONSOLE, "Deaths: " .. info.deaths .. "\n" )
		ply:PrintMessage( HUD_PRINTCONSOLE, "Headshots: " .. info.headshots .. "\n" )
		ply:PrintMessage( HUD_PRINTCONSOLE, "Knife Kills: " .. info.knifekills .. "\n" )
		ply:PrintMessage( HUD_PRINTCONSOLE, "Last Played: " .. last_played .. "\n" )
		ply:PrintMessage( HUD_PRINTCONSOLE, "-------------------------\n" )
	
		Menu_Start()
		
			Menu_AddLine( "[HvH Rank] Player Info:" )
			Menu_AddLine( "------------------------------" )
			Menu_AddLine( "Name: " .. info.name )
			Menu_AddLine( "SteamID: " .. info.steamid )
			Menu_AddLine( "Rank: " .. info.rank )
			Menu_AddLine( "Points: " .. info.score )
			Menu_AddLine( Format( "KDR: %.2f", info.kdr ) )
			Menu_AddLine( "Kills: " .. info.kills )
			Menu_AddLine( "Deaths: " .. info.deaths )
			Menu_AddLine( "Headshots: " .. info.headshots )
			Menu_AddLine( "Knife Kills: " .. info.knifekills )
			Menu_AddLine( "Last Played: " .. last_played )

			Menu_AddLine()
			
			Menu_AddLine( "Back", true, 1 )
			Menu_AddLine( "Exit", false, 10 )
			
		Menu_End( ply, HandlePlayerInfoItem )
		
		ply:PlaySound( "buttons/button14.wav" )

	elseif ( item == 8 ) then

		ply:PlaySound( "buttons/button14.wav" )

		ShowMenu( ply, ply.MenuSection - 1 )

	elseif ( item == 9 ) then

		ply:PlaySound( "buttons/button14.wav" )

		ShowMenu( ply, ply.MenuSection + 1 )
	
	elseif ( item == 10 ) then
	
		ply:PlaySound( "buttons/combine_button7.wav" )
	
		Menu_Close( ply )
	
	end

end

ShowMenu = function( ply, section )

	local result = sql.Query( "SELECT * FROM hvhrank ORDER BY score DESC" )
	
	if ( result ) then
	
		ply.MenuSection = section
		ply.DisplayedPlayersInfo = {}
	
		Menu_Start()
		
			local infocount = #result
			local start_index = ( section * 7 ) - 6
			local end_index = math.min( start_index + 6, infocount )
			local item = 1
			
			Menu_AddLine( Format( "[HvH Rank] Showing from %i to %i of %i:", start_index, end_index, infocount ) )
			
			for i = start_index, end_index do
			
				local info = result[ i ]
				local kills = tonumber( info.kills )
				local deaths = tonumber( info.deaths )
				info.kdr = kills / ( ( deaths != 0 ) && deaths || 1 )
				info.rank = i

				Menu_AddLine( Format( "%s (%s) - KDR: %.2f", info.name, info.score, info.kdr ), true, item )
				
				table.insert( ply.DisplayedPlayersInfo, item, info )
				
				item = item + 1
			
			end
			
			for i = item, 7 do
				Menu_AddLine()
			end
			
			Menu_AddLine()
			
			if ( start_index > 1 ) then
				Menu_AddLine( "Previous", true, 8 )
			else
				Menu_AddLine()
			end

			if ( ( start_index + 7 ) <= infocount ) then
				Menu_AddLine( "Next", true, 9 )
			else
				Menu_AddLine()
			end

			Menu_AddLine( "Exit", false, 10 )
			
		Menu_End( ply, HandleMenuItem )

	else
	
		Menu_Close( ply )
	
	end
	
end

function Stats_ShowTopPlayers( ply )

	ShowMenu( ply, 1 )

end
