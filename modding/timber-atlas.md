---
title: Timber Atlas
parent: Modding
nav_order: 3
---

# Modding with Timber Atlas

Timber Atlas draws the round minimap and the Map tab. On its own it draws the land, water, relief and every dot in one color. Other mods teach it more through a reflection API, so none of them depends on it: your mod finds `TimberAtlas.Modding.MapBridge` by name at runtime, and without Timber Atlas installed every call does nothing.

## Setup

1. Copy the bridge below into your mod and change its namespace.
2. Add Timber Atlas to the mod's `OptionalMods` in `manifest.json`, so it loads first:

   ```json
   "OptionalMods": [ { "Id": "timberatlas" } ]
   ```

3. Add hooks from `StartMod`:

   ```csharp
   if (AtlasBridge.Available)
   {
       AtlasBridge.AddHook("PlayerColor", (Func<string, Color32?>)(player => ColorOf(player)));
       AtlasBridge.AddHook("HideDot", (Func<BaseComponent, bool>)(entity => IsSecret(entity)));
   }
   ```

`AddHook` returns false when the name is unknown or the delegate has the wrong type, and logs why. Call `AtlasBridge.Refresh()` after something the hooks answer from changes. Every type crossing over is .NET, Unity or Timberborn's. The bridge's version is `MapBridge.Version`.

## Hooks

Hooks marked *all* can be added by several mods. For the others the last one added is used.

**Dots**

| Hook | Delegate | |
|---|---|---|
| `EntityOwner` | `Func<BaseComponent, string>` | The player an entity belongs to. |
| `PlayerColor` | `Func<string, Color32?>` | A player's color. *all*: the first mod that answers wins, `null` passes. |
| `LocalPlayer` | `Func<string>` | This machine's player, whose color the pointers fall back to. |
| `DotColor` | `Func<BaseComponent, Color32?>` | A dot's color when its owner has none. *all*: the first answer wins. |
| `HideDot` | `Func<BaseComponent, bool>` | `true` keeps an entity off the map. *all* |
| `Pointers` | `Action<List<Vector2>, List<string>, List<string>>` | Adds places that get a pointer on the rim when they're off the map: grid tile, name, owning player. *all* |

A dot takes its owner's `PlayerColor`, else `DotColor`, else the default gold.

**Fog of war**

| Hook | Delegate | |
|---|---|---|
| `FogActive` | `Func<bool>` | Whether the fog is on. |
| `FogVisibleTiles` | `Func<bool[]>` | Per tile (`x + y * width`) whether the player sees it. |
| `FogExploredTiles` | `Func<bool[]>` | Per tile whether it has been seen. Unexplored ground is drawn black. `null` leaves it only dimmed. |
| `FogVersion` | `Func<int>` | Changes whenever either array does, so the map colors again. |
| `FogWorldVisible` | `Func<Vector3, bool>` | Whether a point of the world is seen. |
| `FogSeaCells` | `Func<bool[]>` | On a map drawn apart, per cell of the open sea whether it has been seen. Unexplored sea is drawn black. |
| `FogSeaRect`, `FogSeaCell`, `FogSeaVersion` | `Func<RectInt>`, `Func<int>`, `Func<int>` | The box those cells cover in drawn tiles, how many tiles a cell is on a side, and a number that changes whenever the cells do. |

