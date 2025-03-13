CreateConVar( "mp_damage_headshot_only", "0", { FCVAR_REPLICATED, FCVAR_NOTIFY } )
local sv_jump_boost = CreateConVar( "sv_jump_boost", "0", { FCVAR_REPLICATED, FCVAR_NOTIFY } )

function GM:StartCommand( ply, ucmd )

	if ( GAMEMODE:IsFreezePeriod() && ply:GetObserverMode() == OBS_MODE_NONE ) then
	
		ucmd:ClearMovement()
		ucmd:ClearButtons()
	
	end

end

local JUMPING = nil

function GM:SetupMove( ply, mv, cmd )

	if ( bit.band( mv:GetButtons(), IN_JUMP ) != 0 && bit.band( mv:GetOldButtons(), IN_JUMP ) == 0 && ply:OnGround() ) then
		JUMPING = true
	end

end

function GM:FinishMove( ply, mv )

	local jump_boost = sv_jump_boost:GetFloat()

	if ( JUMPING && jump_boost > 0 ) then

		local addVel = mv:GetVelocity() 
		
		addVel.z = 0
		
		addVel:Normalize()
		
		addVel = addVel * jump_boost
		
		mv:SetVelocity( mv:GetVelocity() + addVel )
		
	end

	JUMPING = nil

end
