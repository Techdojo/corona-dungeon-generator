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
	
--[[
TODO:
change cell field from boolean to integer, indicating the number of visits;
also, target the less visited cells in order to make maze more uniform;
 
optimize!
]]
 
map = {}
map.width = 79
map.height = 25
map.tile = {}
map.cell = {}
 
map.magic = 500
map.loopChance = 0.1
 
map.cellRadius = 2
map.maxCellsX = math.floor( map.width / map.cellRadius )
map.maxCellsY = math.floor( map.height / map.cellRadius )
 
map.visitedCells = 0
map.totalCells = 0
 
direction = {
{ 0, -1 },
{ 0, 1 },
{ -1, 0 },
{ 1, 0 }
}
 
function initMap()
for i = 1, map.width do
map.tile[i] = {}
end
 
for i = 1, map.maxCellsX do
map.cell[i] = {}
end
end
 
function inRange( x, y )
return	x > map.cellRadius and y > map.cellRadius and
x <= map.width - map.cellRadius and y <= map.height - map.cellRadius
end
 
function cooridorLink( x1, y1, x2, y2, tile )
local cx, cy = x1, y1
 
while cx ~= x2 do
if x1 > x2 then
cx = cx - 1
else
cx = cx + 1
end
if inRange( cx, cy ) then
map.tile[cx][cy] = tile
end
end
 
while cy ~= y2 do
if y1 > y2 then
cy = cy - 1
else
cy = cy + 1
end
if inRange( cx, cy ) then
map.tile[cx][cy] = tile
end
end
end
 
function countCells()
map.totalCells = 0
map.visitedCells = 0
 
for i = 1, map.maxCellsX do
for j = 1, map.maxCellsY do
map.totalCells = map.totalCells + 1
if map.cell[i][j] == true then
map.visitedCells = map.visitedCells + 1
end
end
end
end
 
function findFreeCell( tries )
local rx, ry = 0, 0
for i = 1, tries do
rx = math.random( 1, map.maxCellsX )
ry = math.random( 1, map.maxCellsY )
if map.cell[rx][ry] == true then
return rx, ry
end
end
end
 
function makeMaze()
local rx, ry, rd = 0, 0, {}
local c = 0
 
for i = 1, map.width do
for j = 1, map.height do
map.tile[i][j] = "#"
end
end
 
for i = 1, map.maxCellsX do
for j = 1, map.maxCellsY do
map.cell[i][j] = false
end
end
 
rx = math.random( 1, map.maxCellsX )
ry = math.random( 1, map.maxCellsY )
 
map.cell[rx][ry] = true
 
countCells()
 
while map.visitedCells < map.totalCells do
c = c + 1
if c > map.magic then
return false
end
 
rd = direction[ math.random( 1, 4 ) ]
 
if	inRange( rx*map.cellRadius+rd[1], ry*map.cellRadius+rd[2] ) and
(	map.cell[rx+rd[1]][ry+rd[2]] == false or
math.random() < map.loopChance ) then
cooridorLink( rx*map.cellRadius, ry*map.cellRadius,
(rx+rd[1])*map.cellRadius, (ry+rd[2])*map.cellRadius, " " )
rx = rx + rd[1]
ry = ry + rd[2]
else
rx, ry = findFreeCell( map.magic )
end
 
map.cell[rx][ry] = true
map.tile[rx*map.cellRadius][ry*map.cellRadius] = " "
 
countCells()
end
 
return true
end
 
function showMap()
for j = 1, map.height do
for i = 1, map.width do
io.write( map.tile[i][j] or "?" )
end
io.write( "\n" )
end
end
 
function main()
math.randomseed( os.time() )
 
initMap()
makeMaze()
showMap()
print( "visited " .. map.visitedCells .. " out of " .. map.totalCells .. " cells" )
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