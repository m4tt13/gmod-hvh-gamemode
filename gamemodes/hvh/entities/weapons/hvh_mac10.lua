AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "MAC10"
SWEP.Alias 					= "mac10"
SWEP.IconLetter				= "l"
SWEP.CanBuy        		 	= true

if CLIENT then
	killicon.AddFont( "hvh_mac10", "HvH_KillIcon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_PRIMARY
SWEP.Weight					= 25
SWEP.ViewModelFlip			= true
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= false
SWEP.HoldType				= "pistol"
SWEP.ViewModel				= "models/weapons/v_smg_mac10.mdl"	
SWEP.WorldModel				= "models/weapons/w_smg_mac10.mdl"	

SWEP.Primary.Sound			= Sound( "weapons/mac10/mac10-1.wav" )
SWEP.Primary.Recoil			= 2
SWEP.Primary.Damage			= 29
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.028
SWEP.Primary.Delay			= 0.07
SWEP.Primary.Range			= 4096
SWEP.Primary.RangeModifier	= 0.82
SWEP.Primary.ArmorRatio		= 0.95

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "BULLET_PLAYER_45ACP"
