
local meta = FindMetaTable( "Player" )

if ( !meta ) then return end

function meta:PlaySound( snd )

	net.Start( "HvH_PlaySound" )
		
		net.WriteString( snd )
		
	net.Send( self )

end
