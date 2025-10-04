AddCSLuaFile()

if ( CLIENT ) then

	surface.CreateFont( "hvh_selectionicon", {

		font = "csd",
		size = ScreenScale( 60 ),
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
SWEP.IconLetter        	 	= "c"
SWEP.CanBuy        		 	= false
SWEP.HideViewModelWhenZoomed = true
SWEP.ScaleDamageByDistance	= true

SWEP.Range					= 8192
SWEP.RangeModifier			= 0.75
SWEP.ArmorRatio				= 1.05

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

function SWEP:ShootBullet( damage, recoil, num_bullets, aimcone )

	local owner = self:GetOwner()

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

	owner:FireBullets( bullet )

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
	
		local pos_x = x + wide / 2
		local pos_y = y + tall * 0.2
	
		draw.SimpleText( self.IconLetter, "hvh_selectionicon", pos_x, pos_y, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
		draw.SimpleText( self.IconLetter, "hvh_selectionicon", pos_x + math.Rand( -4, 4 ), pos_y + math.Rand( -14, 14 ), Color( 255, 210, 0, math.Rand( 10, 120 ) ), TEXT_ALIGN_CENTER )
		draw.SimpleText( self.IconLetter, "hvh_selectionicon", pos_x + math.Rand( -4, 4 ), pos_y + math.Rand( -9, 9 ), Color( 255, 210, 0, math.Rand( 10, 120 ) ), TEXT_ALIGN_CENTER )
	
	end

end
