--[[----------------------------------------------------------------------------
	Dungeon Generator Module

	File: gungeon_gen.lua
	
	Description: 
	Collection of common useful functions

	Date: 

	Authors: Aidan Smyth

	Notes: 
	Corona SDK version used: 2012.971
	
	
------------------------------------------------------------------------------]]

local utils = require("utilities")					-- Load utilities

local dunGen = {}
local dunGen_mt = { __index = dunGen }				-- metatable
	
-- Maximum size of the map
local xmax = 80										-- Maximum map width in columns (1 column = 32px)
local ymax = 25										-- Maximum map height in rows of (1 row = 32px)

-- Size of the map
local xsize = 80									-- Actual map width in columns (1 column = 32px), 0 by default
local ysize = 25									-- Actual map height in rows of (1 row = 32px), 0 by default

-- Number of "objects" to generate
local objects = 0

-- define the %chance to generate either a room or a corridor on the map
-- BTW, rooms are 1st priority so actually it's enough to just define the chance
-- of generating a room
local chanceRoom = 75								-- % chance for adding a room
local chanceCorridor = 25							-- % chance for adding a corridor

-- the dungeon map data
local dungeon_map = {}								-- Table to hold the map data

-- we will store the old random seed here
local oldseed = 0

--a list over tile types we're using
local tileUnused = 0
local tileDirtWall = 1								-- not in use
local tileDirtFloor = 2
local tileStoneWall = 3
local tileCorridor = 4
local tileDoor = 5
local tileUpStairs = 6
local tileDownStairs = 7
local tileChest = 8

-- misc. messages to print
local msgXSize = "X size of dungeon: "
local msgYSize = "Y size of dungeon: "
local msgMaxObjects = "max # of objects: "
local msgNumObjects = "# of objects made: "
local msgHelp = ""
local msgDetailedHelp = ""

local dunGenFinished = false

-------------------------------------------------
-- PRIVATE FUNCTIONS
-------------------------------------------------

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
	local now = os.time()
	-- print("os.time is: " .. now)
	-- print("Oldseed is: " .. oldseed)
	local seed = now + oldseed
	-- print("seed is: " .. seed)
	oldseed = seed
	
	math.randomseed(seed)

	-- print("seed: " .. seed .. "\n num:  " .. (min + i));
	local n = max - min + 1
	-- local i = randomizer.nextInt(n);

	local rand = math.random(min, max)
	-- print("rand is: " .. rand)

	if (rand < 0) then
		rand = -rand;
		-- System.out.println("seed: " + seed + "\tnum:  " + (min + i));
	end

	return min + rand
end


local function makeCorridor(x, y, lenght, direction)
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
		for ytemp = y, ytemp > (y-len) do
			if ytemp < 0 or ytemp > ysize then
				return false									-- oh boho, it was!
			end

			if getCell(xtemp, ytemp) ~= tileUnused then
				return false
			end

			ytemp = ytemp - 1
		end

		-- if we're still here, let's start building
		for ytemp = y, ytemp > (y-len) do
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

		for xtemp = x, xtemp < (x+len) do

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

		for ytemp = y, ytemp < (y+len) do
			if ytemp < 0 or ytemp > ysize then
				return false
			end

			if getCell(xtemp, ytemp) ~= tileUnused then
				return false
			end

			ytemp = ytemp + 1
		end

		for ytemp = y, ytemp < (y+len) do
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

		for xtemp = x, xtemp > (x-len) do
			if xtemp < 0 or xtemp > xsize then
				return false
			end

			if getCell(xtemp, ytemp) ~= tileUnused then
				return false
			end

			xtemp = xtemp - 1
		end

		for xtemp = x, xtemp > (x-len) do
			setCell(xtemp, ytemp, floor)
			xtemp = xtemp - 1
		end
	end

	--woot, we're still here! let's tell the other guys we're done!!
	return true
end

