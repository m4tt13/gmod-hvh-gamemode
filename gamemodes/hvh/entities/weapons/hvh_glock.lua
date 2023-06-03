AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "Glock"
SWEP.Alias 					= "glock"
SWEP.IconLetter				= "c"
SWEP.CanBuy        		 	= true

if CLIENT then
	killicon.AddFont( "hvh_glock", "HvH_KillIcon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_SECONDARY
SWEP.Weight					= 5
SWEP.ViewModelFlip			= true
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= false
SWEP.HoldType				= "pistol"
SWEP.ViewModel				= "models/weapons/v_pist_glock18.mdl"	
SWEP.WorldModel				= "models/weapons/w_pist_glock18.mdl"	

SWEP.Primary.Sound			= Sound( "weapons/glock/glock18-1.wav" )
SWEP.Primary.Recoil			= 2
SWEP.Primary.Damage			= 25
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.023
SWEP.Primary.Delay			= 0.15
SWEP.Primary.Range			= 8192
SWEP.Primary.RangeModifier	= 0.75
SWEP.Primary.ArmorRatio		= 1.05

SWEP.Primary.ClipSize		= 20
SWEP.Primary.DefaultClip	= 20
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "BULLET_PLAYER_9MM"

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
	
	local damage = self.Primary.Damage
	local cone = self.Primary.Cone
	local delay = self.Primary.Delay
	
	if ( self:GetBurstMode() ) then
	
		damage = 18
		cone = 0.032
		delay = 0.5
		self:SetBurstShotsRemaining( 2 )
		self:SetNextBurstShot( CurTime() + 0.1 )

	end

	self:EmitSound( self.Primary.Sound )

	self:ShootBullet( damage, self.Primary.NumShots, cone )

	self:SendWeaponAnim( self:GetBurstMode() && ACT_VM_SECONDARYATTACK || ACT_VM_PRIMARYATTACK )
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self:TakePrimaryAmmo( 1 )
	
	self:SetNextPrimaryFire( CurTime() + delay )

end

function SWEP:SecondaryAttack() 

	if ( self:GetBurstMode() ) then
	
		self:SetBurstMode( false )
		self.Primary.Automatic = false
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Switched to semi-automatic" )
	
	else
	
		self:SetBurstMode( true )
		self.Primary.Automatic = true
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Switched to Burst-Fire mode" )
	
	end

	self:SetNextSecondaryFire( CurTime() + 0.3 )

end

function SWEP:Think()

	if ( self:GetBurstShotsRemaining() > 0 ) then
	
		if ( !self:CanPrimaryAttack() ) then 
	
			self:SetBurstShotsRemaining( 0 )
			self:SetNextBurstShot( 0 )
			return 
			
		end
		
		self:EmitSound( self.Primary.Sound )

		self:ShootBullet( self.Primary.Damage, self.Primary.NumShots, 0.05 )

		self.Owner:SetAnimation( PLAYER_ATTACK1 )

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

function SWEP:ShootEffects() end
