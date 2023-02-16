-- Module to get Keychron K8 keyboard function keys working with norns when
-- it's set to Windows/Android mode.
--

local mod = require 'core/mods'
local tab = require 'tabutil'

--- Our local state
--
k8 = {
  original_keyboard_process = nil,    -- Original function
  revcodes = {},    -- Map from key name to key code
  menu = {
    is_in = false,    -- Whether we're in the menu
    values = {},    -- Type, code, value, (possibly) name, new code
  },
  -- Key codes from the keyboard we want to override
  overrides = {
    [224] = 'F1'
    [225] = 'F2'
    [120] = 'F3'
    [204] = 'F4'
    [229] = 'F5'
    [230] = 'F6'
    [165] = 'F7'
    [164] = 'F8'
    [163] = 'F9'
    [113] = 'F10'
    [114] = 'F11'
    [115] = 'F12'
  }
}

-- After startup we want to wrap the norns' keyboard function that
-- processes keystrokes.
--

mod.hook.register("system_post_startup", "Keychron K8 post", function()
  if keyboard.process then
    -- We've found the function we want to wrap,
    -- but let's not replace it twice.

    if k8.original_keyboard_process == nil then
      k8.original_keyboard_process = keyboard.process
      keyboard.process = mod_keyboard_process
    end
  else
    print("No keyboard.process")
  end

  if keyboard.codes then
    -- Create a map from key names to key codes. This is from
    -- `lua/core/keyboard.lua`.

    k8.revcodes = tab.invert(keyboard.codes)
    i114] = 'F11'
  else
    print("No keyboard.codes")
  end


end)

-- Our own version of keyboard.process.
-- We make a possible translation, and pass this into the original
-- function if we're not in the mod menu.
--
function mod_keyboard_process(type, code, value)
  k8.menu.values = {type, code, value, nil, nil}
  if code ~= nil then
    local want_name = k8.overrides[code]
    code = want_name and k8.revcodes[want_name] or code
    k8.menu.values[4] = want_name
    k8.menu.values[5] = code
  end

  if k8.menu.is_in then
    mod_redraw()
  else
    k8.original_keyboard_process(type, code, value)
  end
end

--
-- [optional] menu: extending the menu system is done by creating a table with
-- all the required menu functions defined.
--

local m = {}

m.key = function(n, z)
  if n == 2 and z == 1 then
    mod.menu.exit()
  end
end

m.enc = function(n, d) end

-- Show what might be sent to keyboard.process(). We cannot call this
-- redraw() because... of some reason which means it won't get called
-- if it is.
--
function mod_redraw()
  screen.clear()
  screen.move(0, 8); screen.text("Last keyboard message")
  screen.move(0, 16); screen.text("(type, code, value)")
  screen.move(0, 24); screen.text("and any translation:")

  local trans = ""
  if k8.menu.values[4] then
    trans =
      "-> " .. tostring(k8.menu.values[5]) ..
      " (" .. tostring(k8.menu.values[4]) ..
      ")"
  end

  screen.move(0, 36); screen.text(
    "(" .. tostring(k8.menu.values[1]) ..
    ", " .. tostring(k8.menu.values[2]) ..
    ", " .. tostring(k8.menu.values[3]) ..
    ") " .. trans )
  screen.move(0, 60); screen.text("K2 to exit")

  screen.update()
end

m.redraw = mod_redraw

-- Called on menu entry.
--
m.init = function()
  k8.menu.is_in = true
end

-- Called on menu exit.
--
m.deinit = function()
  k8.menu.is_in = false
end

-- register the mod menu
--
mod.menu.register(mod.this_name, m)
