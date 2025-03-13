AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "MP5 Navy"
SWEP.Alias 					= "mp5"
SWEP.IconLetter				= "x"
SWEP.CanBuy        		 	= true

if CLIENT then
	killicon.AddFont( "hvh_mp5navy", "hvh_killicon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_PRIMARY
SWEP.Weight					= 25
SWEP.ViewModelFlip			= true
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= false
SWEP.HoldType				= "smg"
SWEP.ViewModel				= "models/weapons/v_smg_mp5.mdl"	
SWEP.WorldModel				= "models/weapons/w_smg_mp5.mdl"	

SWEP.Range					= 4096
SWEP.RangeModifier			= 0.84
SWEP.ArmorRatio				= 1

SWEP.Primary.Sound			= Sound( "Weapon_MP5Navy.Single" )
SWEP.Primary.Recoil			= 2
SWEP.Primary.Damage			= 26
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.018
SWEP.Primary.Delay			= 0.075

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "BULLET_PLAYER_9MM"
