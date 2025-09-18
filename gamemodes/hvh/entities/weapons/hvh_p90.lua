AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "P90"
SWEP.Alias 					= "p90"
SWEP.Image        		 	= "vgui/gfx/vgui/p90"
SWEP.IconLetter				= "m"
SWEP.CanBuy        		 	= true

if CLIENT then
	killicon.AddFont( "hvh_p90", "hvh_killicon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_PRIMARY
SWEP.Weight					= 26
SWEP.ViewModelFlip			= true
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= true
SWEP.CSMuzzleScale			= 1.2
SWEP.HoldType				= "ar2"
SWEP.ViewModel				= "models/weapons/v_smg_p90.mdl"	
SWEP.WorldModel				= "models/weapons/w_smg_p90.mdl"	

SWEP.Range					= 4096
SWEP.RangeModifier			= 0.84
SWEP.ArmorRatio				= 1.5

SWEP.Primary.Sound			= Sound( "Weapon_P90.Single" )
SWEP.Primary.Recoil			= 0.3
SWEP.Primary.Damage			= 26
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.027
SWEP.Primary.Delay			= 0.066

SWEP.Primary.ClipSize		= 50
SWEP.Primary.DefaultClip	= 50
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "BULLET_PLAYER_57MM"
