AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "M4A1"	
SWEP.Alias 					= "m4a1"
SWEP.IconLetter				= "w"
SWEP.CanBuy        		 	= true

if CLIENT then
	killicon.AddFont( "hvh_m4a1", "HvH_KillIcon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_PRIMARY
SWEP.Weight					= 25
SWEP.ViewModelFlip			= true
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= true
SWEP.HoldType				= "ar2"
SWEP.ViewModel				= "models/weapons/v_rif_m4a1.mdl"	
SWEP.WorldModel				= "models/weapons/w_rif_m4a1.mdl"	

SWEP.Primary.Sound			= Sound( "Weapon_M4A1.Single" )
SWEP.Primary.SoundSilenced	= Sound( "Weapon_M4A1.Silenced" )
SWEP.Primary.Recoil			= 2
SWEP.Primary.Damage			= 33
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.012
SWEP.Primary.Delay			= 0.0875
SWEP.Primary.Range			= 8192
SWEP.Primary.RangeModifier	= 0.97
SWEP.Primary.ArmorRatio		= 1.4

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "BULLET_PLAYER_556MM"

function SWEP:SetupDataTables()

	self:NetworkVar( "Bool", 3, "SilencerOn" )
	self:NetworkVar( "Float", 3, "DoneSwitchingSilencer" )
	
end

function SWEP:Initialize()

	self.BaseClass.Initialize( self )
	
	if ( SERVER ) then
	
		self:SetSilencerOn( false )
		self:SetDoneSwitchingSilencer( 0 )
		
	end
	
end

function SWEP:PrimaryAttack()

	if ( !self:CanPrimaryAttack() ) then return end

	local cone = self.Primary.Cone

	if ( self:GetSilencerOn() ) then
		cone = 0.015
	end

	self:EmitSound( self:GetSilencerOn() && self.Primary.SoundSilenced || self.Primary.Sound )

	self:ShootBullet( self.Primary.Damage, self.Primary.NumShots, cone )

	self:TakePrimaryAmmo( 1 )
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

end

function SWEP:SecondaryAttack() 

	if ( self:GetSilencerOn() ) then
	
		self:SetSilencerOn( false )
		self:SendWeaponAnim( ACT_VM_DETACH_SILENCER )
	
	else
	
		self:SetSilencerOn( true )
		self:SendWeaponAnim( ACT_VM_ATTACH_SILENCER )
	
	end

	self:SetDoneSwitchingSilencer( CurTime() + 2 )
	self:SetNextPrimaryFire( CurTime() + 2 )
	self:SetNextSecondaryFire( CurTime() + 2 )

end

function SWEP:Reload()
	
	if ( CurTime() < self:GetDoneSwitchingSilencer() ) then
		return
	end
	
	self:DefaultReload( self:GetSilencerOn() && ACT_VM_RELOAD_SILENCED || ACT_VM_RELOAD )
	
end

function SWEP:Holster( wep )

	if ( CurTime() < self:GetDoneSwitchingSilencer() ) then
		self:SetSilencerOn( !self:GetSilencerOn() )
	end

	return true
	
end

function SWEP:Deploy()

	self:SendWeaponAnim( self:GetSilencerOn() && ACT_VM_DRAW_SILENCED || ACT_VM_DRAW )

	self:SetDoneSwitchingSilencer( 0 )
	
	return true
	
end

function SWEP:ShootEffects()

	if ( self:GetSilencerOn() ) then
	
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_SILENCED )
		
	else
	
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self.Owner:MuzzleFlash()
		
	end

	self.Owner:SetAnimation( PLAYER_ATTACK1 )

end

if CLIENT then

	function SWEP:FireAnimationEvent( pos, ang, event, options )

		if ( self:GetSilencerOn() ) then 
			return true
		end

		return self.BaseClass.FireAnimationEvent( self, pos, ang, event, options )

	end
	
end
