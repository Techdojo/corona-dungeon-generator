--[[----------------------------------------------------------------------------
	Dungeon Generator - digging Algorithm Module

	File: dungeon_gen_dig.lua
	
	Description: 
	

	Date: 12/11/2013

	Authors: Aidan Smyth

	Notes: 
	Corona SDK version used: 2012.971
	
	
------------------------------------------------------------------------------]]


-- #############################################################################
-- Load modules
-- #############################################################################
local appGlobals = require("globalData")					-- Load Global data
local utils = require("modules.tools.utilities")			-- Load utilities


-- #############################################################################
-- Setup variables
-- #############################################################################
local dunGenDig = {}
local dunGenDig_mt = { __index = dunGenDig}					-- metatable
	
-- Maximum size of the map
local xmax = 70												-- Maximum map width in columns (1 column = 32px)
local ymax = 25												-- Maximum map height in rows of (1 row = 32px)

-- Size of the map
local xsize = 80											-- Actual map width in columns (1 column = 32px), 0 by default
local ysize = 25											-- Actual map height in rows of (1 row = 32px), 0 by default

-- Number of "objects" to generate
local objects = 0
local rooms = 0
local hiddenRooms = 0
local chests = 0
local enemies = 0

-- define the %chance to generate either a room or a corridor on the map
-- BTW, rooms are 1st priority so actually it's enough to just define the chance
-- of generating a room
local chanceRoom = 75										-- % chance for adding a room
local chanceCorridor = 25									-- % chance for adding a corridor

-- the dungeon map data
local dungeon_map = {}										-- Table to hold the map data

local roomLib = {} 											-- Table to hold data on each room
local roomLibLen = 0

-- we will store the old random seed here
local oldseed = 0

--a list over tile types we're using
local tileUnused = 0
local tileDirtWall = 1										-- not in use
local tileDirtFloor = 2
local tileStoneWall = 3
local tileCorridor = 4
local tileDoor = 5
local tileUpStairs = 6
local tileDownStairs = 7
local tileChest = 8

local dunGenFinished = false

local roomMin = 4
local romMax = 20

-- misc. messages to print
local msgXSize = "X size of dungeon: "
local msgYSize = "Y size of dungeon: "
local msgMaxObjects = "max # of objects: "
local msgNumObjects = "# of objects made: "
local msgHelp = ""
local msgDetailedHelp = ""


-- #############################################################################
-- PRIVATE FUNCTIONS
-- #############################################################################

-- setting a tile's type
local function setCell(x, y, cellType)
	dungeon_map[x + xsize * y] = cellType
end

-- returns the type of a tile

local function getCell(x, y)
	-- print("cell value: " .. dungeon_map[x + xsize * y])
	return dungeon_map[x + xsize * y]
end

-- The RNG. the seed is based on seconds from the OS date/time
local function getRand(min, max)
	-- the seed is based on current date/time and the old, already used seed
	-- local now = os.time()
	local r1 = math.random(1500, 3000)
	local r2 = math.random(10)
	-- print("os.time is: " .. now)
	-- print("Oldseed is: " .. oldseed)
	-- local seed = now + oldseed
	local seed = math.floor(r1 / r2)
	-- print("seed is: " .. seed)
	oldseed = seed
	
	math.randomseed(seed)
	-- math.randomseed( os.time() )

	local rand = math.random(min, max)
	-- print("rand is: " .. rand)

	if (rand < 0) then
		rand = -rand
	end

	-- utils.dbprint("rand: " .. rand)
	return rand
end

--- showDungeon: Displays grid in the console
-- Used to print the map on the console
-- 
local function showDungeon() 
	-- print("showDungeon called")

	print(" ")
	local decRow = "             1         2         3         4         5         6         7"
	print(decRow)
	local topRow = "top 1234567890123456789012345678901234567890123456789012345678901234567890"
	print(topRow)

	local mapRow

	for y = 1, ysize do

		if y < 10 then
			mapRow = "0" .. y .. "| "
		else
			mapRow = y .. "| "
		end

		for x = 1, xsize do
			-- System.out.print(getCell(x, y));
			local cell = getCell(x, y)

			if cell == tileUnused then
				mapRow = mapRow .. " "			-- empty cell, change to '%' to see the cell
			elseif cell == tileDirtWall then
				mapRow = mapRow .. "#"
			elseif cell == tileDirtCorner then
				mapRow = mapRow .. "&"
			elseif cell == tileDirtFloor then
				mapRow = mapRow .. "."
			elseif cell == tileStoneWall then
				mapRow = mapRow .. "N"
			elseif cell == tileCorridor then
				mapRow = mapRow .. "+"
			elseif cell == tileDoor then
				mapRow = mapRow .. "D"
			elseif cell == tileUpStairs then
				mapRow = mapRow .. "<"
			elseif cell == tileDownStairs then
				mapRow = mapRow .. ">"
			elseif cell == tileChest then
				mapRow = mapRow .. "*"
			end
			
			x = x + 1
		end

		if (xsize <= xmax) then
			print(mapRow)
		end

		y = y + 1
	end
