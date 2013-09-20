--[[-----------------------------------------------------------------------
	globalData Module

	File: globalData.lua
	
	Description: 

	Date: 

	Authors: Aidan Smyth

	Notes: 
	Corona SDK version used: 2012.971
	
	
-------------------------------------------------------------------------]]

-- 
local GD = {}
print("globalData loaded")


-- GLOBAL VARIABLES
-------------------------------------------------------------------------------------------

-- Create GLOBAL variables for positioning
GD.orientation
GD.screenWidth = display.contentWidth           -- Screen width
GD.screenHeight = display.contentHeight         -- Screen height
GD.screenTop = 0                                -- Screen Top
GD.screenRight = display.contentWidth           -- Screen Right
GD.screenBottom = display.contentHeight         -- Screen Bottom
GD.screenLeft = 0                               -- Screen Left
GD.screenCenterX = display.contentWidth/2       -- Horizontal Center 
GD.screenCenterY = display.contentHeight/2      -- Vertical Center

-- 
return GD
