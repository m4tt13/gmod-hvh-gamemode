surface.CreateFont( "hvh_scoreboard", {

	font = "Verdana",
	size = 13,
	weight = 700

} )

surface.CreateFont( "hvh_scoreboardsmall", {

	font = "Verdana",
	size = 13,
	weight = 0

} )

local clr_black 	= Color( 0, 0, 0, 255 )
local clr_text 		= Color( 255, 176, 0, 255 )
local clr_selected	= Color( 200, 200, 200, 32 )
local clr_bg 		= Color( 0, 0, 0, 90 )
local clr_border	= Color( 255, 176, 0, 255 )

local function DrawRoundedBackground( wide, tall )

	local coord = { 0, 1, 2, 3, 4, 6, 9, 10 }
	local numSegments = #coord
	
	local x1
	local x2
	local y1
	local y2
	surface.SetDrawColor( clr_bg )

	-- top-left corner --------------------------------------------------------
	local xDir = 1
	local yDir = -1
	local xIndex = 1
	local yIndex = numSegments - 1
	local xMult = 1
	local yMult = 1
	local x = 0
	local y = 0
	
	for i = 1, numSegments - 1 do
	
		x1 = math.min( x + coord[xIndex]*xMult, x + coord[xIndex+1]*xMult )
		x2 = math.max( x + coord[xIndex]*xMult, x + coord[xIndex+1]*xMult )
		y1 = math.max( y + coord[yIndex]*yMult, y + coord[yIndex+1]*yMult )
		y2 = y + coord[numSegments]
		surface.DrawRect( x1, y1, x2 - x1, y2 - y1 )
		xIndex = xIndex + xDir
		yIndex = yIndex + yDir
		
	end

	-- top-right corner -------------------------------------------------------
	xDir = 1
	yDir = -1
	xIndex = 1
	yIndex = numSegments - 1
	x = wide
	y = 0
	xMult = -1
	yMult = 1
	
	for i = 1, numSegments - 1 do
	
		x1 = math.min( x + coord[xIndex]*xMult, x + coord[xIndex+1]*xMult )
		x2 = math.max( x + coord[xIndex]*xMult, x + coord[xIndex+1]*xMult )
		y1 = math.max( y + coord[yIndex]*yMult, y + coord[yIndex+1]*yMult )
		y2 = y + coord[numSegments]
		surface.DrawRect( x1, y1, x2 - x1, y2 - y1 )
		xIndex = xIndex + xDir
		yIndex = yIndex + yDir
		
	end

	-- bottom-right corner ----------------------------------------------------
	xDir = 1
	yDir = -1
	xIndex = 1
	yIndex = numSegments - 1
	x = wide
	y = tall
	xMult = -1
	yMult = -1
	
	for i = 1, numSegments - 1 do
	
		x1 = math.min( x + coord[xIndex]*xMult, x + coord[xIndex+1]*xMult )
		x2 = math.max( x + coord[xIndex]*xMult, x + coord[xIndex+1]*xMult )
		y1 = y - coord[numSegments]
		y2 = math.min( y + coord[yIndex]*yMult, y + coord[yIndex+1]*yMult )
		surface.DrawRect( x1, y1, x2 - x1, y2 - y1 )
		xIndex = xIndex + xDir
		yIndex = yIndex + yDir
		
	end

	-- bottom-left corner -----------------------------------------------------
	xDir = 1
	yDir = -1
	xIndex = 1
	yIndex = numSegments - 1
	x = 0
	y = tall
	xMult = 1
	yMult = -1
	
	for i = 1, numSegments - 1 do
	
		x1 = math.min( x + coord[xIndex]*xMult, x + coord[xIndex+1]*xMult )
		x2 = math.max( x + coord[xIndex]*xMult, x + coord[xIndex+1]*xMult )
		y1 = y - coord[numSegments]
		y2 = math.min( y + coord[yIndex]*yMult, y + coord[yIndex+1]*yMult )
		surface.DrawRect( x1, y1, x2 - x1, y2 - y1 )
		xIndex = xIndex + xDir
		yIndex = yIndex + yDir
		
	end

	-- paint between top left and bottom left ---------------------------------
	x1 = 0
	x2 = coord[numSegments]
	y1 = coord[numSegments]
	y2 = tall - coord[numSegments]
	surface.DrawRect( x1, y1, x2 - x1, y2 - y1 )

	-- paint between left and right -------------------------------------------
	x1 = coord[numSegments]
	x2 = wide - coord[numSegments]
	y1 = 0
	y2 = tall
	surface.DrawRect( x1, y1, x2 - x1, y2 - y1 )
	
	-- paint between top right and bottom right -------------------------------
	x1 = wide - coord[numSegments]
	x2 = wide;
	y1 = coord[numSegments]
	y2 = tall - coord[numSegments]
	surface.DrawRect( x1, y1, x2 - x1, y2 - y1 )
	
