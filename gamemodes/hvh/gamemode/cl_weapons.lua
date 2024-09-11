local loadouts = {

	[WPNSLOT_PRIMARY] 	= CreateClientConVar( "cl_loadout_primary", "hvh_ak47", true, true, "Primary weapon" ),
	[WPNSLOT_SECONDARY] = CreateClientConVar( "cl_loadout_secondary", "hvh_deagle", true, true, "Secondary weapon" )
	
}

local last_weapons = {}

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

local clr_text		= Color( 255, 176, 0, 255 )
local clr_hovered	= Color( 192, 28, 0, 140 )
local clr_bg		= Color( 0, 0, 0, 196 )
local clr_border	= Color( 188, 112, 0, 128 )

function GM:ShowHelp()

	if ( IsValid( self.WeaponSelectPnl ) ) then
	
		GAMEMODE:HideHelp()
		return
		
	end
	
	local ply = LocalPlayer()

	if ( !ply:Alive() ) then
		return
	end
	
	local teamid = ply:Team()

	if ( teamid != TEAM_TERRORIST && teamid != TEAM_CT ) then
		return
	end

	GAMEMODE:HideTeam()

	self.WeaponSelectPnl = vgui.Create( "EditablePanel" )
	self.WeaponSelectPnl:MakePopup()
	self.WeaponSelectPnl:SetKeyboardInputEnabled( false )
	self.WeaponSelectPnl:SetSize( 600, 400 )
	self.WeaponSelectPnl:Center()

	local header = self.WeaponSelectPnl:Add( "DLabel" )
	header:SetHeight( 50 )
	header:SetFont( "HvH_MenuTitle" )
	header:SetTextInset( 15, 0 )
	header:SetTextColor( clr_text )
	header:SetText( "Weapon Menu" )
	header:SetContentAlignment( 4 )
	header:DockMargin( 0, 0, 0, 5 )
	header:Dock( TOP )
	header.Paint = function( self, w, h )

		draw.RoundedBoxEx( 16, 0, 0, w, h, clr_bg, true, true, false, false )
		
	end
		
	local mainMenu = self.WeaponSelectPnl:Add( "Panel" )
	mainMenu:SetWide( 170 )
	mainMenu:DockMargin( 0, 0, 5, 0 )
	mainMenu:DockPadding( 10, 10, 10, 15 )
	mainMenu:Dock( LEFT )
	mainMenu.Paint = function( self, w, h )

		draw.RoundedBoxEx( 16, 0, 0, w, h, clr_bg, false, false, true, false )
		
	end
	
	local wpnModelCanvas = self.WeaponSelectPnl:Add( "Panel" )
	wpnModelCanvas:DockPadding( 0, 10, 10, 0 )
	wpnModelCanvas:Dock( FILL )
	wpnModelCanvas.Paint = function( self, w, h )

		draw.RoundedBoxEx( 16, 0, 0, w, h, clr_bg, false, false, false, true )
		
	end
	
	local weaponModel = wpnModelCanvas:Add( "DModelPanel" )
	weaponModel:SetVisible( false )
	weaponModel:SetHeight( 170 )
	weaponModel:Dock( TOP )
	weaponModel:SetLookAt( Vector( 0, 0, 5 ) )
	weaponModel:SetCamPos( Vector( 20, 35, 20 ) )
	weaponModel:SetAmbientLight( Color( 255, 255, 255 ) )
	weaponModel.LayoutEntity = function( self ) return end
	weaponModel.Paint = function( self, w, h )

		DModelPanel.Paint( self, w, h )

		surface.SetDrawColor( clr_border )
		surface.DrawOutlinedRect( 0, 0, w, h, 1 ) 
		
	end
	
	weaponModel.DoClick = function( self )

		if ( self.WeaponButton ) then
			self.WeaponButton:DoClick()
		end

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
		wpntypeButton:SetFont( "HvH_Menu" )
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
		
			weaponModel:SetVisible( false )
			
		end
		
		for k_, weapon in ipairs( wpntype.Weapons ) do
		
			local swep = weapons.GetStored( weapon )
			
			if ( !swep || !swep.CanBuy ) then continue end
		
			local weaponButton = wpnTypePnl:Add( "DLabel" )
			weaponButton:SetHeight( 20 )
			weaponButton:SetFont( "HvH_Menu" )
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

				last_weapons[ swep.Slot ] = weapon
				RunConsoleCommand( "giveweapon", weapon )
				GAMEMODE:HideHelp() 
				
			end
			
			weaponButton.OnCursorEntered = function( self )
		
				weaponModel.WeaponButton = self
				weaponModel:SetVisible( true )
				weaponModel:SetModel( swep.WorldModel )
				
			end
			
		end
		
	end
	
	local getlastButton = mainMenu:Add( "DLabel" )
	getlastButton:SetHeight( 20 )
	getlastButton:SetFont( "HvH_Menu" )
	getlastButton:SetTextInset( 10, 0 )
	getlastButton:SetTextColor( clr_text )
	getlastButton:SetText( "Last loadout" )
	getlastButton:SetContentAlignment( 4 )
	getlastButton:SetMouseInputEnabled( true )
	getlastButton:DockMargin( 0, 30, 0, 10 )
	getlastButton:Dock( TOP )
	getlastButton.Paint = function( self, w, h )

		if ( self:IsHovered() ) then
		
			surface.SetDrawColor( clr_hovered )
			surface.DrawRect( 0, 0, w, h )
			
		end

		surface.SetDrawColor( clr_border )
		surface.DrawOutlinedRect( 0, 0, w, h, 1 ) 
		
	end

	getlastButton.DoClick = function( self )
	
		for k, v in pairs( last_weapons ) do
			RunConsoleCommand( "giveweapon", v )
		end
		
		GAMEMODE:HideHelp() 

	end
	
	getlastButton.OnCursorEntered = function( self )
		
		weaponModel:SetVisible( false )
		
	end
	
	local savecurButton = mainMenu:Add( "DLabel" )
	savecurButton:SetHeight( 20 )
	savecurButton:SetFont( "HvH_Menu" )
	savecurButton:SetTextInset( 10, 0 )
	savecurButton:SetTextColor( clr_text )
	savecurButton:SetText( "Save loadout" )
	savecurButton:SetContentAlignment( 4 )
	savecurButton:SetMouseInputEnabled( true )
	savecurButton:DockMargin( 0, 0, 0, 10 )
	savecurButton:Dock( TOP )
	savecurButton.Paint = function( self, w, h )

		if ( self:IsHovered() ) then
		
			surface.SetDrawColor( clr_hovered )
			surface.DrawRect( 0, 0, w, h )
			
		end

		surface.SetDrawColor( clr_border )
		surface.DrawOutlinedRect( 0, 0, w, h, 1 ) 
		
	end

	savecurButton.DoClick = function( self )

		for id, wpn in pairs( ply:GetWeapons() ) do
		
			local loadout = loadouts[ wpn:GetSlot() ]
			
			if ( loadout ) then
				loadout:SetString( wpn:GetClass() )
			end
			
		end

		GAMEMODE:HideHelp() 
	
	end
	
	savecurButton.OnCursorEntered = function( self )
		
		weaponModel:SetVisible( false )
		
	end
	
	local cancelButton = mainMenu:Add( "DLabel" )
	cancelButton:SetHeight( 20 )
	cancelButton:SetFont( "HvH_Menu" )
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
	
		GAMEMODE:HideHelp() 

	end
	
	cancelButton.OnCursorEntered = function( self )
	
		weaponModel:SetVisible( false )
		
	end
	
end

function GM:HideHelp()

	if ( IsValid( self.WeaponSelectPnl ) ) then
	
		self.WeaponSelectPnl:Remove()
		self.WeaponSelectPnl = nil
		
	end

end

concommand.Add( "buymenu", function() GAMEMODE:ShowHelp() end )