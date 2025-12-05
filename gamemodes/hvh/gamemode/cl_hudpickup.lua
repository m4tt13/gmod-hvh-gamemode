local PickupHistory = {}
local PickupHistorySlot = 1
local PickupHistoryTall = ScrH() * 0.75
local PickupHistoryInset = 50
local PickupHistoryGap = 90
local PickupHistoryColor = Color( 255, 208, 64 )

surface.CreateFont( "hvh_hudpickup", {

	font = "Counter-Strike",
	size = 108,
	weight = 0,
	antialias = true,
	additive = true

} )

function GM:HUDWeaponPickedUp( wep )

	local ply = LocalPlayer()

	if ( IsValid( ply ) && ply:Alive() && IsValid( wep ) && wep.IconLetter ) then

		local pickup = {}
		pickup.time = CurTime()
		pickup.icon = wep.IconLetter
		
		if ( PickupHistoryTall - ( PickupHistoryGap * PickupHistorySlot ) < 0 ) then
			PickupHistorySlot = 1
		end

		PickupHistory[ PickupHistorySlot ] = pickup
		PickupHistorySlot = PickupHistorySlot + 1
		
	else
	
		self.BaseClass.HUDWeaponPickedUp( self, wep )
	
	end

end

local hud_drawhistory_time = GetConVar( "hud_drawhistory_time" )

function GM:HUDDrawPickupHistory()

	local time = hud_drawhistory_time:GetFloat()
	local reset = PickupHistory[1] != nil
	
	local x, y = ScrW() - PickupHistoryInset, PickupHistoryTall

	for k, pickup in ipairs( PickupHistory ) do
	
		local elapsed = ( pickup.time + time ) - CurTime()
	
		if ( elapsed > 0 ) then
		
			PickupHistoryColor.a = math.min( elapsed * 80, 255 )

			draw.SimpleText( pickup.icon, "hvh_hudpickup", x, y - ( PickupHistoryGap * k ), PickupHistoryColor, TEXT_ALIGN_RIGHT )

			reset = false

		end

	end

	if ( reset ) then

		PickupHistory = {}
		PickupHistorySlot = 1
		
	end
	
	self.BaseClass.HUDDrawPickupHistory( self )

end
