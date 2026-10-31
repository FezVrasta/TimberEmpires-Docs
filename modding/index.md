---
title: Modding
nav_order: 9
has_children: true
---

# Modding

The mods build on each other, and each has a page here.

| Mod | What a mod can do with it |
|---|---|
| [Timber Empires](timber-empires.md) | Add a faction with one blueprint, change its troops' and machines' numbers, give it a look, ship war boats, and call the API from code. |
| [Archipelago](archipelago.md) | Add ships, put goods in a hold, hook into boats and the sea, grow plants on sand and in the sea. |
| [Timber Atlas](timber-atlas.md) | Color the map's dots, hide things from it, mark places on its rim, draw fog of war. |
| [BeaverBuddies](https://github.com/FezVrasta/BeaverBuddies-CoOp-PvP-Edition/blob/master/BeaverBuddies/Doc/Modding.md) | Keep a mod in sync in multiplayer, and add game modes. Its guide is in its repo. |

## Bridges

Archipelago and Timber Atlas are found by reflection, so a mod that wants them doesn't reference their DLLs and loads fine without them. Each page ends with its bridge, one file to copy into your mod. List the mod under `OptionalMods` in your manifest so it loads first, and check the bridge's `Available` before anything that only makes sense with it.
