AddCSLuaFile()

if ( CLIENT ) then

	surface.CreateFont( "hvh_selectionicon", {

		font = "Counter-Strike",
		size = math.min( ScreenScale( 70 ), 127 ),
		weight = 0,
		antialias = true,
		additive = true

	} )
	
end

SWEP.Base 					= "weapon_base"

SWEP.Slot					= WPNSLOT_PRIMARY
SWEP.Type					= WPNTYPE_UNKNOWN
SWEP.DrawAmmo				= false
SWEP.DrawCrosshair			= true
SWEP.SwayScale				= 0.5
SWEP.BobScale				= 0.5
SWEP.ViewModelFOV			= 72
SWEP.ViewModelFlip			= false
SWEP.UseHands				= true
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= false
SWEP.CSMuzzleScale			= 1.0
SWEP.DeploySpeed 			= 1.0
SWEP.HoldType				= "pistol"
SWEP.IconLetter        	 	= "C"
SWEP.CanBuy        		 	= false
SWEP.HideViewModelWhenZoomed = true

SWEP.Penetration			= 2
SWEP.Range					= 8192
SWEP.RangeModifier			= 0.75
SWEP.ArmorRatio				= 1.05
SWEP.MaxSpeed				= 250

SWEP.Primary.Sound			= Sound( "Weapon_AR2.Single" )
SWEP.Primary.Recoil			= 2
SWEP.Primary.Damage			= 150
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.01
SWEP.Primary.Delay			= 0.15

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

local sv_penetration = CreateConVar( "sv_penetration", "1", FCVAR_REPLICATED )
local sv_infinite_ammo = CreateConVar( "sv_infinite_ammo", "0", FCVAR_REPLICATED, "Player's active weapon will never run out of ammo." )

function SWEP:Initialize()

	self:SetDeploySpeed( self.DeploySpeed )
	self:SetHoldType( self.HoldType )

end

function SWEP:PrimaryAttack()

	if ( !self:CanPrimaryAttack() ) then return end

	self:EmitSound( self.Primary.Sound )

	self:ShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone )

	self:TakePrimaryAmmo( 1 )
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

end

function SWEP:SecondaryAttack() end

function SWEP:Deploy()

	self:SendWeaponAnim( ACT_VM_DRAW )

	return true
	
end

local bullet_type_parameters = {

	["BULLET_PLAYER_50AE"] 		= { PenetrationPower = 30, PenetrationDistance = 1000 },
	["BULLET_PLAYER_762MM"]		= { PenetrationPower = 39, PenetrationDistance = 5000 },
	["BULLET_PLAYER_556MM"]		= { PenetrationPower = 35, PenetrationDistance = 4000 },
	["BULLET_PLAYER_556MM_BOX"]	= { PenetrationPower = 35, PenetrationDistance = 4000 },
	["BULLET_PLAYER_338MAG"]	= { PenetrationPower = 45, PenetrationDistance = 8000 },
	["BULLET_PLAYER_9MM"]		= { PenetrationPower = 21, PenetrationDistance = 800 },
	["BULLET_PLAYER_BUCKSHOT"]	= { PenetrationPower = 0, PenetrationDistance = 0 },
	["BULLET_PLAYER_45ACP"]		= { PenetrationPower = 15, PenetrationDistance = 500 },
	["BULLET_PLAYER_357SIG"]	= { PenetrationPower = 25, PenetrationDistance = 800 },
	["BULLET_PLAYER_57MM"]		= { PenetrationPower = 30, PenetrationDistance = 2000 }

}

local material_parameters = {

	[MAT_METAL]		= { PenetrationModifier = 0.5, DamageModifier = 0.3 },
	[MAT_DIRT]		= { PenetrationModifier = 0.5, DamageModifier = 0.3 },
	[MAT_CONCRETE]	= { PenetrationModifier = 0.4, DamageModifier = 0.25 },
	[MAT_GRATE]		= { PenetrationModifier = 1, DamageModifier = 0.99 },
	[MAT_VENT]		= { PenetrationModifier = 0.5, DamageModifier = 0.45 },
	[MAT_TILE]		= { PenetrationModifier = 0.65, DamageModifier = 0.3 },
	[MAT_COMPUTER]	= { PenetrationModifier = 0.4, DamageModifier = 0.45 },
	[MAT_WOOD]		= { PenetrationModifier = 1, DamageModifier = 0.6 }

}

