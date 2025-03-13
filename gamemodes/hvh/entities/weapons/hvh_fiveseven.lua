AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "Five Seven"
SWEP.Alias 					= "fiveseven"
SWEP.IconLetter				= "u"
SWEP.CanBuy        		 	= true

if CLIENT then
	killicon.AddFont( "hvh_fiveseven", "hvh_killicon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_SECONDARY
SWEP.Weight					= 5
SWEP.ViewModelFlip			= true
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= false
SWEP.HoldType				= "pistol"
SWEP.ViewModel				= "models/weapons/v_pist_fiveseven.mdl"	
SWEP.WorldModel				= "models/weapons/w_pist_fiveseven.mdl"	

SWEP.Range					= 4096
SWEP.RangeModifier			= 0.885
SWEP.ArmorRatio				= 1.5

SWEP.Primary.Sound			= Sound( "Weapon_FiveSeven.Single" )
SWEP.Primary.Recoil			= 2
SWEP.Primary.Damage			= 25
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.025
SWEP.Primary.Delay			= 0.15

SWEP.Primary.ClipSize		= 20
SWEP.Primary.DefaultClip	= 20
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "BULLET_PLAYER_57MM"
