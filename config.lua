--[[----------------------------------------------------------------------------
	Corona config file

    File: config.lua
  
	Description: 

    Date: 

    Authors: Aidan Smyth

    Notes: 
	Corona SDK version used: 2012.971
  
------------------------------------------------------------------------------]]

--[[ 
    http://www.coronalabs.com/blog/2012/12/04/the-ultimate-config-lua-file/ 
]]

application = {
    content = {
        width = 1024,				-- 
        height = 768,				-- 
        scale = "letterBox",		-- 
        xAlign = "center",			-- 
        yAlign = "center",			-- 
        fps = 60, 					-- 30/60 frames per second
        imageSuffix = {
            ["@2x"] = 1.5,  		-- Double resolution devices = iPhone 5, iPad 3 / ["file suffix"] = scale factor
        },
    },

    --
    --[[ Push notifications

    notification =
    {
        iphone =
        {
            types =
            {
                "badge", "sound", "alert", "newsstand"
            }
        }
    } 
    ]]--
}


--[[
-- iPad Configuration
if ( string.sub( system.getInfo("model"), 1, 4 ) == "iPad" ) then
    application =
    {
        content =
        {
            width = 360,
            height = 480,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            imageSuffix =
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
    }
-- iPhone5 Configuration
elseif ( string.sub( system.getInfo("model"), 1, 2 ) == "iPhone" and display.pixelHeight > 960 ) then
   application =
   {
      content =
      {
         width = 320,
         height = 568,
         scale = "letterBox",
         xAlign = "center",
         yAlign = "center",
         imageSuffix =
         {
            ["@2x"] = 1.5,
            ["@4x"] = 3.0,
         },
      },
   }

-- iPhone 3,4 and Older iPod Touch
elseif ( string.sub( system.getInfo("model"), 1, 2 ) == "iPhone" ) then
   application =
   {
      content =
      {
         width = 320,
         height = 480,
         scale = "letterBox",
         xAlign = "center",
         yAlign = "center",
         imageSuffix =
         {
            ["@2x"] = 1.5,
            ["@4x"] = 3.0,
         },
      },
   }

-- Android, Kindle Fire, and Nook
elseif ( display.pixelHeight / display.pixelWidth > 1.72 ) then
   application =
   {
      content =
      {
         width = 320,
         height = 570,
         scale = "letterBox",
         xAlign = "center",
         yAlign = "center",
         imageSuffix =
         {
            ["@2x"] = 1.5,
            ["@4x"] = 3.0,
         },
      },
   }
 
else
   application =
   {
      content =
      {
         width = 320,
         height = 512,
         scale = "letterBox",
         xAlign = "center",
         yAlign = "center",
         imageSuffix =
         {
            ["@2x"] = 1.5,
            ["@4x"] = 3.0,
         },
      },
   }
end 
]]--   