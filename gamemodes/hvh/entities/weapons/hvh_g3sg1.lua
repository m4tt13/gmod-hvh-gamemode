AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "G3SG1"
SWEP.Alias 					= "g3sg1"
SWEP.Image        		 	= "vgui/gfx/vgui/g3sg1"
SWEP.IconLetter				= "i"
SWEP.CanBuy        		 	= true

if ( CLIENT ) then
	killicon.AddFont( "hvh_g3sg1", "hvh_killicon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_PRIMARY
SWEP.Type					= WPNTYPE_SNIPER
SWEP.DrawCrosshair			= false
SWEP.Weight					= 20
SWEP.ViewModelFlip			= true
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= true
SWEP.CSMuzzleScale			= 1.5
SWEP.HoldType				= "ar2"
SWEP.ViewModel				= "models/weapons/v_snip_g3sg1.mdl"	
SWEP.WorldModel				= "models/weapons/w_snip_g3sg1.mdl"	

SWEP.Range					= 8192
SWEP.RangeModifier			= 0.98
SWEP.ArmorRatio				= 1.65

SWEP.Primary.Sound			= Sound( "Weapon_G3SG1.Single" )
SWEP.Primary.Recoil			= 1.25
SWEP.Primary.Damage			= 80
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.028
SWEP.Primary.Delay			= 0.25

SWEP.Primary.ClipSize		= 20
SWEP.Primary.DefaultClip	= 20
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "BULLET_PLAYER_762MM"

SWEP.Secondary.Sound		= Sound( "Default.Zoom" )
SWEP.Secondary.Delay		= 0.3

function SWEP:SetupDataTables()

	self:NetworkVar( "Int", 0, "ZoomLevel" )
	self:NetworkVar( "Float", 0, "ZoomFullyActiveTime" )
	
end

function SWEP:Initialize()

	self.BaseClass.Initialize( self )
	
	if ( SERVER ) then
	
		self:SetZoomLevel( 0 )
		self:SetZoomFullyActiveTime( 0 )
		
	end

end

function SWEP:PrimaryAttack()

	if ( !self:CanPrimaryAttack() ) then return end

	local cone = self.Primary.Cone

	if ( self:GetZoomLevel() != 0 && self:GetZoomFullyActiveTime() <= CurTime() ) then
		cone = 0.01
	end

	self:EmitSound( self.Primary.Sound )

	self:ShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, cone )

	self:TakePrimaryAmmo( 1 )
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )

end

function SWEP:SecondaryAttack() 

	if ( self:GetZoomLevel() == 0 ) then
	
		self:SetZoomLevel( 1 )
		self:GetOwner():SetFOV( 40, 0.3 )
		
	elseif ( self:GetZoomLevel() == 1 ) then
	
		self:SetZoomLevel( 2 )
		self:GetOwner():SetFOV( 15, 0.05 )
		
	else
	
		self:SetZoomLevel( 0 )
		self:GetOwner():SetFOV( 0, 0.1 )
	
	end
	
	self:EmitSound( self.Secondary.Sound )

	self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	self:SetZoomFullyActiveTime( CurTime() + self.Secondary.Delay )

end

function SWEP:Reload()

	self:DefaultReload( ACT_VM_RELOAD )
	
	if ( self:GetZoomLevel() != 0 ) then
	
		self:SetZoomLevel( 0 )
		self:GetOwner():SetFOV( 0, 0.1 )
		
	end
	
	self:SetZoomFullyActiveTime( 0 )
	
end

function SWEP:Deploy()

	self:SendWeaponAnim( ACT_VM_DRAW )

	self:SetZoomLevel( 0 )
	self:SetZoomFullyActiveTime( 0 )
	
	return true
	
end

function SWEP:IsZoomed()

	return ( self:GetZoomLevel() != 0 )
	
end