--[[----------------------------------------------------------------------------
	Utilities Module

	File: globalData.lua
	
	Description: 
	Collection of common useful functions

	Date: 

	Authors: Aidan Smyth

	Notes: 
	Corona SDK version used: 2012.971
	
	
------------------------------------------------------------------------------]]

-- 
local GD = require("globalData")					-- Load Global data


-- 
local utils = {}
-- print("utilities module loaded")


-- GLOBAL VARIABLES
--------------------------------------------------------------------------------

-- GLOBAL FUNCTION TO PRINT TABLE
--------------------------------------------------------------------------------
-- Print contents of a table
utils.tprint = function(tbl, indent)
	--print("Printing contents of table")
	if not indent then indent = 0 end
	for k, v in pairs(tbl) do
		formatting = string.rep(" ", indent) .. k ..": "
		if type(v) == "table" then
			print(formatting)
			tprint(v, indent+1)
		else
			print(formatting .. tostring(v))
		end
	end
end

-- GLOBAL FUNCTION TO DEEP COPY A TABLE
--------------------------------------------------------------------------------
utils.deepcopy = function(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--
--------------------------------------------------------------------------------
utils.dbprint = function(message)
	-- print("dbprint called")
	local msg = message
	if GD.debugging == true then
		print(msg)
	end
end


-- 
return utils
