----------------------------------------------------------------------------------
--
-- scenetemplate.lua
--
----------------------------------------------------------------------------------

local appGlobals = require("globalData")			-- Load Global data
local utils = require("utilities")					-- Load utilities
local storyboard = require( "storyboard" )			-- Load storyboard
local dunGenDig = require("dungeon_gen_dig")
-- local dog = require("dog")
-- local cat = require("cat")
local scene = storyboard.newScene()

----------------------------------------------------------------------------------
-- 
--	NOTE:
--	
--	Code outside of listener functions (below) will only be executed once,
--	unless storyboard.removeScene() is called.
-- 
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	-----------------------------------------------------------------------------
		
	--	CREATE display objects and add them to 'group' here.
	--	Example use-case: Restore 'group' from previously saved state.
	
	-----------------------------------------------------------------------------
	
	map = {}
map.width = 70
map.height = 30
 
function initMap()
for i = 1, map.width do
map[i] = {}
for j = 1, map.height do
map[i][j] = "."
end
end
end
 
function showMap()
for j = 1, map.height do
for i = 1, map.width do
io.write( map[i][j] )
end
io.write( "\n" )
end
end
 
function isLegal( x, y )
return ( x > 0 and y > 0 and x <= map.width and y <= map.height )
end
 
function wall( x, y, d, door )
local cx, cy = x, y
local wl = {}
 
while isLegal( cx, cy ) do
if map[cx][cy] ~= "." then break end
map[cx][cy] = "#"
cx = cx + d.x
cy = cy + d.y
table.insert( wl, { x=cx, y=cy } )
end
 
if door and #wl > 1 then
local i = math.random( 1, #wl-1 )
map[wl[i].x][wl[i].y] = "+"
end
 
if door and #wl == 1 then
map[wl[1].x][wl[1].y] = "+"
end
end
 
function count( x, y )
local i, j = 0, 0
local c = 0
 
for i = x-1, x+1 do
for j = y-1, y+1 do
if isLegal( i, j ) then
if map[i][j] ~= "." then
c = c + 1
end
end
end
end
 
return c
end
 
function neardoor( x, y )
local i, j = 0, 0
 
for i = x-1, x+1 do
for j = y-1, y+1 do
if isLegal( i, j ) then
if map[i][j] == "+" then
return true
end
end
end
end
 
return false
end
 
function bsp( walls )
local cx, cy = 0, 0
local i = 0
 
while i < walls do
cx = math.random( 1, map.width )
cy = math.random( 1, map.height )
 
if math.random() < 0.5 then
while map[cx][cy] == "." do
cx = cx - 1
end
cx = cx + 1
 
if count( cx, cy ) < 4 and not neardoor( cx, cy ) then
wall( cx, cy, { x=1, y=0 }, true )
end
else
while map[cx][cy] == "." do
cy = cy - 1
end
cy = cy + 1
 
if count( cx, cy ) < 4 and not neardoor( cx, cy ) then
wall( cx, cy, { x=0, y=1 }, true )
end
end
 
i = i + 1
end
end
 
function main()
math.randomseed( os.time() )
 
initMap()
wall( 1, 1, { x=1, y=0 }, false )
wall( 1, map.height, { x=1, y=0 }, false )
wall( 1, 2, { x=0, y=1 }, false )
wall( map.width, 2, { x=0, y=1 }, false )
 
bsp( 20 )
 
showMap()
end
 
main()

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
		
	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	
	-----------------------------------------------------------------------------
	
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
	
	-----------------------------------------------------------------------------
	
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. remove listeners, widgets, save state, etc.)
	
	-----------------------------------------------------------------------------
	
end


---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------

return scene