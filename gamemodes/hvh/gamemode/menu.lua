local menu_lines = {}
local valid_items = {}

local MENU_UPDATETIME = 4.0

function Menu_Display( ply )

	if ( !ply.CurrentMenu ) then
		return
	end
	
	if ( CurTime() < ply.CurrentMenu.RefreshTime ) then
		return
	end

	ply.CurrentMenu.RefreshTime = CurTime() + MENU_UPDATETIME
	
	net.Start( "hvh_showmenu" )
	
		net.WriteUInt( #ply.CurrentMenu.MenuLines, 8 )
	
		for _, menu_line in ipairs( ply.CurrentMenu.MenuLines ) do
		
			if ( menu_line.Text ) then
			
				net.WriteBool( true )
		
				if ( menu_line.Item ) then
				
					net.WriteBool( true )
					net.WriteUInt( menu_line.Item, 4 )
				
				else
				
					net.WriteBool( false )
				
				end
				
				net.WriteBool( menu_line.Colored )
				net.WriteString( menu_line.Text )
				
			else
			
				net.WriteBool( false )
			
			end
		
		end
	
	net.Send( ply )
	
end

function Menu_Start()

	menu_lines = {}
	valid_items = {}

end

function Menu_AddLine( text, colored, item )

	if ( item ) then valid_items[item] = true end

	local menu_line = {
	
		Text = text,
		Colored = colored || false,
		Item = item
	
	}

	table.insert( menu_lines, menu_line )

end

function Menu_End( ply, callback )
	
	if ( #menu_lines > 0 ) then
	
		ply.CurrentMenu = {
		
			MenuLines = menu_lines,
			ValidItems = valid_items,
			RefreshTime = CurTime(),
			Callback = callback
		
		}
		
		Menu_Display( ply )

	else
	
		Menu_Close()
	
	end

end

function Menu_Close( ply )

	ply.CurrentMenu = nil

	net.Start( "hvh_showmenu" )
	
		net.WriteUInt( 0, 8 )
	
	net.Send( ply )

end

local function OnMenuSelect( ply, item )

	if ( ply.CurrentMenu && ply.CurrentMenu.Callback && ply.CurrentMenu.ValidItems[item] ) then
		ply.CurrentMenu.Callback( ply, item )
	end

end
concommand.Add( "menuselect", function( pl, cmd, args ) OnMenuSelect( pl, tonumber( args[ 1 ] ) ) end )
