AddCSLuaFile()

SWEP.Base 					= "hvh_base"

SWEP.PrintName 				= "AWP"
SWEP.Alias 					= "awp"
SWEP.Image        		 	= "vgui/gfx/vgui/awp"
SWEP.IconLetter				= "r"
SWEP.CanBuy        		 	= true

if CLIENT then
	killicon.AddFont( "hvh_awp", "hvh_killicon", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.Slot					= WPNSLOT_PRIMARY
SWEP.DrawCrosshair			= false
SWEP.Weight					= 30
SWEP.ViewModelFlip			= true
SWEP.CSMuzzleFlashes 		= true
SWEP.CSMuzzleX 				= false
SWEP.CSMuzzleScale			= 1.35
SWEP.HoldType				= "ar2"
SWEP.ViewModel				= "models/weapons/v_snip_awp.mdl"	
SWEP.WorldModel				= "models/weapons/w_snip_awp.mdl"	

SWEP.Range					= 8192
SWEP.RangeModifier			= 0.99
SWEP.ArmorRatio				= 1.95

SWEP.Primary.Sound			= Sound( "Weapon_AWP.Single" )
SWEP.Primary.Recoil			= 2
SWEP.Primary.Damage			= 115
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.05
SWEP.Primary.Delay			= 1.45

SWEP.Primary.ClipSize		= 10
SWEP.Primary.DefaultClip	= 10
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "BULLET_PLAYER_338MAG"

SWEP.Secondary.Sound		= Sound( "Default.Zoom" )
SWEP.Secondary.Delay		= 0.3

function SWEP:SetupDataTables()

	self:NetworkVar( "Int", 0, "ZoomLevel" )
	self:NetworkVar( "Int", 1, "LastZoomLevel" )
	self:NetworkVar( "Float", 0, "ZoomFullyActiveTime" )
	
end

function SWEP:Initialize()

	self.BaseClass.Initialize( self )
	
	if ( SERVER ) then
	
		self:SetZoomLevel( 0 )
		self:SetLastZoomLevel( 0 )
		self:SetZoomFullyActiveTime( 0 )
		
	end

end

function SWEP:PrimaryAttack()

	if ( !self:CanPrimaryAttack() ) then return end

	local cone = self.Primary.Cone

	if ( self:GetZoomLevel() != 0 ) then
	
		if ( self:GetZoomFullyActiveTime() <= CurTime() ) then
			cone = 0.002
		end
	
		self:SetLastZoomLevel( self:GetZoomLevel() )
		self:SetZoomLevel( 0 )
		self.Owner:SetFOV( 0, 0.1 )
		
	end

	self:EmitSound( self.Primary.Sound )

	self:ShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, cone )

	self:TakePrimaryAmmo( 1 )
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

end

function SWEP:SecondaryAttack() 

	if ( self:GetZoomLevel() == 0 ) then
	
		self:SetZoomLevel( 1 )
		self.Owner:SetFOV( 40, 0.15 )
		
	elseif ( self:GetZoomLevel() == 1 ) then
	
		self:SetZoomLevel( 2 )
		self.Owner:SetFOV( 10, 0.08 )
		
	else
	
		self:SetZoomLevel( 0 )
		self.Owner:SetFOV( 0, 0.1 )
	
	end
	
	self:EmitSound( self.Secondary.Sound )

	self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	self:SetZoomFullyActiveTime( CurTime() + self.Secondary.Delay / 2 )

end

function SWEP:Think()

	if ( self:GetLastZoomLevel() != 0 && self:GetNextPrimaryFire() <= CurTime() ) then
	
		self:SetZoomLevel( self:GetLastZoomLevel() )
		self:SetLastZoomLevel( 0 )
	
		if ( self:GetZoomLevel() == 1 ) then
			self.Owner:SetFOV( 40, 0.05 )
		else
			self.Owner:SetFOV( 10, 0.05 )
		end
		
		self:SetZoomFullyActiveTime( CurTime() + 0.05 )
	
	end

end

function SWEP:Reload()

	self:DefaultReload( ACT_VM_RELOAD )
	
	if ( self:GetZoomLevel() != 0 ) then
	
		self:SetZoomLevel( 0 )
		self.Owner:SetFOV( 0, 0.1 )
		
	end
	
	self:SetLastZoomLevel( 0 )
	self:SetZoomFullyActiveTime( 0 )
	
end

function SWEP:Deploy()

	self:SendWeaponAnim( ACT_VM_DRAW )

	self:SetZoomLevel( 0 )
	self:SetLastZoomLevel( 0 )
	self:SetZoomFullyActiveTime( 0 )
	
	return true
	
end

if CLIENT then

	local matScopeArc = Material( "sprites/scope_arc" )
	local matScopeDust = Material( "overlays/scope_lens" )

	function SWEP:DrawHUDBackground()

		if ( self:GetZoomLevel() != 0 ) then 
		
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

		return ( self:GetZoomLevel() == 0 ) 
		
	end
	
	function SWEP:AdjustMouseSensitivity()

		if ( self:GetZoomLevel() == 1 ) then
			return 0.5
		elseif ( self:GetZoomLevel() == 2 ) then
			return 0.15
		end

		return nil

	end
	
	function SWEP:GetTracerOrigin()

		if ( self:GetZoomLevel() != 0 ) then 
		
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

end