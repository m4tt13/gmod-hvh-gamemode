AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "USP"
SWEP.Alias 					= "usp"
SWEP.IconLetter				= "y"
SWEP.CanBuy        		 	= true

if CLIENT then
	killicon.AddFont( "hvh_usp", "hvh_killicon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_SECONDARY
SWEP.Weight					= 5
SWEP.ViewModelFlip			= true
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= false
SWEP.HoldType				= "pistol"
SWEP.ViewModel				= "models/weapons/v_pist_usp.mdl"	
SWEP.WorldModel				= "models/weapons/w_pist_usp.mdl"	

SWEP.Range					= 4096
SWEP.RangeModifier			= 0.79
SWEP.ArmorRatio				= 1

SWEP.Primary.Sound			= Sound( "Weapon_USP.Single" )
SWEP.Primary.Recoil			= 2
SWEP.Primary.Damage			= 34
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.023
SWEP.Primary.Delay			= 0.15

SWEP.Primary.ClipSize		= 12
SWEP.Primary.DefaultClip	= 12
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "BULLET_PLAYER_45ACP"

SWEP.Secondary.Delay		= 3

function SWEP:SetupDataTables()

	self:NetworkVar( "Bool", 0, "SilencerOn" )
	self:NetworkVar( "Float", 0, "DoneSwitchingSilencer" )
	
end

function SWEP:Initialize()

	self.BaseClass.Initialize( self )
	
	if ( SERVER ) then
	
		self:SetSilencerOn( false )
		self:SetDoneSwitchingSilencer( 0 )
		
	end
	
end

local snd_silenced = Sound( "Weapon_USP.SilencedShot" )

function SWEP:PrimaryAttack()

	if ( !self:CanPrimaryAttack() ) then return end

	local damage = self.Primary.Damage
	local cone = self.Primary.Cone

	if ( self:GetSilencerOn() ) then
	
		damage = 30
		cone = 0.03
		
	end

	self:EmitSound( self:GetSilencerOn() && snd_silenced || self.Primary.Sound )

	self:ShootBullet( damage, self.Primary.Recoil, self.Primary.NumShots, cone )

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

	self:SetDoneSwitchingSilencer( CurTime() + self.Secondary.Delay )
	self:SetNextPrimaryFire( CurTime() + self.Secondary.Delay )
	self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )

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
