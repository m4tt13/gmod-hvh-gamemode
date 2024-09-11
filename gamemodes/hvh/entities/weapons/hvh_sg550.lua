AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "SG550"
SWEP.Alias 					= "sg550"
SWEP.IconLetter				= "o"
SWEP.CanBuy        		 	= true

if CLIENT then
	killicon.AddFont( "hvh_sg550", "HvH_KillIcon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_PRIMARY
SWEP.DrawCrosshair			= false
SWEP.Weight					= 20
SWEP.ViewModelFlip			= true
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= true
SWEP.HoldType				= "ar2"
SWEP.ViewModel				= "models/weapons/v_snip_sg550.mdl"	
SWEP.WorldModel				= "models/weapons/w_snip_sg550.mdl"	

SWEP.Primary.Sound			= Sound( "Weapon_SG550.Single" )
SWEP.Primary.SoundZoom		= Sound( "Default.Zoom" )
SWEP.Primary.Recoil			= 2
SWEP.Primary.Damage			= 70
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.025
SWEP.Primary.Delay			= 0.25
SWEP.Primary.Range			= 8192
SWEP.Primary.RangeModifier	= 0.98
SWEP.Primary.ArmorRatio		= 1.45

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "BULLET_PLAYER_556MM"

function SWEP:SetupDataTables()

	self:NetworkVar( "Int", 3, "ZoomLevel" )
	self:NetworkVar( "Float", 3, "ZoomFullyActiveTime" )
	
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
		cone = 0.008
	end

	self:EmitSound( self.Primary.Sound )

	self:ShootBullet( self.Primary.Damage, self.Primary.NumShots, cone )

	self:TakePrimaryAmmo( 1 )
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

end

function SWEP:SecondaryAttack() 

	if ( self:GetZoomLevel() == 0 ) then
	
		self:SetZoomLevel( 1 )
		self.Owner:SetFOV( 40, 0.3 )
		
	elseif ( self:GetZoomLevel() == 1 ) then
	
		self:SetZoomLevel( 2 )
		self.Owner:SetFOV( 15, 0.05 )
		
	else
	
		self:SetZoomLevel( 0 )
		self.Owner:SetFOV( 0, 0.1 )
	
	end
	
	self:EmitSound( self.Primary.SoundZoom )

	self:SetNextSecondaryFire( CurTime() + 0.3 )
	self:SetZoomFullyActiveTime( CurTime() + 0.3 )

end

function SWEP:Reload()

	self:DefaultReload( ACT_VM_RELOAD )
	
	if ( self:GetZoomLevel() != 0 ) then
	
		self:SetZoomLevel( 0 )
		self.Owner:SetFOV( 0, 0.1 )
		
	end
	
	self:SetZoomFullyActiveTime( 0 )
	
end

function SWEP:Deploy()

	self:SendWeaponAnim( ACT_VM_DRAW )

	self:SetZoomLevel( 0 )
	self:SetZoomFullyActiveTime( 0 )
	
	return true
	
end

if CLIENT then

	function SWEP:DrawHUD()

		if ( self:GetZoomLevel() != 0 ) then 
		
			surface.SetDrawColor( 0, 0, 0, 255 )
			
			surface.DrawLine( ScrW() / 2, 0, ScrW() / 2, ScrH() )
			surface.DrawLine( 0, ScrH() / 2, ScrW(), ScrH() / 2 )
			
		end
		
	end
	
	function SWEP:ShouldDrawViewModel()

		return ( self:GetZoomLevel() == 0 ) 
		
	end
	
	function SWEP:AdjustMouseSensitivity()

		if ( self:GetZoomLevel() == 1 ) then
			return 0.5
		elseif ( self:GetZoomLevel() == 2 ) then
			return 0.2
		end

		return nil

	end

end