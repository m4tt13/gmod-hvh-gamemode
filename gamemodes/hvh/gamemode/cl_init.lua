include( "shared.lua" )
include( "cl_deathnotice.lua" )
include( "cl_hud.lua" )
include( "cl_pickteam.lua" )
include( "cl_playerlist.lua" )
include( "cl_scoreboard.lua" )
include( "cl_targetid.lua" )
include( "cl_topplayers.lua" )
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

	return BaseClass.HUDShouldDraw( self, name )
	
end

function GM:HUDPaint()

	hook.Run( "HUDDrawGeneral" )
	hook.Run( "HUDDrawTargetID" )
	hook.Run( "HUDDrawPickupHistory" )
	hook.Run( "DrawDeathNotice" )

end

local chat_colors = {

	["\x01"] = Color( 255, 255, 255 ),
	["\x02"] = Color( 255, 127, 127 ),
	["\x03"] = Color( 127, 255, 127 ),
	["\x04"] = Color( 127, 127, 255 ),
	["\x05"] = Color( 150, 210, 255 )

}

function GM:ChatText( playerindex, playername, text, filter )

	if ( filter == "none" ) then
	
		local tab = {}
		local pattern = "[\x01\x02\x03\x04\x05]"

		for s in text:gsub( pattern, "\0%0\0" ):gmatch( "%Z+" ) do
		   
		   local clr = chat_colors[s]
		   
		   if ( clr ) then
				table.insert( tab, clr )
		   else
				table.insert( tab, s )
		   end
		   
		end
		
		chat.AddText( unpack( tab ) )

		return true
		
	end
	
	return BaseClass.ChatText( self, playerindex, playername, text, filter )

end

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )

	if ( !GetConVar( "mp_friendlyfire" ):GetBool() ) then
	
		local attacker = dmginfo:GetAttacker()

		if ( IsValid( attacker ) && attacker:IsPlayer() && attacker:Team() == ply:Team() ) then
			return true
		end
		
	end

	if ( hitgroup != HITGROUP_HEAD && GetConVar( "mp_damage_headshot_only" ):GetBool() ) then
		return true
	end

	return false

end

local function RecvPlaySound()

	local snd = net.ReadString()
		
	surface.PlaySound( Sound( snd ) )

end
net.Receive( "HvH_PlaySound", RecvPlaySound )
