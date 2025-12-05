
local meta = FindMetaTable( "Player" )

if ( !meta ) then return end

function meta:PlaySound( snd )

	net.Start( "hvh_playsound" )
		
		net.WriteString( snd )
		
	net.Send( self )

end

function meta:OutputDamageStatsAndReset()

	if ( self.DamageGivenList ) then

		self:PrintMessage( HUD_PRINTCONSOLE, "Player: " .. self:Name() .. " - Damage Given\n" )
		self:PrintMessage( HUD_PRINTCONSOLE, "-------------------------\n" )
		
		for name, record in pairs( self.DamageGivenList ) do
			self:PrintMessage( HUD_PRINTCONSOLE, Format( "Damage Given to %q - %i in %i hit%s\n", name, record.Damage, record.NumHits, ( ( record.NumHits == 1 ) && "" || "s" ) ) )
		end
		
		self.DamageGivenList = nil
		
	end
	
	if ( self.DamageTakenList ) then

		self:PrintMessage( HUD_PRINTCONSOLE, "Player: " .. self:Name() .. " - Damage Taken\n" )
		self:PrintMessage( HUD_PRINTCONSOLE, "-------------------------\n" )
		
		for name, record in pairs( self.DamageTakenList ) do
			self:PrintMessage( HUD_PRINTCONSOLE, Format( "Damage Taken from %q - %i in %i hit%s\n", name, record.Damage, record.NumHits, ( ( record.NumHits == 1 ) && "" || "s" ) ) )
		end
		
		self.DamageTakenList = nil
		
	end

end