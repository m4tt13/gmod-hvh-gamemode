surface.CreateFont( "hvh_killicon", {

	font = "csd",
	size = 64,
	weight = 0,
	antialias = true,
	additive = true

} )

local hud_deathnotice_time = CreateConVar( "hud_deathnotice_time", "6", FCVAR_REPLICATED, "Amount of time to show death notice (kill feed) for" )
local cl_drawhud = GetConVar( "cl_drawhud" )

local Color_Icon = Color( 255, 80, 0, 255 )
local NPC_Color_Enemy = Color( 250, 50, 50, 255 )
local NPC_Color_Friendly = Color( 50, 200, 50, 255 )

killicon.AddFont( "headshot", "hvh_killicon", "D", Color_Icon )
killicon.AddFont( "default", "hvh_killicon", "C", Color_Icon )
killicon.AddAlias( "suicide", "default" )

local Deaths = {}

local function getDeathColor( teamID, target )

	if ( teamID == -1 ) then
		return table.Copy( NPC_Color_Enemy )
	end

	if ( teamID == -2 ) then
		return table.Copy( NPC_Color_Friendly )
	end

	return table.Copy( team.GetColor( teamID ) )

end

function GM:AddDeathNotice( attacker, team1, inflictor, victim, team2, flags )

	if ( !victim ) then return end
	if ( inflictor == "suicide" ) then attacker = nil end

	local Death = {}
	Death.time		= CurTime()

	Death.left		= attacker
	Death.right		= victim
	Death.icon		= inflictor
	Death.flags		= flags

	Death.color1	= getDeathColor( team1, Death.left )
	Death.color2	= getDeathColor( team2, Death.right )

	table.insert( Deaths, Death )

end

DEATH_NOTICE_HEADSHOT = 4

local function DrawDeath( x, y, death, time )

	local fadeout = ( death.time + time ) - CurTime()

	local alpha = math.Clamp( fadeout * 255, 0, 255 )
	death.color1.a = alpha
	death.color2.a = alpha
	
	draw.SimpleText( death.right, "ChatFont", x, y, death.color2, TEXT_ALIGN_RIGHT )
	
	x = x - surface.GetTextSize( death.right )
	
	if ( bit.band( death.flags, DEATH_NOTICE_HEADSHOT ) != 0 ) then 
	
		x = x - killicon.GetSize( "headshot" )
	
		killicon.Render( x, y, "headshot", alpha, true )
		
	end
	
	x = x - killicon.GetSize( death.icon )
	
	killicon.Render( x, y, death.icon, alpha, true )

	if ( death.left ) then
		draw.SimpleText( death.left, "ChatFont", x, y, death.color1, TEXT_ALIGN_RIGHT )
	end

	return y + 40

end

function GM:DrawDeathNotice()

	if ( cl_drawhud:GetInt() == 0 ) then return end

	local time = hud_deathnotice_time:GetFloat()
	local reset = Deaths[1] != nil

	local x = ScrW() - 15
	local y = 15
	
	local ply 	= LocalPlayer()
	local mode 	= ply:GetObserverMode()
	
	if ( mode != OBS_MODE_NONE ) then
		y = y + 60
	end

	for k, Death in ipairs( Deaths ) do

		if ( Death.time + time > CurTime() ) then

			if ( Death.lerp ) then
			
				x = x * 0.3 + Death.lerp.x * 0.7
				y = y * 0.3 + Death.lerp.y * 0.7
				
			end

			Death.lerp = Death.lerp or {}
			Death.lerp.x = x
			Death.lerp.y = y

			y = DrawDeath( math.floor( x ), math.floor( y ), Death, time )
			reset = false

		end

	end

	if ( reset ) then
		Deaths = {}
	end

end
