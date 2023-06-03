function GM:HUDDrawTargetID()

	local ply 	= LocalPlayer()
	local mode 	= ply:GetObserverMode()
	
	if ( mode == OBS_MODE_DEATHCAM || mode == OBS_MODE_CHASE ) then
		return
	end

	if ( mode == OBS_MODE_IN_EYE ) then
	
		local obsTarget = ply:GetObserverTarget()
	
		if ( IsValid( obsTarget ) && obsTarget:IsPlayer() ) then
			ply = obsTarget
		end
		
	end
	
	local tr = util.GetPlayerTrace( ply )
	local trace = util.TraceLine( tr )
	if ( !trace.Hit ) then return end
	if ( !trace.HitNonWorld ) then return end
	
	local text = "ERROR"
	local font = "TargetID"
	
	if ( trace.Entity:IsPlayer() ) then
		text = trace.Entity:Nick()
	else
		return
	end
	
	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )
	
	local MouseX, MouseY = gui.MousePos()
	
	if ( MouseX == 0 && MouseY == 0 ) then
	
		MouseX = ScrW() / 2
		MouseY = ScrH() / 2
	
	end
	
	local x = MouseX
	local y = MouseY
	
	x = x - w / 2
	y = y + 30
	
	draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0, 120 ) )
	draw.SimpleText( text, font, x + 2, y + 2, Color( 0, 0, 0, 50 ) )
	draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )
	
	y = y + h + 5
	
	local text = trace.Entity:Health() .. "%"
	local font = "TargetIDSmall"
	
	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )
	local x = MouseX - w / 2
	
	draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0, 120 ) )
	draw.SimpleText( text, font, x + 2, y + 2, Color( 0, 0, 0, 50 ) )
	draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )

end
