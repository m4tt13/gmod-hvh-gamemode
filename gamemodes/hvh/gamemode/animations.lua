local mp_vaulting_anim = CreateConVar( "mp_vaulting_anim", "1", FCVAR_REPLICATED )
local mp_typing_anim = CreateConVar( "mp_typing_anim", "1", FCVAR_REPLICATED )

function GM:HandlePlayerVaulting( ply, velocity, plyTable )

	if ( !mp_vaulting_anim:GetBool() ) then return end
	
	return self.BaseClass.HandlePlayerVaulting( self, ply, velocity, plyTable )

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
	elseif ( mp_vaulting_anim:GetBool() && !ply:IsOnGround() && len >= 1000 ) then
		rate = 0.1
	end

	ply:SetPlaybackRate( rate )

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

		if ( Vehicle:GetClass() == "prop_vehicle_prisoner_pod" ) then
			-- No steering in seats (when overridden to use jeep animations)
			-- So that it doesn't stick to random value it had before
			steer = 0

			-- Fix weapon aiming poseparam in vehicle
			ply:SetPoseParameter( "aim_yaw", math.NormalizeAngle( ply:GetAimVector():Angle().y - Vehicle:GetAngles().y - 90 ) )
		end

		-- Gotta convert from 0..1 (network range) to -1..1 (pose param range) on client
		if ( CLIENT ) then steer = steer * 2 - 1 end
		ply:SetPoseParameter( "vehicle_steer", steer )

	end

	GAMEMODE:GrabEarAnimation( ply )

	-- We only need to do this clientside..
	if ( CLIENT ) then
		GAMEMODE:MouthMoveAnimation( ply )
	end

end

function GM:GrabEarAnimation( ply, plyTable )

	if ( !mp_typing_anim:GetBool() ) then return end

	self.BaseClass.GrabEarAnimation( self, ply, plyTable )

end
