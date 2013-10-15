-------------------------------------------------
--
-- cat.lua
--
-- Example "cat" class for Corona SDK tutorial.
--
-------------------------------------------------
print("cat module loaded")

local cat = {}
local cat_mt = { __index = cat }	-- metatable

-------------------------------------------------
-- PRIVATE FUNCTIONS
-------------------------------------------------
 
local function getCatYears( realYears )	-- local; only visible in this module
	return realYears * 7
end
 
-------------------------------------------------
-- PUBLIC FUNCTIONS
-------------------------------------------------
 
function cat.new( name, ageInYears )	-- constructor
	print("cat name: " .. name)
	print("cat age" .. ageInYears)
	local newCat = {
		name = name or "Unnamed",
		age = ageInYears or 2
	}
	
	return setmetatable( newCat, cat_mt )
end

return cat