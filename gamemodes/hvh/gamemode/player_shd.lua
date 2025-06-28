CreateConVar( "mp_damage_headshot_only", "0", FCVAR_REPLICATED, "Determines whether non-headshot hits do any damage." )
CreateConVar( "mp_friendlyfire", "0", { FCVAR_REPLICATED, FCVAR_NOTIFY }, "Allows team members to injure other members of their team." )
local sv_jump_boost = CreateConVar( "sv_jump_boost", "0", FCVAR_REPLICATED )

function GM:StartCommand( ply, ucmd )

	if ( ply:GetObserverMode() != OBS_MODE_NONE ) then
	
		ucmd:RemoveKey( IN_DUCK )
	
	elseif ( GAMEMODE:IsFreezePeriod() ) then

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
