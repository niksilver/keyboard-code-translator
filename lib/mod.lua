-- Module to get Keychron K8 keyboard function keys working with norns when
-- it's set to Windows/Android mode.
--

local mod = require 'core/mods'
local tab = require 'tabutil'

--- Our local state
--
k8 = {
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

-- Our own version of keyboard.process, which just wraps the original.
--
function mod_keyboard_process(type, code, value)
  print(type, code, value)
  if code ~= nil then
    local want_name = k8.overrides[code]
    local want_code = want_name and k8.revcodes[want_name]
    print(want_name, want_code)
  end
  k8.original_keyboard_process(type, code, value)
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

m.redraw = function()
  screen.clear()
  screen.move(0, 40)
  screen.text("found k.p? " .. tostring(k8.original_keyboard_process))
  screen.update()
end

m.init = function() end -- on menu entry, ie, if you wanted to start timers
m.deinit = function() end -- on menu exit

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
