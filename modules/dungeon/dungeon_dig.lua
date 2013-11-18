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

----------------------------------------
-- Setup dungeon container data
----------------------------------------
local dungeon = {}
local dungeon_mt = { __index = dungeon}						-- metatable
-- Size of the map
dungeon.width = 0											-- Actual map width in columns (1 column = 32px), 0 by default
dungeon.height = 0											-- Actual map height in rows of (1 row = 32px), 0 by default
-- the dungeon map data
dungeon.map = {}											-- Table to hold the map data
dungeon.rooms = {}											-- Table to hold the map data
	
-- Maximum size of the map
local xmax = 70												-- Maximum map width in columns (1 column = 32px)
local ymax = 25												-- Maximum map height in rows of (1 row = 32px)


----------------------------------------
-- Setup dungeon generation variables
----------------------------------------

-- Number of "objects" to generate
local objects = 0
local rooms = 0
local hiddenRooms = 0
local chests = 0
local enemies = 0

-- Define the %chance to generate either a room or a corridor on the map
-- BTW, rooms are 1st priority so actually it's enough to just define the chance
-- of generating a room
local chanceRoom = 85										-- % chance for adding a room
local chanceCorridor = 90									-- % chance for adding a corridor
local chanceHidden = 100									-- % chance for adding a hidden room

-- we will store the old random seed here
local oldseed = 0

--a list of tile types we're using
local tileUnused = 0
local tileDirtWall = 1										
local tileDirtCorner = 2									
local tileDirtFloor = 3
local tileStoneWall = 4
local tileCorridor = 5
local tileDoor = 6
local tileUpStairs = 7
local tileDownStairs = 8
local tileChest = 9

-- Nim/max room sizes
local roomMin = 4
local roomMax = 20

-- misc. messages to print
local msgXSize = "X size of dungeon: "
local msgYSize = "Y size of dungeon: "
local msgMaxObjects = "max # of objects: "
local msgNumObjects = "# of objects made: "
local msgHelp = ""
local msgDetailedHelp = ""

local dunGenFinished = false

-- #############################################################################
-- PRIVATE FUNCTIONS
-- #############################################################################

-- setting a tile's type
local function setCell(x, y, cellType)
	dungeon.map[x + dungeon.width * y] = cellType
end

-- returns the type of a tile
local function getCell(x, y)
	-- print("cell value: " .. dungeon.map[x + dungeon.width * y])
	return dungeon.map[x + dungeon.width * y]
end

