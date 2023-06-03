surface.CreateFont( "HvH_HudNumbers", {

	font = "Tahoma",
	size = 45,
	weight = 600,
	antialias = true,
	additive = true

} )

surface.CreateFont( "HvH_HudIcon", {

	font = "csd",
	size = 50,
	weight = 0,
	antialias = true,
	additive = true

} )

surface.CreateFont( "HvH_HudIconSmall", {

	font = "csd",
	size = 28,
	weight = 0,
	antialias = true

} )

local clr_text		= Color( 255, 176, 0, 255 )
local clr_numbers	= Color( 255, 176, 0, 120 )
local clr_bar		= Color( 0, 0, 0, 196 )
local clr_bg		= Color( 0, 0, 0, 96 )

local ammo_letters = {

	["BULLET_PLAYER_50AE"] 		= "U",
	["BULLET_PLAYER_762MM"] 	= "V",
	["BULLET_PLAYER_556MM"] 	= "N",
	["BULLET_PLAYER_556MM_BOX"] = "N",
	["BULLET_PLAYER_338MAG"] 	= "W",
	["BULLET_PLAYER_9MM"] 		= "R",
	["BULLET_PLAYER_BUCKSHOT"] 	= "J",
	["BULLET_PLAYER_45ACP"] 	= "M",
	["BULLET_PLAYER_357SIG"] 	= "T",
	["BULLET_PLAYER_57MM"]		= "S"
	
}

local function GetRoundTimer()

	local timer = math.ceil( GAMEMODE:GetRoundRemainingTime() )

	if ( GAMEMODE:IsFreezePeriod() ) then
		timer = math.ceil( GAMEMODE:GetRoundStartTime() - CurTime() )
	end
	
	if ( timer < 0 ) then
		timer = 0
	end
	
	return timer

end

local function HUD_DrawHealth()

	local scrw, scrh = ScrW(), ScrH()
	
	local ply		= LocalPlayer()
	local health	= ply:Health()
	
	if ( health < 0 ) then
		health = 0
	end

	draw.RoundedBox( 5, 15, scrh - 55, 120, 40, clr_bg )
	draw.SimpleText( health, "HvH_HudNumbers", 130, scrh - 35, clr_numbers, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
	draw.SimpleText( "F", "HvH_HudIcon", 20, scrh - 48, clr_numbers, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

end

local function HUD_DrawArmor()

	local scrw, scrh = ScrW(), ScrH()
	
	local ply	= LocalPlayer()
	local armor	= ply:Armor()
	
	if ( armor < 0 ) then
		armor = 0
	end

	draw.RoundedBox( 5, 170, scrh - 55, 120, 40, clr_bg )
	draw.SimpleText( armor, "HvH_HudNumbers", 285, scrh - 35, clr_numbers, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
	draw.SimpleText( ( armor > 0 ) && "E" || "p", "HvH_HudIcon", 175, scrh - 48, clr_numbers, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

end

local function HUD_DrawRoundTimer()

	local scrw, scrh = ScrW(), ScrH()

	draw.RoundedBox( 5, ( scrw / 2 ) - 70, scrh - 55, 140, 40, clr_bg )
	draw.SimpleText( string.FormattedTime( GetRoundTimer(), "%i:%.2i" ), "HvH_HudNumbers", ( scrw / 2 ) + 65, scrh - 35, clr_numbers, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
	draw.SimpleText( "G", "HvH_HudIcon", ( scrw / 2 ) - 65, scrh - 48, clr_numbers, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

end

local function HUD_DrawAmmo()

	local scrw, scrh = ScrW(), ScrH()

	local ply 	= LocalPlayer()
	local wpn 	= ply:GetActiveWeapon()
	
	if ( !IsValid( wpn ) ) then
		return
	end
	
	local ammoType = wpn:GetPrimaryAmmoType()
	
	if ( ammoType == -1 ) then
		return
	end
	
	draw.RoundedBox( 5, scrw - 200, scrh - 55, 185, 40, clr_bg )
	
	if ( wpn:GetMaxClip1() != -1 ) then
	
		draw.SimpleText( wpn:Clip1(), "HvH_HudNumbers", scrw - 130, scrh - 35, clr_numbers, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

		draw.NoTexture()
		surface.SetDrawColor( clr_numbers )
		surface.DrawTexturedRect( scrw - 125, scrh - 52, 3, 34 )
		
	end

	draw.SimpleText( ply:GetAmmoCount( ammoType ), "HvH_HudNumbers", scrw - 55, scrh - 35, clr_numbers, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
	
	local ammoLetter = ammo_letters[ game.GetAmmoName( ammoType ) ]
	
	if ( ammoLetter ) then
		draw.SimpleText( ammoLetter, "HvH_HudIcon", scrw - 50, scrh - 48, clr_numbers, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	end

end

local function HUD_DrawSpec()

	local scrw, scrh = ScrW(), ScrH()

	surface.SetDrawColor( clr_bar )
	surface.DrawRect( 0, 0, scrw, 60 )
	surface.DrawRect( 0, scrh - 60, scrw, 60 )
	
	draw.SimpleText( team.GetName( TEAM_CT ) .. " :", "HvH_Menu", scrw - 45, 10, clr_text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
	draw.SimpleText( team.GetScore( TEAM_CT ), "HvH_Menu", scrw - 40, 10, clr_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	
	draw.SimpleText( team.GetName( TEAM_TERRORIST ) .. " :", "HvH_Menu", scrw - 45, 30, clr_text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
	draw.SimpleText( team.GetScore( TEAM_TERRORIST ), "HvH_Menu", scrw - 40, 30, clr_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	
	draw.SimpleText( "Map : " .. game.GetMap(), "HvH_Menu", 20, 10, clr_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	
	draw.SimpleText( "G", "HvH_HudIconSmall", 16, 30, clr_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( " : " .. string.FormattedTime( GetRoundTimer(), "%i:%.2i" ), "HvH_Menu", 35, 30, clr_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	
	local ply 	= LocalPlayer()
	local mode 	= ply:GetObserverMode()
	
	if ( mode != OBS_MODE_IN_EYE && mode != OBS_MODE_CHASE ) then
		return
	end
	
	local obsTarget = ply:GetObserverTarget()
	
	if ( IsValid( obsTarget ) && obsTarget:IsPlayer() ) then

		local health = obsTarget:Health()
		local strHealth = ""

		if ( health > 0 && obsTarget:Alive() ) then
			strHealth = " (" .. health .. ")"
		end
		
		draw.SimpleText( obsTarget:Name() .. strHealth, "HvH_Menu", scrw / 2, scrh - 30, team.GetColor( obsTarget:Team() ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		
	end

end

function GM:HUDDrawGeneral()
	
	if ( GetConVarNumber( "cl_drawhud" ) == 0 ) then return end
	
	local ply 	= LocalPlayer()
	local mode 	= ply:GetObserverMode()
	
	if ( mode != OBS_MODE_NONE ) then
		
		HUD_DrawSpec()
		
	else
	
		HUD_DrawHealth()
		HUD_DrawArmor()
		HUD_DrawRoundTimer()
		HUD_DrawAmmo()
	
	end

end
