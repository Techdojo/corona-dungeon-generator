--[[

]]

local dungen = {}
	
	-- Maximum size of the map
	local xmax = 80											-- Maximum map width in columns (1 column = 32px)
	local ymax = 25											-- Maximum map height in rows of (1 row = 32px)
	
	-- Size of the map
	local xsize = 0											-- Actual map width in columns (1 column = 32px), 0 by default
	local ysize = 0											-- Actual map height in rows of (1 row = 32px), 0 by default
	
	-- Number of "objects" to generate
	local objects = 0
	
	-- define the %chance to generate either a room or a corridor on the map
	-- BTW, rooms are 1st priority so actually it's enough to just define the chance
	-- of generating a room
	local chanceRoom = 75									-- % chance for adding a room
	local chanceCorridor = 25								-- % chance for adding a corridor
	
	-- the dungeon map data
	local dungeon_map = {}									-- Table to hold the map data
	
	-- we will store the old random seed here
	local oldseed = 0
	
	--a list over tile types we're using
	local tileUnused = 0
	local tileDirtWall = 1		-- not in use
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


	-- setting a tile's type
	local setCell = function(x, y, cellType)
		dungeonMap[x + xsize * y] = celltype
	end
 
	-- returns the type of a tile
	
	local getcell = function(x, y)
		return dungeon_map[x + xsize * y]	
	end
	
	-- The RNG. the seed is based on seconds from the OS date/time
	local getRand = function(min, max)
		-- the seed is based on current date/time and the old, already used seed
		local now = os.time()
		local seed = now + oldseed
		oldseed = seed
		
		randomizer = math.randomseed(seed)
		n = max - min + 1
		i = math.random(n)
		
		if i < 0 then
			i = -i
		end
		-- print("seed: " .. seed .. "\n num:  " .. (min + i));
		return min + 1
	end
	
	




end

return dungen