-- The RNG. the seed is based on seconds from the OS date/time
local function getRand(min, max)
	-- the seed is based on current date/time and the old, already used seed
	-- local now = os.time()
	-- local r1 = math.random(1500, 3000)
	-- local r2 = math.random(10)
	-- -- print("os.time is: " .. now)
	-- -- print("Oldseed is: " .. oldseed)
	-- -- local seed = now + oldseed
	-- local seed = math.floor(r1 / r2)
	-- -- print("seed is: " .. seed)
	-- oldseed = seed
	
	-- math.randomseed(seed)
	-- -- math.randomseed( os.time() )

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

	for y = 1, dungeon.height do

		if y < 10 then
			mapRow = "0" .. y .. "| "
		else
			mapRow = y .. "| "
		end

		for x = 1, dungeon.width do
			-- System.out.print(getCell(x, y));
			local cell = getCell(x, y)

			if cell == tileUnused then
				mapRow = mapRow .. " "						-- empty cell, change to '%' to see the cell
			elseif cell == tileDirtWall then
				mapRow = mapRow .. "#"
			elseif cell == tileDirtCorner then
				mapRow = mapRow .. "&"
			elseif cell == tileDirtFloor then
				mapRow = mapRow .. "."
			elseif cell == tileStoneWall then
				mapRow = mapRow .. "N"
			elseif cell == tileCorridor then
				mapRow = mapRow .. ","
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

		if (dungeon.width <= xmax) then
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
local function makeCorridor(x, y, length, direction)
	-- utils.dbprint("Make corridor")
	-- define the dimensions of the corridor (er.. only the width and height..)
	local len = getRand(2, length)
	local floor = tileCorridor
	local dir = 0
	utils.dbprint("direction: "..direction)

	if direction > 0 and direction < 5 then
		dir = direction
	end
	utils.dbprint("x: "..x)
	utils.dbprint("y: "..y)
	utils.dbprint("length: "..len)
	utils.dbprint("dir: "..dir)

	local xtemp = 0
	local ytemp = 0

	if dir == 1 then
		-- north
		-- check if there's enough space for the corridor
		-- start with checking it's not out of the boundaries
		if x <= 1 or x >= dungeon.width then
			return false
		else 
			xtemp = x
		end

		-- same thing here, to make sure it's not out of the boundaries
		ytemp = y
		while ytemp > (y-len) do
			if ytemp <= 1 or ytemp >= dungeon.height then
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

	elseif dir == 2 then
		-- east
		if y <= 1  or y >= dungeon.height then
			return false
		else
			ytemp = y
		end

		xtemp = x
		while xtemp < (x+len) do

			if xtemp <= 1 or xtemp >= dungeon.width then
				return false
			end

			if getCell(xtemp, ytemp) ~= tileUnused then
				return false
			end

			xtemp = xtemp + 1
		end

		xtemp = x
		while xtemp < (x+len) do
			setCell(xtemp, ytemp, floor)
			xtemp = xtemp + 1
		end

	elseif dir == 3 then
		-- south
		if x < 0 or x > dungeon.width then
			return false
		else 
			xtemp = x
		end

		ytemp = y
		while ytemp < (y+len) do
			if ytemp < 0 or ytemp > dungeon.height then
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

	elseif dir == 4 then
		-- west
		if y <= 1 or y >= dungeon.height then
			return false
		else
			ytemp = y
		end

		xtemp = x
		while xtemp > (x-len) do
			if xtemp <= 1 or xtemp >= dungeon.width then
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
-- @param ylength The height of the room
-- @param direction The direction to build in
--
local function makeRoom(x, y, xlength, ylength, direction)
	
	-- define the dimensions of the room, it should be at least 4x4 tiles (2x2 
	-- for walking on, the rest is walls)

	local roomNum 											-- 
	local room 												-- room will hold the room data table
	local width = getRand(roomMin, xlength)					-- the width of the room
	local height = getRand(roomMin, ylength)				-- the height of the room
	local xStart 											-- First x coordinate
	local yStart 											-- First y coordinate
	local xEnd 												-- Last x coordinate
	local yEnd 												-- Last y coordinate
	local xtemp 											-- the current x position to check
	local ytemp 											-- the current y position to check
	-- utils.dbprint("Map center: " .. math.floor(x) .. " X " .. math.floor(y))
	-- utils.dbprint("Room size: " .. room.width .. "X" .. room.height)

	--the tile type it's going to be filled with
	local floor = tileDirtFloor
	local wall = tileDirtWall
	local corner = tileDirtCorner
	local door = tileDoor
	local chest = tileChest
	local corridor = tileCorridor

	-- choose the way it's pointing at
	local dir = 0 											-- 1,2,3,4 (north,east,south,west)

	if direction > 1 or direction < 5 then
		dir = direction
	end

	-- save room data to roomLib table
	function createRoomData(xStart, yStart, xEnd, yEnd, width, height)
		utils.dbprint("Called createRoomData")

		roomNum = #dungeon.rooms
		-- Detrmine position in roomLib then call saveRoomData
		if roomNum == nil then
			roomNum = 1
		else
			roomNum = roomNum+1
		end
		utils.dbprint("room number: " .. roomNum)

		dungeon.rooms[roomNum] = {} 						-- 
		dungeon.rooms[roomNum].xStart = xStart 				-- 
		dungeon.rooms[roomNum].yStart = yStart 				-- 
		dungeon.rooms[roomNum].xEnd = xEnd 					-- 
		dungeon.rooms[roomNum].yEnd = yEnd 					-- 
		dungeon.rooms[roomNum].width = width 				-- 
		dungeon.rooms[roomNum].height = height 				-- 
		-- wall cell Coordinates
		dungeon.rooms[roomNum].wallCoords = {
			{},												-- north
			{},												-- east
			{},												-- south
			{}												-- west
		}
		dungeon.rooms[roomNum].doors = {0,0,0,0} 			-- doors(north,east,south,west)
		dungeon.rooms[roomNum].chests = 0 					-- number of chests in the room
		utils.dbprint("Finished creating room table\n")

		-- Return the current room number
		return roomNum
	end

	-- Save a room's wall cell location into wall direction tables
	function saveWallCoordinate(roomNum,wallDir,x,y)
		local wallCoords = dungeon.rooms[roomNum].wallCoords[wallDir]
		
		table.insert(wallCoords, {x,y})
		-- print("Print condents of coordinate table:")
	end
	-- debug print room data
	-- utils.dbprint("Room data test [x: " .. roomLib[roomLibLen].xStart .. ", y: " .. roomLib[roomLibLen].yStart .. ", width: " .. roomLib[roomLibLen].width .. ", height: " .. roomLib[roomLibLen].height .. "]")

	utils.dbprint("\nStart room building, dir: "..dir)

	if dir == 1 then		-- Build north

		xStart = math.floor(x - (width / 2))
		yStart = math.floor(y)
		xEnd = math.floor(xStart + width - 1)
		yEnd = math.floor(y - height + 1)
		xtemp = xStart
		ytemp = yStart

		-- Check if there is enough space for the room to the north
		-- utils.dbprint("Start north space check loops")
		for i = 1, height do
			-- utils.dbprint("ytemp: "..ytemp)
			if ytemp <= 1 or ytemp >= dungeon.height then
				utils.dbprint("Room hits top or bottom walls")
				return false 								-- if ytemp is the start or end wall, stop. 
			end
			for j = 1, width do
				-- utils.dbprint("xtemp: "..xtemp)
				if xtemp <= 1 or xtemp >= dungeon.width then 
					-- utils.dbprint("Room hits left or right walls")
					return false 							-- if xtemp is the start or end wall, stop.
				end
				-- Check to see if the room will collide with an inner part of a room or
				-- corridor, if it does return false.
				if getCell(xtemp, ytemp) == door or getCell(xtemp, ytemp) == floor or getCell(xtemp, ytemp) == corridor then 
					utils.dbprint("Room hits a filled cell")
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

			
		-- Were still here so enter into roomdata table and save data
		local roomNum = createRoomData(xStart, yStart, xEnd, yEnd, width, height)
		utils.dbprint("returned room is: ".. roomNum)
		room = dungeon.rooms[roomNum]

		-- ...and build the room
		-- utils.dbprint("Start build loops")
		xtemp = room.xStart
		ytemp = room.yStart

		for i = 1, room.height do
			-- utils.dbprint("ytemp: ".. ytemp.." yEnd:"..room.yEnd)
			for j = 1, room.width do
				-- start with the walls
				if xtemp == room.xStart then 									-- Build first wall
					if ytemp == room.yStart then
						-- utils.dbprint("build first corner")
						setCell(xtemp, ytemp, corner)							-- Build first corner
					elseif ytemp == room.yEnd then								
						-- utils.dbprint("build first corner")
						setCell(xtemp, ytemp, corner) 							-- Build third corner
					else 
						setCell(xtemp, ytemp, wall)
						saveWallCoordinate(roomNum, 4, xtemp, ytemp)			-- Save west wall coordinates
					end
				elseif xtemp == room.xEnd then 									-- Build south wall
					if ytemp == room.yStart then								
						-- utils.dbprint("build second corner")
						setCell(xtemp, ytemp, corner)							-- Build second corner
					elseif ytemp == room.yEnd then								
						-- utils.dbprint("build second corner")
						setCell(xtemp, ytemp, corner)							-- Build fourth corner
					else 
						setCell(xtemp, ytemp, wall)
						saveWallCoordinate(roomNum, 2, xtemp, ytemp)			-- Save east wall coordinates
					end 
				elseif ytemp == room.yStart then 
					setCell(xtemp, ytemp, wall)
					saveWallCoordinate(roomNum, 3, xtemp, ytemp)				-- Save south wall coordinates
				elseif ytemp == room.yEnd then 
					setCell(xtemp, ytemp, wall)
					saveWallCoordinate(roomNum, 1, xtemp, ytemp)				-- Save north wall coordinates
				else -- and then fill with the floor
					setCell(xtemp, ytemp, floor) 
				end
				xtemp = xtemp + 1
				j = j + 1
			end
			xtemp = room.xStart
			ytemp = ytemp - 1
			i = i + 1
		end
		-- utils.dbprint("End build loops")
		
	elseif dir == 2 then -- Build east
		
		xStart = math.floor(x)
		yStart = math.floor(y - (height/2))
		xEnd = math.floor(xStart + width - 1)
		yEnd = math.floor(yStart + height - 1)
		xtemp = xStart
		ytemp = yStart
		
		-- Check if there is enough space for the room to the east
		-- utils.dbprint("Start east space check loops")
		for i = 1, height do
			-- utils.dbprint("ytemp: "..ytemp)
			if ytemp <= 1 or ytemp >= dungeon.height then
				utils.dbprint("Room hits left or right walls")
				return false 								-- if ytemp is the start or end wall, stop. 
			end
			for j = 1, width do
				-- utils.dbprint("xtemp: "..xtemp)
				if xtemp <= 1 or xtemp >= dungeon.width then 
					utils.dbprint("Room hits top or bottom walls")
					return false 							-- if xtemp is the start or end wall, stop.
				end 
				if getCell(xtemp, ytemp) == door or getCell(xtemp, ytemp) == floor or getCell(xtemp, ytemp) == corridor then 
					utils.dbprint("Room hits a filled cell")
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
 		
		-- Were still here so enter into roomdata table and save data
		local roomNum = createRoomData(xStart, yStart, xEnd, yEnd, width, height)
		utils.dbprint("returned room is: ".. roomNum)
		room = dungeon.rooms[roomNum]

		-- ...and build the room
		-- utils.dbprint("Start build loops")
		xtemp = room.xStart
		ytemp = room.yStart

		for i = 1, room.height do
			-- utils.dbprint("ytemp: ".. ytemp.." yEnd:"..room.yEnd)
			for j = 1, room.width do
				-- start with the walls
				if xtemp == room.xStart then 									-- Build first wall
					if ytemp == room.yStart then
						-- utils.dbprint("build first corner")
						setCell(xtemp, ytemp, corner)							-- Build first corner
					elseif ytemp == room.yEnd then								
						-- utils.dbprint("build first corner")
						setCell(xtemp, ytemp, corner) 							-- Build third corner
					else 
						setCell(xtemp, ytemp, wall)
						saveWallCoordinate(roomNum, 4, xtemp, ytemp)			-- Save west wall coordinates
					end
				elseif xtemp == room.xEnd then 									-- Build south wall
					if ytemp == room.yStart then								
						-- utils.dbprint("build second corner")
						setCell(xtemp, ytemp, corner)							-- Build second corner
					elseif ytemp == room.yEnd then								
						-- utils.dbprint("build second corner")
						setCell(xtemp, ytemp, corner)							-- Build fourth corner
					else 
						setCell(xtemp, ytemp, wall)
						saveWallCoordinate(roomNum, 2, xtemp, ytemp)			-- Save east wall coordinates
					end 
				elseif ytemp == room.yStart then 
					setCell(xtemp, ytemp, wall)
					saveWallCoordinate(roomNum, 1, xtemp, ytemp)				-- Save north wall coordinates
				elseif ytemp == room.yEnd then 
					setCell(xtemp, ytemp, wall)
					saveWallCoordinate(roomNum, 3, xtemp, ytemp)				-- Save south wall coordinates
				else -- and then fill with the floor
					setCell(xtemp, ytemp, floor) 
				end
				xtemp = xtemp + 1
				j = j + 1
			end
			xtemp = room.xStart
			ytemp = ytemp + 1
			i = i + 1
		end
		-- utils.dbprint("End build loops")
		
	elseif dir == 3 then -- Build south

		xStart = math.floor(x - (width / 2))
		yStart = math.floor(y)
		xEnd = math.floor((xStart + width) - 1)
		yEnd = math.floor(y + height - 1)
		xtemp = xStart
		ytemp = yStart
		utils.dbprint("yStart: "..xStart)
		utils.dbprint("yEnd: "..yEnd)
		
		-- Check if there is enough space for the room to the south
		-- utils.dbprint("Start south space check loops")
		for i = 1, height do
			utils.dbprint("ytemp: "..ytemp)
			if ytemp <= 1 or ytemp >= dungeon.height then
				utils.dbprint("Room hits top or bottom walls")
				return false 								-- if ytemp is the start or end wall, stop. 
			end

			for j = 1, width do
				-- utils.dbprint("xtemp: "..xtemp)
				if xtemp <= 1 or xtemp >= dungeon.width then 
					utils.dbprint("Room hits left or right walls")
					return false 							-- if xtemp is the start or end wall, stop.
				end 

				if getCell(xtemp, ytemp) == door or getCell(xtemp, ytemp) == floor or getCell(xtemp, ytemp) == corridor then 
					utils.dbprint("Room hits a filled cell")
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
 		
		-- Were still here so enter into roomdata table and save data
		local roomNum = createRoomData(xStart, yStart, xEnd, yEnd, width, height)
		utils.dbprint("returned room is: ".. roomNum)
		room = dungeon.rooms[roomNum]

		-- ...and build the room
		-- utils.dbprint("Start build loops")
		xtemp = room.xStart
		ytemp = room.yStart

		for i = 1, room.height do
			-- utils.dbprint("ytemp: ".. ytemp.." yEnd:"..room.yEnd)
			for j = 1, room.width do
				-- start with the walls
				if xtemp == room.xStart then 									-- Build first wall
					if ytemp == room.yStart then
						-- utils.dbprint("build first corner")
						setCell(xtemp, ytemp, corner)							-- Build first corner
					elseif ytemp == room.yEnd then								
						-- utils.dbprint("build first corner")
						setCell(xtemp, ytemp, corner) 							-- Build third corner
					else 
						setCell(xtemp, ytemp, wall)
						saveWallCoordinate(roomNum, 4, xtemp, ytemp)			-- Save west wall coordinates
					end
				elseif xtemp == room.xEnd then 									-- Build south wall
					if ytemp == room.yStart then								
						-- utils.dbprint("build second corner")
						setCell(xtemp, ytemp, corner)							-- Build second corner
					elseif ytemp == room.yEnd then								
						-- utils.dbprint("build second corner")
						setCell(xtemp, ytemp, corner)							-- Build fourth corner
					else 
						setCell(xtemp, ytemp, wall)
						saveWallCoordinate(roomNum, 2, xtemp, ytemp)			-- Save east wall coordinates
					end 
				elseif ytemp == room.yStart then 
					setCell(xtemp, ytemp, wall)
					saveWallCoordinate(roomNum, 1, xtemp, ytemp)				-- Save north wall coordinates
				elseif ytemp == room.yEnd then 
					setCell(xtemp, ytemp, wall)
					saveWallCoordinate(roomNum, 3, xtemp, ytemp)				-- Save south wall coordinates
				else -- and then fill with the floor
					setCell(xtemp, ytemp, floor) 
				end
				xtemp = xtemp + 1
				j = j + 1
			end
			xtemp = room.xStart
			ytemp = ytemp + 1
			i = i + 1
		end
		-- utils.dbprint("End build south loops")
		
	elseif dir == 4 then 	-- Build west

		xStart = math.floor(x)
		yStart = math.floor(y - (height / 2))
		xEnd = math.floor(x - width + 1)
		yEnd = math.floor(yStart + height - 1)
		xtemp = xStart
		ytemp = yStart
		
		-- Check if there is enough space for the room to the east
		-- utils.dbprint("Start east space check loops")
		for i = 1, height do
			-- utils.dbprint("ytemp: "..ytemp)
			if ytemp <= 1 or ytemp >= dungeon.height then
				utils.dbprint("Room hits left or right walls")
				return false 								-- if ytemp is the start or end wall, stop. 
			end
			for j = 1, width do
				-- utils.dbprint("xtemp: "..xtemp)
				if xtemp <= 1 or xtemp >= dungeon.width then 
					utils.dbprint("Room hits top or bottom walls")
					return false 							-- if xtemp is the start or end wall, stop.
				end 
				if getCell(xtemp, ytemp) == door or getCell(xtemp, ytemp) == floor or getCell(xtemp, ytemp) == corridor then 
					utils.dbprint("Room hits a filled cell")
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
 		
		-- Were still here so enter into roomdata table and save data
		local roomNum = createRoomData(xStart, yStart, xEnd, yEnd, width, height)
		utils.dbprint("returned room is: ".. roomNum)
		room = dungeon.rooms[roomNum]

		-- ...and build the room
		-- utils.dbprint("Start build loops")
		xtemp =room.xStart
		ytemp = room.yStart

		for i = 1, room.height do
			-- utils.dbprint("ytemp: ".. ytemp.." yEnd:"..room.yEnd)
			for j = 1, room.width do
				-- start with the walls
				if xtemp == room.xStart then 									-- Build first wall
					if ytemp == room.yStart then
						-- utils.dbprint("build first corner")
						setCell(xtemp, ytemp, corner)							-- Build first corner
					elseif ytemp == room.yEnd then								
						-- utils.dbprint("build first corner")
						setCell(xtemp, ytemp, corner) 							-- Build third corner
					else 
						setCell(xtemp, ytemp, wall)
						saveWallCoordinate(roomNum, 2, xtemp, ytemp)			-- Save east wall coordinates
					end
				elseif xtemp == room.xEnd then 									-- Build south wall
					if ytemp == room.yStart then								
						-- utils.dbprint("build second corner")
						setCell(xtemp, ytemp, corner)							-- Build second corner
					elseif ytemp == room.yEnd then								
						-- utils.dbprint("build second corner")
						setCell(xtemp, ytemp, corner)							-- Build fourth corner
					else 
						setCell(xtemp, ytemp, wall)
						saveWallCoordinate(roomNum, 4, xtemp, ytemp)			-- Save west wall coordinates
					end 
				elseif ytemp == room.yStart then 
					setCell(xtemp, ytemp, wall)
					saveWallCoordinate(roomNum, 1, xtemp, ytemp)				-- Save north wall coordinates
				elseif ytemp == room.yEnd then 
					setCell(xtemp, ytemp, wall)
					saveWallCoordinate(roomNum, 3, xtemp, ytemp)				-- Save south wall coordinates
				else -- and then fill with the floor
					setCell(xtemp, ytemp, floor) 
				end
				xtemp = xtemp - 1
				j = j + 1
			end
			xtemp = room.xStart
			ytemp = ytemp + 1
			i = i + 1
		end
		-- utils.dbprint("End build south loops")
	end

	utils.dbprint("Built a "..room.width.."x"..room.height.." room, dir: " .. dir .. ", coords: x" .. room.xStart  .. ", y" .. room.yStart .. " / x" .. room.xEnd .. ", y" .. room.yEnd )
	-- utils.dbprint("End all build loops")

	-- Test wall coordinate data
	-- local coordsTest = room.wallCoords[dir][1]
	-- utils.dbprint("test1 north: "..room.wallCoords[dir][1])
	-- utils.dbprint("test1 north xpos: "..room.wallCoords[dir][1][1])
	-- utils.dbprint("test1 north ypos: "..room.wallCoords[dir][1][2])
	

	-- yay, all done
	return true