end

local function DrawRoundedBorder( wide, tall )

	local coord = { 0, 1, 2, 3, 4, 6, 9, 10 }
	local numSegments = #coord
	
	local x1
	local x2
	local y1
	local y2
	surface.SetDrawColor( clr_border )

	-- top-left corner --------------------------------------------------------
	local xDir = 1
	local yDir = -1
	local xIndex = 1
	local yIndex = numSegments - 1
	local xMult = 1
	local yMult = 1
	local x = 0
	local y = 0
	
	for i = 1, numSegments - 1 do
	
		x1 = math.min( x + coord[xIndex]*xMult, x + coord[xIndex+1]*xMult )
		x2 = math.max( x + coord[xIndex]*xMult, x + coord[xIndex+1]*xMult )
		y1 = math.min( y + coord[yIndex]*yMult, y + coord[yIndex+1]*yMult )
		y2 = math.max( y + coord[yIndex]*yMult, y + coord[yIndex+1]*yMult )
		surface.DrawRect( x1, y1, x2 - x1, y2 - y1 )
		xIndex = xIndex + xDir
		yIndex = yIndex + yDir
		
	end

	-- top-right corner -------------------------------------------------------
	xDir = 1
	yDir = -1
	xIndex = 1
	yIndex = numSegments - 1
	x = wide
	y = 0
	xMult = -1
	yMult = 1
	
	for i = 1, numSegments - 1 do
	
		x1 = math.min( x + coord[xIndex]*xMult, x + coord[xIndex+1]*xMult )
		x2 = math.max( x + coord[xIndex]*xMult, x + coord[xIndex+1]*xMult )
		y1 = math.min( y + coord[yIndex]*yMult, y + coord[yIndex+1]*yMult )
		y2 = math.max( y + coord[yIndex]*yMult, y + coord[yIndex+1]*yMult )
		surface.DrawRect( x1, y1, x2 - x1, y2 - y1 )
		xIndex = xIndex + xDir
		yIndex = yIndex + yDir
		
	end

	-- bottom-right corner ----------------------------------------------------
	xDir = 1
	yDir = -1
	xIndex = 1
	yIndex = numSegments - 1
	x = wide
	y = tall
	xMult = -1
	yMult = -1
	
	for i = 1, numSegments - 1 do
	
		x1 = math.min( x + coord[xIndex]*xMult, x + coord[xIndex+1]*xMult )
		x2 = math.max( x + coord[xIndex]*xMult, x + coord[xIndex+1]*xMult )
		y1 = math.min( y + coord[yIndex]*yMult, y + coord[yIndex+1]*yMult )
		y2 = math.max( y + coord[yIndex]*yMult, y + coord[yIndex+1]*yMult )
		surface.DrawRect( x1, y1, x2 - x1, y2 - y1 )
		xIndex = xIndex + xDir
		yIndex = yIndex + yDir
		
	end

	-- bottom-left corner -----------------------------------------------------
	xDir = 1
	yDir = -1
	xIndex = 1
	yIndex = numSegments - 1
	x = 0
	y = tall
	xMult = 1
	yMult = -1
	
	for i = 1, numSegments - 1 do
	
		x1 = math.min( x + coord[xIndex]*xMult, x + coord[xIndex+1]*xMult )
		x2 = math.max( x + coord[xIndex]*xMult, x + coord[xIndex+1]*xMult )
		y1 = math.min( y + coord[yIndex]*yMult, y + coord[yIndex+1]*yMult )
		y2 = math.max( y + coord[yIndex]*yMult, y + coord[yIndex+1]*yMult )
		surface.DrawRect( x1, y1, x2 - x1, y2 - y1 )
		xIndex = xIndex + xDir
		yIndex = yIndex + yDir
		
	end

	-- top --------------------------------------------------------------------
	x1 = coord[numSegments]
	x2 = wide - coord[numSegments]
	y1 = 0
	y2 = 1
	surface.DrawRect( x1, y1, x2 - x1, y2 - y1 )

	-- bottom -----------------------------------------------------------------
	x1 = coord[numSegments]
	x2 = wide - coord[numSegments]
	y1 = tall - 1
	y2 = tall
	surface.DrawRect( x1, y1, x2 - x1, y2 - y1 )

	-- left -------------------------------------------------------------------
	x1 = 0
	x2 = 1
	y1 = coord[numSegments]
	y2 = tall - coord[numSegments];
	surface.DrawRect( x1, y1, x2 - x1, y2 - y1 )

	-- right ------------------------------------------------------------------
	x1 = wide - 1
	x2 = wide
	y1 = coord[numSegments]
	y2 = tall - coord[numSegments]
	surface.DrawRect( x1, y1, x2 - x1, y2 - y1 )
	
