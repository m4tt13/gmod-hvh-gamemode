surface.CreateFont( "HvH_KillIcon", {

	font = "csd",
	size = 50,
	weight = 0,
	antialias = true,
	additive = true

} )

local Color_Icon = Color( 255, 80, 0, 255 )
local NPC_Color = Color( 250, 50, 50, 255 )

killicon.AddFont( "headshot", "HvH_KillIcon", "D", Color_Icon )

local Deaths = {}

local function RecvPlayerKilledByPlayer()

	local victim	= net.ReadEntity()
	local inflictor	= net.ReadString()
	local attacker	= net.ReadEntity()
	local headshot	= net.ReadBool()

	if ( !IsValid( attacker ) ) then return end
	if ( !IsValid( victim ) ) then return end

	GAMEMODE:AddDeathNotice( attacker:Name(), attacker:Team(), inflictor, victim:Name(), victim:Team(), headshot )

end
net.Receive( "PlayerKilledByPlayer", RecvPlayerKilledByPlayer )

local function RecvPlayerKilledSelf()

	local victim = net.ReadEntity()
	if ( !IsValid( victim ) ) then return end
	GAMEMODE:AddDeathNotice( nil, 0, "suicide", victim:Name(), victim:Team(), false )

end
net.Receive( "PlayerKilledSelf", RecvPlayerKilledSelf )

local function RecvPlayerKilled()

	local victim	= net.ReadEntity()
	if ( !IsValid( victim ) ) then return end
	local inflictor	= net.ReadString()
	local attacker	= "#" .. net.ReadString()

	GAMEMODE:AddDeathNotice( attacker, -1, inflictor, victim:Name(), victim:Team(), false )

end
net.Receive( "PlayerKilled", RecvPlayerKilled )

local function RecvPlayerKilledNPC()

	local victimtype = net.ReadString()
	local victim	= "#" .. victimtype
	local inflictor	= net.ReadString()
	local attacker	= net.ReadEntity()

	if ( !IsValid( attacker ) ) then return end

	GAMEMODE:AddDeathNotice( attacker:Name(), attacker:Team(), inflictor, victim, -1, false )

	local bIsLocalPlayer = ( IsValid(attacker) && attacker == LocalPlayer() )

	local bIsEnemy = IsEnemyEntityName( victimtype )
	local bIsFriend = IsFriendEntityName( victimtype )

	if ( bIsLocalPlayer && bIsEnemy ) then
		achievements.IncBaddies()
	end

	if ( bIsLocalPlayer && bIsFriend ) then
		achievements.IncGoodies()
	end

	if ( bIsLocalPlayer && ( !bIsFriend && !bIsEnemy ) ) then
		achievements.IncBystander()
	end

end
net.Receive( "PlayerKilledNPC", RecvPlayerKilledNPC )

local function RecvNPCKilledNPC()

	local victim	= "#" .. net.ReadString()
	local inflictor	= net.ReadString()
	local attacker	= "#" .. net.ReadString()

	GAMEMODE:AddDeathNotice( attacker, -1, inflictor, victim, -1, false )

end
net.Receive( "NPCKilledNPC", RecvNPCKilledNPC )

function GM:AddDeathNotice( Attacker, team1, Inflictor, Victim, team2, headshot )

	local Death = {}
	Death.time		= CurTime()

	Death.left		= Attacker
	Death.right		= Victim
	Death.icon		= Inflictor
	Death.headshot	= headshot

	if ( team1 == -1 ) then Death.color1 = table.Copy( NPC_Color )
	else Death.color1 = table.Copy( team.GetColor( team1 ) ) end

	if ( team2 == -1 ) then Death.color2 = table.Copy( NPC_Color )
	else Death.color2 = table.Copy( team.GetColor( team2 ) ) end

	if ( Death.left == Death.right ) then
	
		Death.left = nil
		Death.icon = "suicide"
		
	end

	table.insert( Deaths, Death )

end

local function DrawDeath( x, y, death, hud_deathnotice_time )

	local fadeout = ( death.time + hud_deathnotice_time ) - CurTime()

	local alpha = math.Clamp( fadeout * 255, 0, 255 )
	death.color1.a = alpha
	death.color2.a = alpha

	local maxH = 0
	
	local w, h

	draw.SimpleText( death.right, "ChatFont", x, y, death.color2, TEXT_ALIGN_RIGHT )
	
	w, h = surface.GetTextSize( death.right )
	x = x - w

	maxH = math.max( maxH, h )
	
	if ( death.headshot ) then
	
		w, h = killicon.GetSize( "headshot" )
		x = x - ( w / 2 )
		
		maxH = math.max( maxH, h )
	
		killicon.Draw( x, y, "headshot", alpha )
		x = x - ( w / 2 )
		
	end
	
	w, h = killicon.GetSize( death.icon )
	x = x - ( w / 2 )
	
	maxH = math.max( maxH, h )
	
	killicon.Draw( x, y, death.icon, alpha )
	x = x - ( w / 2 )
	
	if ( death.left ) then
	
		draw.SimpleText( death.left, "ChatFont", x, y, death.color1, TEXT_ALIGN_RIGHT )
		
		w, h = surface.GetTextSize( death.left )
		x = x - w
		
		maxH = math.max( maxH, h )
		
	end

	return ( y + maxH * 0.70 )

end

function GM:DrawDeathNotice()

	if ( GetConVarNumber( "cl_drawhud" ) == 0 ) then return end

	local hud_deathnotice_time = GetConVar( "hud_deathnotice_time" ):GetFloat()

	x = ScrW() - 15
	y = 15
	
	local ply 	= LocalPlayer()
	local mode 	= ply:GetObserverMode()
	
	if ( mode != OBS_MODE_NONE ) then
		y = y + 60
	end

	for k, Death in pairs( Deaths ) do

		if ( Death.time + hud_deathnotice_time > CurTime() ) then

			if ( Death.lerp ) then
			
				x = x * 0.3 + Death.lerp.x * 0.7
				y = y * 0.3 + Death.lerp.y * 0.7
				
			end

			Death.lerp = Death.lerp or {}
			Death.lerp.x = x
			Death.lerp.y = y

			y = DrawDeath( x, y, Death, hud_deathnotice_time )

		end

	end

	for k, Death in pairs( Deaths ) do
	
		if ( Death.time + hud_deathnotice_time > CurTime() ) then
			return
		end
		
	end

	Deaths = {}

end