**Islands drawn apart** (a map whose grid isn't how it shows)

| Hook | Delegate | |
|---|---|---|
| `IsDrawnApart` | `Func<bool>` | Whether the map is laid out differently from the grid. |
| `IslandCount` | `Func<int>` | |
| `IslandRect` | `Func<int, RectInt>` | An island's box on the grid. |
| `IslandOffset` | `Func<int, Vector2Int>` | Where its box is drawn, from its place on the grid. |
| `IslandAt` | `Func<Vector2Int, int>` | The island a grid tile belongs to, -1 for none. |
| `InLimits` | `Func<Vector2Int, bool>` | Whether a tile is inside an island's limits. The rest is open sea. |
| `ToDrawn` | `Func<Vector3, Vector3>` | A point of the grid to where it's drawn. |
| `ToCompact2D` | `Func<Vector2, Vector2>` | A drawn point back to the grid. |
| `OpenSea` | `Func<bool>` | Whether ground outside the islands' limits is open sea. |
| `SeaSurface` | `Func<float>` | The height the sea stands at, in tiles. |

## Examples

Color a player's dots:

```csharp
AtlasBridge.AddHook("EntityOwner", (Func<BaseComponent, string>)(e => e.GetComponent<Owned>()?.PlayerId));
AtlasBridge.AddHook("PlayerColor", (Func<string, Color32?>)(id => id == "me" ? new Color32(250, 219, 89, 255) : null));
```

Keep hidden things off the map:

```csharp
AtlasBridge.AddHook("HideDot", (Func<BaseComponent, bool>)(e => e.GetComponent<Secret>() != null));
```

Mark a place on the rim when it's off the map:

```csharp
AtlasBridge.AddHook("Pointers", (Action<List<Vector2>, List<string>, List<string>>)((at, names, owners) =>
{
    at.Add(new Vector2(40, 12));
    names.Add("Outpost");
    owners.Add("me");
}));
```

Draw the fog:

```csharp
AtlasBridge.AddHook("FogActive", (Func<bool>)(() => true));
AtlasBridge.AddHook("FogVisibleTiles", (Func<bool[]>)(() => visible));
AtlasBridge.AddHook("FogVersion", (Func<int>)(() => version));
```

## Who adds what

| Mod | Hooks |
|---|---|
| BeaverBuddies | `PlayerColor`, `LocalPlayer`: the colors the match gives its players. |
| Timber Empires | `EntityOwner`, `PlayerColor` (its record, for AI opponents), `DotColor` (allies, enemies), `HideDot`, `Pointers`, the fog hooks. |
| Archipelago | The island hooks, `OpenSea`, `SeaSurface`, and `HideDot` for boats shown out at sea. |

## The bridge

`AtlasBridge.cs`, the file to copy.

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;

namespace YourMod.Bridge
{
    /**
     * Talks to Timber Atlas without referencing it: finds its MapBridge class by name at runtime and binds each
     * method to a delegate. Every type crossing over is .NET, Unity or Timberborn's. Without Timber Atlas the
     * calls do nothing, so Timber Atlas is never a hard dependency.
     *
     * This file stands alone: copy it into a mod and change the namespace. Add Timber Atlas to the mod's
     * OptionalMods in its manifest so it loads first, then add hooks in StartMod. The hooks and the delegate
     * type each one takes are listed in TimberAtlas/Modding/MapBridge.cs.
     */
    public static class AtlasBridge
    {
        private const string BridgeType = "TimberAtlas.Modding.MapBridge";
        // The bridge version this was written against
        public const int SupportedVersion = 1;

        private static Type _type;
        private static bool _looked;

        private static Type Type
        {
            get
            {
                if (_looked) return _type;
                _looked = true;
                _type = AppDomain.CurrentDomain.GetAssemblies()
                    .Select(a => a.GetType(BridgeType, false))
                    .FirstOrDefault(t => t != null);
                return _type;
            }
        }

        public static bool Available => Type != null;

        private static readonly Dictionary<string, Delegate> Bound = new();

        private static T Bind<T>(string name) where T : Delegate
        {
            if (Bound.TryGetValue(name, out Delegate bound)) return (T)bound;
            MethodInfo method = Type?.GetMethod(name, BindingFlags.Public | BindingFlags.Static);
            T result = method == null ? null : (T)Delegate.CreateDelegate(typeof(T), method, false);
            Bound[name] = result;
            return result;
        }

        public static int Version => Bind<Func<int>>("GetVersion")?.Invoke() ?? 0;

        /** Adds a hook by name. False without Timber Atlas, or when it doesn't know the name or the delegate's type. */
        public static bool AddHook(string name, Delegate handler) => Bind<Func<string, Delegate, bool>>("AddHook")?.Invoke(name, handler) ?? false;

        /** Reads the colors and pointers again after a mod's own state changed. */
        public static void Refresh() => Bind<Action>("Refresh")?.Invoke();

        // For tests and demos
        public static void OpenMapTab() => Bind<Action>("OpenMapTab")?.Invoke();
        public static void DevShow(bool shown) => Bind<Action<bool>>("DevShow")?.Invoke(shown);
        public static void DevZoom(int step) => Bind<Action<int>>("DevZoom")?.Invoke(step);
        public static void DevClick(float x, float y) => Bind<Action<float, float>>("DevClick")?.Invoke(x, y);
        public static string DevStats() => Bind<Func<string>>("DevStats")?.Invoke() ?? "no minimap";
    }
}
```
