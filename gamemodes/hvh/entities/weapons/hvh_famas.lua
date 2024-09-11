AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "FAMAS"
SWEP.Alias 					= "famas"
SWEP.IconLetter				= "t"
SWEP.CanBuy        		 	= true

if CLIENT then
	killicon.AddFont( "hvh_famas", "HvH_KillIcon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_PRIMARY
SWEP.Weight					= 75
SWEP.ViewModelFlip			= false
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= true
SWEP.HoldType				= "ar2"
SWEP.ViewModel				= "models/weapons/v_rif_famas.mdl"	
SWEP.WorldModel				= "models/weapons/w_rif_famas.mdl"	

SWEP.Primary.Sound			= Sound( "Weapon_FAMAS.Single" )
SWEP.Primary.Recoil			= 2
SWEP.Primary.Damage			= 30
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.017
SWEP.Primary.Delay			= 0.0825
SWEP.Primary.Range			= 8192
SWEP.Primary.RangeModifier	= 0.96
SWEP.Primary.ArmorRatio		= 1.4

SWEP.Primary.ClipSize		= 25
SWEP.Primary.DefaultClip	= 25
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "BULLET_PLAYER_556MM"

function SWEP:SetupDataTables()

	self:NetworkVar( "Bool", 3, "BurstMode" )
	self:NetworkVar( "Int", 3, "BurstShotsRemaining" )
	self:NetworkVar( "Float", 3, "NextBurstShot" )
	
end

function SWEP:Initialize()

	self.BaseClass.Initialize( self )
	
	if ( SERVER ) then
	
		self:SetBurstMode( false )
		self:SetBurstShotsRemaining( 0 )
		self:SetNextBurstShot( 0 )
		
	end

end

function SWEP:PrimaryAttack()

	if ( !self:CanPrimaryAttack() ) then return end
	
	local cone = self.Primary.Cone
	local delay = self.Primary.Delay
	
	if ( self:GetBurstMode() ) then
	
		cone = 0.008
		delay = 0.55
		self:SetBurstShotsRemaining( 2 )
		self:SetNextBurstShot( CurTime() + 0.05 )

	end

	self:EmitSound( self.Primary.Sound )

	self:ShootBullet( self.Primary.Damage, self.Primary.NumShots, cone )

	self:TakePrimaryAmmo( 1 )
	
	self:SetNextPrimaryFire( CurTime() + delay )

end

function SWEP:SecondaryAttack() 

	if ( self:GetBurstMode() ) then
	
		self:SetBurstMode( false )
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Switched to automatic" )
	
	else
	
		self:SetBurstMode( true )
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Switched to Burst-Fire mode" )
	
	end
	
	self:SetNextSecondaryFire( CurTime() + 0.3 )

end

function SWEP:Think()

	if ( self:GetBurstShotsRemaining() > 0 && CurTime() >= self:GetNextBurstShot() ) then
	
		if ( !self:CanPrimaryAttack() ) then 
	
			self:SetBurstShotsRemaining( 0 )
			self:SetNextBurstShot( 0 )
			return 
			
		end
		
		self:EmitSound( self.Primary.Sound )

		self:ShootBullet( self.Primary.Damage, self.Primary.NumShots, 0.008 )

		self:TakePrimaryAmmo( 1 )
		
		self:SetBurstShotsRemaining( self:GetBurstShotsRemaining() - 1 )
			
		if ( self:GetBurstShotsRemaining() > 0 ) then
			self:SetNextBurstShot( CurTime() + 0.1 )
		else
			self:SetNextBurstShot( 0 )
		end
	
	end

end

function SWEP:Reload()
	
	self:DefaultReload( ACT_VM_RELOAD )
	
	self:SetBurstShotsRemaining( 0 )
	self:SetNextBurstShot( 0 )

end

function SWEP:Deploy()

	self:SendWeaponAnim( ACT_VM_DRAW )

	self:SetBurstShotsRemaining( 0 )
	self:SetNextBurstShot( 0 )
	
	return true
	
end
