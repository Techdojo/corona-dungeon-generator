--[[----------------------------------------------------------------------------
	Dungeon Generator Module

	File: dungeon_gen_bsp.lua
	
	Description: 
	

	Date: 

	Authors: Aidan Smyth

	Notes: 
	Corona SDK version used: 2012.971
	
	
------------------------------------------------------------------------------]]

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