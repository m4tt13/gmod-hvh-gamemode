local menu_panel = nil
local menu_lines = {}
local valid_items = {}

local clr_item 	= Color( 255, 167, 42, 255 )
local clr_menu 	= Color( 233, 208, 173, 255 )
local clr_bg 	= Color( 0, 0, 0, 100 )

local key2item = {

	[KEY_1] = 1,
	[KEY_2] = 2,
	[KEY_3] = 3,
	[KEY_4] = 4,
	[KEY_5] = 5,
	[KEY_6] = 6,
	[KEY_7] = 7,
	[KEY_8] = 8,
	[KEY_9] = 9,
	[KEY_0] = 10,
	
}

local item2num = {

	"1. ", 
	"2. ", 
	"3. ", 
	"4. ", 
	"5. ", 
	"6. ", 
	"7. ", 
	"8. ", 
	"9. ", 
	"0. "
	
}

function Menu_TakesInput()

	return ( IsValid( menu_panel ) && menu_panel.TakesInput )

end

local function RemoveMenuPnl()

	if ( IsValid( menu_panel ) ) then
		
		menu_panel:Remove() 
		menu_panel = nil 
		
	end

end

function Menu_HandleKeyInput( key )

	if ( !IsValid( menu_panel ) || !menu_panel.TakesInput ) then
		return
	end
	
	local item = key2item[key]
	
	if ( item && valid_items[item] ) then
	
		menu_panel.TakesInput = false
		menu_panel:AlphaTo( 0, 0.5, 0.5, function() RemoveMenuPnl() end )
		
		for k, v in ipairs( menu_panel:GetChildren() ) do
		
			if ( v.Colored && v.Item == item ) then
				v:AlphaTo( 255, 0.5 )
			else
				v:AlphaTo( 0, 0.5 )
			end
		
		end
		
		RunConsoleCommand( "menuselect", item )
	
	end

end

local function OpenMenu()

	local animate = true

	if ( IsValid( menu_panel ) ) then 

		menu_panel:Remove() 
		animate = false
		
	end
	
	menu_panel = vgui.Create( "EditablePanel" )
	menu_panel.TakesInput = true
	menu_panel.Paint = function( self, w, h )

		draw.RoundedBox( 5, 0, 0, w, h, clr_bg )
		
	end
	
	local height = 10
	local width = 0
	local h_step = draw.GetFontHeight( "hvh_menu" )
	
	for _, menu_line in ipairs( menu_lines ) do
	
		if ( menu_line.Text ) then
		
			local line = menu_panel:Add( "DLabel" )
			line:SetFont( "hvh_menu" )
			line:SetTextColor( menu_line.Colored && clr_item || clr_menu )
			line:SetText( ( item2num[ menu_line.Item ] || "" ) .. menu_line.Text )
			line:SizeToContentsX()
			line:SetHeight( h_step )
			line:SetPos( 10, height )
			
			if ( menu_line.Colored ) then
				line:SetAlpha( 200 )
			end
			
			line.Item = menu_line.Item
			line.Colored = menu_line.Colored

			width = math.max( width, line:GetWide() )
			
		end
		
		height = height + h_step
		
	end

	menu_panel:SetSize( width + 20, height + 10 )
	menu_panel:SetX( 15 )
	menu_panel:CenterVertical()
	
	if ( animate ) then
	
		menu_panel:SetAlpha( 0 )
		menu_panel:AlphaTo( 255, 0.1 )

	end

end

local function CloseMenu()

	if ( !IsValid( menu_panel ) || !menu_panel.TakesInput ) then
		return
	end
	
	menu_panel.TakesInput = false
	menu_panel:AlphaTo( 0, 0.5, 0.5, function() RemoveMenuPnl() end )
	
	for k, v in ipairs( menu_panel:GetChildren() ) do
		v:AlphaTo( 0, 0.5 )
	end

end

local function RecvShowMenu()

	menu_lines = {}
	valid_items = {}

	local num_lines = net.ReadUInt( 8 )
	
	if ( num_lines > 0 ) then
	
		for i = 1, num_lines do
		
			local menu_line = {}
		
			local empty = !net.ReadBool()
			
			if ( !empty ) then
			
				local selectable = net.ReadBool()
				
				if ( selectable ) then
				
					menu_line.Item = net.ReadUInt( 4 )
					valid_items[ menu_line.Item ] = true

				end
				
				menu_line.Colored = net.ReadBool()
				menu_line.Text = net.ReadString()
			
			end

			table.insert( menu_lines, menu_line )
			
		end
		
		OpenMenu()
		
	else
	
		CloseMenu()
	
	end

end
net.Receive( "hvh_showmenu", RecvShowMenu )