end

local function IsSpecTeam( teamid )

	return ( teamid == TEAM_CONNECTING || teamid == TEAM_UNASSIGNED || teamid == TEAM_SPECTATOR )

end

local function NumSpecPlayers()

	return ( team.NumPlayers( TEAM_CONNECTING ) + team.NumPlayers( TEAM_UNASSIGNED ) + team.NumPlayers( TEAM_SPECTATOR ) )

end

local function TeamLatency( index )

	local pingsum = 0
	local numcounted = 0
	
	for id, pl in ipairs( player.GetAll() ) do
	
		if ( pl:Team() == index )  then
		
			local ping = pl:Ping()
			
			if ( ping >= 1 ) then
			
				pingsum = pingsum + ping
				numcounted = numcounted + 1
				
			end
			
		end
		
	end
	
	if ( numcounted < 1 ) then
		return 0
	end

	return math.floor( pingsum / numcounted )
	
end

local function AddHeader( pnl )

	local header = pnl:Add( "Panel" )
	header:SetHeight( draw.GetFontHeight( "hvh_scoreboardsmall" ) + 7 )
	header:DockMargin( 0, 0, 0, 8 )
	header:Dock( TOP )
	
	header.Ping = header:Add( "DLabel" )
	header.Ping:SetFont( "hvh_scoreboardsmall" )
	header.Ping:SetTextInset( 2, 0 )
	header.Ping:SetTextColor( clr_text )
	header.Ping:SetText( "Latency" )
	header.Ping:SetWidth( 57 )
	header.Ping:SetContentAlignment( 6 )
	header.Ping:Dock( RIGHT )
	
	header.Deaths = header:Add( "DLabel" )
	header.Deaths:SetFont( "hvh_scoreboardsmall" )
	header.Deaths:SetTextInset( 2, 0 )
	header.Deaths:SetTextColor( clr_text )
	header.Deaths:SetText( "Deaths" )
	header.Deaths:SetWidth( 57 )
	header.Deaths:SetContentAlignment( 6 )
	header.Deaths:Dock( RIGHT )
	
	header.Score = header:Add( "DLabel" )
	header.Score:SetFont( "hvh_scoreboardsmall" )
	header.Score:SetTextInset( 2, 0 )
	header.Score:SetTextColor( clr_text )
	header.Score:SetText( "Score" )
	header.Score:SetContentAlignment( 6 )
	header.Score:Dock( FILL )
	
	header.Paint = function( self, w, h )
	
		surface.SetDrawColor( clr_black )
		surface.DrawRect( 1, h - 2, w - 2, 1 )

	end
	
