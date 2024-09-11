local votemap_enabled = CreateConVar( "votemap_enabled", "1" )
local votemap_needed = CreateConVar( "votemap_needed", "0.60", FCVAR_NONE, "Percentage of votes needed to change the map (Def 60%).", 0.05, 1.0 )
local votemap_minplayers = CreateConVar( "votemap_minplayers", "0", FVCAR_NONE, "Number of players required before VoteMap will be enabled.", 0 )
local votemap_initialdelay = CreateConVar( "votemap_initialdelay", "30.0", FCVAR_NONE, "Time (in seconds) before first VoteMap can be held.", 0 )

local maplist = {}
local votemap_allowed = true

function VoteMap_Init()

	local file = file.Open( "cfg/votemaplist.txt", "r", "MOD" )
	
	if ( file ) then
	
		while ( !file:EndOfFile() ) do
			
			local line = string.Trim( file:ReadLine() )
			
			if ( line != "" && string.sub( line, 1, 2 ) != "//" && line != game.GetMap() ) then
			
				local map = {
				
					Name = line,
					Votes = 0
				
				}
				
				local index = table.insert( maplist, map )
				
				maplist[ index ].Index = index
			
			end

		end
		
		file:Close()
	
	end

	timer.Simple( votemap_initialdelay:GetFloat(), function() votemap_allowed = true end )
	
end

local function ChangeMap( name )

	votemap_allowed = false
	
	PrintMessage( HUD_PRINTTALK, Format( "[VoteMap] Changing map to %s...", name ) )
	
	timer.Simple( 5.0, function() RunConsoleCommand( "changelevel", name ) end )
	
end

local function SortMapList()

	table.sort( maplist, function( a, b ) 
	
		if ( a.Votes != b.Votes ) then
			return a.Votes > b.Votes
		end
	
		return a.Index < b.Index
	
	end )

end

function VoteMap_OnPlayerDisconnected( ply )

	if ( ply.VotedMap ) then

		local map = ply.VotedMap
		
		map.Votes = map.Votes - 1
		
		SortMapList()
		
		ply.VotedMap = nil
		
	end
	
	if ( !votemap_enabled:GetBool() ) then
		return
	end
	
	if ( !votemap_allowed ) then
		return
	end
	
	local voters = #player.GetHumans()
	
	if ( !ply:IsBot() ) then
		voters = voters - 1
	end
	
	if ( voters < 1 ) then
		return
	end
	
	local votes_needed = math.ceil( voters * votemap_needed:GetFloat() )
	
	for k, v in ipairs( maplist ) do
	
		if ( v.Votes >= votes_needed ) then
			
			ChangeMap( v.Name )
			break
			
		end

	end

end

local function VotingAllowed( ply )

	if ( !votemap_enabled:GetBool() ) then
	
		ply:ChatPrint( "[VoteMap] Voting is disabled.")
		return false
	
	end

	if ( !votemap_allowed ) then
	
		ply:ChatPrint( "[VoteMap] Voting is not allowed yet.")
		return false
		
	end
	
	if ( #player.GetHumans() < votemap_minplayers:GetInt() ) then
	
		ply:ChatPrint( "[VoteMap] The minimal number of players required has not been met.")
		return false
		
	end
	
	return true

end

local snd_button_press1 = Sound( "buttons/button14.wav" )
local snd_button_press2 = Sound( "buttons/combine_button7.wav" )

local ShowMenu = nil

local function HandleMenuItem( ply, item )

	if ( item >= 1 && item <= 7 ) then
	
		if ( VotingAllowed( ply ) ) then
	
			if ( ply.VotedMap ) then
			
				local old_map = ply.VotedMap
				
				old_map.Votes = old_map.Votes - 1
				
			end
			
			local map = ply.DisplayedMapList[ item ]

			map.Votes = map.Votes + 1
			
			SortMapList()
			
			ply.VotedMap = map
			
			local votes_needed = math.ceil( #player.GetHumans() * votemap_needed:GetFloat() )

			PrintMessage( HUD_PRINTTALK, Format( "[VoteMap] %s wants to change map to %s (%i/%i).", ply:Name(), map.Name, map.Votes, votes_needed ) )

			if ( map.Votes >= votes_needed ) then
				ChangeMap( map.Name )
			end
		
		end

		ply:PlaySound( snd_button_press1 )
		
		Menu_Close( ply )

	elseif ( item == 8 ) then

		ply:PlaySound( snd_button_press1 )

		ShowMenu( ply, ply.MenuSection - 1 )

	elseif ( item == 9 ) then

		ply:PlaySound( snd_button_press1 )

		ShowMenu( ply, ply.MenuSection + 1 )
	
	elseif ( item == 10 ) then
	
		ply:PlaySound( snd_button_press2 )
	
		Menu_Close( ply )
	
	end

end

ShowMenu = function( ply, section )

	ply.MenuSection = section
	ply.DisplayedMapList = {}
	
	Menu_Start()
	
		Menu_AddLine( "[VoteMap] Map List:" )
	
		local mapcount = #maplist
		local start_index = ( section * 7 ) - 6
		local end_index = math.min( start_index + 6, mapcount )
		local votes_needed = math.ceil( #player.GetHumans() * votemap_needed:GetFloat() )
		local item = 1

		for i = start_index, end_index do

			local map = maplist[ i ]

			if ( ply.VotedMap == map ) then
				Menu_AddLine( Format( "%i. %s (%i/%i)", item, map.Name, map.Votes, votes_needed ) )
			else
				Menu_AddLine( Format( "%s (%i/%i)", map.Name, map.Votes, votes_needed ), true, item )
			end
			
			table.insert( ply.DisplayedMapList, item, map )
			
			item = item + 1
			
		end
		
		for i = item, 7 do
			Menu_AddLine()
		end
		
		Menu_AddLine()
		
		if ( start_index > 1 ) then
			Menu_AddLine( "Previous", true, 8 )
		else
			Menu_AddLine()
		end

		if ( ( start_index + 7 ) <= mapcount ) then
			Menu_AddLine( "Next", true, 9 )
		else
			Menu_AddLine()
		end

		Menu_AddLine( "Exit", false, 10 )
		
	Menu_End( ply, HandleMenuItem )
	
end

function VoteMap_ShowMenu( ply )

	if ( #maplist < 1 ) then
		return
	end

	if ( !VotingAllowed( ply ) ) then
		return
	end
	
	ShowMenu( ply, 1 )
	
end
