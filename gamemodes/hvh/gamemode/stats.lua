local hvhrank_points_start 		= CreateConVar( "hvhrank_points_start", "1000" )
local hvhrank_points_kill 		= CreateConVar( "hvhrank_points_kill", "2" )
local hvhrank_points_diff 		= CreateConVar( "hvhrank_points_diff", "100" )
local hvhrank_points_headshot 	= CreateConVar( "hvhrank_points_headshot", "1" )
local hvhrank_show_rank_all		= CreateConVar( "hvhrank_show_rank_all", "1" )

local table_exist = false

util.AddNetworkString( "HvH_TopPlayers" )

function Stats_Load()
	
	local result = sql.Query( "CREATE TABLE IF NOT EXISTS hvhrank (id INTEGER PRIMARY KEY, steamid TEXT, name TEXT, score NUMERIC, kills NUMERIC, deaths NUMERIC, headshots NUMERIC)" )
	
	if ( result == false ) then
		Msg( Format( "[HvH Rank] Could not create SQL table: %s\n", sql.LastError() ) )
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
		
			Score = result[1].score, 
			Kills = result[1].kills, 
			Deaths = result[1].deaths, 
			Headshots = result[1].headshots 
			
		}
		
	elseif ( result == nil ) then
	
		local points_start = hvhrank_points_start:GetInt()
	
		ply.Stats = { 
		
			Score = points_start, 
			Kills = 0, 
			Deaths = 0,
			Headshots = 0 
			
		}
		
		sql.Query( Format( "INSERT INTO hvhrank VALUES (NULL, %s, %s, %i, 0, 0, 0)", sql.SQLStr( steamid ), sql.SQLStr( ply:Name() ), points_start ) )
		
	end

end

function Stats_SavePlayer( ply )

	if ( !ply.Stats ) then
		return
	end

	sql.Query( Format( "UPDATE hvhrank SET name = %s, score = %i, kills = %i, deaths = %i, headshots = %i WHERE steamid = %s", sql.SQLStr( ply:Name() ), ply.Stats.Score, ply.Stats.Kills, ply.Stats.Deaths, ply.Stats.Headshots, sql.SQLStr( ply:SteamID() ) ) )

end

function Stats_OnPlayerDeath( victim, attacker, headshot )

	if ( !victim.Stats || !attacker.Stats || attacker == victim ) then
		return
	end
	
	victim.Stats.Deaths		= victim.Stats.Deaths + 1
	attacker.Stats.Kills	= attacker.Stats.Kills + 1

	local points_kill = hvhrank_points_kill:GetInt()
	local points_diff = hvhrank_points_diff:GetInt()
	local score_diff = victim.Stats.Score - attacker.Stats.Score
	
	if ( score_diff > 0 && points_diff != 0	) then
		points_kill = points_kill + math.floor( score_diff / points_diff )
	end
	
	victim.Stats.Score 		= victim.Stats.Score	- points_kill
	attacker.Stats.Score 	= attacker.Stats.Score 	+ points_kill
	
	victim:ChatPrint( Format( "\x01[\x04HvH Rank\x01] -%i points (%i) for being killed by \x03%s\x01 (%i)", points_kill, victim.Stats.Score, attacker:Name(), attacker.Stats.Score ) )
	attacker:ChatPrint( Format( "\x01[\x04HvH Rank\x01] +%i points (%i) for killing \x03%s\x01 (%i)", points_kill, attacker.Stats.Score, victim:Name(), victim.Stats.Score ) )
	
	if ( headshot ) then
	
		local points_headshot = hvhrank_points_headshot:GetInt()
	
		attacker.Stats.Score 		= attacker.Stats.Score + points_headshot
		attacker.Stats.Headshots 	= attacker.Stats.Headshots + 1
		
		attacker:ChatPrint( Format( "\x01[\x04HvH Rank\x01] +%i points (%i) for headshotting \x03%s\x01 (%i)", points_headshot, attacker.Stats.Score, victim:Name(), victim.Stats.Score ) )
		
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
			
				local text = Format( "\x01[\x04HvH Rank\x01] Player \x03%s\x01 is ranked at %i/%i with %i points, %i kills, %i deaths and %i headshots", ply:Name(), rank, #result, ply.Stats.Score, ply.Stats.Kills, ply.Stats.Deaths, ply.Stats.Headshots )
				
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

function Stats_ShowTopPlayers( ply )

	if ( !ply.Stats ) then
		return
	end

	local result = sql.Query( "SELECT * FROM hvhrank ORDER BY score DESC LIMIT 15" )
	
	if ( result ) then
	
		net.Start( "HvH_TopPlayers" )
		
			net.WriteUInt( #result, 4 )

			for rank, row in ipairs( result ) do

				net.WriteString( row.name )
				net.WriteInt( row.score, 32 )
				net.WriteInt( row.kills, 32 )
				net.WriteInt( row.deaths, 32 )
				net.WriteInt( row.headshots, 32 )
			
			end
		
		net.Send( ply )

	end

end