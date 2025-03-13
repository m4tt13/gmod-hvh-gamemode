
if ( !util ) then return end

function util.ColorizeText( ... )

	local str = ""

   	for k, v in ipairs( { ... } ) do
	
		if ( isstring( v ) ) then
			str = str .. v
		elseif ( IsColor( v ) ) then
			str = str .. Format( "\x01%02x%02x%02x", v.r, v.g, v.b )
		else
			error( "bad argument #" .. k .. " to 'ColorizeText' (string or Color expected, got " .. type( v ) .. ")" )
		end
		
	end
	
	return str
   
end

if SERVER then

	function util.PlaySound( snd )

		net.Start( "hvh_playsound" )
			
			net.WriteString( snd )
		
		net.Broadcast()

	end
	
end