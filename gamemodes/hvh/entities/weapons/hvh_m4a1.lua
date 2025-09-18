AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "M4A1"	
SWEP.Alias 					= "m4a1"
SWEP.Image        		 	= "vgui/gfx/vgui/m4a1"
SWEP.IconLetter				= "w"
SWEP.CanBuy        		 	= true

if CLIENT then
	killicon.AddFont( "hvh_m4a1", "hvh_killicon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_PRIMARY
SWEP.Weight					= 25
SWEP.ViewModelFlip			= true
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= true
SWEP.CSMuzzleScale			= 1.6
SWEP.HoldType				= "ar2"
SWEP.ViewModel				= "models/weapons/v_rif_m4a1.mdl"	
SWEP.WorldModel				= "models/weapons/w_rif_m4a1.mdl"	

SWEP.Range					= 8192
SWEP.RangeModifier			= 0.97
SWEP.ArmorRatio				= 1.4

SWEP.Primary.Sound			= Sound( "Weapon_M4A1.Single" )
SWEP.Primary.Recoil			= 0.65
SWEP.Primary.Damage			= 33
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.012
SWEP.Primary.Delay			= 0.0875

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "BULLET_PLAYER_556MM"

SWEP.Secondary.Delay		= 2

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

local snd_silenced = Sound( "Weapon_M4A1.Silenced" )

function SWEP:PrimaryAttack()

	if ( !self:CanPrimaryAttack() ) then return end

	local cone = self.Primary.Cone

	if ( self:GetSilencerOn() ) then
		cone = 0.015
	end

	self:EmitSound( self:GetSilencerOn() && snd_silenced || self.Primary.Sound )

	self:ShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, cone )

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

function SWEP:OnTraceAttack( dmginfo, dir, trace )

	local rangeModifier = self.RangeModifier
	
	if ( self:GetSilencerOn() ) then	
		rangeModifier = 0.95
	end

	local travelledDistance = trace.Fraction * self.Range
	local damageScale = math.pow( rangeModifier, ( travelledDistance / 500 ) )

	dmginfo:ScaleDamage( damageScale )

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
