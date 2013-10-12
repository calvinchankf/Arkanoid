--Name : Chan Kin Fung
--SID  : 1009634214
--Major: IERG

--add physics engine
local physics = require("physics")
physics.start()
display.setStatusBar( display.HiddenStatusBar)
physics.setGravity(0,0)

--functions declaration (partially only)
local setBrick = {}
local setBall = {}
local setPaddle = {}
local ballTrack = {}

--variables declaration
local ball
local randomNum
local collisionTime = 0
local paddle
local bricks = {}

local wallTop = display.newRect(0, 0, display.contentWidth, 0 )
physics.addBody(wallTop, "static", {density = 10, bounce = 1, friction = 0})

local wallLeft = display.newRect(0, 0, 0, display.contentHeight)
physics.addBody(wallLeft, "static", {density = 10, bounce = 1, friction = 0})

local wallRight = display.newRect(320, 0, 0, display.contentHeight)
physics.addBody(wallRight, "static", {density = 10, bounce = 1, friction = 0})

--functions
function setBall()
	ball = display.newCircle(display.contentWidth/2, display.contentHeight-30,10)
	physics.addBody(ball,{density = 10, bounce = 1, friction = 0, radius =10})
	randomNum = math.random (-450, 450)
	ball:setLinearVelocity( randomNum, -math.sqrt(500*500-randomNum*randomNum))
	Runtime:addEventListener('enterFrame', ballTrack)
end

local function onLocalCollision( self, event)
		if ( event.phase == "began" ) then
                self:removeSelf()
				self = nil
				collisionTime=collisionTime+1
        end
end

function setBrick()
for h = 1, 4 do
	bricks[h]={}
	for i = 1, 10 do
		bricks[h][i] = display.newRect(20+28*(i-1), 20+15*(h-1), 26, 13)
		physics.addBody(bricks[h][i], "static", {density = 10, bounce = 1, friction = 0})
		if h==1 then
			bricks[h][i]:setFillColor( 255, 0, 0 )
		else if h==2 then 
			bricks[h][i]:setFillColor( 0, 255, 0 )
		else if h==3 then 
			bricks[h][i]:setFillColor( 0, 0, 255 )
		else bricks[h][i]:setFillColor( 255, 255, 0 )
		end end end
		bricks[h][i].collision = onLocalCollision
		bricks[h][i]:addEventListener( "collision", bricks[h][i])
	end
end
end

local function paddleDrag( event )
	local theBall = event.target

	local phase = event.phase
	if "began" == phase then
		display.getCurrentStage():setFocus( theBall )
		theBall.isFocus = true

		theBall.x0 = event.x - theBall.x -- Store initial position
		event.target.bodyType = "kinematic" --"kinematic" to avoid gravitional forces)

	elseif theBall.isFocus then
		if "moved" == phase then
			theBall.x = event.x - theBall.x0
		elseif "ended" == phase or "cancelled" == phase then
			display.getCurrentStage():setFocus( nil )
			theBall.isFocus = false
		end
	end
	return true -- Stop further propagation of touch event!
end

function setPaddle()
	paddle = display.newRoundedRect(display.contentWidth/2-35, display.contentHeight-30, 70, 12,6)
	physics.addBody(paddle, "kinematic", {bounce = 1, friction = 0})
	paddle:addEventListener( "touch", paddleDrag )
end

function ballTrack:enterFrame(event)
	if ((ball.y > display.contentHeight) or (collisionTime == 40))then
		for h = 1, 4 do
			for i = 1, 10 do
					display.remove(bricks[h][i])
					bricks[h][i] = nil
			end
		end
		setBrick() --reset brick 
		ball:removeSelf() --remove and reset the ball 
		ball = nil
		setBall()
		
		paddle:removeSelf()
		paddle = nil
		setPaddle()
		
		collisionTime = 0
	end
end

setBrick()
setBall()
setPaddle()