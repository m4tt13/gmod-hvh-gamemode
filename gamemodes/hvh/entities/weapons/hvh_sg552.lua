AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "SG552"
SWEP.Alias 					= "sg552"
SWEP.IconLetter				= "A"
SWEP.CanBuy        		 	= true

if CLIENT then
	killicon.AddFont( "hvh_sg552", "HvH_KillIcon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_PRIMARY
SWEP.Weight					= 25
SWEP.ViewModelFlip			= true
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= true
SWEP.HoldType				= "ar2"
SWEP.ViewModel				= "models/weapons/v_rif_sg552.mdl"	
SWEP.WorldModel				= "models/weapons/w_rif_sg552.mdl"	

SWEP.Primary.Sound			= Sound( "weapons/sg552/sg552-1.wav" )
SWEP.Primary.Recoil			= 2
SWEP.Primary.Damage			= 33
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.012
SWEP.Primary.Delay			= 0.0825
SWEP.Primary.Range			= 8192
SWEP.Primary.RangeModifier	= 0.955
SWEP.Primary.ArmorRatio		= 1.4

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "BULLET_PLAYER_556MM"

function SWEP:SetupDataTables()

	self:NetworkVar( "Int", 3, "ZoomLevel" )
	
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

	self:ShootBullet( self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone )

	self:TakePrimaryAmmo( 1 )
	
	self:SetNextPrimaryFire( CurTime() + delay )

end

function SWEP:SecondaryAttack() 

	if ( self:GetZoomLevel() == 0 ) then
	
		self:SetZoomLevel( 1 )
		self.Owner:SetFOV( 55, 0.2 )
		
	else
	
		self:SetZoomLevel( 0 )
		self.Owner:SetFOV( 0, 0.15 )
		
	end

	self:SetNextSecondaryFire( CurTime() + 0.3 )

end

function SWEP:Reload()

	self:DefaultReload( ACT_VM_RELOAD )
	
	if ( self:GetZoomLevel() != 0 ) then
	
		self:SetZoomLevel( 0 )
		self.Owner:SetFOV( 0, 0.15 )
		
	end
	
end

function SWEP:Deploy()

	self:SendWeaponAnim( ACT_VM_DRAW )

	self:SetZoomLevel( 0 )
	
	return true
	
end

if CLIENT then

	function SWEP:AdjustMouseSensitivity()

		if ( self:GetZoomLevel() == 1 ) then
			return 0.7
		end

		return nil

	end

end