end

local function AddPlayerLine( pnl, pl, isspec )

	local playerline = pnl:Add( "Panel" )
	playerline:SetHeight( 16 )
	playerline:Dock( TOP )
	playerline.Player = pl
	playerline.TeamIndex = pl:Team()
	playerline.IsSpec = isspec

	local clr = team.GetColor( pl:Team() )
	
	if ( !isspec ) then
	
		playerline.Ping = playerline:Add( "DLabel" )
		playerline.Ping:SetFont( "hvh_scoreboard" )
		playerline.Ping:SetTextInset( 2, 0 )
		playerline.Ping:SetTextColor( clr )
		playerline.Ping:SetWidth( 57 )
		playerline.Ping:SetContentAlignment( 6 )
		playerline.Ping:Dock( RIGHT )
		
		playerline.Deaths = playerline:Add( "DLabel" )
		playerline.Deaths:SetFont( "hvh_scoreboard" )
		playerline.Deaths:SetTextInset( 2, 0 )
		playerline.Deaths:SetTextColor( clr )
		playerline.Deaths:SetWidth( 57 )
		playerline.Deaths:SetContentAlignment( 6 )
		playerline.Deaths:Dock( RIGHT )
		
		playerline.Frags = playerline:Add( "DLabel" )
		playerline.Frags:SetFont( "hvh_scoreboard" )
		playerline.Frags:SetTextInset( 2, 0 )
		playerline.Frags:SetTextColor( clr )
		playerline.Frags:SetWidth( 50 )
		playerline.Frags:SetContentAlignment( 6 )
		playerline.Frags:Dock( RIGHT )
		
		playerline.Class = playerline:Add( "DLabel" )
		playerline.Class:SetFont( "hvh_scoreboard" )
		playerline.Class:SetTextInset( 2, 0 )
		playerline.Class:SetTextColor( clr )
		playerline.Class:SetWidth( 70 )
		playerline.Class:SetContentAlignment( 4 )
		playerline.Class:Dock( RIGHT )
		
	end
	
	playerline.Name = playerline:Add( "DLabel" )
	playerline.Name:SetFont( "hvh_scoreboard" )
	playerline.Name:SetTextInset( 6, 0 )
	playerline.Name:SetTextColor( clr )
	playerline.Name:SetContentAlignment( 4 )
	playerline.Name:Dock( FILL )
	
	playerline.Paint = function( self, w, h )

		if ( !IsValid( self.Player ) || self.Player != LocalPlayer() ) then return end

		surface.SetDrawColor( clr_selected )
		surface.DrawRect( 0, 0, w, h )
		
	end
	
	playerline.Think = function( self )
	
		if ( !IsValid( self.Player ) || self.Player:Team() != self.TeamIndex ) then
		
			self:SetZPos( 9999 )
			self:Remove()
			return
			
		end
		
		local zpos = self.Player:EntIndex()
		
		if ( !self.IsSpec ) then
		
			if ( self.NumPing == nil || self.NumPing != self.Player:Ping() ) then
			
				self.NumPing = self.Player:Ping()
				self.Ping:SetText( self.Player:IsBot() && "BOT" || self.NumPing )
				
			end
			
			if ( self.NumDeaths == nil || self.NumDeaths != self.Player:Deaths() ) then
			
				self.NumDeaths = self.Player:Deaths()
				self.Deaths:SetText( self.NumDeaths )
				
			end
			
			if ( self.NumKills == nil || self.NumKills != self.Player:Frags() ) then
			
				self.NumKills = self.Player:Frags()
				self.Frags:SetText( self.NumKills )
				
			end
			
			if ( self.Alive == nil || self.Alive != self.Player:Alive() ) then
			
				self.Alive = self.Player:Alive()
				self.Class:SetText( self.Alive && "" || "Dead" )
				
			end
			
			zpos = ( self.NumKills * -50 ) + self.NumDeaths + zpos
			
		end

		if ( self.PName == nil || self.PName != self.Player:Nick() ) then
		
			self.PName = self.Player:Nick()
			self.Name:SetText( self.PName )
			
		end

		self:SetZPos( zpos )
		
	end
	
	playerline:Think()

	return playerline
	
