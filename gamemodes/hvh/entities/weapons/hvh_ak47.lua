AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "AK47"
SWEP.Alias 					= "ak47"
SWEP.IconLetter				= "b"
SWEP.CanBuy        		 	= true

if CLIENT then
	killicon.AddFont( "hvh_ak47", "HvH_KillIcon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_PRIMARY
SWEP.Weight					= 25
SWEP.ViewModelFlip			= true
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= true
SWEP.HoldType				= "ar2"
SWEP.ViewModel				= "models/weapons/v_rif_ak47.mdl"	
SWEP.WorldModel				= "models/weapons/w_rif_ak47.mdl"	

SWEP.Primary.Sound			= Sound( "weapons/ak47/ak47-1.wav" )
SWEP.Primary.Recoil			= 2
SWEP.Primary.Damage			= 36
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.Delay			= 0.0955
SWEP.Primary.Range			= 8192
SWEP.Primary.RangeModifier	= 0.98
SWEP.Primary.ArmorRatio		= 1.55

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "BULLET_PLAYER_762MM"
