AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "AUG"
SWEP.Alias 					= "aug"
SWEP.Image        		 	= "vgui/gfx/vgui/aug"
SWEP.IconLetter				= "e"
SWEP.CanBuy        		 	= true
SWEP.HideViewModelWhenZoomed = false

if ( CLIENT ) then
	killicon.AddFont( "hvh_aug", "hvh_killicon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_PRIMARY
SWEP.Type					= WPNTYPE_RIFLE
SWEP.Weight					= 25
SWEP.ViewModelFlip			= true
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= true
SWEP.CSMuzzleScale			= 1.3
SWEP.HoldType				= "ar2"
SWEP.ViewModel				= "models/weapons/v_rif_aug.mdl"	
SWEP.WorldModel				= "models/weapons/w_rif_aug.mdl"	

SWEP.Range					= 8192
SWEP.RangeModifier			= 0.96
SWEP.ArmorRatio				= 1.4
SWEP.MaxSpeed				= 221

SWEP.Primary.Sound			= Sound( "Weapon_AUG.Single" )
SWEP.Primary.Recoil			= 0.625
SWEP.Primary.Damage			= 32
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.012
SWEP.Primary.Delay			= 0.0825

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "BULLET_PLAYER_762MM"

SWEP.Secondary.Delay		= 0.3

function SWEP:SetupDataTables()

	self:NetworkVar( "Int", "ZoomLevel" )
	
end

function SWEP:Initialize()

	self.BaseClass.Initialize( self )
	
	if ( SERVER ) then
		self:SetZoomLevel( 0 )
	end

end

function SWEP:PrimaryAttack()

	if ( !self:CanPrimaryAttack() ) then return end
	
	local delay = self.Primary.Delay
	
	if ( self:GetZoomLevel() != 0 ) then
		delay = 0.135
	end

	self:EmitSound( self.Primary.Sound )

	self:ShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone )

	self:TakePrimaryAmmo( 1 )
	
	self:SetNextPrimaryFire( CurTime() + delay )
	self:SetNextSecondaryFire( CurTime() + delay )

end

function SWEP:SecondaryAttack() 

	if ( self:GetZoomLevel() == 0 ) then
	
		self:SetZoomLevel( 1 )
		self:GetOwner():SetFOV( 55, 0.2 )
		
	else
	
		self:SetZoomLevel( 0 )
		self:GetOwner():SetFOV( 0, 0.15 )
		
	end

	self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )

end

function SWEP:Reload()

	self:DefaultReload( ACT_VM_RELOAD )
	
	if ( self:GetZoomLevel() != 0 ) then
	
		self:SetZoomLevel( 0 )
		self:GetOwner():SetFOV( 0, 0.15 )
		
	end
	
end

function SWEP:Deploy()

	self:SendWeaponAnim( ACT_VM_DRAW )

	self:SetZoomLevel( 0 )
	
	return true
	
end

function SWEP:IsZoomed()

	return ( self:GetZoomLevel() != 0 )
	
end