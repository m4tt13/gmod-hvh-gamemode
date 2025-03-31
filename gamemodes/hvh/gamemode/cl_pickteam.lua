local clr_text		= Color( 255, 176, 0, 255 )
local clr_hovered	= Color( 192, 28, 0, 140 )
local clr_bg		= Color( 0, 0, 0, 196 )
local clr_border	= Color( 188, 112, 0, 128 )

function GM:ShowTeam()

	local ply		= LocalPlayer()
	local teamid 	= ply:Team()

	if ( IsValid( self.TeamSelectPnl ) ) then
	
		if ( teamid != TEAM_UNASSIGNED ) then
			GAMEMODE:HideTeam()
		end
		
		return
		
	end
	
	if ( IsValid( self.ScoreboardPnl ) && self.ScoreboardPnl:IsVisible() ) then
		return
	end
	
	GAMEMODE:HideHelp()

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
	
	local classModelCanvas = self.TeamSelectPnl:Add( "Panel" )
	classModelCanvas:DockPadding( 0, 10, 10, 0 )
	classModelCanvas:Dock( FILL )
	classModelCanvas.Paint = function( self, w, h )

		draw.RoundedBoxEx( 16, 0, 0, w, h, clr_bg, false, false, false, true )
		
	end
	
	local classModel = classModelCanvas:Add( "DModelPanel" )
	classModel:SetVisible( false )
	classModel:SetHeight( 300 )
	classModel:Dock( TOP )
	classModel:SetLookAt( Vector( 0, 0, 40 ) )
	classModel:SetCamPos( Vector( 50, 25, 50 ) )
	classModel:SetAmbientLight( Color( 255, 255, 255 ) )
	classModel.LayoutEntity = function( self ) return end
	classModel.Paint = function( self, w, h )

		DModelPanel.Paint( self, w, h )

		surface.SetDrawColor( clr_border )
		surface.DrawOutlinedRect( 0, 0, w, h, 1 ) 
		
	end
	
	classModel.DoClick = function( self )

		if ( self.ClassButton ) then
			self.ClassButton:DoClick()
		end

	end
	
	local activeTeamPnl = nil
	local activeTeamButton = nil
	
	local teamPanels = {}
	
	for k, teamModels in ipairs( PlayerModels ) do
	
		local teamPnl = self.TeamSelectPnl:Add( "Panel" )
		teamPnl:SetVisible( false )
		teamPnl:SetWide( 170 )
		teamPnl:DockPadding( 10, 10, 10, 15 )
		teamPnl:Dock( LEFT )
		
		if ( !activeTeamPnl ) then
		
			activeTeamPnl = teamPnl
			activeTeamPnl:SetVisible( true )
			
		end
		
		teamPnl.Paint = function( self, w, h )
		
			surface.SetDrawColor( clr_bg )
			surface.DrawRect( 0, 0, w, h )
		
		end
		
		teamPanels[k] = teamPnl
		
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
		
		if ( !activeTeamButton ) then 
			activeTeamButton = teamButton 
		end
		
		teamButton.Paint = function( self, w, h )

			if ( self:IsHovered() || self == activeTeamButton ) then
			
				surface.SetDrawColor( clr_hovered )
				surface.DrawRect( 0, 0, w, h )
				
			end

			surface.SetDrawColor( clr_border )
			surface.DrawOutlinedRect( 0, 0, w, h, 1 ) 
			
		end

		teamButton.DoClick = function( self )

			activeTeamButton = self

			activeTeamPnl:SetVisible( false )
			activeTeamPnl = teamPnl
			activeTeamPnl:SetVisible( true )
			
		end
		
		teamButton.OnCursorEntered = function( self )
		
			classModel:SetVisible( false )
			
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
		
				classModel.ClassButton = self
				classModel:SetVisible( true )
				classModel:SetModel( modelInfo.MDL )
				
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
			
			classModel:SetVisible( false )
			
		end
		
	end
	
	local autojoinButton = mainMenu:Add( "DLabel" )
	autojoinButton:SetHeight( 20 )
	autojoinButton:SetFont( "hvh_menu" )
	autojoinButton:SetTextInset( 10, 0 )
	autojoinButton:SetTextColor( clr_text )
	autojoinButton:SetText( "Auto-Assign" )
	autojoinButton:SetContentAlignment( 4 )
	autojoinButton:SetMouseInputEnabled( true )
	autojoinButton:DockMargin( 0, 30, 0, 10 )
	autojoinButton:Dock( TOP )
	autojoinButton.Paint = function( self, w, h )

		if ( self:IsHovered() || self == activeTeamButton ) then
		
			surface.SetDrawColor( clr_hovered )
			surface.DrawRect( 0, 0, w, h )
			
		end

		surface.SetDrawColor( clr_border )
		surface.DrawOutlinedRect( 0, 0, w, h, 1 ) 
		
	end

	autojoinButton.DoClick = function( self )

		local bestTeamPnl = teamPanels[team.BestAutoJoinTeam()]

		if ( bestTeamPnl ) then
		
			activeTeamButton = self
		
			activeTeamPnl:SetVisible( false )
			activeTeamPnl = bestTeamPnl
			activeTeamPnl:SetVisible( true )
			
		end

	end
	
	autojoinButton.OnCursorEntered = function( self )
		
		classModel:SetVisible( false )
		
	end
	
	local spectateButton = mainMenu:Add( "DLabel" )
	spectateButton:SetHeight( 20 )
	spectateButton:SetFont( "hvh_menu" )
	spectateButton:SetTextInset( 10, 0 )
	spectateButton:SetTextColor( clr_text )
	spectateButton:SetText( "Spectate" )
	spectateButton:SetContentAlignment( 4 )
	spectateButton:SetMouseInputEnabled( true )
	spectateButton:DockMargin( 0, 0, 0, 10 )
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
		
		classModel:SetVisible( false )
		
	end
	
	if ( teamid != TEAM_UNASSIGNED ) then
	
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
			
			classModel:SetVisible( false )
			
		end
		
	end
	
	autojoinButton:DoClick()
	
end

function GM:HideTeam()

	if ( IsValid( self.TeamSelectPnl ) ) then
	
		self.TeamSelectPnl:Remove()
		self.TeamSelectPnl = nil
		
	end

end

concommand.Add( "teammenu", function() GAMEMODE:ShowTeam() end )
