CreateConVar( "mp_vaulting_anim", "0", FCVAR_REPLICATED )
CreateConVar( "mp_typing_anim", "0", FCVAR_REPLICATED )

function GM:HandlePlayerVaulting( ply, velocity )

	if ( !GetConVar( "mp_vaulting_anim" ):GetBool() ) then return end
	if ( velocity:LengthSqr() < 1000000 ) then return end
	if ( ply:IsOnGround() ) then return end

	ply.CalcIdeal = ACT_MP_SWIM

	return true

end

function GM:UpdateAnimation( ply, velocity, maxseqgroundspeed )

	local len = velocity:Length()
	local movement = 1.0

	if ( len > 0.2 ) then
		movement = ( len / maxseqgroundspeed )
	end

	local rate = math.min( movement, 2 )

	-- if we're under water we want to constantly be swimming..
	if ( ply:WaterLevel() >= 2 ) then
		rate = math.max( rate, 0.5 )
	elseif ( GetConVar( "mp_vaulting_anim" ):GetBool() && !ply:IsOnGround() && len >= 1000 ) then
		rate = 0.1
	end

	ply:SetPlaybackRate( rate )

	-- We only need to do this clientside..
	if ( CLIENT ) then
		if ( ply:InVehicle() ) then
			--
			-- This is used for the 'rollercoaster' arms
			--
			local Vehicle = ply:GetVehicle()
			local Velocity = Vehicle:GetVelocity()
			local fwd = Vehicle:GetUp()
			local dp = fwd:Dot( Vector( 0, 0, 1 ) )

			ply:SetPoseParameter( "vertical_velocity", ( dp < 0 && dp || 0 ) + fwd:Dot( Velocity ) * 0.005 )

			-- Pass the vehicles steer param down to the player
			local steer = Vehicle:GetPoseParameter( "vehicle_steer" )
			steer = steer * 2 - 1 -- convert from 0..1 to -1..1
			if ( Vehicle:GetClass() == "prop_vehicle_prisoner_pod" ) then steer = 0 ply:SetPoseParameter( "aim_yaw", math.NormalizeAngle( ply:GetAimVector():Angle().y - Vehicle:GetAngles().y - 90 ) ) end
			ply:SetPoseParameter( "vehicle_steer", steer )

		end
		
		if ( GetConVar( "mp_typing_anim" ):GetBool() ) then
			GAMEMODE:GrabEarAnimation( ply )
		end
		
		GAMEMODE:MouthMoveAnimation( ply )
	end

end