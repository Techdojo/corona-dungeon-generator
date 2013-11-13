--[[-----------------------------------------------------------------------
	Font Module

	File: fonts.lua
	
	Description: 

	Date: 14/08/2013

	Authors: Aidan Smyth

	Notes: 
	Corona SDK version used: 2012.971
	
	Adapted from:
	http://www.coronalabs.com/blog/2013/01/16/faq-wednesday-custom-fonts/
	
-------------------------------------------------------------------------]]

local device = require("device") 												-- Get system information from device module

-- Create a table that will contain all of our font name we are setting up.
local F = {}

-- Font table
-------------------------------------------------------------------------------------------
-- List of fonts to be used, with the font names for diferent OS's and devices

F.GillInfantReg = ""															-- Add Gill Sans Infant Regular
F.GillInfantBold = ""															-- Add Gill Sans Infant Bold

F.Fallback = native.systemFont													-- Add the systems default font in case other fonts will not load

-- Helper script to get fonts installed on system
-------------------------------------------------------------------------------------------
-- Code to have Corona display the font names found
-- copy into your main.lua file to find the font names of the fonts you want to use on each
-- system the app will be deployed on. COMMENT OUT CODE FOR PRODUCTION


--[[
local fonts = native.getFontNames()
local count = 0
-- Count the number of total fonts
for i,fontname in ipairs(fonts) do
    count = count+1
end
print( "\rFont count = " .. count )
-- Enter part of the font name to look for...
local name = "gill"
-- Get font names to test to see if it is on the system
local name = tostring(name)
-- Display each font in the terminal console
for i, fontname in ipairs(fonts) do
	name = string.lower( name )
	j, k = string.find( string.lower( fontname ), name )
	if( j ~= nil ) then
		print( "fontname = " .. tostring( fontname ) )
	end
end
]]--



-- Font Names
-------------------------------------------------------------------------------------------
-- Using the code block above enter the font names listed for each platform


if device.isSimulator then														-- If app is running on a PC's simulator
	if "Win" == device.OS then													-- If the OS is windows set font names as...
		F.GillInfantReg = "GillSansInfantStdRegular"
		F.GillInfantBold = "GillSansInfantStdRegular"							-- Gill Sans Infant Bold doesn't work on windows so add in Gill Sans Infant Regular
	elseif device.OS == "Mac OS X" then											-- If the OS is Mac OS set font names as...
		F.GillInfantReg = "GillSansInfantStdRegular"
		F.GillInfantBold = "GillSansInfantStdBold"
	end
else 																			-- otherwise it is running on a device so...
	if device.isApple then														-- if the app is running on an iOS device set font names as...
		F.GillInfantReg = "GillSansInfantStdRegular"
		F.GillInfantBold = "GillSansInfantStdBold"
	elseif device.isAndroid then												-- if the app is running on an Android device set font names as...
		F.GillInfantReg = "GillSansInfantStdRegular"
		F.GillInfantBold = "GillSansInfantStdBold"
	else 																		-- if all else fails set font names as...
		-- If none of the above use a fallback font
		F.GillInfantReg = F.Fallback
		F.GillInfantBold = F.Fallback
	end
end

-- Return the table "F", providing access to it from where the module is "required"
return F