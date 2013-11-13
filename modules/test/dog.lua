-------------------------------------------------
--
-- dog.lua
--
-- Example "dog" class for Corona SDK tutorial.
--
-------------------------------------------------
print("dog module loaded")

local dog = {}
local dog_mt = { __index = dog }	-- metatable
 
-------------------------------------------------
-- PRIVATE FUNCTIONS
-------------------------------------------------
 
local function getDogYears( realYears )	-- local; only visible in this module
	return realYears * 7
end
 
-------------------------------------------------
-- PUBLIC FUNCTIONS
-------------------------------------------------
 
function dog.new( name, ageInYears )	-- constructor
		
	local newDog = {
		name = name or "Unnamed",
		age = ageInYears or 2
	}
	
	return setmetatable( newDog, dog_mt )
end
 
-------------------------------------------------
 
function dog:rollOver()
	print( self.name .. " rolled over." )
end
 
-------------------------------------------------
 
function dog:sit()
	print( self.name .. " sits down in place." )
end
 
-------------------------------------------------
 
function dog:bark()
	print( self.name .. " says \"woof!\"" )
end
 
-------------------------------------------------
 
function dog:printAge()
	print( self.name .. " is " .. getDogYears( self.age ) .. " in dog years." )
end
 
-------------------------------------------------
 
return dog