end

--- makeCorridor
-- 
--
-- @param x 
-- @param y 
-- @param length 
-- @param direction The direction to build in
--
local function makeCorridor(x, y, lenght, direction)
	-- utils.dbprint("Make corridor")
	-- define the dimensions of the corridor (er.. only the width and height..)
	local len = getRand(2, lenght)
	local floor = tileCorridor
	local dir = 0
	if direction > 0 and direction < 4 then
		dir = direction
	end

	local xtemp = 0
	local ytemp = 0

	if dir == 0 then
		-- north
		-- check if there's enough space for the corridor
		-- start with checking it's not out of the boundaries
		if x < 0 or x > xsize then
			return false
		else 
			xtemp = x
		end

		-- same thing here, to make sure it's not out of the boundaries
		ytemp = y
		while ytemp > (y-len) do
			if ytemp < 0 or ytemp > ysize then
				return false									-- oh boho, it was!
			end

			if getCell(xtemp, ytemp) ~= tileUnused then
				return false
			end

			ytemp = ytemp - 1
		end

		-- if we're still here, let's start building
		ytemp = y
		while ytemp > (y-len) do
			setCell(xtemp, ytemp, floor)
			ytemp = ytemp - 1
		end

	elseif dir == 1 then
		-- east
		if y < 0 or y > ysize then
			return false
		else
			ytemp = y
		end

		xtemp = x
		while xtemp < (x+len) do

			if xtemp < 0 or xtemp > xsize then
				return false
			end

			if getCell(xtemp, ytemp) ~= tileUnused then
				return false
			end

			xtemp = xtemp + 1
		end

		for xtemp = x, xtemp < (x+len) do
			setCell(xtemp, ytemp, floor)
			xtemp = xtemp + 1
		end

	elseif dir == 2 then
		-- south
		if x < 0 or x > xsize then
			return false
		else 
			xtemp = x
		end

		ytemp = y
		while ytemp < (y+len) do
			if ytemp < 0 or ytemp > ysize then
				return false
			end

			if getCell(xtemp, ytemp) ~= tileUnused then
				return false
			end

			ytemp = ytemp + 1
		end

		ytemp = y
		while ytemp < (y+len) do
			setCell(xtemp, ytemp, floor)
			ytemp = ytemp + 1
		end

	elseif dir == 3 then
		-- west
		if ytemp < 0 or ytemp > ysize then
			return false
		else
			ytemp = y
		end

		xtemp = x
		while xtemp > (x-len) do
			if xtemp < 0 or xtemp > xsize then
				return false
			end

			if getCell(xtemp, ytemp) ~= tileUnused then
				return false
			end

			xtemp = xtemp - 1
		end

		xtemp = x
		while xtemp > (x-len) do
			setCell(xtemp, ytemp, floor)
			xtemp = xtemp - 1
		end
	end

	--woot, we're still here! let's tell the other guys we're done!!
	return true
end

