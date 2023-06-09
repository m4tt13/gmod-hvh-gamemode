AddCSLuaFile()

if CLIENT then

	surface.CreateFont( "HvH_SelectionIcon", {

		font = "csd",
		size = 80,
		weight = 0,
		antialias = true,
		additive = true

	} )
	
end

SWEP.Base 				= "weapon_base"

SWEP.Slot				= 0
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false
SWEP.SwayScale			= 0.5
SWEP.BobScale			= 0.5
SWEP.ViewModelFOV		= 72
SWEP.ViewModelFlip		= false
SWEP.UseHands			= true
SWEP.CSMuzzleFlashes 	= true
SWEP.CSMuzzleX 			= false
SWEP.DeploySpeed 		= 1.0
SWEP.HoldType			= "pistol"
SWEP.IconLetter         = "c"
SWEP.CanBuy        		 = false

SWEP.Primary.Sound			= Sound( "Weapon_AR2.Single" )
SWEP.Primary.Recoil			= 2
SWEP.Primary.Damage			= 150
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.01
SWEP.Primary.Delay			= 0.15
SWEP.Primary.Range			= 8192
SWEP.Primary.RangeModifier	= 0.75
SWEP.Primary.ArmorRatio		= 1.05

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

CreateConVar( "sv_infinite_ammo", "0", { FCVAR_REPLICATED, FCVAR_NOTIFY } )

function SWEP:Initialize()

	self:SetDeploySpeed( self.DeploySpeed )
	self:SetHoldType( self.HoldType )

end

function SWEP:PrimaryAttack()

	if ( !self:CanPrimaryAttack() ) then return end

	self:EmitSound( self.Primary.Sound )

	self:ShootBullet( self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone )

	self:TakePrimaryAmmo( 1 )
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

end

function SWEP:SecondaryAttack() end

function SWEP:Deploy()

	self:SendWeaponAnim( ACT_VM_DRAW )

	return true
	
end

function SWEP:ShootBullet( damage, num_bullets, aimcone, ammo_type, force, tracer, distance )

	local owner = self:GetOwner()

	local bullet = {}
	bullet.Num		= num_bullets
	bullet.Src		= owner:GetShootPos()
	bullet.Dir		= owner:GetAimVector()
	bullet.Spread	= Vector( aimcone, aimcone, 0 )
	bullet.Tracer	= tracer || 5
	bullet.Force	= force || 1
	bullet.Damage	= damage
	bullet.AmmoType = ammo_type || self.Primary.Ammo
	bullet.Distance	= distance || self.Primary.Range

	owner:FireBullets( bullet )

	self:ShootEffects()

end

function SWEP:TakePrimaryAmmo( num )

	if ( GetConVar( "sv_infinite_ammo" ):GetBool() ) then return end
	
	if ( self:Clip1() <= 0 ) then

		if ( self:Ammo1() <= 0 ) then return end

		self:GetOwner():RemoveAmmo( num, self:GetPrimaryAmmoType() )

		return 
		
	end

	self:SetClip1( self:Clip1() - num )

end

if CLIENT then

	function SWEP:DrawHUD()

		local x, y = ScrW() / 2.0, ScrH() / 2.0

		surface.SetDrawColor( 0, 255, 0, 255 )
		
		local gap = 4
		local length = gap + 8
		
		surface.DrawLine( x - length, y, x - gap, y )
		surface.DrawLine( x + length, y, x + gap, y )
		surface.DrawLine( x, y - length, x, y - gap )
		surface.DrawLine( x, y + length, x, y + gap )
		
	end

	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	
		draw.SimpleText( self.IconLetter, "HvH_SelectionIcon", x + wide / 2, y + tall * 0.3, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
	
	end

end
