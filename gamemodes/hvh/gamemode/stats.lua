local hvhrank_points_start 		= CreateConVar( "hvhrank_points_start", "1000" )
local hvhrank_points_kill 		= CreateConVar( "hvhrank_points_kill", "2" )
local hvhrank_points_diff 		= CreateConVar( "hvhrank_points_diff", "100" )
local hvhrank_points_headshot 	= CreateConVar( "hvhrank_points_headshot", "1" )
local hvhrank_points_knife_mult	= CreateConVar( "hvhrank_points_knife_mult", "2" )
local hvhrank_show_rank_all		= CreateConVar( "hvhrank_show_rank_all", "1" )

local table_exist = false

local clr_prefix = Color( 127, 127, 255 )

function Stats_Load()
	
	local result = sql.Query( "CREATE TABLE IF NOT EXISTS hvhrank (id INTEGER PRIMARY KEY, steamid TEXT, name TEXT, score NUMERIC, kills NUMERIC, deaths NUMERIC, headshots NUMERIC, knifekills NUMERIC)" )
	
	if ( result == false ) then
		MsgC( Color( 255, 0, 0 ), Format( "[HvH Rank] Could not create SQL table: %s\n", sql.LastError() ) )
	else
		table_exist = true
	end
	
end

function Stats_LoadPlayer( ply, steamid )

	if ( !table_exist || ply:IsBot() ) then
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
		
		sql.Query( Format( "INSERT INTO hvhrank VALUES (NULL, %s, %s, %i, 0, 0, 0, 0)", sql.SQLStr( steamid ), sql.SQLStr( ply:Name() ), points_start ) )
		
	end

end

function Stats_SavePlayer( ply )

	if ( !ply.Stats ) then
		return
	end

	sql.Query( Format( "UPDATE hvhrank SET name = %s, score = %i, kills = %i, deaths = %i, headshots = %i, knifekills = %i WHERE steamid = %s", sql.SQLStr( ply:Name() ), ply.Stats.Score, ply.Stats.Kills, ply.Stats.Deaths, ply.Stats.Headshots, ply.Stats.KnifeKills, sql.SQLStr( ply:SteamID() ) ) )

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

local snd_button_press1 = Sound( "buttons/button14.wav" )
local snd_button_press2 = Sound( "buttons/combine_button7.wav" )

local ShowMenu = nil

local function HandleMenuItem( ply, item )

	if ( item == 8 ) then

		ply:PlaySound( snd_button_press1 )

		ShowMenu( ply, ply.MenuSection - 1 )

	elseif ( item == 9 ) then

		ply:PlaySound( snd_button_press1 )

		ShowMenu( ply, ply.MenuSection + 1 )
	
	elseif ( item == 10 ) then
	
		ply:PlaySound( snd_button_press2 )
	
		Menu_Close( ply )
	
	end

end

ShowMenu = function( ply, section )

	local offset = ( section - 1 ) * 10
	local result = sql.Query( Format( "SELECT * FROM hvhrank ORDER BY score DESC LIMIT 11 OFFSET %i", offset ) )
	
	if ( result ) then
	
		ply.MenuSection = section
	
		Menu_Start()
		
			Menu_AddLine( "[HvH Rank] Top Players:" )
			
			local item = 1
			
			for _, row in ipairs( result ) do
			
				local deaths = tonumber( row.deaths ) != 0 && tonumber( row.deaths ) || 1
				local kdr = tonumber( row.kills ) / deaths
				local rank = offset + item
				
				Menu_AddLine( Format( "%i. %s - %.2f KDR - %i points", rank, row.name, kdr, tonumber( row.score ) ) )
				
				item = item + 1
				if ( item > 10 ) then break end
			
			end
			
			for i = item, 10 do
				Menu_AddLine()
			end
			
			Menu_AddLine()
			
			if ( offset > 1 ) then
				Menu_AddLine( "Previous", true, 8 )
			else
				Menu_AddLine()
			end

			if ( #result > 10 ) then
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

	if ( !table_exist ) then
		return
	end

	ShowMenu( ply, 1 )

end
