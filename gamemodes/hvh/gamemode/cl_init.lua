include( "shared.lua" )

surface.CreateFont( "hvh_menu", {

	font = "Verdana",
	size = 14,
	weight = 700,
	antialias = true

} )

surface.CreateFont( "hvh_menutitle", {

	font = "Verdana",
	size = 20,
	weight = 700,
	antialias = true

} )

include( "cl_deathnotice.lua" )
include( "cl_hud.lua" )
include( "cl_menu.lua" )
include( "cl_pickteam.lua" )
include( "cl_scoreboard.lua" )
include( "cl_targetid.lua" )
include( "cl_weapons.lua" )

CreateClientConVar( "cl_default_spec_mode", tostring( OBS_MODE_ROAMING ), true, true, "Default Spectator Mode" )
CreateClientConVar( "cl_loadout_primary", "hvh_ak47", true, true, "Primary Weapon" )
CreateClientConVar( "cl_loadout_secondary", "hvh_deagle", true, true, "Secondary Weapon" )

local hud = {

	["CHudHealth"] 			= true,
	["CHudBattery"] 		= true,
	["CHudAmmo"] 			= true,
	["CHudSecondaryAmmo"] 	= true

}

function GM:HUDShouldDraw( name )

	if ( hud[name] ) then return false end
	
	return self.BaseClass.HUDShouldDraw( self, name )
	
end

function GM:HUDPaint()

	hook.Run( "HUDDrawGeneral" )
	hook.Run( "HUDDrawTargetID" )
	hook.Run( "HUDDrawPickupHistory" )
	hook.Run( "DrawDeathNotice" )

end

local cl_chatfilters = GetConVar( "cl_chatfilters" )

function GM:OnPlayerChat( player, strText, bTeamOnly, bPlayerIsDead )

	local tab = {}
	
	if ( IsValid( player ) && ( player:Team() == TEAM_CONNECTING || player:Team() == TEAM_UNASSIGNED || player:Team() == TEAM_SPECTATOR ) ) then
	
		table.insert( tab, Color( 255, 180, 30 ) )
		table.insert( tab, "*SPEC* " )
		
	elseif ( bPlayerIsDead ) then
	
		table.insert( tab, Color( 255, 30, 40 ) )
		table.insert( tab, "*DEAD* " )
		
	end

	if ( bTeamOnly ) then
	
		table.insert( tab, Color( 30, 160, 40 ) )
		table.insert( tab, "(TEAM) " )
		
	end

	if ( IsValid( player ) ) then
		table.insert( tab, player )
	else
		table.insert( tab, "Console" )
	end

	local filter_context = TEXT_FILTER_GAME_CONTENT
	if ( bit.band( cl_chatfilters:GetInt(), 64 ) != 0 ) then filter_context = TEXT_FILTER_CHAT end

	table.insert( tab, color_white )
	table.insert( tab, ": " .. util.FilterText( strText, filter_context, IsValid( player ) and player or nil ) )

	chat.AddText( unpack( tab ) )

	return true

end

function GM:ChatText( playerindex, playername, text, filter )

	if ( filter == "none" ) then
	
		local args = {}
		local cur_pos = 1
		local total_len = string.len( text )

		while ( cur_pos <= total_len ) do

			local code_start = string.find( text, "\x01", cur_pos, true )

			if ( code_start ) then

				local code_end = code_start + 7
				local range_len = code_start - cur_pos
				
				if ( range_len > 0 ) then
					table.insert( args, string.sub( text, cur_pos, code_start - 1 ) )
				end
				
				if ( code_end <= total_len ) then
				
					local r = tonumber( text[ code_start + 1 ] .. text[ code_start + 2 ], 16 ) || 0
					local g = tonumber( text[ code_start + 3 ] .. text[ code_start + 4 ], 16 ) || 0
					local b = tonumber( text[ code_start + 5 ] .. text[ code_start + 6 ], 16 ) || 0
					
					table.insert( args, Color( r, g, b ) )
					
				end
				
				cur_pos = code_end

			else

				table.insert( args, string.sub( text, cur_pos ) )
				break

			end
			
		end
		
		chat.AddText( unpack( args ) )

		return true
		
	end
	
	return self.BaseClass.ChatText( self, playerindex, playername, text, filter )

end

function GM:PlayerBindPress( pl, bind, down, code )

	if ( down && code >= KEY_0 && code <= KEY_9 ) then
	
		local item = ( ( code - KEY_0 ) % -10 ) + 10
		
		if ( Menu_HandleInput( item ) ) then
			return true
		end
		
	end
	
end

function GM:OnSpawnMenuOpen()

	RunConsoleCommand( "lastinv" )

end

local function RecvPlaySound()

	local snd = net.ReadString()
	
	surface.PlaySound( snd )

end
net.Receive( "hvh_playsound", RecvPlaySound )
