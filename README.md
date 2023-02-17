# Keyboard code translator

A mod for the monome norns which translates problematic keyboard key presses.
It is configured for the Keychron K8 in Windows/Android mode, which is very
niche. However, you can change that by editing the script yourself.

## The problem (and solution)

You can
[attach a (typing) keyboard](https://monome.org/docs/norns/control-clock/#keyboard)
to the monome norns for improved functionality, and even choose your
per-country keyboard layout.

However, some keyboards still produce unrecognised or problematic key codes.
This norns mod fixes that by translating input key codes.
It is currently configured to fix the function keys
on a Keychron K8 in Windows/Android mode. That's pretty specific, but you can
edit the script to change that.

## Installation

Install it as you would any other mod. In this case

```
;install https://github.com/niksilver/keyboard-code-translator
```

## (Re)configuration

You'll need to edit file `lib/mod.lua`. Change the `overrides` mapping which
takes a code from the keyboard and says what key name it should generate.

To find what key codes your keyboard generates go to the mod's menu in
`SYSTEM > MODS`. When you press a key that will show the code generated,
plus any translation that the mod currently does. It will also show the
key state. It is presented like the input to
(the `keyboard.code()` function)[https://monome.org/docs/norns/api/modules/keyboard.html#code].

Note that the key code displayed on this screen is the code as it
comes from the keyboard, before any country-specific mapping.

## References

- [Mods documentation (in progress)](https://monome.org/docs/norns/community-scripts/#mods)
- [Example mod](https://github.com/monome/norns-example-mod)
- [Mod development discussion at lines](https://github.com/monome/norns/blob/main/lua/core/keyboard.lua)
- [System keyboard codes](https://github.com/monome/norns/blob/main/lua/core/keyboard.lua)
