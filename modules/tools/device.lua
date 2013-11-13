--[[-----------------------------------------------------------------------
	Device Module

	File: device.lua
	
	Description: 

	Date: 14/08/2013

	Authors: Aidan Smyth

	Notes: 
	Corona SDK version used: 2012.971
   
   -- Adapted from:
   http://www.coronalabs.com/blog/2012/12/11/device-detection-on-steroids/
	
-------------------------------------------------------------------------]]

-- Create a table that will contain all of our tests we are setting up.
local M = {}
 
-- Set up some defaults...
M.OS = system.getInfo( "platformName" )											-- Get the system OS
M.isSimulator = false															-- Boolean: is the app running on a simulator

M.windows = false																-- Boolean: is the app running on windows
M.isApple = false																-- Boolean: is the app running on Mac OS

M.iOS = false																	-- Boolean: is the app running on a iOS device
M.isAndroid = false																-- Boolean: is the app running on a Android device

M.isGoogle = false																-- Boolean: is the app running on a google device
M.isKindleFire = false															-- Boolean: is the app running on a kindle

M.isNook = false																-- Boolean: is the app running on a Nook

M.is_iPad = false																-- Boolean: is the app running on a iPad

M.isTall = false																-- Boolean: is the app running on a tall device (iphone 5)


-- local OS = system.getInfo( "platformName" )
local model = system.getInfo("model")											-- Get the device model number

-- Are we on the Simulator?
if ( "simulator" == system.getInfo("environment") ) then						-- If the app is running on a simulator
    M.isSimulator = true														-- Set simulator
end

if ( (display.pixelHeight/display.pixelWidth) > 1.5 ) then						-- If the pixel height is 1.5
   M.isTall = true																-- the device is tall
end
 
-- Now identify the Apple family of devices:
if ( string.sub( model, 1, 2 ) == "iP" ) then 
   -- We are an iOS device of some sort
   M.isApple = true
 
   if ( string.sub( model, 1, 4 ) == "iPad" ) then
      M.is_iPad = true
   end
 
else --...(the rest of the else is below)

   -- Not Apple, so it must be one of the Android devices
   M.isAndroid = true
 
   -- Let's assume we are on Google Play for the moment
   M.isGoogle = true
 
   -- All of the Kindles start with "K", although Corona builds before #976 returned
   -- "WFJWI" instead of "KFJWI" (this is now fixed, and our clause handles it regardless)
   if ( model == "Kindle Fire" or model == "WFJWI" or string.sub( model, 1, 2 ) == "KF" ) then
      M.isKindleFire = true
      M.isGoogle = false  --revert Google Play to false
   end
 
   -- Are we on a Nook?
   if ( string.sub( model, 1 ,4 ) == "Nook") then
      M.isNook = true
      M.isGoogle = false  --revert Google Play to false
   end
 
end

-- Return the table "M", providing access to it from where the module is "require"d
return M