local function TraceToExit( start, dir, step_size, max_distance )

	local distance = 0

	while ( distance <= max_distance ) do
	
		distance = distance + step_size

		local pos = start + ( distance * dir )

		if ( bit.band( util.PointContents( pos ), MASK_SOLID ) == 0 ) then
			return pos
		end
		
	end

	return nil

end

function SWEP:ShootBullet( damage, recoil, num_bullets, aimcone )

	local owner = self:GetOwner()

	local penetration_power = 0
	local penetration_distance = 0

	local bullet_params = bullet_type_parameters[self.Primary.Ammo]
	if ( bullet_params ) then
	
		penetration_power = bullet_params.PenetrationPower
		penetration_distance = bullet_params.PenetrationDistance

	end
	
	local bullet_ctxs = {}

	local bullet = {}
	bullet.Num			= num_bullets
	bullet.Src			= owner:GetShootPos()
	bullet.Dir			= owner:GetAimVector()
	bullet.Spread		= Vector( aimcone, aimcone, 0 )
	bullet.Tracer		= 1
	bullet.TracerName	= "Tracer"
	bullet.Force		= 1
	bullet.Damage		= damage
	bullet.Distance		= self.Range
	bullet.AmmoType 	= self.Primary.Ammo
	bullet.Attacker 	= owner
	bullet.Inflictor 	= self
	bullet.Callback 	= function( attacker, tr, dmgInfo )
	
		local ctx = {}
		
		ctx.Trace = tr
		ctx.Penetration = self.Penetration
		ctx.Distance = self.Range
		ctx.TravelledDistance = tr.Fraction * ctx.Distance
		ctx.PenetrationPower = penetration_power
		
		dmgInfo:ScaleDamage( math.pow( self:GetRangeModifier(), ctx.TravelledDistance / 500 ) )
		ctx.Damage = dmgInfo:GetDamage()
		
		table.insert( bullet_ctxs, ctx )

	end

	owner:FireBullets( bullet )
	
	if ( sv_penetration:GetBool() ) then
	
		bullet.Num = 1
		bullet.Spread = Vector( 0, 0, 0 )
		
		for _, ctx in ipairs( bullet_ctxs ) do
		
			if ( ctx.Trace.Fraction == 0 ) then
				continue
			end
		
			local dir = ctx.Trace.Normal
			bullet.Dir = dir
		
			while ( true ) do
			
				if ( ctx.Trace.Fraction == 1 ) then
					break
				end
				
				if ( ctx.TravelledDistance > penetration_distance ) then
					break
				end
		
				if ( ctx.Penetration == 0 ) then
					break
				end
				
				local penetration_end = TraceToExit( ctx.Trace.HitPos, dir, 24, 128 )
				if ( !penetration_end ) then
					break
				end
				
				local exitTr = util.TraceLine( {
					start = penetration_end,
					endpos = ctx.Trace.HitPos,
					mask = MASK_SHOT
				} )
				
				if ( exitTr.Entity != ctx.Trace.Entity && exitTr.Entity != NULL ) then
				
					exitTr = util.TraceLine( {
						start = penetration_end,
						endpos = ctx.Trace.HitPos,
						mask = MASK_SHOT,
						filter = exitTr.Entity
					} )
				
				end
				
				local penetration_modifier = 1
				local damage_modifier = 0.5
				
				local mat_params = material_parameters[ctx.Trace.MatType]
				if ( mat_params ) then
				
					penetration_modifier = mat_params.PenetrationModifier
					damage_modifier = mat_params.DamageModifier

				end
				
				if ( ctx.Trace.MatType == exitTr.MatType ) then
				
					if ( exitTr.MatType == MAT_WOOD || exitTr.MatType == MAT_METAL ) then
						penetration_modifier = penetration_modifier * 2
					end
					
				end
				
				local trace_distance = ( exitTr.HitPos - ctx.Trace.HitPos ):Length()
				if ( trace_distance > ( ctx.PenetrationPower * penetration_modifier ) ) then
					break
				end
				
				if ( exitTr.Fraction != 1 && exitTr.Entity != NULL && !exitTr.HitSky ) then
				
					if ( !( CLIENT && !IsFirstTimePredicted() ) ) then
				
						local edata = EffectData()
						edata:SetOrigin( exitTr.HitPos )
						edata:SetStart( exitTr.StartPos )
						edata:SetSurfaceProp( exitTr.SurfaceProps )
						edata:SetDamageType( DMG_BULLET )
						edata:SetHitBox( exitTr.HitBox )
						
						if ( CLIENT ) then
							edata:SetEntity( exitTr.Entity )
						else
							edata:SetEntIndex( exitTr.Entity:EntIndex() )
						end
						
						util.Effect( "Impact", edata )
						
					end
					
				end
				
				ctx.PenetrationPower = ctx.PenetrationPower - ( trace_distance / penetration_modifier )
				ctx.TravelledDistance = ctx.TravelledDistance + trace_distance
				ctx.Distance = ( ctx.Distance - ctx.TravelledDistance ) * 0.5
				ctx.Damage = ctx.Damage * damage_modifier

				if ( ctx.Damage == 0 ) then
					break
				end

				ctx.Penetration = ctx.Penetration - 1
		
				bullet.Src			= exitTr.HitPos
				bullet.Damage		= ctx.Damage
				bullet.Distance		= ctx.Distance
				bullet.IgnoreEntity	= ( IsValid( ctx.Trace.Entity ) && ctx.Trace.Entity:IsPlayer() ) && ctx.Trace.Entity || NULL
				bullet.Callback 	= function( attacker, tr, dmgInfo )

					ctx.Trace = tr
					ctx.TravelledDistance = ctx.TravelledDistance + ( tr.Fraction * ctx.Distance )
					
					dmgInfo:ScaleDamage( math.pow( self:GetRangeModifier(), ctx.TravelledDistance / 500 ) )
					ctx.Damage = dmgInfo:GetDamage()
				
				end

				owner:FireBullets( bullet )
			
			end
		
		end
		
	end

	self:ShootEffects()
	
	if ( owner:IsNPC() ) then return end
	
	owner:ViewPunch( Angle( util.SharedRandom( self:GetClass(), -0.2, -0.1, 0 ) * recoil, util.SharedRandom( self:GetClass(), -0.1, 0.1, 1 ) * recoil, 0 ) )
	
	if ( ( SERVER && game.SinglePlayer() ) || ( CLIENT && !game.SinglePlayer() && IsFirstTimePredicted() ) ) then
		
		local eyeang = owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil
		owner:SetEyeAngles( eyeang )
		
	end
   
