AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "Dual Elites"
SWEP.Alias 					= "elite"
SWEP.IconLetter				= "s"
SWEP.CanBuy        		 	= true

if CLIENT then
	killicon.AddFont( "hvh_elite", "HvH_KillIcon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_SECONDARY
SWEP.Weight					= 5
SWEP.ViewModelFlip			= false
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= false
SWEP.HoldType				= "duel"
SWEP.ViewModel				= "models/weapons/v_pist_elite.mdl"	
SWEP.WorldModel				= "models/weapons/w_pist_elite.mdl"	

SWEP.Primary.Sound			= Sound( "weapons/elite/elite-1.wav" )
SWEP.Primary.Recoil			= 2
SWEP.Primary.Damage			= 45
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.027
SWEP.Primary.Delay			= 0.075
SWEP.Primary.Range			= 4096
SWEP.Primary.RangeModifier	= 0.75
SWEP.Primary.ArmorRatio		= 1.05

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "BULLET_PLAYER_9MM"

function SWEP:FiringLeft()

	return ( bit.band( self:Clip1(), 1 ) == 0 )
	
end

function SWEP:ShootEffects()

	if ( self:FiringLeft() ) then
		self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	else
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	end

	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

end

if CLIENT then

	function SWEP:FireAnimationEvent( pos, ang, event, options )

		if ( !self.CSMuzzleFlashes ) then return end

		if ( event == 5001 ) then

			local data = EffectData()
			data:SetFlags( 0 )
			data:SetEntity( self.Owner:GetViewModel() )
			data:SetAttachment( self:FiringLeft() && 2 || 1 )
			data:SetScale( 1 )

			if ( self.CSMuzzleX ) then
				util.Effect( "CS_MuzzleFlash_X", data )
			else
				util.Effect( "CS_MuzzleFlash", data )
			end

			return true
			
		end

		return self.BaseClass.FireAnimationEvent( self, pos, ang, event, options )

	end
	
end