end

local function AddSection( pnl, teamindex )

	local header = pnl:Add( "Panel" )
	header:SetHeight( draw.GetFontHeight( "hvh_scoreboardsmall" ) + 7 )
	header:Dock( TOP )
	header.TeamIndex = teamindex
	
	local divider_clr = clr_black
	local header_clr = clr_text

	if ( teamindex != TEAM_SPECTATOR ) then
	
		divider_clr = team.GetColor( teamindex )
		header_clr = team.GetColor( teamindex )
	
		header.Ping = header:Add( "DLabel" )
		header.Ping:SetFont( "hvh_scoreboardsmall" )
		header.Ping:SetTextInset( 2, 0 )
		header.Ping:SetTextColor( header_clr )
		header.Ping:SetWidth( 115 )
		header.Ping:SetContentAlignment( 6 )
		header.Ping:Dock( RIGHT )
		
		header.Score = header:Add( "DLabel" )
		header.Score:SetFont( "hvh_scoreboardsmall" )
		header.Score:SetTextInset( 2, 0 )
		header.Score:SetTextColor( header_clr )
		header.Score:SetWidth( 50 )
		header.Score:SetContentAlignment( 6 )
		header.Score:Dock( RIGHT )
		
	end
	
	header.TeamInfo = header:Add( "DLabel" )
	header.TeamInfo:SetFont( "hvh_scoreboardsmall" )
	header.TeamInfo:SetTextInset( 2, 0 )
	header.TeamInfo:SetTextColor( header_clr )
	header.TeamInfo:SetContentAlignment( 4 )
	header.TeamInfo:Dock( FILL )
	
	header.Paint = function( self, w, h )
	
		surface.SetDrawColor( divider_clr )
		surface.DrawRect( 1, h - 2, w - 2, 1 )
		
	end
	
	header.Think = function( self )
	
		local numPlayers
	
		if ( self.TeamIndex == TEAM_SPECTATOR ) then
		
			numPlayers = NumSpecPlayers()
		
		else
		
			local teamLatency = TeamLatency( self.TeamIndex )
		
			if ( self.NumPing == nil || self.NumPing != teamLatency ) then
			
				self.NumPing = teamLatency
				self.Ping:SetText( ( self.NumPing == 0 ) && "" || self.NumPing )
				
			end
			
			if ( self.NumScore == nil || self.NumScore != team.GetScore( self.TeamIndex ) ) then
			
				self.NumScore = team.GetScore( self.TeamIndex )
				self.Score:SetText( self.NumScore )
				
			end
			
			numPlayers = team.NumPlayers( self.TeamIndex )
			
		end
		
		if ( self.NumPlayers == nil || self.NumPlayers != numPlayers ) then
		
			self.NumPlayers = numPlayers
			self.TeamInfo:SetText( team.GetName( self.TeamIndex ) .. "    -    " .. self.NumPlayers .. " player" .. ( ( self.NumPlayers == 1 ) && "" || "s" ) )
			
		end
		
	end
	
	header:Think()
	
	local section = pnl:Add( "Panel" )
	section:SetHeight( 0 )
	section:DockMargin( 0, 0, 0, 8 )
	section:Dock( TOP )
	section.Header = header
	section.TeamIndex = teamindex

	section.OnChildAdded   = function( self, child ) self:InvalidateLayout() end
	section.OnChildRemoved = function( self, child ) self:InvalidateLayout() end
	
	section.PerformLayout = function( self, w, h )

		if ( self.TeamIndex == TEAM_SPECTATOR ) then self.Header:SetVisible( self:HasChildren() ) end

		self:SizeToChildren( false, true )
		self:InvalidateParent()
		
	end
	
	section.Think = function( self )
	
		for id, pl in ipairs( player.GetAll() ) do

			if ( IsValid( pl.ScoreEntry ) ) then continue end

			if ( self.TeamIndex == TEAM_SPECTATOR ) then
			
				if ( IsSpecTeam( pl:Team() ) ) then
					pl.ScoreEntry = AddPlayerLine( self, pl, true )
				end
				
			elseif ( self.TeamIndex == pl:Team() ) then
			
				pl.ScoreEntry = AddPlayerLine( self, pl, false )
				
			end

		end
		
	end
	
	section:Think()
	
