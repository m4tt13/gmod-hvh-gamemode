AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "MAC10"
SWEP.Alias 					= "mac10"
SWEP.IconLetter				= "l"
SWEP.CanBuy        		 	= true

if CLIENT then
	killicon.AddFont( "hvh_mac10", "hvh_killicon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_PRIMARY
SWEP.Weight					= 25
SWEP.ViewModelFlip			= true
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= false
SWEP.HoldType				= "pistol"
SWEP.ViewModel				= "models/weapons/v_smg_mac10.mdl"	
SWEP.WorldModel				= "models/weapons/w_smg_mac10.mdl"	

SWEP.Range					= 4096
SWEP.RangeModifier			= 0.82
SWEP.ArmorRatio				= 0.95

SWEP.Primary.Sound			= Sound( "Weapon_MAC10.Single" )
SWEP.Primary.Recoil			= 2
SWEP.Primary.Damage			= 29
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.028
SWEP.Primary.Delay			= 0.07

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "BULLET_PLAYER_45ACP"