local function makeRoom(x, y, xlength, ylength, direction)
	print("Make a room")
	-- define the dimensions of the room, it should be at least 4x4 tiles (2x2 for walking on, the rest is walls)
	local xlen = getRand(4, xlength)
	local ylen = getRand(4, ylength)
	--the tile type it's going to be filled with
	local floor = tileDirtFloor
	local wall = tileDirtWall

	-- choose the way it's pointing at
	local dir = 0

	if direction > 0 or direction < 4 then
		dir = direction
	end

	if dir == 0 then
		print("North")
		-- north
		-- Check if there's enough space left for it
		local ytemp = math.floor(y)
		local xtemp = math.floor(x-xlen/2)
		print("ytemp is: " .. ytemp .. " and xtemp is: " .. xtemp)

		-- Check if there is enough room for the room
		while ytemp > (y-ylen) do
			-- Check room starts at the top or max width
			if ytemp < 0 or ytemp > ysize then
				print("return false 1")
				return false
			end

			while xtemp < (x+(xlen+1)/2) do
				if xtemp < 0 or xtemp > xsize then
					print("return false 2")
					return false
				end

				if getCell(xtemp, ytemp) ~= tileUnused then
					print("return false 3")
					return false
				end -- no space left...

				xtemp = xtemp + 1
			end

			ytemp = ytemp - 1
		end

		ytemp = math.floor(y)
		xtemp = math.floor(x-xlen/2)
		-- we're still here, build
		while ytemp > (y-ylen) do
			print(ytemp .. " > " .. math.floor(y-ylen))
			while xtemp < math.floor(x+(xlen+1)/2) do
				-- start with the walls
				if xtemp == math.floor(x-xlen/2) then
					setCell(xtemp, ytemp, wall)
				elseif xtemp == math.floor(x+(xlen-1)/2) then
					setCell(xtemp, ytemp, wall)
				elseif ytemp == y then
					setCell(xtemp, ytemp, wall)
				elseif ytemp == (y-ylen+1) then
					setCell(xtemp, ytemp, wall)
					-- and then fill with the floor
				else
					setCell(xtemp, ytemp, floor)
				end

				xtemp = xtemp + 1
			end

			ytemp = ytemp - 1
		end
		
	elseif dir == 1 then
		print("east")
		-- east
		local ytemp = math.floor(y-ylen/2)
		local xtemp = math.floor(x)
		print("ytemp is: " .. ytemp .. " and xtemp is: " .. xtemp)

		while ytemp < (y+(ylen+1)/2) do
			if ytemp < 0 or ytemp > ysize then
				return false
			end
			while xtemp < (x+xlen) do
				if xtemp < 0 or xtemp > xsize then
					return false
				end
				if getCell(xtemp, ytemp) ~= tileUnused then
					return false
				end

				xtemp = xtemp + 1
			end

			ytemp = ytemp + 1
		end

		ytemp = math.floor(y-ylen/2)
		xtemp = math.floor(x)
		while ytemp < (y+(ylen+1)/2) do
			while xtemp < (x+xlen) do

				if xtemp == x then
					setCell(xtemp, ytemp, wall)
				elseif xtemp == (x+xlen-1) then
					setCell(xtemp, ytemp, wall)
				elseif ytemp == (y-ylen/2) then
					setCell(xtemp, ytemp, wall)
				elseif ytemp == (y+(ylen-1)/2) then
					setCell(xtemp, ytemp, wall)
				else
					setCell(xtemp, ytemp, floor)
				end

				xtemp = xtemp + 1
			end

			ytemp = ytemp + 1
		end
		
	elseif dir == 2 then
		print("South")
		-- south
		local ytemp = math.floor(y)
		local xtemp = math.floor(x-xlen/2)
		print("ytemp is: " .. ytemp .. " and xtemp is: " .. xtemp)

		while ytemp < (y+ylen) do
			if ytemp < 0 or ytemp > ysize then
				return false
			end
			while xtemp < (x+(xlen+1)/2) do
				if xtemp < 0 or xtemp > xsize then
					return false
				end
				if getCell(xtemp, ytemp) ~= tileUnused then
					return false
				end

				xtemp = xtemp + 1
			end

			ytemp = ytemp + 1
		end

		ytemp = math.floor(y)
		xtemp = math.floor(x-xlen/2)
		while ytemp < (y+ylen) do
			while xtemp < (x+(xlen+1)/2) do

				if xtemp == (x-xlen/2) then
					setCell(xtemp, ytemp, wall)
				elseif xtemp == (x+(xlen-1)/2) then
					setCell(xtemp, ytemp, wall)
				elseif ytemp == y then
					setCell(xtemp, ytemp, wall)
				elseif ytemp == (y+ylen-1) then
					setCell(xtemp, ytemp, wall)
				else
					setCell(xtemp, ytemp, floor)
				end

				xtemp = xtemp + 1
			end

			ytemp = ytemp + 1
		end
		
	elseif dir == 3 then
		print("West")
		-- west
		local ytemp = math.floor(y-ylen/2)
		local xtemp = math.floor(x)
		print("ytemp is: " .. ytemp .. " and xtemp is: " .. xtemp)

		while ytemp < (y+(ylen+1)/2) do
			if ytemp < 0 or ytemp > ysize then
				return false
			end

			while xtemp > (x-xlen) do
				if xtemp < 0 or xtemp > xsize then
					return false
				end

				if getCell(xtemp, ytemp) ~= tileUnused then
					return false
				end

				xtemp = xtemp - 1
			end
			ytemp = ytemp + 1
		end

		ytemp = math.floor(y-ylen/2)
		xtemp = math.floor(x)
		while ytemp < (y+(ylen+1)/2) do
			while xtemp > (x-xlen) do

				if xtemp == x then setCell(xtemp, ytemp, wall)
				elseif xtemp == (x-xlen+1) then setCell(xtemp, ytemp, wall)
				elseif ytemp == (y-ylen/2) then setCell(xtemp, ytemp, wall)
				elseif ytemp == (y+(ylen-1)/2) then setCell(xtemp, ytemp, wall)
				else setCell(xtemp, ytemp, floor) end

				xtemp = xtemp - 1
			end

			ytemp = ytemp + 1
		end
		
	end

	-- yay, all done
	return true