end

local function CreateScoreboard()

	local scoreboard = vgui.Create( "EditablePanel" )
	scoreboard:SetMinimumSize( nil, 450 )
	scoreboard:SetSize( 650, 450 )
	scoreboard:Center()
	scoreboard:DockPadding( 5, 5, 5, 5 )
	
	scoreboard.ServerName = scoreboard:Add( "DLabel" )
	scoreboard.ServerName:SetSize( 312, 30 )
	scoreboard.ServerName:SetPos( 3, 2 )
	scoreboard.ServerName:SetFont( "hvh_scoreboard" )
	scoreboard.ServerName:SetTextColor( clr_text )
	scoreboard.ServerName:SetContentAlignment( 7 )

	scoreboard.Paint = function( self, w, h )

		DrawRoundedBackground( w, h )
		DrawRoundedBorder( w, h )
		
	end

	scoreboard.PerformLayout = function( self, w, h )

		self:SizeToChildren( false, true )
		self:Center()
		
	end
	
	scoreboard.Think = function( self )

		self.ServerName:SetText( GetHostName() )
		
	end
	
	scoreboard:Think()
	
	AddHeader( scoreboard )
	AddSection( scoreboard, TEAM_TERRORIST )
	AddSection( scoreboard, TEAM_CT )
	AddSection( scoreboard, TEAM_SPECTATOR )

	return scoreboard
	
end

function GM:ScoreboardShow()

	if ( IsValid( self.TeamSelectPnl ) ) then
		self.TeamSelectPnl:Hide()
	end

	if ( IsValid( self.WeaponSelectPnl ) ) then
		self.WeaponSelectPnl:Hide()
	end

	if ( !IsValid( self.ScoreboardPnl ) ) then
		self.ScoreboardPnl = CreateScoreboard()
	end

	if ( IsValid( self.ScoreboardPnl ) ) then
	
		self.ScoreboardPnl:Show()
		self.ScoreboardPnl:MakePopup()
		self.ScoreboardPnl:SetMouseInputEnabled( false )
		self.ScoreboardPnl:SetKeyboardInputEnabled( false )
		
	end

end

function GM:ScoreboardHide()

	if ( IsValid( self.ScoreboardPnl ) ) then
		self.ScoreboardPnl:Hide()
	end

	if ( IsValid( self.TeamSelectPnl ) ) then
	
		self.TeamSelectPnl:Show()
		self.TeamSelectPnl:MakePopup()
		self.TeamSelectPnl:SetKeyboardInputEnabled( false )
		
	end

	if ( IsValid( self.WeaponSelectPnl ) ) then
	
		self.WeaponSelectPnl:Show()
		self.WeaponSelectPnl:MakePopup()
		self.WeaponSelectPnl:SetKeyboardInputEnabled( false )
		
	end

end