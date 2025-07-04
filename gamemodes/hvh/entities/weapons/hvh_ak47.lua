AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "AK47"
SWEP.Alias 					= "ak47"
SWEP.IconLetter				= "b"
SWEP.CanBuy        		 	= true

if CLIENT then
	killicon.AddFont( "hvh_ak47", "hvh_killicon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_PRIMARY
SWEP.Weight					= 25
SWEP.ViewModelFlip			= true
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= true
SWEP.CSMuzzleScale			= 1.6
SWEP.HoldType				= "ar2"
SWEP.ViewModel				= "models/weapons/v_rif_ak47.mdl"	
SWEP.WorldModel				= "models/weapons/w_rif_ak47.mdl"	

SWEP.Range					= 8192
SWEP.RangeModifier			= 0.98
SWEP.ArmorRatio				= 1.55

SWEP.Primary.Sound			= Sound( "Weapon_AK47.Single" )
SWEP.Primary.Recoil			= 1
SWEP.Primary.Damage			= 36
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.Delay			= 0.0955

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "BULLET_PLAYER_762MM"
