AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "Galil"
SWEP.Alias 					= "galil"
SWEP.Image        		 	= "vgui/gfx/vgui/galil"
SWEP.IconLetter				= "v"
SWEP.CanBuy        		 	= true

if ( CLIENT ) then
	killicon.AddFont( "hvh_galil", "hvh_killicon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_PRIMARY
SWEP.Type					= WPNTYPE_RIFLE
SWEP.Weight					= 25
SWEP.ViewModelFlip			= false
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= true
SWEP.CSMuzzleScale			= 1.6
SWEP.HoldType				= "ar2"
SWEP.ViewModel				= "models/weapons/v_rif_galil.mdl"	
SWEP.WorldModel				= "models/weapons/w_rif_galil.mdl"	

SWEP.Range					= 8192
SWEP.RangeModifier			= 0.98
SWEP.ArmorRatio				= 1.55

SWEP.Primary.Sound			= Sound( "Weapon_Galil.Single" )
SWEP.Primary.Recoil			= 0.65
SWEP.Primary.Damage			= 30
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.027
SWEP.Primary.Delay			= 0.0875

SWEP.Primary.ClipSize		= 35
SWEP.Primary.DefaultClip	= 35
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "BULLET_PLAYER_556MM"
