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
    [204] = 'F4'
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
  else
    print("No keyboard.codes")
  end


end)

-- Our own version of keyboard.process.
-- We make a possible translation, and pass this into the original
-- function if we're not in the mod menu.
--
function mod_keyboard_process(type, code, value)
  print(type, code, value)
  k8.menu.values = {type, code, value, nil, nil}
  if code ~= nil then
    local want_name = k8.overrides[code]
    code = want_name and k8.revcodes[want_name] or code
    k8.menu.values[4] = want_name
    k8.menu.values[5] = code
    print(want_name, code)
  end

  if k8.menu.is_in then
    print("Redrawing with " .. tostring(mod_redraw))
    mod_redraw()
    print("Redrawn")
  else
    print("Entering " .. tostring(k8.original_keyboard_process))
    k8.original_keyboard_process(type, code, value)
    print("Entered")
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

-- Show what might be sent to keyboard.process()
--
function mod_redraw()
  print("In redraw() 1")
  for i = 1, 5 do
    print("[" .. i .. "] = " .. tostring(k8.menu.values[i]))
  end
  screen.clear()
  screen.move(0, 8); screen.text("Last keyboard message")
  screen.move(0, 16); screen.text("(type, code, value)")
  screen.move(0, 24); screen.text("and any translation:")
  print("In redraw() 2")

  local trans = ""
  if k8.menu.values[4] then
    trans =
      "-> " .. tostring(k8.menu.values[5]) ..
      " (" .. tostring(k8.menu.values[4]) ..
      ")"
  end
  print("In redraw() 3")

  screen.move(0, 36); screen.text(
    "(" .. tostring(k8.menu.values[1]) ..
    ", " .. tostring(k8.menu.values[2]) ..
    ", " .. tostring(k8.menu.values[3]) ..
    ") " .. trans )
  print("In redraw() 4")

  print(
    "(" .. tostring(k8.menu.values[1]) ..
    ", " .. tostring(k8.menu.values[2]) ..
    ", " .. tostring(k8.menu.values[3]) ..
    ") " .. trans )

  print("In redraw() 5")
  screen.update()
  print("In redraw() 6")
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
-- NOTE: `mod.this_name` is a convienence variable which will be set to the name
-- of the mod which is being loaded. in order for the menu to work it must be
-- registered with a name which matches the name of the mod in the dust folder.
--
mod.menu.register(mod.this_name, m)


--
-- [optional] returning a value from the module allows the mod to provide
-- library functionality to scripts via the normal lua `require` function.
--
-- NOTE: it is important for scripts to use `require` to load mod functionality
-- instead of the norns specific `include` function. using `require` ensures
-- that only one copy of the mod is loaded. if a script were to use `include`
-- new copies of the menu, hook functions, and state would be loaded replacing
-- the previous registered functions/menu each time a script was run.
--
-- here we provide a single function which allows a script to get the mod's
-- state table. using this in a script would look like:
--
-- local mod = require 'name_of_mod/lib/mod'
-- local the_state = mod.get_state()
--
local api = {}

api.get_state = function()
  return state
end

return api