end




-- #############################################################################
-- PUBLIC FUNCTIONS
-- #############################################################################

-- dungeon.createDungeon(maxWidth, maxHeight, numRooms, numChests, numHiddenRooms, "algorithum")
function dungeon.createDungeon( intx, inty, numRooms, numChests, numHiddenRooms, algorithum )

	-- utils.dbprint("dunGen.createDungeon called")

	local r1 = math.random(1500, 3000)
	local r2 = math.random(10)
	-- utils.dbprint("os.time is: " .. now)
	-- utils.dbprint("Oldseed is: " .. oldseed)
	-- local seed = now + oldseed
	local seed = math.floor(r1 / r2)
	-- utils.dbprint("seed is: " .. seed)
	oldseed = seed
	
	math.randomseed(seed)
	-- math.randomseed( os.time() )

	-- Check initial values for createDungeon parameters
	-- Check dungeon width parameter, if no value asign a min value
	if intx == nil then
		dungeon.width = 3
	elseif intx < 3 then 
		dungeon.width = 3
	elseif intx > xmax then 
		dungeon.width = xmax
	else 
		dungeon.width = intx 
	end
	-- Check dungeon height parameter, if no value asign a min value
	if inty == nil then
		dungeon.height = 3
	elseif inty < 3 then 
		dungeon.height = 3
	elseif inty > ymax then 
		dungeon.height = ymax
	else 
		dungeon.height = inty 
	end
	-- Check dungeon room count parameter, if no value asign a min value
	if numRooms == nil then
		rooms = 4
	elseif numRooms < 1 then 
		rooms = 4
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

	utils.dbprint("Dungeon size is " .. dungeon.width .. "x" .. dungeon.height)
	-- utils.dbprint(msgMaxObjects .. rooms)
	-- utils.dbprint("Number of rooms: " .. rooms)
	-- utils.dbprint("Number of hidden rooms: " .. hiddenRooms)
	-- utils.dbprint("Number of chests: " .. chests)
	-- utils.dbprint("Number of enemies: " .. enemies)


	-- redefine the map var, so it's adjusted to our new map size
	-- for y=1, dungeon.height do
	-- 	for x=1,dungeon.width do
	-- 		dungeon.map[x + dungeon.width * y] = 0	-- [x + dungeon.width * y]
	-- 		x = x + 1
	-- 	end
	-- 	y = y + 1
	-- end

	-- utils.dbprint("Fill map table with default data")
	for y = 1, dungeon.height do
		-- utils.dbprint("y loop iteration: " .. y)
		for x = 1, dungeon.width do
			-- utils.dbprint("x loop iteration: " .. x)
			-- ie, making the borders of unwalkable walls
			if y == 1 then setCell(x, y, tileStoneWall)
			elseif y == dungeon.height then setCell(x, y, tileStoneWall)
			elseif x == 1 then setCell(x, y, tileStoneWall)
			elseif x == dungeon.width then setCell(x, y, tileStoneWall)
			-- and fill the rest with dirt
			else setCell(x, y, tileUnused) end

			x = x + 1
		end

		y = y + 1
	end

	--*******************************************************************************
	-- And now the code of the random-map-generation-algorithm begins!
	--*******************************************************************************/

	-- Set max room size based on dungeon size
	if dungeon.width > dungeon.height then
		roomMax = math.floor(dungeon.height/3)
	else
		roomMax = math.floor(dungeon.width/3)
	end

	-- Start with making a room in the middle, which we can start building upon
	-- makeRoom(startx, starty, width, height, direction)
	makeRoom(dungeon.width/2, dungeon.height/2, roomMax, roomMax, getRand(1,4))

	-- keep count of the number of "objects" we've made
	local currentRooms = 1; 			-- +1 for the first room we just made
	local roomNum 						-- The room number picked to dig from
	local room 							-- The picked room data
	local countingTries = 0
	local testing = 0
	
	for countingTries = 1, 1000 do 	-- 0, 1000
		-- utils.dbprint("countingTries: " .. countingTries)		
		local roomFound = false			-- Boolean to check if a valid room is found

		-- start with a random wall
		local newx = 0  
		local newy = 0 
		local xmod = 0 
		local ymod = 0 
		local validTile = 0 			-- validTile direction starts at null
		-- utils.dbprint("validTile is:" .. validTile)
		local wallDir = 0 				-- set wallDir
		local cellTemp	 				-- Cell position in the array to test
		local feature 					-- what feature to build

		-- check if we've reached our room quota
		if currentRooms == numRooms then
			break
		end
	
		-- Pick a room number
		if currentRooms == 1 then
			roomNum = 1
			room = dungeon.rooms[roomNum]
		else
			roomNum = getRand(1, currentRooms)
			room = dungeon.rooms[roomNum]
		end

		-- Number of wall cells to check in the room
		local cellsNorth = #room.wallCoords[1]
		local cellsEast = #room.wallCoords[2]
		local cellsSouth = #room.wallCoords[3]
		local cellsWest = #room.wallCoords[4]
		local cellsTotal = cellsNorth + cellsEast + cellsSouth + cellsWest
		utils.dbprint("cellsTotal is: "..cellsTotal)

		-- Try to find a suitable object (room or corridor)..
		-- (yea, i know it's kinda ugly with a for-loop... -_-')
		for testing = 1, cellsTotal do 	-- 1 - 100
			-- utils.dbprint("testing: " .. testing)

			-- pick a random wall
			wallDir = getRand(1,4)
			-- wallDir = 4

			-- then pick a wall cell at random
			cellstotest = #room.wallCoords[wallDir]
			local cellRnd = getRand(1,cellstotest)
			newx = room.wallCoords[wallDir][cellRnd][1]
			newy = room.wallCoords[wallDir][cellRnd][2]
			utils.dbprint("cell is [dir: "..wallDir.." cellnum: "..cellRnd.."] x:"..newx.." y:"..newy)
			
			if wallDir == 1 then
				validTile = 1 
				xmod = 0
				ymod = -1
			elseif wallDir == 2 then
				validTile = 2 
				xmod = 1
				ymod = 0
			elseif wallDir == 3 then
				validTile = 3 
				xmod = 0
				ymod = 1
			elseif wallDir == 4 then
				validTile = 4
				xmod = -1
				ymod = 0
			end

			-- check that we haven't got another door nearby, so we won't get alot of openings besides
			-- each other
			if (getCell(newx, newy-1) == tileDoor) then --north
				validTile = 0
			elseif (getCell(newx+1, newy) == tileDoor) then --east
				validTile = 0
			elseif (getCell(newx, newy+1) == tileDoor) then --south
				validTile = 0
			elseif (getCell(newx-1, newy) == tileDoor) then --west
				validTile = 0
			end
			
			--if we can, jump out of the loop and continue with the rest
			if validTile > 0 then break end

			testing = testing + 1
		end -- end for testing loop

		-- We have a tile we can build with so...
		if validTile > 0 then
				--choose what to build now at our newly found place, and at what direction
				feature = getRand(0, 100)
				feature = 85
				-- utils.dbprint("feature is: "..feature)
				if (feature <= chanceRoom) then -- a new room
					if makeRoom((newx), (newy), 8, 6, validTile) then
						-- utils.dbprint("Make a connecting room")
						currentRooms = currentRooms +1 -- add to our quota
 
						-- then we mark the wall opening with a door
						setCell(newx, newy, tileDoor)
 
						-- clean up infront of the door so we can reach it
						-- setCell((newx+xmod), (newy+ymod), tileDirtFloor);
					end
				elseif feature > chanceRoom then -- new corridor
					utils.dbprint("\nmake a connecting corridor")
					if (makeCorridor((newx+xmod), (newy+ymod), roomMax, wallDir)) then
						--same thing here, add to the quota and a door
						-- currentFeatures = currentFeatures + 1
 
						setCell(newx, newy, tileDoor)
					end

				end
			end

		countingTries = countingTries + 1
	end
	










	dunGenFinished = true

	if dunGenFinished == true then
		showDungeon()
		-- utils.tprint(dungeon.map)
	end

end

	

-- 
return dungeon
