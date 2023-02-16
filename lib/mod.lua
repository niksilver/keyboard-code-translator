-- Module to get Keychron K8 keyboard function keys working with norns when
-- it's set to Windows/Android mode.
--

local mod = require 'core/mods'

--- Our local state
--
k8 = {}

--
-- [optional] hooks are essentially callbacks which can be used by multiple mods
-- at the same time. each function registered with a hook must also include a
-- name. registering a new function with the name of an existing function will
-- replace the existing function. using descriptive names (which include the
-- name of the mod itself) can help debugging because the name of a callback
-- function will be printed out by matron (making it visible in maiden) before
-- the callback function is called.
--
-- here we have dummy functionality to help confirm things are getting called
-- and test out access to mod level state via mod supplied fuctions.
--

mod.hook.register("system_post_startup", "Keychron K8 post", function()
  if keyboard.process then
    print("We've found keyboard.process")
    if k8.original_keyboard_process == nil then
      k8.original_keyboard_process = keyboard.process
      keyboard.process = mod_keyboard_process
    end
  else
    print("No keyboard.process")
  end
end)
print("Hello from mod.lua")

mod.hook.register("script_pre_init", "my init hacks", function()
  -- tweak global environment here ahead of the script `init()` function being called
end)

-- Our own version of keyboard.process, which just wraps the original.
--
function mod_keyboard_process(type, code, value)
  print(type, code, value)
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
