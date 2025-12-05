local clr_text		= Color( 255, 176, 0, 255 )
local clr_hovered	= Color( 192, 28, 0, 140 )
local clr_bg		= Color( 0, 0, 0, 196 )
local clr_border	= Color( 188, 112, 0, 128 )

local motd_text = nil

local matCSLogo = Material( "vgui/gfx/vgui/cs_logo" )

function GM:ShowHelp()

	if ( IsValid( self.MOTDPnl ) ) then return end

	GAMEMODE:HideTeam()
	GAMEMODE:HideSpare2()

	self.MOTDPnl = vgui.Create( "EditablePanel" )
	self.MOTDPnl:MakePopup()
	self.MOTDPnl:SetSize( 600, 400 )
	self.MOTDPnl:Center()
	
	local header = self.MOTDPnl:Add( "DLabel" )
	header:SetHeight( 50 )
	header:SetFont( "hvh_menutitle" )
	header:SetTextInset( 60, 0 )
	header:SetTextColor( clr_text )
	header:SetText( GetHostName() )
	header:SetContentAlignment( 4 )
	header:DockMargin( 0, 0, 0, 5 )
	header:Dock( TOP )
	header.Paint = function( self, w, h )

		draw.RoundedBoxEx( 16, 0, 0, w, h, clr_bg, true, true, false, false )
		
		surface.SetDrawColor( clr_text )
		surface.SetMaterial( matCSLogo )
		surface.DrawTexturedRect( 10, 5, 40, 40 ) 
		
	end
	
	local mainMenu = self.MOTDPnl:Add( "Panel" )
	mainMenu:DockPadding( 10, 10, 10, 15 )
	mainMenu:Dock( FILL )
	mainMenu.Paint = function( self, w, h )

		draw.RoundedBoxEx( 16, 0, 0, w, h, clr_bg, false, false, true, true )
		
	end
	
	local html = mainMenu:Add( "DHTML" )
	html:Dock( FILL )
	html:DockMargin( 0, 0, 0, 10 )
	html:SetAllowLua( true )
	
	if ( motd_text ) then
	
		if ( motd_text:StartsWith( "http://" ) || motd_text:StartsWith( "https://" ) || motd_text:StartsWith( "asset://" ) || motd_text == "about:blank" || motd_text == "chrome://credits/" ) then
			html:OpenURL( motd_text )
		else
			html:SetHTML( motd_text )
		end
		
	else
	
		html:OpenURL( "about:blank" )

	end
	
	local OKButton = mainMenu:Add( "DLabel" )
	OKButton:SetHeight( 20 )
	OKButton:SetFont( "hvh_menu" )
	OKButton:SetTextColor( clr_text )
	OKButton:SetText( "OK" )
	OKButton:SetContentAlignment( 5 )
	OKButton:SetMouseInputEnabled( true )
	OKButton:DockMargin( 0, 0, 430, 0 )
	OKButton:Dock( BOTTOM )
	OKButton.Paint = function( self, w, h )

		if ( self:IsHovered() ) then
		
			surface.SetDrawColor( clr_hovered )
			surface.DrawRect( 0, 0, w, h )
			
		end

		surface.SetDrawColor( clr_border )
		surface.DrawOutlinedRect( 0, 0, w, h, 1 ) 
		
	end

	OKButton.DoClick = function( self )
	
		GAMEMODE:HideHelp()
	
		local ply = LocalPlayer()
		
		if ( !IsValid( ply ) || ply:Team() == TEAM_UNASSIGNED ) then
			GAMEMODE:ShowTeam()
		end

	end
	
	if ( IsValid( self.ScoreboardPnl ) && self.ScoreboardPnl:IsVisible() ) then
		self.MOTDPnl:Hide()
	end

end

function GM:HideHelp()

	if ( IsValid( self.MOTDPnl ) ) then
	
		self.MOTDPnl:Remove()
		self.MOTDPnl = nil
		
	end

end

local function RecvShowMOTD()

	local has_text = net.ReadBool()
	
	if ( has_text ) then
		motd_text = net.ReadString()
	end
	
	GAMEMODE:ShowHelp()

end
net.Receive( "hvh_showmotd", RecvShowMOTD )