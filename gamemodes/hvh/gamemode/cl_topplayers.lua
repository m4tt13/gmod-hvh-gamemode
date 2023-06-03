local top_players = {}

local clr_black 	= Color( 0, 0, 0, 140 )
local clr_text		= Color( 255, 176, 0, 255 )
local clr_hovered	= Color( 192, 28, 0, 140 )
local clr_bg		= Color( 0, 0, 0, 196 )
local clr_border	= Color( 188, 112, 0, 128 )

function GM:ShowSpare1()

	if ( IsValid( self.TopPlayersPnl ) ) then 
	
		GAMEMODE:HideSpare1() 
		return 
		
	end

	GAMEMODE:HideHelp()
	GAMEMODE:HideTeam()

	self.TopPlayersPnl = vgui.Create( "EditablePanel" )
	self.TopPlayersPnl:MakePopup()
	self.TopPlayersPnl:SetKeyboardInputEnabled( false )
	self.TopPlayersPnl:SetSize( 600, 400 )
	self.TopPlayersPnl:Center()

	local header = self.TopPlayersPnl:Add( "DLabel" )
	header:SetHeight( 50 )
	header:SetFont( "HvH_MenuTitle" )
	header:SetTextInset( 15, 0 )
	header:SetTextColor( clr_text )
	header:SetText( "Top Players" )
	header:SetContentAlignment( 4 )
	header:DockMargin( 0, 0, 0, 5 )
	header:Dock( TOP )
	header.Paint = function( self, w, h )

		draw.RoundedBoxEx( 16, 0, 0, w, h, clr_bg, true, true, false, false )
		
	end
		
	local mainMenu = self.TopPlayersPnl:Add( "Panel" )
	mainMenu:DockPadding( 10, 10, 10, 15 )
	mainMenu:Dock( FILL )
	mainMenu.Paint = function( self, w, h )

		draw.RoundedBoxEx( 16, 0, 0, w, h, clr_bg, false, false, true, true )
		
	end
	
	local headerRow = mainMenu:Add( "Panel" )
	headerRow:SetHeight( 19 )
	headerRow:DockMargin( 0, 0, 0, -1 )
	headerRow:Dock( TOP )
	headerRow.Paint = function( self, w, h )

		surface.SetDrawColor( clr_black )
		surface.DrawRect( 0, 0, w, h, 1 ) 
		
	end
	
	local headshotsHdr = headerRow:Add( "DLabel" )
	headshotsHdr:SetFont( "HvH_MenuSmall" )
	headshotsHdr:SetTextInset( 10, 0 )
	headshotsHdr:SetTextColor( clr_text )
	headshotsHdr:SetText( "Headshots" )
	headshotsHdr:SetWidth( 90 )
	headshotsHdr:SetContentAlignment( 4 )
	headshotsHdr:Dock( RIGHT )
	headshotsHdr.Paint = function( self, w, h )

		surface.SetDrawColor( clr_border )
		surface.DrawOutlinedRect( 0, 0, w, h, 1 ) 
		
	end
	
	local deathsHdr = headerRow:Add( "DLabel" )
	deathsHdr:SetFont( "HvH_MenuSmall" )
	deathsHdr:SetTextInset( 10, 0 )
	deathsHdr:SetTextColor( clr_text )
	deathsHdr:SetText( "Deaths" )
	deathsHdr:SetWidth( 80 )
	deathsHdr:SetContentAlignment( 4 )
	deathsHdr:Dock( RIGHT )
	deathsHdr.Paint = function( self, w, h )

		surface.SetDrawColor( clr_border )
		surface.DrawOutlinedRect( 0, 0, w + 1, h, 1 ) 
		
	end
	
	local killsHdr = headerRow:Add( "DLabel" )
	killsHdr:SetFont( "HvH_MenuSmall" )
	killsHdr:SetTextInset( 10, 0 )
	killsHdr:SetTextColor( clr_text )
	killsHdr:SetText( "Kills" )
	killsHdr:SetWidth( 80 )
	killsHdr:SetContentAlignment( 4 )
	killsHdr:Dock( RIGHT )
	killsHdr.Paint = function( self, w, h )

		surface.SetDrawColor( clr_border )
		surface.DrawOutlinedRect( 0, 0, w + 1, h, 1 ) 
		
	end
	
	local scoreHdr = headerRow:Add( "DLabel" )
	scoreHdr:SetFont( "HvH_MenuSmall" )
	scoreHdr:SetTextInset( 10, 0 )
	scoreHdr:SetTextColor( clr_text )
	scoreHdr:SetText( "Score" )
	scoreHdr:SetWidth( 80 )
	scoreHdr:SetContentAlignment( 4 )
	scoreHdr:Dock( RIGHT )
	scoreHdr.Paint = function( self, w, h )

		surface.SetDrawColor( clr_border )
		surface.DrawOutlinedRect( 0, 0, w + 1, h, 1 ) 
		
	end
	
	local nameHdr = headerRow:Add( "DLabel" )
	nameHdr:SetFont( "HvH_MenuSmall" )
	nameHdr:SetTextInset( 10, 0 )
	nameHdr:SetTextColor( clr_text )
	nameHdr:SetText( "Name" )
	nameHdr:SetWidth( 220 )
	nameHdr:SetContentAlignment( 4 )
	nameHdr:Dock( RIGHT )
	nameHdr.Paint = function( self, w, h )

		surface.SetDrawColor( clr_border )
		surface.DrawOutlinedRect( 0, 0, w + 1, h, 1 ) 
		
	end
	
	local rankHdr = headerRow:Add( "DLabel" )
	rankHdr:SetFont( "HvH_MenuSmall" )
	rankHdr:SetTextColor( clr_text )
	rankHdr:SetText( "№" )
	rankHdr:SetContentAlignment( 5 )
	rankHdr:Dock( FILL )
	rankHdr.Paint = function( self, w, h )

		surface.SetDrawColor( clr_border )
		surface.DrawOutlinedRect( 0, 0, w + 1, h, 1 ) 
		
	end
	
	for pos, stats in ipairs( top_players ) do
	
		local playerRow = mainMenu:Add( "Panel" )
		playerRow:SetHeight( 19 )
		playerRow:DockMargin( 0, 0, 0, -1 )
		playerRow:Dock( TOP )
		playerRow.Paint = function( self, w, h )

			surface.SetDrawColor( clr_black )
			surface.DrawRect( 0, 0, w, h, 1 ) 
			
		end

		local headshots = playerRow:Add( "DLabel" )
		headshots:SetFont( "HvH_MenuSmall" )
		headshots:SetTextInset( 10, 0 )
		headshots:SetTextColor( clr_text )
		headshots:SetText( stats.Headshots )
		headshots:SetWidth( 90 )
		headshots:SetContentAlignment( 4 )
		headshots:Dock( RIGHT )
		headshots.Paint = function( self, w, h )

			surface.SetDrawColor( clr_border )
			surface.DrawOutlinedRect( 0, 0, w, h, 1 ) 
			
		end
		
		local deaths = playerRow:Add( "DLabel" )
		deaths:SetFont( "HvH_MenuSmall" )
		deaths:SetTextInset( 10, 0 )
		deaths:SetTextColor( clr_text )
		deaths:SetText( stats.Deaths )
		deaths:SetWidth( 80 )
		deaths:SetContentAlignment( 4 )
		deaths:Dock( RIGHT )
		deaths.Paint = function( self, w, h )

			surface.SetDrawColor( clr_border )
			surface.DrawOutlinedRect( 0, 0, w + 1, h, 1 ) 
			
		end
		
		local kills = playerRow:Add( "DLabel" )
		kills:SetFont( "HvH_MenuSmall" )
		kills:SetTextInset( 10, 0 )
		kills:SetTextColor( clr_text )
		kills:SetText( stats.Kills )
		kills:SetWidth( 80 )
		kills:SetContentAlignment( 4 )
		kills:Dock( RIGHT )
		kills.Paint = function( self, w, h )

			surface.SetDrawColor( clr_border )
			surface.DrawOutlinedRect( 0, 0, w + 1, h, 1 ) 
			
		end
		
		local score = playerRow:Add( "DLabel" )
		score:SetFont( "HvH_MenuSmall" )
		score:SetTextInset( 10, 0 )
		score:SetTextColor( clr_text )
		score:SetText( stats.Score )
		score:SetWidth( 80 )
		score:SetContentAlignment( 4 )
		score:Dock( RIGHT )
		score.Paint = function( self, w, h )

			surface.SetDrawColor( clr_border )
			surface.DrawOutlinedRect( 0, 0, w + 1, h, 1 ) 
			
		end
		
		local name = playerRow:Add( "DLabel" )
		name:SetFont( "HvH_MenuSmall" )
		name:SetTextInset( 10, 0 )
		name:SetTextColor( clr_text )
		name:SetText( stats.Name )
		name:SetWidth( 220 )
		name:SetContentAlignment( 4 )
		name:Dock( RIGHT )
		name.Paint = function( self, w, h )

			surface.SetDrawColor( clr_border )
			surface.DrawOutlinedRect( 0, 0, w + 1, h, 1 ) 
			
		end
		
		local rank = playerRow:Add( "DLabel" )
		rank:SetFont( "HvH_MenuSmall" )
		rank:SetTextColor( clr_text )
		rank:SetText( pos )
		rank:SetContentAlignment( 5 )
		rank:Dock( FILL )
		rank.Paint = function( self, w, h )

			surface.SetDrawColor( clr_border )
			surface.DrawOutlinedRect( 0, 0, w + 1, h, 1 ) 
			
		end
		
	end
	
	local cancelButton = mainMenu:Add( "DLabel" )
	cancelButton:SetHeight( 20 )
	cancelButton:SetFont( "HvH_Menu" )
	cancelButton:SetTextInset( 10, 0 )
	cancelButton:SetTextColor( clr_text )
	cancelButton:SetText( "Cancel" )
	cancelButton:SetContentAlignment( 4 )
	cancelButton:SetMouseInputEnabled( true )
	cancelButton:DockMargin( 0, 0, 430, 0 )
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
	
		GAMEMODE:HideSpare1() 

	end
	
end

local function RecvTopPlayers()

	top_players = {}

	local numPlayers = net.ReadUInt( 4 )

	for i = 1, numPlayers do
	
		local name		= net.ReadString()
		local score		= net.ReadInt( 32 )
		local kills		= net.ReadInt( 32 )
		local deaths	= net.ReadInt( 32 )
		local headshots	= net.ReadInt( 32 )
		
		local stats = { 
		
			Name = name, 
			Score = score, 
			Kills = kills, 
			Deaths = deaths,
			Headshots = headshots 
			
		}
		
		table.insert( top_players, stats )
		
	end
	
	GAMEMODE:ShowSpare1()

end
net.Receive( "HvH_TopPlayers", RecvTopPlayers )

function GM:HideSpare1()

	if ( IsValid( self.TopPlayersPnl ) ) then
	
		self.TopPlayersPnl:Remove()
		self.TopPlayersPnl = nil
		
	end

end