end

function SWEP:TakePrimaryAmmo( num )

	if ( sv_infinite_ammo:GetBool() ) then return end
	
	if ( self:Clip1() <= 0 ) then

		if ( self:Ammo1() <= 0 ) then return end

		self:GetOwner():RemoveAmmo( num, self:GetPrimaryAmmoType() )

		return 
		
	end

	self:SetClip1( self:Clip1() - num )

end

function SWEP:GetRangeModifier()

	return self.RangeModifier

end

function SWEP:GetMaxSpeed()

	return self.MaxSpeed

end

function SWEP:IsZoomed()

	return false
	
end

if ( CLIENT ) then

	local matScopeArc = Material( "sprites/scope_arc" )
	local matScopeDust = Material( "overlays/scope_lens" )

	function SWEP:DrawHUDBackground()

		if ( self:IsZoomed() && self.Type == WPNTYPE_SNIPER ) then 
		
			local screenWide = ScrW()
			local screenTall = ScrH()
	
			local inset = screenTall / 16
			local y1 = inset
			local x1 = ( screenWide - screenTall ) / 2 + inset
			local y2 = screenTall - inset
			local x2 = screenWide - x1

			local x = screenWide / 2
			local y = screenTall / 2

			local uv1 = 0.5 / 256.0
			local uv2 = 1.0 - uv1

			local xMod = ( screenWide / 2 )
			local yMod = ( screenTall / 2 )

			local iMiddleX = ( screenWide / 2 )
			local iMiddleY = ( screenTall / 2 )
			
			surface.SetMaterial( matScopeDust )
			surface.SetDrawColor( color_white )
			
			local vert = {}
			vert[1] = { x = iMiddleX + xMod, y = iMiddleY + yMod, u = uv2, v = uv1 }
			vert[2] = { x = iMiddleX - xMod, y = iMiddleY + yMod, u = uv1, v = uv1 }
			vert[3] = { x = iMiddleX - xMod, y = iMiddleY - yMod, u = uv1, v = uv2 }
			vert[4] = { x = iMiddleX + xMod, y = iMiddleY - yMod, u = uv2, v = uv2 }
			surface.DrawPoly( vert )

			surface.SetDrawColor( color_black )

			surface.DrawLine( 0, y, screenWide, y )
			surface.DrawLine( x, 0, x, screenTall )
			
			surface.SetMaterial( matScopeArc )

			vert[1] = { x = x, y = y, u = uv1, v = uv1 }
			vert[2] = { x = x2, y = y, u = uv2, v = uv1 }
			vert[3] = { x = x2, y = y2, u = uv2, v = uv2 }
			vert[4] = { x = x, y = y2, u = uv1, v = uv2 }
			surface.DrawPoly( vert )
			
			vert[1] = { x = x - 1, y = y1, u = uv1, v = uv2 }
			vert[2] = { x = x2, y = y1, u = uv2, v = uv2 }
			vert[3] = { x = x2, y = y + 1, u = uv2, v = uv1 }
			vert[4] = { x = x - 1, y = y + 1, u = uv1, v = uv1 }
			surface.DrawPoly( vert )

			vert[1] = { x = x1, y = y, u = uv2, v = uv1 }
			vert[2] = { x = x, y = y, u = uv1, v = uv1 }
			vert[3] = { x = x, y = y2, u = uv1, v = uv2 }
			vert[4] = { x = x1, y = y2, u = uv2, v = uv2 }
			surface.DrawPoly( vert )

			vert[1] = { x = x1, y = y1, u = uv2, v = uv2 }
			vert[2] = { x = x, y = y1, u = uv1, v = uv2 }
			vert[3] = { x = x, y = y, u = uv1, v = uv1 }
			vert[4] = { x = x1, y = y, u = uv2, v = uv1 }
			surface.DrawPoly( vert )

			surface.DrawRect( 0, 0, screenWide, y1 )
			surface.DrawRect( 0, y2, screenWide, screenTall )
			surface.DrawRect( 0, y1, x1, screenTall )
			surface.DrawRect( x2, y1, screenWide, screenTall )
			
		end
		
	end
	
	function SWEP:ShouldDrawViewModel()

		return ( !self:IsZoomed() || !self.HideViewModelWhenZoomed ) 
		
	end
	
	function SWEP:AdjustMouseSensitivity()
	
		return -1

	end
	
	function SWEP:GetTracerOrigin()

		if ( self:IsZoomed() && self.Type == WPNTYPE_SNIPER ) then 
		
			local owner = self:GetOwner()
			local ply = LocalPlayer()
		
			if ( ( ( owner == ply ) && !owner:ShouldDrawLocalPlayer() ) || 
				 ( ( owner != ply ) && owner:IsPlayer() && ply:GetObserverMode() == OBS_MODE_IN_EYE && ply:GetObserverTarget() == owner ) ) then
				
				local tracerOrigin = owner:GetShootPos()
				tracerOrigin.z = tracerOrigin.z - 1
				return tracerOrigin
				
			end
			
		end
		
	end

	function SWEP:FireAnimationEvent( pos, ang, event, options )

		if ( !self.CSMuzzleFlashes ) then return end
		
		if ( event == 5001 || event == 5011 || event == 5021 || event == 5031 ) then

			local data = EffectData()
			data:SetFlags( 0 )
			data:SetEntity( self:GetOwner():GetViewModel() )
			data:SetAttachment( math.floor( ( event - 4991 ) / 10 ) )
			data:SetScale( self.CSMuzzleScale )

			if ( self.CSMuzzleX ) then
				util.Effect( "CS_MuzzleFlash_X", data )
			else
				util.Effect( "CS_MuzzleFlash", data )
			end

			return true
			
		end

	end

	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	
		draw.SimpleText( self.IconLetter, "hvh_selectionicon", x + wide / 2, y + tall / 2, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	
	end

end
