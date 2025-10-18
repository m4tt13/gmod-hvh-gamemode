AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "Dual Elites"
SWEP.Alias 					= "elite"
SWEP.Image        		 	= "vgui/gfx/vgui/elites"
SWEP.IconLetter				= "s"
SWEP.CanBuy        		 	= true

if ( CLIENT ) then
	killicon.AddFont( "hvh_elite", "hvh_killicon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_SECONDARY
SWEP.Type					= WPNTYPE_PITSOL
SWEP.Weight					= 5
SWEP.ViewModelFlip			= true
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= false
SWEP.CSMuzzleScale			= 1.0
SWEP.HoldType				= "duel"
SWEP.ViewModel				= "models/weapons/v_pist_elite.mdl"	
SWEP.WorldModel				= "models/weapons/w_pist_elite.mdl"	

SWEP.Range					= 4096
SWEP.RangeModifier			= 0.75
SWEP.ArmorRatio				= 1.05
SWEP.MaxSpeed				= 250

SWEP.Primary.Sound			= Sound( "Weapon_Elite.Single" )
SWEP.Primary.Recoil			= 2
SWEP.Primary.Damage			= 45
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.027
SWEP.Primary.Delay			= 0.075

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "BULLET_PLAYER_9MM"

function SWEP:SetupDataTables()

	self:NetworkVar( "Bool", 0, "FireRight" )
	
end

function SWEP:Initialize()

	self.BaseClass.Initialize( self )
	
	if ( SERVER ) then
		self:SetFireRight( false )
	end

end

function SWEP:PrimaryAttack()

	if ( !self:CanPrimaryAttack() ) then return end

	self:SetFireRight( !self:GetFireRight() )

	self:EmitSound( self.Primary.Sound )

	self:ShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone )

	self:TakePrimaryAmmo( 1 )
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

end

function SWEP:ShootEffects()

	self:SendWeaponAnim( self:GetFireRight() && ACT_VM_PRIMARYATTACK || ACT_VM_SECONDARYATTACK )
	self:GetOwner():MuzzleFlash()
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

end

if ( CLIENT ) then

	function SWEP:GetTracerOrigin()
	
		local ent = self
		local owner = self:GetOwner()
		local ply = LocalPlayer()

		if ( ( ( owner == ply ) && !owner:ShouldDrawLocalPlayer() ) || ( ( owner != ply ) && owner:IsPlayer() && ply:GetObserverMode() == OBS_MODE_IN_EYE && ply:GetObserverTarget() == owner ) ) then
		
			local viewmodel = owner:GetViewModel()
			
			if ( viewmodel ) then
				ent = viewmodel
			end

		end
		
		if ( self:GetFireRight() ) then
		
			local att = ent:GetAttachment( ent:LookupAttachment( "muzzle" ) ) || ent:GetAttachment( ent:LookupAttachment( "2" ) )
			return att.Pos
			
		else
		
			local att = ent:GetAttachment( ent:LookupAttachment( "muzzle2" ) ) || ent:GetAttachment( ent:LookupAttachment( "1" ) )
			return att.Pos
			
		end
		
	end

	function SWEP:FireAnimationEvent( pos, ang, event, options )
		
		if ( event == 5001 && self:GetFireRight() ) then 
			event = 5011 
		end
		
		return self.BaseClass.FireAnimationEvent( self, pos, ang, event, options )

	end
	
end