--- makeRoom
-- Builds a room based on based on a set of parameters. It checks to see if
-- there is enough space, if there is it then builds the room
--
-- @param x The starting x position
-- @param y The starting y position
-- @param xlength The width if the room
-- @param ylength The heigth of the room
-- @param direction The direction to build in
--
local function makeRoom(x, y, xlength, ylength, direction)
	utils.dbprint("\nStart room building")
	-- define the dimensions of the room, it should be at least 4x4 tiles (2x2 
	-- for walking on, the rest is walls)

	local xlen = getRand(roomMin, xlength)
	local ylen = getRand(roomMin, ylength)

	-- utils.dbprint("Map center: " .. math.floor(x) .. " X " .. math.floor(y))
	-- utils.dbprint("Room size: " .. xlen .. " X " .. ylen)
	local roomWidth = xlen				-- the width of the room
	local roomHeight = ylen				-- the height of the room
	local xStart 						-- the starting x position to check
	local yStart 						-- the starting y position to check
	local xEnd 							-- the ending x position to check
	local yEnd 							-- the ending y position to check
	local xtemp 						-- the current x position to check
	local ytemp 						-- the current y position to check
	local countX 						-- the amount for width cells to loop through
	local countY 						-- the amount for height cells to loop through

	--the tile type it's going to be filled with
	local floor = tileDirtFloor
	local wall = tileDirtWall
	local corner = tileDirtCorner

	-- choose the way it's pointing at
	local dir = 0

	if direction > 0 or direction < 4 then
		dir = direction
	end



	if dir == 0 then		-- Build north

		xStart = math.floor(x - (xlen / 2))
		yStart = math.floor(y)
		xEnd = math.floor(xStart + xlen - 1)
		yEnd = math.floor(y - ylen + 1)
		xtemp = xStart
		ytemp = yStart
		utils.dbprint("Room width is: "..roomWidth)
		utils.dbprint("Room height is: "..roomHeight)
		utils.dbprint("xStart is: "..xStart)
		utils.dbprint("yStart is: "..yStart)
		utils.dbprint("xEnd is: "..xEnd)
		utils.dbprint("yEnd is: "..yEnd)
		utils.dbprint("Create "..roomWidth.."x"..roomHeight.." room north cord pos: x" .. xStart  .. ", y" .. yStart .. " / x" .. xEnd .. ", y" .. yEnd )
		
		-- Check if there is enough space for the room to the north
		-- utils.dbprint("Start north space check loops")
		for i = 1, ylen do
			-- utils.dbprint("ytemp: "..ytemp)
			if ytemp < 1 or ytemp > ysize then
				-- utils.dbprint("Room hits left or right walls")
				return false 								-- if ytemp is the start or end wall, stop. 
			end
			for j = 1, xlen do
				-- utils.dbprint("xtemp: "..xtemp)
				if xtemp <= 1 or xtemp >= xsize then 
					-- utils.dbprint("Room hits top or bottom walls")
					return false 							-- if xtemp is the start or end wall, stop.
				end 
				if getCell(xtemp, ytemp) ~= tileUnused then 
					-- utils.dbprint("Room hits a filled cell")
					return false 							-- if cell is not emptey, stop.
				end 
				xtemp = xtemp + 1
				j = j + 1
			end
			xtemp = xStart
			ytemp = ytemp - 1
			i = i + 1
		end
		-- utils.dbprint("End north space check loops")
 		
		-- we're still here, build
		-- utils.dbprint("Start build loops")
		xtemp = xStart
		ytemp = yStart

		for i = 1, ylen do
			-- utils.dbprint("ytemp: ".. ytemp.." yEnd:"..yEnd)
			for j = 1, xlen do
				-- start with the walls
				if xtemp == xStart then setCell(xtemp, ytemp, wall)
				elseif xtemp == xEnd then setCell(xtemp, ytemp, wall) 
				elseif ytemp == yStart then setCell(xtemp, ytemp, wall)
				elseif ytemp == yEnd then setCell(xtemp, ytemp, wall)
				-- and then fill with the floor
				else setCell(xtemp, ytemp, floor) end
				xtemp = xtemp + 1
				j = j + 1
			end
			xtemp = xStart
			ytemp = ytemp - 1
			i = i + 1
		end
		-- utils.dbprint("End build loops")
		
	elseif dir == 1 then -- Build east
		
		xStart = math.floor(x)
		yStart = math.floor(y - (ylen/2))
		xEnd = math.floor(xStart + xlen - 1)
		yEnd = math.floor(yStart + ylen - 1)
		xtemp = xStart
		ytemp = yStart
		utils.dbprint("Room width is: "..roomWidth)
		utils.dbprint("Room height is: "..roomHeight)
		utils.dbprint("xStart is: "..xStart)
		utils.dbprint("yStart is: "..yStart)
		utils.dbprint("xEnd is: "..xEnd)
		utils.dbprint("yEnd is: "..yEnd)
		utils.dbprint("Create "..roomWidth.."x"..roomHeight.." room east cord pos: x" .. xStart  .. ", y" .. yStart .. " / x" .. xEnd .. ", y" .. yEnd )
		
		-- Check if there is enough space for the room to the east
		-- utils.dbprint("Start east space check loops")
		for i = 1, ylen do
			-- utils.dbprint("ytemp: "..ytemp)
			if ytemp < 1 or ytemp > ysize then
				-- utils.dbprint("Room hits left or right walls")
				return false 								-- if ytemp is the start or end wall, stop. 
			end
			for j = 1, xlen do
				-- utils.dbprint("xtemp: "..xtemp)
				if xtemp <= 1 or xtemp >= xsize then 
					-- utils.dbprint("Room hits top or bottom walls")
					return false 							-- if xtemp is the start or end wall, stop.
				end 
				if getCell(xtemp, ytemp) ~= tileUnused then 
					-- utils.dbprint("Room hits a filled cell")
					return false 							-- if cell is not emptey, stop.
				end 
				xtemp = xtemp + 1
				j = j + 1
			end
			xtemp = xStart
			ytemp = ytemp + 1
			i = i + 1
		end
		-- utils.dbprint("End space check loops")
 		
		-- we're still here, build
		-- utils.dbprint("Start build loops")
		xtemp = xStart
		ytemp = yStart

		for i = 1, ylen do
			-- utils.dbprint("ytemp: ".. ytemp.." yEnd:"..yEnd)
			for j = 1, xlen do
				-- start with the walls
				if xtemp == xStart then setCell(xtemp, ytemp, wall)
				elseif xtemp == xEnd then setCell(xtemp, ytemp, wall) 
				elseif ytemp == yStart then setCell(xtemp, ytemp, wall)
				elseif ytemp == yEnd then setCell(xtemp, ytemp, wall)
				-- and then fill with the floor
				else setCell(xtemp, ytemp, floor) end
				xtemp = xtemp + 1
				j = j + 1
			end
			xtemp = xStart
			ytemp = ytemp + 1
			i = i + 1
		end
		-- utils.dbprint("End build loops")
		
	elseif dir == 2 then -- Build south

		xStart = math.floor(x - (xlen / 2))
		yStart = math.floor(y)
		xEnd = math.floor((xStart + xlen) - 1)
		yEnd = math.floor(y + ylen - 1)
		xtemp = xStart
		ytemp = yStart
		utils.dbprint("Room width is: "..roomWidth)
		utils.dbprint("Room height is: "..roomHeight)
		utils.dbprint("xStart is: "..xStart)
		utils.dbprint("yStart is: "..yStart)
		utils.dbprint("xEnd is: "..xEnd)
		utils.dbprint("yEnd is: "..yEnd)
		utils.dbprint("Create "..roomWidth.."x"..roomHeight.." room south cord pos: x" .. xStart  .. ", y" .. yStart .. " / x" .. xEnd .. ", y" .. yEnd )
		
		-- Check if there is enough space for the room to the south
		-- utils.dbprint("Start south space check loops")
		for i = 1, ylen do
			-- utils.dbprint("ytemp: "..ytemp)
			if ytemp < 1 or ytemp > ysize then
				-- utils.dbprint("Room hits left or right walls")
				return false 								-- if ytemp is the start or end wall, stop. 
			end
			for j = 1, xlen do
				-- utils.dbprint("xtemp: "..xtemp)
				if xtemp <= 1 or xtemp >= xsize then 
					-- utils.dbprint("Room hits top or bottom walls")
					return false 							-- if xtemp is the start or end wall, stop.
				end 
				if getCell(xtemp, ytemp) ~= tileUnused then 
					-- utils.dbprint("Room hits a filled cell")
					return false 							-- if cell is not emptey, stop.
				end 
				xtemp = xtemp + 1
				j = j + 1
			end
			xtemp = xStart
			ytemp = ytemp - 1
			i = i + 1
		end
		-- utils.dbprint("End space check loops")
 		
		-- we're still here, build
		-- utils.dbprint("Start build loops")
		xtemp = xStart
		ytemp = yStart

		for i = 1, ylen do
			-- utils.dbprint("ytemp: ".. ytemp.." yEnd:"..yEnd)
			for j = 1, xlen do
				-- start with the walls
				if xtemp == xStart then setCell(xtemp, ytemp, wall)
				elseif xtemp == xEnd then setCell(xtemp, ytemp, wall) 
				elseif ytemp == yStart then setCell(xtemp, ytemp, wall)
				elseif ytemp == yEnd then setCell(xtemp, ytemp, wall)
				-- and then fill with the floor
				else setCell(xtemp, ytemp, floor) end
				xtemp = xtemp + 1
				j = j + 1
			end
			xtemp = xStart
			ytemp = ytemp + 1
			i = i + 1
		end
		-- utils.dbprint("End build south loops")
		
	elseif dir == 3 then 	-- Build west
		xStart = math.floor(x - xlen + 1)
		yStart = math.floor(y - (ylen / 2))
		xEnd = math.floor(x)
		yEnd = math.floor(yStart + ylen - 1)
		xtemp = xStart
		ytemp = yStart

		-- utils.dbprint("Room cord pos: x" .. xStart  .. ", y" .. yStart .. " / x" .. xEnd .. ", y" .. yEnd )
		-- Check if there is enough space for the room to the west
		-- utils.dbprint("Check space for a room to the west")

		xStart = math.floor(x)
		yStart = math.floor(y - (ylen / 2))
		xEnd = math.floor(x - xlen + 1)
		yEnd = math.floor(yStart + ylen - 1)
		xtemp = xStart
		ytemp = yStart
		utils.dbprint("Room width is: "..roomWidth)
		utils.dbprint("Room height is: "..roomHeight)
		utils.dbprint("xStart is: "..xStart)
		utils.dbprint("yStart is: "..yStart)
		utils.dbprint("xEnd is: "..xEnd)
		utils.dbprint("yEnd is: "..yEnd)
		utils.dbprint("Create "..roomWidth.."x"..roomHeight.." room west cord pos: x" .. xStart  .. ", y" .. yStart .. " / x" .. xEnd .. ", y" .. yEnd )
		
		-- Check if there is enough space for the room to the east
		-- utils.dbprint("Start east space check loops")
		for i = 1, ylen do
			-- utils.dbprint("ytemp: "..ytemp)
			if ytemp < 1 or ytemp > ysize then
				-- utils.dbprint("Room hits left or right walls")
				return false 								-- if ytemp is the start or end wall, stop. 
			end
			for j = 1, xlen do
				-- utils.dbprint("xtemp: "..xtemp)
				if xtemp <= 1 or xtemp >= xsize then 
					-- utils.dbprint("Room hits top or bottom walls")
					return false 							-- if xtemp is the start or end wall, stop.
				end 
				if getCell(xtemp, ytemp) ~= tileUnused then 
					-- utils.dbprint("Room hits a filled cell")
					return false 							-- if cell is not emptey, stop.
				end 
				xtemp = xtemp - 1
				j = j + 1
			end
			xtemp = xStart
			ytemp = ytemp + 1
			i = i + 1
		end
		-- utils.dbprint("End space check loops")
 		
		-- we're still here, build
		-- utils.dbprint("Start build loops")
		xtemp = xStart
		ytemp = yStart

		for i = 1, ylen do
			-- utils.dbprint("ytemp: ".. ytemp.." yEnd:"..yEnd)
			for j = 1, xlen do
				-- start with the walls
				if xtemp == xStart then setCell(xtemp, ytemp, wall)
				elseif xtemp == xEnd then setCell(xtemp, ytemp, wall) 
				elseif ytemp == yStart then setCell(xtemp, ytemp, wall)
				elseif ytemp == yEnd then setCell(xtemp, ytemp, wall)
				-- and then fill with the floor
				else setCell(xtemp, ytemp, floor) end
				xtemp = xtemp - 1
				j = j + 1
			end
			xtemp = xStart
			ytemp = ytemp + 1
			i = i + 1
		end
		-- utils.dbprint("End build south loops")
	end
	-- utils.dbprint("End all build loops")

	-- Find how many rooms are in roomLib table
	roomLibLen = #roomLib
	-- saves room data to roomLib table
	function saveRoomData(room)
		roomLib[room] = {}
		roomLib[room].xStart = xStart
		roomLib[room].yStart = yStart
		roomLib[room].xEnd = xEnd
		roomLib[room].yEnd = yEnd
		roomLib[room].width = roomWidth
		roomLib[room].height = roomHeight
		roomLib[room].chests = 0
	end
	-- Detrmine position in roomLib then call saveRoomData
	if roomLibLen == nil then
		roomLibLen = 1
		utils.dbprint("roomLibLen: " .. roomLibLen)
		saveRoomData(roomLibLen)
	else
		roomLibLen = roomLibLen + 1
		utils.dbprint("roomLibLen: " .. roomLibLen)
		saveRoomData(roomLibLen)
	end
	-- debug print room data
	utils.dbprint("Room data test [x: " .. roomLib[roomLibLen].xStart .. ", y: " .. roomLib[roomLibLen].yStart .. ", width: " .. roomLib[roomLibLen].width .. ", height: " .. roomLib[roomLibLen].height .. "]")

	-- yay, all done
	return true
