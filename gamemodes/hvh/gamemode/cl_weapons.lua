local clr_text		= Color( 255, 176, 0, 255 )
local clr_hovered	= Color( 192, 28, 0, 140 )
local clr_bg		= Color( 0, 0, 0, 196 )
local clr_border	= Color( 188, 112, 0, 128 )

local allowed_weapons = {

	[WPNTYPE_PITSOL] = {
	
		Name 	= "Pistols",
		Weapons = { "hvh_glock", "hvh_usp", "hvh_p228", "hvh_deagle", "hvh_elite", "hvh_fiveseven" }
		
	},
	
	[WPNTYPE_SHOTGUN] = {
	
		Name = "Shotguns",
		Weapons = { "hvh_xm1014", "hvh_m3" }
		
	},
	
	[WPNTYPE_SMG] = {
	
		Name = "SMGs",
		Weapons = { "hvh_mac10", "hvh_tmp", "hvh_mp5navy", "hvh_ump45", "hvh_p90" }
		
	},
	
	[WPNTYPE_RIFLE] = {
	
		Name = "Rifles",
		Weapons = { "hvh_galil", "hvh_famas", "hvh_ak47", "hvh_m4a1", "hvh_sg552", "hvh_aug" }
		
	},
	
	[WPNTYPE_SNIPER] = {
	
		Name = "Snipers",
		Weapons = { "hvh_scout", "hvh_awp",	"hvh_g3sg1", "hvh_sg550" }
		
	},
	
	[WPNTYPE_MACHINEGUN] = {
	
		Name = "Machine Guns",
		Weapons = { "hvh_m249" }
		
	}
	
}

local matCSLogo = Material( "vgui/gfx/vgui/cs_logo" )

