AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "P228"	
SWEP.Alias 					= "p228"
SWEP.Image        		 	= "vgui/gfx/vgui/p228"
SWEP.IconLetter				= "Y"
SWEP.CanBuy        		 	= true

if ( CLIENT ) then
	killicon.AddFont( "hvh_p228", "hvh_killicon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_SECONDARY
SWEP.Type					= WPNTYPE_PITSOL
SWEP.Weight					= 5
SWEP.ViewModelFlip			= true
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= false
SWEP.CSMuzzleScale			= 1.0
SWEP.HoldType				= "pistol"
SWEP.ViewModel				= "models/weapons/v_pist_p228.mdl"	
SWEP.WorldModel				= "models/weapons/w_pist_p228.mdl"	

SWEP.Range					= 4096
SWEP.RangeModifier			= 0.8
SWEP.ArmorRatio				= 1.25
SWEP.MaxSpeed				= 250

SWEP.Primary.Sound			= Sound( "Weapon_P228.Single" )
SWEP.Primary.Recoil			= 2
SWEP.Primary.Damage			= 40
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.032
SWEP.Primary.Delay			= 0.15

SWEP.Primary.ClipSize		= 13
SWEP.Primary.DefaultClip	= 13
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "BULLET_PLAYER_357SIG"
