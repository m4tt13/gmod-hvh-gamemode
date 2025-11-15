AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "XM1014"
SWEP.Alias 					= "xm1014"
SWEP.Image        		 	= "vgui/gfx/vgui/xm1014"
SWEP.IconLetter				= "B"
SWEP.CanBuy        		 	= true

if ( CLIENT ) then
	killicon.AddFont( "hvh_xm1014", "hvh_killicon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_PRIMARY
SWEP.Type					= WPNTYPE_SHOTGUN
SWEP.Weight					= 20
SWEP.ViewModelFlip			= true
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= false
SWEP.CSMuzzleScale			= 1.3
SWEP.HoldType				= "shotgun"
SWEP.ViewModel				= "models/weapons/v_shot_xm1014.mdl"	
SWEP.WorldModel				= "models/weapons/w_shot_xm1014.mdl"	

SWEP.Range					= 3048
SWEP.RangeModifier			= 0.96
SWEP.ArmorRatio				= 1
SWEP.MaxSpeed				= 240

SWEP.Primary.Sound			= Sound( "Weapon_XM1014.Single" )
SWEP.Primary.Recoil			= 4
SWEP.Primary.Damage			= 20
SWEP.Primary.NumShots		= 6
SWEP.Primary.Cone			= 0.0725
SWEP.Primary.Delay			= 0.25

SWEP.Primary.ClipSize		= 7
SWEP.Primary.DefaultClip	= 7
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "BULLET_PLAYER_BUCKSHOT"

function SWEP:SetupDataTables()

	self:NetworkVar( "Int", "ReloadState" )
	self:NetworkVar( "Float", "ReloadTimer" )
	
end

function SWEP:Initialize()

	self.BaseClass.Initialize( self )
	
	if ( SERVER ) then
	
		self:SetReloadState( 0 )
		self:SetReloadTimer( 0 )
		
	end

end

function SWEP:PrimaryAttack()

	if ( !self:CanPrimaryAttack() ) then return end

	self:SetReloadState( 0 )
	self:SetReloadTimer( 0 )

	self:EmitSound( self.Primary.Sound )

	self:ShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone )

	self:TakePrimaryAmmo( 1 )
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

end

function SWEP:Think()

	if ( self:GetReloadState() == 0 || CurTime() < self:GetReloadTimer() ) then 
		return
	end
	
	if ( self:Clip1() < self:GetMaxClip1() && self:Ammo1() > 0 ) then
	
		if ( self:GetReloadState() == 1 ) then
		
			self:SetReloadState( 2 )
			self:SetReloadTimer( CurTime() + 0.5 )
				
			self:SendWeaponAnim( ACT_VM_RELOAD )
			
			self:SetNextPrimaryFire( CurTime() + 0.5 )
			
		else

			self:SetReloadState( 1 )

			self:GetOwner():RemoveAmmo( 1, self:GetPrimaryAmmoType() )
			self:SetClip1( self:Clip1() + 1 )
		
		end
		
	else
	
		self:SetReloadState( 0 )
		self:SetReloadTimer( 0 )
		
		self:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
	
	end

end

function SWEP:Reload()

	if ( self:GetReloadState() != 0 ) then
		return
	end
	
	if ( self:Clip1() < self:GetMaxClip1() && self:Ammo1() > 0 ) then
	
		self:SetReloadState( 1 )
		self:SetReloadTimer( CurTime() + 0.5 )
		
		self:SendWeaponAnim( ACT_SHOTGUN_RELOAD_START )

		self:SetNextPrimaryFire( CurTime() + 0.5 )
		
	end
	
end

function SWEP:Deploy()

	self:SendWeaponAnim( ACT_VM_DRAW )

	self:SetReloadState( 0 )
	self:SetReloadTimer( 0 )
	
	return true
	
end
