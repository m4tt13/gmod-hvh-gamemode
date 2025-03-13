AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "Deagle"
SWEP.Alias 					= "deagle"
SWEP.IconLetter				= "f"
SWEP.CanBuy        		 	= true

if CLIENT then
	killicon.AddFont( "hvh_deagle", "hvh_killicon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_SECONDARY
SWEP.Weight					= 7
SWEP.ViewModelFlip			= true
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= false
SWEP.HoldType				= "revolver"
SWEP.ViewModel				= "models/weapons/v_pist_deagle.mdl"	
SWEP.WorldModel				= "models/weapons/w_pist_deagle.mdl"	

SWEP.Range					= 4096
SWEP.RangeModifier			= 0.81
SWEP.ArmorRatio				= 1.5

SWEP.Primary.Sound			= Sound( "Weapon_DEagle.Single" )
SWEP.Primary.Recoil			= 2
SWEP.Primary.Damage			= 54
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.03
SWEP.Primary.Delay			= 0.225

SWEP.Primary.ClipSize		= 7
SWEP.Primary.DefaultClip	= 7
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "BULLET_PLAYER_50AE"