end


-- used to print the map on the console
local function showDungeon() 
	-- print("showDungeon called")

	local topRow = "top 123456789*123456789*123456789*123456789*123456789*123456789*123456789*"
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
				mapRow = mapRow .. "+"
			elseif cell == tileDirtFloor then
				mapRow = mapRow .. "."
			elseif cell == tileStoneWall then
				mapRow = mapRow .. "N"
			elseif cell == tileCorridor then
				mapRow = mapRow .. "#"
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

-------------------------------------------------
-- PUBLIC FUNCTIONS
-------------------------------------------------

function dunGen.createDungeon( intx, inty, intobj )
	print("dunGen.createDungeon called")

	if intobj < 1 then 
		objects = 10
	else
		objects = intobj
	end

	if intx == nil then
		xsize = 3
	elseif intx < 3 then 
		xsize = 3
	elseif intx > xmax then 
		xsize = xmax
	else 
		xsize = intx 
	end

	if inty == nil then
		ysize = 3
	elseif inty < 3 then 
		ysize = 3
	elseif inty > ymax then 
		ysize = ymax
	else 
		ysize = inty 
	end

	print(msgXSize .. xsize)
	print(msgYSize .. ysize)
	print(msgMaxObjects .. objects)

	-- redefine the map var, so it's adjusted to our new map size
	-- for y=1, ysize do
	-- 	for x=1,xsize do
	-- 		dungeon_map[x + xsize * y] = 0	-- [x + xsize * y]
	-- 		x = x + 1
	-- 	end
	-- 	y = y + 1
	-- end

	print("Fill map table with default data")
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
	-- *******************************************************************************/

	-- start with making a room in the middle, which we can start building upon
	makeRoom(xsize/2, ysize/2, 10, 10, 0); -- getRand(0,3)

	-- keep count of the number of "objects" we've made
	currentFeatures = 1; -- +1 for the first room we just made









	dunGenFinished = true

	if dunGenFinished == true then
		showDungeon()
		-- utils.tprint(dungeon_map)
	end
end
	
	

-- 
return dunGen