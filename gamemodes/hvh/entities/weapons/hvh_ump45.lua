AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "UMP45"
SWEP.Alias 					= "ump45"
SWEP.IconLetter				= "q"
SWEP.CanBuy        		 	= true

if CLIENT then
	killicon.AddFont( "hvh_ump45", "HvH_KillIcon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_PRIMARY
SWEP.Weight					= 25
SWEP.ViewModelFlip			= true
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= false
SWEP.HoldType				= "smg"
SWEP.ViewModel				= "models/weapons/v_smg_ump45.mdl"	
SWEP.WorldModel				= "models/weapons/w_smg_ump45.mdl"	

SWEP.Range					= 4096
SWEP.RangeModifier			= 0.82
SWEP.ArmorRatio				= 1

SWEP.Primary.Sound			= Sound( "Weapon_UMP45.Single" )
SWEP.Primary.Recoil			= 2
SWEP.Primary.Damage			= 30
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.024
SWEP.Primary.Delay			= 0.1

SWEP.Primary.ClipSize		= 25
SWEP.Primary.DefaultClip	= 25
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "BULLET_PLAYER_45ACP"
