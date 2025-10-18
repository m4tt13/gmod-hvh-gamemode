AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "TMP"
SWEP.Alias 					= "tmp"
SWEP.Image        		 	= "vgui/gfx/vgui/tmp"
SWEP.IconLetter				= "d"
SWEP.CanBuy        		 	= true

if ( CLIENT ) then
	killicon.AddFont( "hvh_tmp", "hvh_killicon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_PRIMARY
SWEP.Type					= WPNTYPE_SMG
SWEP.Weight					= 25
SWEP.ViewModelFlip			= true
SWEP.CSMuzzleFlashes 		= false
SWEP.CSMuzzleX 				= false
SWEP.CSMuzzleScale			= 0.8
SWEP.HoldType				= "smg"
SWEP.ViewModel				= "models/weapons/v_smg_tmp.mdl"	
SWEP.WorldModel				= "models/weapons/w_smg_tmp.mdl"	

SWEP.Range					= 4096
SWEP.RangeModifier			= 0.84
SWEP.ArmorRatio				= 1
SWEP.MaxSpeed				= 250

SWEP.Primary.Sound			= Sound( "Weapon_TMP.Single" )
SWEP.Primary.Recoil			= 0.725
SWEP.Primary.Damage			= 26
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.025
SWEP.Primary.Delay			= 0.07

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "BULLET_PLAYER_9MM"

function SWEP:ShootEffects()

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

end

if ( CLIENT ) then

	function SWEP:FireAnimationEvent( pos, ang, event, options )
	
		if ( event == 5001 || event == 5011 || event == 5021 || event == 5031 || event == 5003 || event == 5013 || event == 5023 || event == 5033 ) then 
			return true 
		end
		
	end
	
end