end




-- #############################################################################
-- PUBLIC FUNCTIONS
-- #############################################################################

-- dunGenDig.createDungeon(maxWidth, maxHeight, numRooms, numChests, numHiddenRooms, "algorithum")
function dunGenDig.createDungeon( intx, inty, numRooms, numChests, numHiddenRooms, algorithum )

	-- utils.dbprint("dunGen.createDungeon called")

	-- Check initial values for createDungeon parameters
	-- Check dungeon width parameter, if no value asign a min value
	if intx == nil then
		xsize = 3
	elseif intx < 3 then 
		xsize = 3
	elseif intx > xmax then 
		xsize = xmax
	else 
		xsize = intx 
	end
	-- Check dungeon height parameter, if no value asign a min value
	if inty == nil then
		ysize = 3
	elseif inty < 3 then 
		ysize = 3
	elseif inty > ymax then 
		ysize = ymax
	else 
		ysize = inty 
	end
	-- Check dungeon room count parameter, if no value asign a min value
	if numRooms == nil then
		rooms = 10
	elseif numRooms < 1 then 
		rooms = 10
	else
		rooms = numRooms
	end
	-- Check dungeon chest number parameter, if no value asign a min value
	if numChests == nil then
		chests = 10
	elseif numChests < 1 then 
		chests = 10
	else
		chests = numChests
	end
	-- Check dungeon hidden room parameter, if no value asign a min value
	if numHiddenRooms == nil then
		hiddenRooms = getRand(0,1)
	-- elseif numHiddenRooms < 1 then 
	-- 	hiddenRooms = getRand(0,1)
	else
		hiddenRooms = getRand(0,1)
	end

	enemies = getRand(1,10)

	utils.dbprint(msgXSize .. xsize)
	utils.dbprint(msgYSize .. ysize)
	utils.dbprint(msgMaxObjects .. rooms)
	utils.dbprint("Number of rooms: " .. rooms)
	utils.dbprint("Number of hidden rooms: " .. hiddenRooms)
	utils.dbprint("Number of chests: " .. chests)
	utils.dbprint("Number of enemies: " .. enemies)


	-- redefine the map var, so it's adjusted to our new map size
	-- for y=1, ysize do
	-- 	for x=1,xsize do
	-- 		dungeon_map[x + xsize * y] = 0	-- [x + xsize * y]
	-- 		x = x + 1
	-- 	end
	-- 	y = y + 1
	-- end

	-- print("Fill map table with default data")
	for y = 1, ysize do
		-- print("y loop iteration: " .. y)
		for x = 1, xsize do
			-- print("x loop iteration: " .. x)
			-- ie, making the borders of unwalkable walls
			if y == 1 then setCell(x, y, tileStoneWall)
			elseif y == ysize then setCell(x, y, tileStoneWall)
			elseif x == 1 then setCell(x, y, tileStoneWall)
			elseif x == xsize then setCell(x, y, tileStoneWall)
			-- and fill the rest with dirt
			else setCell(x, y, tileUnused) end

			x = x + 1
		end

		y = y + 1
	end

	--*******************************************************************************
	-- And now the code of the random-map-generation-algorithm begins!
	--*******************************************************************************/

	-- start with making a room in the middle, which we can start building upon
	-- makeRoom(startx, starty, width, height, direction)
	makeRoom(xsize/2, ysize/2, 12, 12, getRand(0,3))

	-- keep count of the number of "objects" we've made
	local currentRooms = 1; -- +1 for the first room we just made


	-- then we sart the main loop
	local countingTries = 0
	local testing = 0

	--[[
	for countingTries = 0, 1000 do 	-- 0, 1000
		-- print("countingTries: " .. countingTries)

		-- check if we've reached our room quota
		if currentRooms == rooms then
			break
		end

		-- start with a random wall
		local newx = 0  
		local newy = 0 
		local xmod = 0 
		local ymod = 0 
		local validTile = -1
		-- print("validTile is:" .. validTile)


		-- 1000 chances to find a suitable object (room or corridor)..
		-- (yea, i know it's kinda ugly with a for-loop... -_-')
		for testing = 0, 1000 do 	-- 0, 1000
			-- print("testing: " .. testing)

			-- Pick a random spot on the map
			newx = getRand(2, xsize-1) 	-- randomly picked x pos
			newy = getRand(2, ysize-1) 	-- randomly picked y pos
			-- print("tempx: " .. newx .. " tempy: " .. newy)
			validTile = -1 				-- Set validTile to -1 (invalid)

			-- If the randomly picked tile is wall or corridor
			if getCell(newx, newy) == tileDirtWall or getCell(newx, newy) == tileCorridor then
				-- check if we can reach the place
				if getCell(newx, newy+1) == tileDirtFloor or getCell(newx, newy+1) == tileCorridor then
					validTile = 0 		-- tile is to north
					xmod = 0 			-- x modifier does not change
					ymod = -1 			-- y modifier changes to 1 row above
					-- utils.dbprint("validTile is: " .. validTile)
				elseif getCell(newx-1, newy) == tileDirtFloor or getCell(newx-1, newy) == tileCorridor then
					validTile = 1 		-- tile is to east
					xmod = 1 			-- x modifier changes to 1 to the right
					ymod = 0 			-- y modifier does not change
					-- utils.dbprint("validTile is: " .. validTile)
				elseif getCell(newx, newy-1) == tileDirtFloor or getCell(newx, newy-1) == tileCorridor then
					validTile = 2 		-- tile is to the south
					xmod = 0 			-- x modifier does not change
					ymod = 1 			-- y modifier changes to 1 row bellow
					-- utils.dbprint("validTile is: " .. validTile)
				elseif getCell(newx+1, newy) == tileDirtFloor or getCell(newx+1, newy) == tileCorridor then
					validTile = 3 		-- tile is to the west
					xmod = -1 			-- x modifier changes to 1 to the left
					ymod = 0 			-- y modifier does not change
					-- utils.dbprint("validTile is: " .. validTile)
				end

				-- check that we haven't got another door nearby, so we won't get alot of openings besides
				-- each other
				if validTile > -1 then
					if getCell(newx, newy+1) == tileDoor then 		-- check north
						validTile = -1
					elseif getCell(newx-1, newy) == tileDoor then 	-- check east
						validTile = -1
					elseif getCell(newx, newy-1) == tileDoor then	-- check south
						validTile = -1
					elseif getCell(newx+1, newy) == tileDoor then	-- check west
						validTile = -1
					end
				end

				-- if we can, jump out of the loop and continue with the rest
				if validTile > -1 then
					break
				end
			end

			testing = testing + 1
		end -- end for testing loop

		-- If we found a tile/directon to buuild then...
		if validTile > -1 then
			-- choose what to build now at our newly found place, and at what direction
			local feature = math.random(0, 100)
			-- utils.dbprint("Feature is: " .. feature)

			if feature <= chanceRoom then -- a new room
				-- utils.dbprint("Make room")
				-- makeRoom(x, y, xlength, ylength, direction)
				if makeRoom((newx+xmod), (newy+ymod), roomMax, roomMax, validTile) then
					currentRooms = currentRooms + 1 -- add to our quota

					-- then we mark the wall opening with a door
					setCell(newx, newy, tileDoor)

					-- clean up infront of the door so we can reach it
					setCell((newx+xmod), (newy+ymod), tileDirtFloor)
				end
			elseif feature > chanceRoom then -- new corridor
				-- utils.dbprint("Make corridor")
				if makeCorridor((newx+xmod), (newy+ymod), 6, validTile) then
					-- same thing here, add to the quota and a door
					currentFeatures = currentFeatures + 1

					setCell(newx, newy, tileDoor)
				end
			end
		end

		countingTries = countingTries + 1
	end
	]]










	dunGenFinished = true

	if dunGenFinished == true then
		showDungeon()
		-- utils.tprint(dungeon_map)
	end
end
	

-- 
return dunGenDig
