--[[----------------------------------------------------------------------------
	Corona Dungeon Generator
	
	Corona SDK version used: 2012.971
	
	File: main.lua
	
	Description: 
	
	Date: 
	
	Authors: Aidan Smyth
	
	Notes: 
	
------------------------------------------------------------------------------]]

-- #############################################################################
-- GLOBAL APPLICATION SETTINGS
-- #############################################################################

-- set default screen background color to white
display.setDefault( "background", 255, 255, 255 )


-- Inital Settings
--------------------------------------------------------------------------------

--Remove status bar
display.setStatusBar( display.HiddenStatusBar ) -- Hide status bar from the beginning

-- Import modules
local GD = require("globalData")					-- Load Global data
local json = require ("json")						-- Load JSON
local storyboard = require ("storyboard")			-- Load Storyboard
local utils = require("modules.tools.utilities")	-- Load utilities

-- Set scenes to purge automatically.
storyboard.purgeOnSceneChange = true

-- os.execute("cls") -- Clear the Corona SDK terminal on restart



-- #############################################################################
-- START APP
-- #############################################################################

-- go to file "menu.lua" use "fade" and take 400ms
storyboard.gotoScene( "scenetemplate", "fade", 200 )


-- #############################################################################
-- Load debug modules
-- #############################################################################
