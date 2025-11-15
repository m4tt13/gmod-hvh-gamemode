local clr_text		= Color( 255, 176, 0, 255 )
local clr_hovered	= Color( 192, 28, 0, 140 )
local clr_bg		= Color( 0, 0, 0, 196 )
local clr_border	= Color( 188, 112, 0, 128 )

local class_random_image = {

	[TEAM_TERRORIST] 	= "vgui/gfx/vgui/t_random",
	[TEAM_CT] 			= "vgui/gfx/vgui/ct_random"
	
}

function GM:ShowTeam()

	if ( IsValid( self.TeamSelectPnl ) ) then return end

	GAMEMODE:HideHelp()
	GAMEMODE:HideSpare2()

	self.TeamSelectPnl = vgui.Create( "EditablePanel" )
	self.TeamSelectPnl:MakePopup()
	self.TeamSelectPnl:SetKeyboardInputEnabled( false )
	self.TeamSelectPnl:SetSize( 600, 400 )
	self.TeamSelectPnl:Center()

	local header = self.TeamSelectPnl:Add( "DLabel" )
	header:SetHeight( 50 )
	header:SetFont( "hvh_menutitle" )
	header:SetTextInset( 15, 0 )
	header:SetTextColor( clr_text )
	header:SetText( "Team Menu" )
	header:SetContentAlignment( 4 )
	header:DockMargin( 0, 0, 0, 5 )
	header:Dock( TOP )
	header.Paint = function( self, w, h )

		draw.RoundedBoxEx( 16, 0, 0, w, h, clr_bg, true, true, false, false )
		
	end
	
	local mainMenu = self.TeamSelectPnl:Add( "Panel" )
	mainMenu:SetWide( 170 )
	mainMenu:DockMargin( 0, 0, 5, 0 )
	mainMenu:DockPadding( 10, 10, 10, 15 )
	mainMenu:Dock( LEFT )
	mainMenu.Paint = function( self, w, h )

		draw.RoundedBoxEx( 16, 0, 0, w, h, clr_bg, false, false, true, false )
		
	end
	
	local classImageCanvas = self.TeamSelectPnl:Add( "Panel" )
	classImageCanvas:DockPadding( 0, 10, 10, 0 )
	classImageCanvas:Dock( FILL )
	classImageCanvas.Paint = function( self, w, h )

		draw.RoundedBoxEx( 16, 0, 0, w, h, clr_bg, false, false, false, true )
		
	end
	
	local classImage = classImageCanvas:Add( "DImage" )
	classImage:SetVisible( false )
	classImage:Dock( TOP )
	classImage.Paint = function( self, w, h )
	
		self:PaintAt( 0, 0, w, h )

		surface.SetDrawColor( clr_border )
		surface.DrawOutlinedRect( 0, 0, w, h, 1 ) 
		
	end
	
	classImage.PerformLayout = function( self, w, h )

		self:SetHeight( w * ( self.ActualHeight / self.ActualWidth ) )
		
	end
	
	local activeTeamPnl = nil
	local bestAutoJoinTeam = team.BestAutoJoinTeam()
	
	for k, teamModels in ipairs( g_PlayerModels ) do
	
		local teamPnl = self.TeamSelectPnl:Add( "Panel" )
		teamPnl:SetVisible( false )
		teamPnl:SetWide( 170 )
		teamPnl:DockPadding( 10, 10, 10, 15 )
		teamPnl:Dock( LEFT )
		
		if ( !activeTeamPnl ) then
		
			activeTeamPnl = teamPnl
			activeTeamPnl:SetVisible( true )
			
		end
		
		if ( k == bestAutoJoinTeam ) then
		
			activeTeamPnl:SetVisible( false )
			activeTeamPnl = teamPnl
			activeTeamPnl:SetVisible( true )
			
		end
		
		teamPnl.Paint = function( self, w, h )
		
			surface.SetDrawColor( clr_bg )
			surface.DrawRect( 0, 0, w, h )
		
		end
		
		local teamButton = mainMenu:Add( "DLabel" )
		teamButton:SetHeight( 20 )
		teamButton:SetFont( "hvh_menu" )
		teamButton:SetTextInset( 10, 0 )
		teamButton:SetTextColor( clr_text )
		teamButton:SetText( team.GetName( k ) )
		teamButton:SetContentAlignment( 4 )
		teamButton:SetMouseInputEnabled( true )
		teamButton:DockMargin( 0, 0, 0, 10 )
		teamButton:Dock( TOP )
		teamButton.Paint = function( self, w, h )

			if ( self:IsHovered() || teamPnl == activeTeamPnl ) then
			
				surface.SetDrawColor( clr_hovered )
				surface.DrawRect( 0, 0, w, h )
				
			end

			surface.SetDrawColor( clr_border )
			surface.DrawOutlinedRect( 0, 0, w, h, 1 ) 
			
		end

		teamButton.DoClick = function( self )

			activeTeamPnl:SetVisible( false )
			activeTeamPnl = teamPnl
			activeTeamPnl:SetVisible( true )
			
		end
		
		teamButton.OnCursorEntered = function( self )
		
			classImage:SetVisible( false )
			
		end

		for k_, modelInfo in ipairs( teamModels ) do
		
			local classButton = teamPnl:Add( "DLabel" )
			classButton:SetHeight( 20 )
			classButton:SetFont( "hvh_menu" )
			classButton:SetTextInset( 10, 0 )
			classButton:SetTextColor( clr_text )
			classButton:SetText( modelInfo.Name )
			classButton:SetContentAlignment( 4 )
			classButton:SetMouseInputEnabled( true )
			classButton:DockMargin( 0, 0, 0, 10 )
			classButton:Dock( TOP )
			classButton.Paint = function( self, w, h )

				if ( self:IsHovered() ) then
				
					surface.SetDrawColor( clr_hovered )
					surface.DrawRect( 0, 0, w, h )
					
				end

				surface.SetDrawColor( clr_border )
				surface.DrawOutlinedRect( 0, 0, w, h, 1 ) 
				
			end
			
			classButton.DoClick = function( self )

				RunConsoleCommand( "changeteam2", k, k_ )
				GAMEMODE:HideTeam()
				
			end
			
			classButton.OnCursorEntered = function( self )
		
				classImage:SetVisible( true )
				classImage:SetImage( modelInfo.Image )
				classImage:InvalidateLayout()
				
			end
			
		end
		
		local autoselectButton = teamPnl:Add( "DLabel" )
		autoselectButton:SetHeight( 20 )
		autoselectButton:SetFont( "hvh_menu" )
		autoselectButton:SetTextInset( 10, 0 )
		autoselectButton:SetTextColor( clr_text )
		autoselectButton:SetText( "Auto-Select" )
		autoselectButton:SetContentAlignment( 4 )
		autoselectButton:SetMouseInputEnabled( true )
		autoselectButton:DockMargin( 0, 30, 0, 10 )
		autoselectButton:Dock( TOP )
		autoselectButton.Paint = function( self, w, h )

			if ( self:IsHovered() ) then
			
				surface.SetDrawColor( clr_hovered )
				surface.DrawRect( 0, 0, w, h )
				
			end

			surface.SetDrawColor( clr_border )
			surface.DrawOutlinedRect( 0, 0, w, h, 1 ) 
			
		end
		
		autoselectButton.DoClick = function( self )

			RunConsoleCommand( "changeteam", k )
			GAMEMODE:HideTeam() 
			
		end
		
		autoselectButton.OnCursorEntered = function( self )
			
			classImage:SetVisible( true )
			classImage:SetImage( class_random_image[k] )
			classImage:InvalidateLayout()
			
		end
		
	end
	
	local spectateButton = mainMenu:Add( "DLabel" )
	spectateButton:SetHeight( 20 )
	spectateButton:SetFont( "hvh_menu" )
	spectateButton:SetTextInset( 10, 0 )
	spectateButton:SetTextColor( clr_text )
	spectateButton:SetText( "Spectate" )
	spectateButton:SetContentAlignment( 4 )
	spectateButton:SetMouseInputEnabled( true )
	spectateButton:DockMargin( 0, 30, 0, 10 )
	spectateButton:Dock( TOP )
	spectateButton.Paint = function( self, w, h )

		if ( self:IsHovered() ) then
		
			surface.SetDrawColor( clr_hovered )
			surface.DrawRect( 0, 0, w, h )
			
		end

		surface.SetDrawColor( clr_border )
		surface.DrawOutlinedRect( 0, 0, w, h, 1 ) 
		
	end

	spectateButton.DoClick = function( self )
	
		RunConsoleCommand( "changeteam", TEAM_SPECTATOR )
		GAMEMODE:HideTeam()

	end
	
	spectateButton.OnCursorEntered = function( self )
		
		classImage:SetVisible( false )
		
	end
	
	local ply = LocalPlayer()
	
	if ( IsValid( ply ) && ply:Team() != TEAM_UNASSIGNED ) then
	
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
		
			GAMEMODE:HideTeam() 

		end
		
		cancelButton.OnCursorEntered = function( self )
			
			classImage:SetVisible( false )
			
		end
		
	end
	
	if ( IsValid( self.ScoreboardPnl ) && self.ScoreboardPnl:IsVisible() ) then
		self.TeamSelectPnl:Hide()
	end
	
end

function GM:HideTeam()

	if ( IsValid( self.TeamSelectPnl ) ) then
	
		self.TeamSelectPnl:Remove()
		self.TeamSelectPnl = nil
		
	end

end

concommand.Add( "teammenu", function() GAMEMODE:ShowTeam() end )
