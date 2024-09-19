AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "M3"
SWEP.Alias 					= "m3"
SWEP.IconLetter				= "k"
SWEP.CanBuy        		 	= true

if CLIENT then
	killicon.AddFont( "hvh_m3", "HvH_KillIcon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_PRIMARY
SWEP.Weight					= 20
SWEP.ViewModelFlip			= true
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= false
SWEP.HoldType				= "shotgun"
SWEP.ViewModel				= "models/weapons/v_shot_m3super90.mdl"	
SWEP.WorldModel				= "models/weapons/w_shot_m3super90.mdl"	

SWEP.Range					= 3000
SWEP.RangeModifier			= 0.96
SWEP.ArmorRatio				= 1

SWEP.Primary.Sound			= Sound( "Weapon_M3.Single" )
SWEP.Primary.Recoil			= 2
SWEP.Primary.Damage			= 22
SWEP.Primary.NumShots		= 9
SWEP.Primary.Cone			= 0.0675
SWEP.Primary.Delay			= 0.875

SWEP.Primary.ClipSize		= 8
SWEP.Primary.DefaultClip	= 8
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "BULLET_PLAYER_BUCKSHOT"

function SWEP:SetupDataTables()

	self:NetworkVar( "Int", 0, "ReloadState" )
	self:NetworkVar( "Float", 0, "ReloadTimer" )
	
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

	self:ShootBullet( self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone )

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

			self.Owner:RemoveAmmo( 1, self:GetPrimaryAmmoType() )
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
