AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "Knife"
SWEP.Alias 					= "knife"
SWEP.IconLetter				= "j"
SWEP.CanBuy        		 	= true

if CLIENT then
	killicon.AddFont( "hvh_knife", "hvh_killicon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_MELEE
SWEP.DrawCrosshair			= true
SWEP.Weight					= 0
SWEP.ViewModelFlip			= false
SWEP.CSMuzzleFlashes 		= false
SWEP.CSMuzzleX 				= false
SWEP.CSMuzzleScale			= 1.0
SWEP.HoldType				= "knife"
SWEP.ViewModel				= "models/weapons/v_knife_t.mdl"	
SWEP.WorldModel				= "models/weapons/w_knife_t.mdl"	

SWEP.ArmorRatio				= 1.7

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

local snd_deploy	= Sound( "Weapon_Knife.Deploy" )
local snd_slash 	= Sound( "Weapon_Knife.Slash" )
local snd_stab 		= Sound( "Weapon_Knife.Stab" )
local snd_hit		= Sound( "Weapon_Knife.Hit" )
local snd_hitwall 	= Sound( "Weapon_Knife.HitWall" )

local head_hull_mins = Vector( -16, -16, -18 )
local head_hull_maxs = Vector( 16, 16, 18 )

local phys_pushscale = GetConVar( "phys_pushscale" )

function SWEP:SwingOrStab( bStab )

	local ply = self:GetOwner()

	if ( !IsValid( ply ) ) then return end

	ply:LagCompensation( true )

	local vecSrc = ply:GetShootPos()
	local vecDir = ply:GetAimVector()
	local vecEnd = vecSrc + ( vecDir * ( bStab && 32 || 48 ) )

	local tr = util.TraceLine( { start = vecSrc, endpos = vecEnd, filter = ply, mask = MASK_SOLID } )

	if ( tr.Fraction == 1.0 ) then
	
		tr = util.TraceHull( { start = vecSrc, endpos = vecEnd, filter = ply, mask = MASK_SOLID, mins = head_hull_mins, maxs = head_hull_maxs } )
		
		if ( tr.Fraction < 1.0 ) then
		
			vecEnd = vecSrc + ( ( tr.HitPos - vecSrc ) * 2 )
		
			tmpTrace = util.TraceLine( { start = vecSrc, endpos = vecEnd, filter = ply, mask = MASK_SOLID } )
			
			if ( tmpTrace.Fraction < 1.0 ) then
				tr = tmpTrace	
			end
		
			vecEnd = tr.HitPos
		
		end
		
	end
	
	ply:SetAnimation( PLAYER_ATTACK1 )
	
	if ( tr.Fraction < 1.0 ) then
	
		self:SendWeaponAnim( ACT_VM_HITCENTER )
		
		local hitEnt = tr.Entity

		if ( hitEnt != NULL && !tr.HitSky ) then

			tr.HitBox = 0
			tr.HitGroup = HITGROUP_GENERIC

			if ( SERVER ) then

				local damage = 42
				
				if ( bStab ) then
				
					damage = 65
				
					if ( hitEnt:IsPlayer() ) then
					
						local vecTragetForward = hitEnt:GetAngles():Forward()
						local vecLOS = hitEnt:GetPos() - ply:GetPos()
						
						vecTragetForward.z = 0
						vecLOS.z = 0
						
						vecLOS:Normalize()

						local dot = vecLOS:Dot( vecTragetForward )

						if ( dot > 0.8 ) then
							damage = damage * 3
						end
						
					end
				
				else
				
					local bFirstSwing = ( self:GetNextPrimaryFire() + 0.4 ) < CurTime()
				
					damage = bFirstSwing && 20 || 15

				end

				local dmgInfo = DamageInfo()
				dmgInfo:SetDamage( damage )
				dmgInfo:SetAttacker( ply )
				dmgInfo:SetInflictor( ply )
				dmgInfo:SetDamageForce( vecDir * 300 * phys_pushscale:GetFloat() )
				dmgInfo:SetDamagePosition( tr.HitPos )
				dmgInfo:SetDamageType( DMG_SLASH )

				hitEnt:DispatchTraceAttack( dmgInfo, tr, vecDir )
				
			end
			
			self:EmitSound( hitEnt:IsPlayer() && ( bStab && snd_stab || snd_hit ) || snd_hitwall )

			if ( !( CLIENT && !IsFirstTimePredicted() ) ) then
			
				local edata = EffectData()
				edata:SetOrigin( tr.HitPos )
				edata:SetStart( tr.StartPos )
				edata:SetSurfaceProp( tr.SurfaceProps )
				edata:SetDamageType( DMG_SLASH )
				edata:SetHitBox( tr.HitBox )
				
				if ( CLIENT ) then
					edata:SetEntity( hitEnt )
				else
					edata:SetEntIndex( hitEnt:EntIndex() )
				end
				
				edata:SetAngles( ply:GetAngles() )
				edata:SetFlags( 1 )

				util.Effect( "Impact", edata )
				
			end

		end
		
		self:SetNextPrimaryFire( CurTime() + ( bStab && 1.1 || 0.5 ) )
		self:SetNextSecondaryFire( CurTime() + ( bStab && 1.1 || 0.5 ) )
	
	else
	
		self:SendWeaponAnim( ACT_VM_MISSCENTER )

		self:EmitSound( snd_slash )
		
		self:SetNextPrimaryFire( CurTime() + ( bStab && 1.0 || 0.4 ) )
		self:SetNextSecondaryFire( CurTime() + ( bStab && 1.0 || 0.5 ) )
	
	end
	
	ply:LagCompensation( false )
	
end

function SWEP:PrimaryAttack()

	self:SwingOrStab( false )

end

function SWEP:SecondaryAttack()

	self:SwingOrStab( true )

end

function SWEP:Deploy()

	self:SendWeaponAnim( ACT_VM_DRAW )

	self:EmitSound( snd_deploy )

	return true
	
end

function SWEP:OnTraceAttack( dmginfo, dir, trace ) end