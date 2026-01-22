local sv_unhide_head_detect = CreateConVar( "sv_unhide_head_detect", "2.5", FCVAR_REPLICATED )
local sv_unhide_head_reset = CreateConVar( "sv_unhide_head_reset", "0.5", FCVAR_REPLICATED )
local sv_unhide_head_punish = CreateConVar( "sv_unhide_head_punish", "5", FCVAR_REPLICATED )
local sv_jump_boost_gain = CreateConVar( "sv_jump_boost_gain", "0", FCVAR_REPLICATED )
local sv_jump_boost_dynamic = CreateConVar( "sv_jump_boost_dynamic", "0", FCVAR_REPLICATED )
local sv_jump_boost_min_speed = CreateConVar( "sv_jump_boost_min_speed", "0", FCVAR_REPLICATED )
local sv_jump_boost_max_speed = CreateConVar( "sv_jump_boost_max_speed", "5000", FCVAR_REPLICATED )
local sv_jump_boost_cooldown = CreateConVar( "sv_jump_boost_cooldown", "0.5", FCVAR_REPLICATED )

function GM:StartCommand( ply, ucmd )

	if ( ply:GetObserverMode() != OBS_MODE_NONE ) then
	
		ucmd:RemoveKey( IN_DUCK )
	
	elseif ( GAMEMODE:IsFreezePeriod() ) then

		ucmd:ClearMovement()
		ucmd:ClearButtons()
	
	end

end

local sv_maxspeed = GetConVar( "sv_maxspeed" )

function GM:Move( ply, mv )

	if ( !ply:IsWalking() ) then

		local weapon = ply:GetActiveWeapon()
		
		if ( IsValid( weapon ) && weapon.GetMaxSpeed ) then
		
			local maxspeed = weapon:GetMaxSpeed()
			
			mv:SetMaxClientSpeed( maxspeed )
			
			if ( !( maxspeed > 0 && maxspeed < sv_maxspeed:GetFloat() ) ) then
				maxspeed = sv_maxspeed:GetFloat()
			end
			
			if ( ply:Crouching() && ply:GetGroundEntity() != NULL ) then
				maxspeed = maxspeed * ply:GetCrouchedWalkSpeed()
			end
			
			mv:SetMaxSpeed( maxspeed )

		end
		
	end
	
	if ( sv_unhide_head_detect:GetFloat() > 0 ) then
 
		ply.NextJumpTick = ply:GetNW2Int( "NextJumpTick" )
		ply.NextJumpTickAcc = ply:GetNW2Int( "NextJumpTickAcc" )
		ply.NextJumpTickRem = ply:GetNW2Int( "NextJumpTickRem" )
	 
		if ( ply.NextJumpTickRem >= 0 ) then
	 
			if ( ply:Crouching() && !ply:OnGround() ) then
	 
				local distance = select( 2, ply:GetHull() ).z + select( 2, ply:GetHullDuck() ).z
				local groundTrace = util.TraceHull( { start = mv:GetOrigin(), endpos = Vector( mv:GetOrigin().x, mv:GetOrigin().y, mv:GetOrigin().z - distance ), mins = Vector( -16, -16 ), maxs = Vector( 16, 16 ), mask = MASK_SHOT, collisiongroup = COLLISION_GROUP_WORLD } )
	 
				if ( groundTrace.HitWorld ) then
	 
					local ceilTrace = util.TraceHull( { start = groundTrace.HitPos, endpos = Vector( groundTrace.HitPos.x, groundTrace.HitPos.y, groundTrace.HitPos.z + distance ), mins = Vector( -16, -16 ), maxs = Vector( 16, 16 ), mask = MASK_SHOT, collisiongroup = COLLISION_GROUP_WORLD } )
	 
					if ( ceilTrace.HitWorld ) then
						ply.NextJumpTick = ply.NextJumpTickAcc + math.floor( 0.5 + sv_unhide_head_reset:GetFloat() / engine.TickInterval() )
					end
	 
				end
	 
			end
	 
			if ( ply.NextJumpTick > ply.NextJumpTickAcc ) then
				ply.NextJumpTickRem = ply.NextJumpTickRem + 1
			else
				ply.NextJumpTickRem = 0
			end
	 
			if ( ply.NextJumpTickRem >= math.floor( 0.5 + sv_unhide_head_detect:GetFloat() / engine.TickInterval() ) ) then
				ply.NextJumpTickRem = -math.floor( 0.5 + sv_unhide_head_punish:GetFloat() / engine.TickInterval() )
			end
	 
		end
	 
		if ( ply.NextJumpTickRem < 0 ) then
	 
			mv:SetButtons( 0 )
			ply.NextJumpTickRem = ply.NextJumpTickRem + 1
	 
		end
	 
		ply:SetNW2Int( "NextJumpTick", ply.NextJumpTick )
		ply:SetNW2Int( "NextJumpTickAcc", ply.NextJumpTickAcc + 1 )
		ply:SetNW2Int( "NextJumpTickRem", ply.NextJumpTickRem )
	 
	end

end

local JUMPING = nil

function GM:SetupMove( ply, mv, cmd )

	if ( bit.band( mv:GetButtons(), IN_JUMP ) != 0 && bit.band( mv:GetOldButtons(), IN_JUMP ) == 0 && ply:OnGround() ) then
		JUMPING = true
	end

end

function GM:FinishMove( ply, mv )

	if ( sv_jump_boost_gain:GetFloat() > 0 ) then
		
		ply.JumpBoostCooldown = ply:GetNW2Int( "JumpBoostCooldown" )
		
		if ( ply.JumpBoostCooldown >= 0 && JUMPING ) then

			local vel = mv:GetVelocity()
			local spd = vel:Length2D()

			if ( spd >= sv_jump_boost_min_speed:GetFloat() && spd < sv_jump_boost_max_speed:GetFloat() ) then
			
				local gain = sv_jump_boost_gain:GetFloat()
				
				if ( sv_jump_boost_dynamic:GetBool() ) then
					gain = gain * ( sv_jump_boost_max_speed:GetFloat() - spd ) / ( sv_jump_boost_max_speed:GetFloat() - sv_jump_boost_min_speed:GetFloat() )
				end
				
				vel.z = 0
				vel:Normalize()
				vel = vel * math.min( gain, sv_jump_boost_max_speed:GetFloat() - spd )
				mv:SetVelocity( mv:GetVelocity() + vel )
				ply.JumpBoostCooldown = -math.floor( 0.5 + sv_jump_boost_cooldown:GetFloat() / engine.TickInterval() )
				
			end
			
		end

		if ( ply.JumpBoostCooldown < 0 ) then
			ply.JumpBoostCooldown = ply.JumpBoostCooldown + 1
		end
		
		ply:SetNW2Int( "JumpBoostCooldown", ply.JumpBoostCooldown )
		
	end

	JUMPING = nil

end