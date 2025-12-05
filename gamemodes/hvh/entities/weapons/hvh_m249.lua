AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "M249"
SWEP.Alias 					= "m249"
SWEP.Image        		 	= "vgui/gfx/vgui/m249"
SWEP.IconLetter				= "Z"
SWEP.CanBuy        		 	= true

if ( CLIENT ) then
	killicon.AddFont( "hvh_m249", "hvh_killicon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_PRIMARY
SWEP.Type					= WPNTYPE_MACHINEGUN
SWEP.Weight					= 25
SWEP.ViewModelFlip			= false
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= true
SWEP.CSMuzzleScale			= 1.5
SWEP.HoldType				= "ar2"
SWEP.ViewModel				= "models/weapons/v_mach_m249para.mdl"	
SWEP.WorldModel				= "models/weapons/w_mach_m249para.mdl"	

SWEP.Range					= 8192
SWEP.RangeModifier			= 0.97
SWEP.ArmorRatio				= 1.5
SWEP.MaxSpeed				= 220

SWEP.Primary.Sound			= Sound( "Weapon_M249.Single" )
SWEP.Primary.Recoil			= 0.8
SWEP.Primary.Damage			= 32
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.016
SWEP.Primary.Delay			= 0.08

SWEP.Primary.ClipSize		= 100
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "BULLET_PLAYER_556MM_BOX"