function GM:ShowSpare2()

	if ( IsValid( self.WeaponSelectPnl ) ) then return end

	local ply = LocalPlayer()

	if ( !IsValid( ply ) || !ply:Alive() ) then
		return
	end
	
	local teamid = ply:Team()

	if ( teamid != TEAM_TERRORIST && teamid != TEAM_CT ) then
		return
	end
	
	GAMEMODE:HideHelp()
	GAMEMODE:HideTeam()

	self.WeaponSelectPnl = vgui.Create( "EditablePanel" )
	self.WeaponSelectPnl:MakePopup()
	self.WeaponSelectPnl:SetKeyboardInputEnabled( false )
	self.WeaponSelectPnl:SetSize( 600, 400 )
	self.WeaponSelectPnl:Center()

	local header = self.WeaponSelectPnl:Add( "DLabel" )
	header:SetHeight( 50 )
	header:SetFont( "hvh_menutitle" )
	header:SetTextInset( 60, 0 )
	header:SetTextColor( clr_text )
	header:SetText( "Weapon Menu" )
	header:SetContentAlignment( 4 )
	header:DockMargin( 0, 0, 0, 5 )
	header:Dock( TOP )
	header.Paint = function( self, w, h )

		draw.RoundedBoxEx( 16, 0, 0, w, h, clr_bg, true, true, false, false )
		
		surface.SetDrawColor( clr_text )
		surface.SetMaterial( matCSLogo )
		surface.DrawTexturedRect( 10, 5, 40, 40 ) 
		
	end
		
	local mainMenu = self.WeaponSelectPnl:Add( "Panel" )
	mainMenu:SetWide( 170 )
	mainMenu:DockMargin( 0, 0, 5, 0 )
	mainMenu:DockPadding( 10, 10, 10, 15 )
	mainMenu:Dock( LEFT )
	mainMenu.Paint = function( self, w, h )

		draw.RoundedBoxEx( 16, 0, 0, w, h, clr_bg, false, false, true, false )
		
	end
	
	local wpnImageCanvas = self.WeaponSelectPnl:Add( "Panel" )
	wpnImageCanvas:DockPadding( 0, 10, 10, 0 )
	wpnImageCanvas:Dock( FILL )
	wpnImageCanvas.Paint = function( self, w, h )

		draw.RoundedBoxEx( 16, 0, 0, w, h, clr_bg, false, false, false, true )
		
	end
	
	local weaponImage = wpnImageCanvas:Add( "DImage" )
	weaponImage:SetVisible( false )
	weaponImage:Dock( TOP )
	weaponImage.Paint = function( self, w, h )
	
		local imgW = w * 0.9
		local imgH = h * 0.9

		self:PaintAt( ( w - imgW ) / 2, ( h - imgH ) / 2, imgW, imgH )
 
		surface.SetDrawColor( clr_border )
		surface.DrawOutlinedRect( 0, 0, w, h, 1 ) 
		
	end
	
	weaponImage.PerformLayout = function( self, w, h )

		self:SetHeight( w * ( self.ActualHeight / self.ActualWidth ) )
		
	end

	local activeWpnTypePnl = nil
	
	for k, wpntype in ipairs( allowed_weapons ) do
	
		local wpnTypePnl = self.WeaponSelectPnl:Add( "Panel" )
		wpnTypePnl:SetVisible( false )
		wpnTypePnl:SetWide( 170 )
		wpnTypePnl:DockPadding( 10, 10, 10, 15 )
		wpnTypePnl:Dock( LEFT )
		
		if ( !activeWpnTypePnl ) then
		
			activeWpnTypePnl = wpnTypePnl
			activeWpnTypePnl:SetVisible( true )
			
		end
		
		wpnTypePnl.Paint = function( self, w, h )
		
			surface.SetDrawColor( clr_bg )
			surface.DrawRect( 0, 0, w, h )
		
		end
		
		local wpntypeButton = mainMenu:Add( "DLabel" )
		wpntypeButton:SetHeight( 20 )
		wpntypeButton:SetFont( "hvh_menu" )
		wpntypeButton:SetTextInset( 10, 0 )
		wpntypeButton:SetTextColor( clr_text )
		wpntypeButton:SetText( wpntype.Name )
		wpntypeButton:SetContentAlignment( 4 )
		wpntypeButton:SetMouseInputEnabled( true )
		wpntypeButton:DockMargin( 0, 0, 0, 10 )
		wpntypeButton:Dock( TOP )
		wpntypeButton.Paint = function( self, w, h )

			if ( self:IsHovered() || wpnTypePnl == activeWpnTypePnl ) then
			
				surface.SetDrawColor( clr_hovered )
				surface.DrawRect( 0, 0, w, h )
				
			end

			surface.SetDrawColor( clr_border )
			surface.DrawOutlinedRect( 0, 0, w, h, 1 ) 
			
		end

		wpntypeButton.DoClick = function( self )
			
			activeWpnTypePnl:SetVisible( false )
			activeWpnTypePnl = wpnTypePnl
			activeWpnTypePnl:SetVisible( true )
			
		end
		
		wpntypeButton.OnCursorEntered = function( self )
		
			weaponImage:SetVisible( false )
			
		end
		
		for k_, weapon in ipairs( wpntype.Weapons ) do
		
			local swep = weapons.GetStored( weapon )
			
			if ( !swep || !swep.CanBuy ) then continue end
		
			local weaponButton = wpnTypePnl:Add( "DLabel" )
			weaponButton:SetHeight( 20 )
			weaponButton:SetFont( "hvh_menu" )
			weaponButton:SetTextInset( 10, 0 )
			weaponButton:SetTextColor( clr_text )
			weaponButton:SetText( swep.PrintName )
			weaponButton:SetContentAlignment( 4 )
			weaponButton:SetMouseInputEnabled( true )
			weaponButton:DockMargin( 0, 0, 0, 10 )
			weaponButton:Dock( TOP )
			weaponButton.Paint = function( self, w, h )

				if ( self:IsHovered() ) then
				
					surface.SetDrawColor( clr_hovered )
					surface.DrawRect( 0, 0, w, h )
					
				end

				surface.SetDrawColor( clr_border )
				surface.DrawOutlinedRect( 0, 0, w, h, 1 ) 
				
			end
			
			weaponButton.DoClick = function( self )

				RunConsoleCommand( "giveweapon", weapon )
				GAMEMODE:HideSpare2() 
				
			end
			
			weaponButton.OnCursorEntered = function( self )
		
				weaponImage:SetVisible( true )
				weaponImage:SetImage( swep.Image )
				weaponImage:InvalidateLayout()
				
			end
			
		end
		
	end
	
	local cancelButton = mainMenu:Add( "DLabel" )
	cancelButton:SetHeight( 20 )
	cancelButton:SetFont( "hvh_menu" )
	cancelButton:SetTextInset( 10, 0 )
	cancelButton:SetTextColor( clr_text )
	cancelButton:SetText( "Cancel" )
	cancelButton:SetContentAlignment( 4 )
	cancelButton:SetMouseInputEnabled( true )
	cancelButton:Dock( BOTTOM )
	cancelButton.Paint = function( self, w, h )

		if ( self:IsHovered() ) then
		
			surface.SetDrawColor( clr_hovered )
			surface.DrawRect( 0, 0, w, h )
			
		end

		surface.SetDrawColor( clr_border )
		surface.DrawOutlinedRect( 0, 0, w, h, 1 ) 
		
	end

	cancelButton.DoClick = function( self )
	
		GAMEMODE:HideSpare2() 

	end
	
	cancelButton.OnCursorEntered = function( self )
	
		weaponImage:SetVisible( false )
		
	end
	
	if ( IsValid( self.ScoreboardPnl ) && self.ScoreboardPnl:IsVisible() ) then
		self.WeaponSelectPnl:Hide()
	end
	
end

function GM:HideSpare2()

	if ( IsValid( self.WeaponSelectPnl ) ) then
	
		self.WeaponSelectPnl:Remove()
		self.WeaponSelectPnl = nil
		
	end

end

concommand.Add( "buymenu", function() GAMEMODE:ShowSpare2() end )