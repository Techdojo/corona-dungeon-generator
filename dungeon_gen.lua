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
	
	local makeCorridor = function(x, y, lenght, direction)
		-- define the dimensions of the corridor (er.. only the width and height..)
		local len = getRand(2, lenght)
		local floor = tileCorridor
		local dir = 0
		
		if direction > 0 and direction < 4 then
			dir = direction
		end
		
		local xtemp = 0;
		local ytemp = 0;
		
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
					return false -- oh boho, it was!
				end

				if getCell(xtemp, ytemp) ~= tileUnused then
					return false
				end

				ytemp = ytemp - 1
			end

			-- if we're still here, let's start building
			for ytemp = y, ytemp > (y-len) do
				setCell(xtemp, ytemp, floor)
				ytemp =  ytemp - 1
			end

		elseif dir == 1 then
			-- east
			if y < 0 or y > ysize then
				return false
			else
				ytemp = y
			end

			for (xtemp = x; xtemp < (x+len); xtemp++){
				if (xtemp < 0 or xtemp > xsize) return false;
				if (getCell(xtemp, ytemp) ~= tileUnused) return false;
			}

			for (xtemp = x; xtemp < (x+len); xtemp++){
				setCell(xtemp, ytemp, floor);
			}
		elseif dir == 2 then
			-- south
			if (x < 0 or x > xsize) return false;
			else xtemp = x;
 
			for (ytemp = y; ytemp < (y+len); ytemp++){
				if (ytemp < 0 or ytemp > ysize) return false;
				if (getCell(xtemp, ytemp) ~= tileUnused) return false;
			}
 
			for (ytemp = y; ytemp < (y+len); ytemp++){
				setCell(xtemp, ytemp, floor);
			}
		elseif dir == 3 then
			-- west
			if (ytemp < 0 or ytemp > ysize) return false;
			else ytemp = y;
 
			for (xtemp = x; xtemp > (x-len); xtemp--){
				if (xtemp < 0 or xtemp > xsize) return false;
				if (getCell(xtemp, ytemp) ~= tileUnused) return false; 
			}
 
			for (xtemp = x; xtemp > (x-len); xtemp--){
				setCell(xtemp, ytemp, floor);
			}
		}
 
		-- woot, were still here! lets tell the other guys were done!!
		return true;
	}

	local makeRoom = function(x, y, xlength, ylength, direction)
		-- define the dimensions of the room, it should be at least 4x4 tiles 
		-- (2x2 for walking on, the rest is walls)
		xlen = getRand(4, xlength);
		ylen = getRand(4, ylength);
		--the tile type it's going to be filled with
		floor = tileDirtFloor; --jordgolv..
		wall = tileDirtWall; --jordv????gg
		--choose the way it's pointing at
		dir = 0;
		if direction > 0 && direction < 4 then
			dir = direction
		end
 
		switch(dir){
		case 0:
		-- north
			-- Check if there's enough space left for it
			for (int ytemp = y; ytemp > (y-ylen); ytemp--){
				if (ytemp < 0 or ytemp > ysize) return false;
				for (int xtemp = (x-xlen/2); xtemp < (x+(xlen+1)/2); xtemp++){
					if (xtemp < 0 or xtemp > xsize) return false;
					if (getCell(xtemp, ytemp) ~= tileUnused) return false; -- no space left...
				}
			}
 
			-- we're still here, build
			for (int ytemp = y; ytemp > (y-ylen); ytemp--){
				for (int xtemp = (x-xlen/2); xtemp < (x+(xlen+1)/2); xtemp++){
					-- start with the walls
					if (xtemp == (x-xlen/2)) setCell(xtemp, ytemp, wall);
					else if (xtemp == (x+(xlen-1)/2)) setCell(xtemp, ytemp, wall);
					else if (ytemp == y) setCell(xtemp, ytemp, wall);
					else if (ytemp == (y-ylen+1)) setCell(xtemp, ytemp, wall);
					-- and then fill with the floor
					else setCell(xtemp, ytemp, floor);
				}
			}
			break;
		case 1:
		-- east
			for (int ytemp = (y-ylen/2); ytemp < (y+(ylen+1)/2); ytemp++){
				if (ytemp < 0 or ytemp > ysize) return false;
				for (int xtemp = x; xtemp < (x+xlen); xtemp++){
					if (xtemp < 0 or xtemp > xsize) return false;
					if (getCell(xtemp, ytemp) ~= tileUnused) return false;
				}
			}
 
			for (int ytemp = (y-ylen/2); ytemp < (y+(ylen+1)/2); ytemp++){
				for (int xtemp = x; xtemp < (x+xlen); xtemp++){
 
					if (xtemp == x) setCell(xtemp, ytemp, wall);
					else if (xtemp == (x+xlen-1)) setCell(xtemp, ytemp, wall);
					else if (ytemp == (y-ylen/2)) setCell(xtemp, ytemp, wall);
					else if (ytemp == (y+(ylen-1)/2)) setCell(xtemp, ytemp, wall);
 
					else setCell(xtemp, ytemp, floor);
				}
			}
			break;
		case 2:
		-- south
			for (int ytemp = y; ytemp < (y+ylen); ytemp++){
				if (ytemp < 0 or ytemp > ysize) return false;
				for (int xtemp = (x-xlen/2); xtemp < (x+(xlen+1)/2); xtemp++){
					if (xtemp < 0 or xtemp > xsize) return false;
					if (getCell(xtemp, ytemp) ~= tileUnused) return false;
				}
			}
 
			for (int ytemp = y; ytemp < (y+ylen); ytemp++){
				for (int xtemp = (x-xlen/2); xtemp < (x+(xlen+1)/2); xtemp++){
 
					if (xtemp == (x-xlen/2)) setCell(xtemp, ytemp, wall);
					else if (xtemp == (x+(xlen-1)/2)) setCell(xtemp, ytemp, wall);
					else if (ytemp == y) setCell(xtemp, ytemp, wall);
					else if (ytemp == (y+ylen-1)) setCell(xtemp, ytemp, wall);
 
					else setCell(xtemp, ytemp, floor);
				}
			}
			break;
		case 3:
		-- west
			for (int ytemp = (y-ylen/2); ytemp < (y+(ylen+1)/2); ytemp++){
				if (ytemp < 0 or ytemp > ysize) return false;
				for (int xtemp = x; xtemp > (x-xlen); xtemp--){
					if (xtemp < 0 or xtemp > xsize) return false;
					if (getCell(xtemp, ytemp) ~= tileUnused) return false; 
				}
			}
 
			for (int ytemp = (y-ylen/2); ytemp < (y+(ylen+1)/2); ytemp++){
				for (int xtemp = x; xtemp > (x-xlen); xtemp--){
 
					if (xtemp == x) setCell(xtemp, ytemp, wall);
					else if (xtemp == (x-xlen+1)) setCell(xtemp, ytemp, wall);
					else if (ytemp == (y-ylen/2)) setCell(xtemp, ytemp, wall);
					else if (ytemp == (y+(ylen-1)/2)) setCell(xtemp, ytemp, wall);
 
					else setCell(xtemp, ytemp, floor);
				}
			}
			break;
		}
 
		-- yay, all done
		return true;
	}
 
 
	-- used to print the map on the screen
	local showDungeon = function ()
		for (int y = 0; y < ysize; y++){
			for (int x = 0; x < xsize; x++){
				-- print(getCell(x, y))
				switch(getCell(x, y)){
				case tileUnused:
					print(" ")
					break
				case tileDirtWall:
					print("+")
					break
				case tileDirtFloor:
					print(".")
					break
				case tileStoneWall:
					print("O")
					break
				case tileCorridor:
					print("#")
					break
				case tileDoor:
					print("D")
					break
				case tileUpStairs:
					print("<")
					break
				case tileDownStairs:
					print(">")
					break
				case tileChest:
					print("*")
					break
				};
			}
			if xsize <= xmax then
				print()
			end
		}
	}
 
	-- and here's the one generating the whole map
	local createDungeon = function(inx, iny, inobj)
		if inobj < 1 then
			objects = 10
		else 
			objects = inobj
		end
 
		-- justera kartans storlek, om den ????r st????rre eller mindre ????n "gr????nserna"
		-- adjust the size of the map, if it's smaller or bigger than the limits
		if inx < 3 then
			xsize = 3
		else if inx > xmax
			xsize = xmax
		else
			xsize = inx
		end
 
		if iny < 3 then
			ysize = 3
		else if iny > ymax then
			ysize = ymax
		else 
			ysize = iny
		end
 
		print(msgXSize .. xsize)
		print(msgYSize .. ysize)
		print(msgMaxObjects .. objects)
 
		-- redefine the map var, so its adjusted to our new map size
		dungeon_map = new int[xsize * ysize];
 
		-- start with making the "standard stuff" on the map
		for y = 0, y < ysize do
			for x = 0, x < xsize do
				-- ie, making the borders of unwalkable walls
				if (y == 0) 
					setCell(x, y, tileStoneWall)
				else if (y == ysize-1) 
					setCell(x, y, tileStoneWall)
				else if (x == 0) 
					setCell(x, y, tileStoneWall)
				else if (x == xsize-1) 
					setCell(x, y, tileStoneWall)
				else
					-- and fill the rest with dirt
					setCell(x, y, tileUnused)
				end
				
				x = x + 1
			}
			y = y + 1
		}
 
		--[[*******************************************************************************
		And now the code of the random-map-generation-algorithm begins!
		*******************************************************************************]]
 
		-- start with making a room in the middle, which we can start building upon
		makeRoom(xsize/2, ysize/2, 8, 6, getRand(0,3)); -- getrand saken f????r att slumpa fram riktning p?? rummet
 
		-- keep count of the number of "objects" we've made
		int currentFeatures = 1; -- +1 for the first room we just made
 
		-- then we sart the main loop
		for (int countingTries = 0; countingTries < 1000; countingTries++){
			-- check if we've reached our quota
			if (currentFeatures == objects){
				break;
			}
 
			-- start with a random wall
			local newx = 0;
			local xmod = 0;
			local newy = 0;
			local ymod = 0;
			local validTile = -1;
			
			-- 1000 chances to find a suitable object (room or corridor)..
			-- (yea, i know its kinda ugly with a for-loop... -_-)
			for (testing = 0, testing < 1000) do
				newx = getRand(1, xsize-1);
				newy = getRand(1, ysize-1);
				validTile = -1;
				-- System.out.println("tempx: " + newx + "\ttempy: " + newy);
				if (getCell(newx, newy) == tileDirtWall or getCell(newx, newy) == tileCorridor){
					-- check if we can reach the place
					if (getCell(newx, newy+1) == tileDirtFloor or getCell(newx, newy+1) == tileCorridor){
						validTile = 0; -- 
						xmod = 0;
						ymod = -1;
					}
					else if (getCell(newx-1, newy) == tileDirtFloor or getCell(newx-1, newy) == tileCorridor){
						validTile = 1; -- 
						xmod = +1;
						ymod = 0;
					}
					else if (getCell(newx, newy-1) == tileDirtFloor or getCell(newx, newy-1) == tileCorridor){
						validTile = 2; -- 
						xmod = 0;
						ymod = +1;
					}
					else if (getCell(newx+1, newy) == tileDirtFloor or getCell(newx+1, newy) == tileCorridor){
						validTile = 3; -- 
						xmod = -1;
						ymod = 0;
					}
 
					-- check that we haven't got another door nearby, so we won't get alot of openings besides
					-- each other
					if (validTile > -1){
						if (getCell(newx, newy+1) == tileDoor) -- north
							validTile = -1;
						else if (getCell(newx-1, newy) == tileDoor)-- east
							validTile = -1;
						else if (getCell(newx, newy-1) == tileDoor)-- south
							validTile = -1;
						else if (getCell(newx+1, newy) == tileDoor)-- west
							validTile = -1;
					}
 
					-- if we can, jump out of the loop and continue with the rest
					if (validTile > -1) break;
				}
				testing = testing + 1
			}
			if (validTile > -1){
				-- choose what to build now at our newly found place, and at what direction
				int feature = getRand(0, 100);
				if (feature <= chanceRoom){ -- a new room
					if (makeRoom((newx+xmod), (newy+ymod), 8, 6, validTile)){
						currentFeatures++; -- add to our quota
 
						-- then we mark the wall opening with a door
						setCell(newx, newy, tileDoor);
 
						-- clean up infront of the door so we can reach it
						setCell((newx+xmod), (newy+ymod), tileDirtFloor);
					}
				}
				else if (feature >= chanceRoom){ -- new corridor
					if (makeCorridor((newx+xmod), (newy+ymod), 6, validTile)){
						-- same thing here, add to the quota and a door
						currentFeatures++;
 
						setCell(newx, newy, tileDoor);
					}
				}
			}
		}
 
 
		--[[******************************************************************************
		All done with the building, lets finish this one off
		*******************************************************************************]]
 
		-- sprinkle out the bonusstuff (stairs, chests etc.) over the map
		int newx = 0;
		int newy = 0;
		int ways = 0; -- from how many directions we can reach the random spot from
		int state = 0; -- the state the loop is in, start with the stairs
		while (state ~= 10){
			for (int testing = 0; testing < 1000; testing++){
				newx = getRand(1, xsize-1);
				newy = getRand(1, ysize-2); -- cheap bugfix, pulls down newy to 0<y<24, from 0<y<25
 
				-- System.out.println("x: " + newx + "\ty: " + newy);
				ways = 4; -- the lower the better
 
				-- check if we can reach the spot
				if (getCell(newx, newy+1) == tileDirtFloor or getCell(newx, newy+1) == tileCorridor){
				-- north
					if (getCell(newx, newy+1) ~= tileDoor)
					ways--;
				}
				if (getCell(newx-1, newy) == tileDirtFloor or getCell(newx-1, newy) == tileCorridor){
				-- east
					if (getCell(newx-1, newy) ~= tileDoor)
					ways--;
				}
				if (getCell(newx, newy-1) == tileDirtFloor or getCell(newx, newy-1) == tileCorridor){
				-- south
					if (getCell(newx, newy-1) ~= tileDoor)
					ways--;
				}
				if (getCell(newx+1, newy) == tileDirtFloor or getCell(newx+1, newy) == tileCorridor){
				-- west
					if (getCell(newx+1, newy) ~= tileDoor)
					ways--;
				}
 
				if (state == 0){
					if (ways == 0){
					-- we're in state 0, let's place a "upstairs" thing
						setCell(newx, newy, tileUpStairs);
						state = 1;
						break;
					}
				}
				else if (state == 1){
					if (ways == 0){
					-- state 1, place a "downstairs"
						setCell(newx, newy, tileDownStairs);
						state = 10;
						break;
					}
				}
			}
		}
 
 
		-- all done with the map generation, tell the user about it and finish
		System.out.println(msgNumObjects + currentFeatures);
 
		return true;
	}
---------------------------------------------------------
 
	public static void main(String[] args){
		-- initial stuff used in making the map
		int x = 80; int y = 25; int dungeon_objects = 0;
 
		-- convert a string to a int, if there's more then one arg
		if (args.length >= 1)
			dungeon_objects = Integer.parseInt(args[0]);
		if (args.length >= 2)
			x = Integer.parseInt(args[1]);
 
		if (args.length >= 3)
			y = Integer.parseInt(args[2]);
		-- create a new class of "dungen", so we can use all the goodies within it
		dungen generator = new dungen();
 
		-- then we create a new dungeon map
		if (generator.createDungeon(x, y, dungeon_objects)){
			-- always good to be able to see the results..
			generator.showDungeon();
		}
	}
}
