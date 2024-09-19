include( "shared.lua" )
include( "cl_deathnotice.lua" )
include( "cl_hud.lua" )
include( "cl_menu.lua" )
include( "cl_pickteam.lua" )
include( "cl_scoreboard.lua" )
include( "cl_targetid.lua" )
include( "cl_weapons.lua" )

DEFINE_BASECLASS( "gamemode_base" )

surface.CreateFont( "HvH_Menu", {

	font = "Verdana",
	size = 14,
	weight = 700,
	antialias = true

} )

surface.CreateFont( "HvH_MenuSmall", {

	font = "Verdana",
	size = 13,
	weight = 0,
	antialias = true

} )

surface.CreateFont( "HvH_MenuTitle", {

	font = "Verdana",
	size = 20,
	weight = 700,
	antialias = true

} )

function GM:Initialize()

	BaseClass.Initialize( self )

end

local hud = {

	["CHudHealth"] 			= true,
	["CHudBattery"] 		= true,
	["CHudAmmo"] 			= true,
	["CHudSecondaryAmmo"] 	= true

}

function GM:HUDShouldDraw( name )

	if ( hud[name] ) then return false end
	
	if ( name == "CHudWeaponSelection" && Menu_TakesInput() ) then
		return false
	end

	return BaseClass.HUDShouldDraw( self, name )
	
end

function GM:HUDPaint()

	hook.Run( "HUDDrawGeneral" )
	hook.Run( "HUDDrawTargetID" )
	hook.Run( "HUDDrawPickupHistory" )
	hook.Run( "DrawDeathNotice" )

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
	
	return BaseClass.ChatText( self, playerindex, playername, text, filter )

end

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )

	if ( GetConVarNumber( "mp_friendlyfire" ) == 0 ) then
	
		local attacker = dmginfo:GetAttacker()

		if ( IsValid( attacker ) && attacker:IsPlayer() && attacker:Team() == ply:Team() ) then
			return true
		end
		
	end

	if ( GetConVarNumber( "mp_damage_headshot_only" ) != 0 && dmginfo:IsBulletDamage() && hitgroup != HITGROUP_HEAD ) then
		return true
	end

	return false

end

function GM:PlayerButtonDown( ply, button )

	if ( IsFirstTimePredicted() ) then
		Menu_HandleKeyInput( button )
	end

end

local function RecvPlaySound()

	local snd = net.ReadString()
	
	surface.PlaySound( Sound( snd ) )

end
net.Receive( "HvH_PlaySound", RecvPlaySound )
