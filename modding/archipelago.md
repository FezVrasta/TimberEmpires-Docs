---
title: Archipelago
parent: Modding
nav_order: 2
---

# Modding with Archipelago

A mod takes part in the sea without referencing Archipelago's DLL: it finds `Archipelago.Modding.ModBridge` by name at runtime and binds its methods to delegates. Copy the bridge below into your mod, change its namespace, and call it. Without Archipelago every call returns a default and every hook does nothing, so the only check a mod needs is `ArchipelagoBridge.Available`, for what only makes sense with a sea.

Add Archipelago to the mod's `OptionalMods` in its manifest so it loads first:

```json
"OptionalMods": [{ "Id": "archipelago" }]
```

Every type crossing the bridge is .NET, Unity or Timberborn's. Boats are named by any component of their entity. `ModBridge.Version` goes up when a method's meaning changes, not for a new method.

## What a blueprint does

Most of it needs no code, and no bridge.

**A ship.** A template with a `BoatSpec` is a ship with a crew and a hold, placeable only on a Shipyard's slip. Copy the Barge's (`Buildings/Barge/Barge.Folktails.blueprint.json`) into a template collection the faction loads and change it:

```json
"BoatSpec": {
  "TilesPerHour": 35,
  "WindTilesPerHour": 45,
  "TurnDegreesPerHour": 300,
  "WindTurnDegreesPerHour": 380,
  "Draft": 0.4
}
```

| Field | What it is |
|---|---|
| `TilesPerHour`, `WindTilesPerHour` | How fast it sails with no wind and in the strongest wind, in tiles an hour. The wind's strength in between. Without `WindTilesPerHour` the wind makes no difference |
| `TurnDegreesPerHour`, `WindTurnDegreesPerHour` | How fast it turns, the same way. Without `TurnDegreesPerHour` it turns on the spot |
| `Draft` | How deep it sits in the water, in tiles |

**A steam engine.** A `BoatEngineSpec` on the same blueprint burns its fuels from the hold while the ship sails, and drives it at `SpeedBoost` times its calm pace whatever the wind, by sail or engine, whichever is faster. Out of any fuel, or worn past `BreaksAtWear`, it sails as it would without one. Iron Teeth's war boat has one:

```json
"BoatEngineSpec": {
  "Fuels": [ { "Good": "Log", "PerHour": 0.03 }, { "Good": "Water", "PerHour": 0.1 } ],
  "SpeedBoost": 1.5,
  "BreaksAtWear": 0.5
}
```

The hold, the crew and the deck are components of the same blueprint (`ShipHoldSpec`, the workplace's workers, `ShipDeckSpec`), like the Barge's.

**Adding to the Barge.** An optional blueprint, `Buildings/Barge/Barge.Folktails.optional.blueprint.json`, is merged into Archipelago's and dropped when Archipelago isn't there.

**Plants.** The seabed and the beach are dry sand, so nothing planted on it grows. Two specs change that:

- `"GrowsOnSandSpec": {}` on a plant (a natural resource: tree, crop) lets it be planted on sand and keeps it from drying out there. The palm, algae, sea grapes and sea mangrove have it.
- `"NeedsSandSpec": {}` on a building makes it work only standing on sand (the Sun Lounger), with a status saying so anywhere else.
- `"GrowsInSeaSpec": {}` on a plant makes it a sea plant: it grows only over a sea tile with no river water on it, and it dies anywhere else. How deep the water is over it comes from its `FloodableNaturalResourceSpec`: `MinWaterHeight` and `MaxWaterHeight` in tiles, where sea level is 1 and each layer of seabed below it adds one. Without one both are 1. Algae, sea grapes and the sea mangrove have it. Add `GrowsOnSandSpec` as well if it should also be plantable on the beach.

## What needs code

Only what changes while the game runs: who sails a ship, whether it's sunk, who owns it, what its panel shows. Everything below goes through the bridge, which the bottom of this page has. A boat nothing hooked behaves as with Archipelago alone, so a mod hooks only what it changes, and a number that's the same for every ship of a kind is a `BoatSpec` field, not a hook.

## The ship's side panel

`ArchipelagoBridge.AddShipPanelSection(id, initialize, show, update, clear)` adds a section under the goods a ship loads: `initialize` builds its element once per game, then `show(entity)`, `update()` and `clear()` follow the panel's. Hide it yourself for ships it doesn't apply to.

## The hold

`ArchipelagoBridge.HoldGive(boat, good, amount)` puts goods in a ship's hold, past what it's set to load. They stay aboard until the player sets that good to unload. `HoldTake(boat, good, amount)` takes them out if that much is there and no hauler is after it, and `HoldStock(boat, good)` says how much is there.

## Hooks

`ArchipelagoBridge.AddHook(name, handler)`. Every handler gets the boat's component. A boat nothing hooked behaves as its blueprint says.

| Hook | Handler | |
|---|---|---|
| `CanSail` | `Func<BaseComponent, bool>` | Whether it can sail now (a crew aboard). Every handler has to say yes. |
| `Afloat` | `Func<BaseComponent, bool>` | Whether it isn't sunk. |
| `Effort` | `Func<BaseComponent, float>` | How hard its crew drives it, as a share of the pace its `BoatSpec` gives (a war boat's troops rowing). The answers multiply. |
| `SailsWithoutWorkers` | `Func<BaseComponent, bool>` | Whether the mod's own crew sails it instead of its workers, who then leave it. |
| `Wear`, `Mend` | `Func<BaseComponent, float>`, `Action<BaseComponent, float>` | How worn the hull is, 0 to 1 (above zero it can be sent to a Shipyard), and the share of it a Shipyard's workers mended. |
| `Sees` | `Func<Vector2, bool>` | Whether this machine's player sees a spot of the drawn sea (fog of war). Every handler has to say yes. |
| `CanCommand` | `Func<BaseComponent, string, bool>` | Whether a player (by ID) may give it orders. |
| `CommandedElsewhere` | `Func<BaseComponent, bool>` | Whether the mod commands it itself, so Archipelago's commander leaves it alone. |
| `AtSea` | `Action<BaseComponent, bool>` | It went out to sea (true) or came ashore (false). |
| `Beached` | `Action<BaseComponent>` | It beached. |
| `Ballast` | `Func<BaseComponent, int>` | Weight carried outside the hold, in the hold's units (guns). It takes room from the hold and slows the ship like cargo. The answers add up. |
| `Tick` | `Action<BaseComponent>` | Every tick it's finished. |
| `Owner` | `Func<BaseComponent, string>` | The player a boat or a Trade Post belongs to, by ID. Trade between two owners goes by the post's values; without it everything is one owner's and goods change hands for free. |
| `PlayerName` | `Func<string, string>` | A player's name by ID, shown on Trade Posts that aren't yours. |

## Orders

`Sail`, `BeachAt` and `Halt` act on this machine only. A mod that gives orders sends them to every machine itself (through BeaverBuddies' events, say), then applies them everywhere.

## The sea

`IsArchipelago` says whether the map is a sea at all. `ToDrawn` and `ToCompact2D` say where a point is on screen and on the grid. Anything a mod draws over the world (cursors, pings, labels) goes through `ToDrawn` first.

## The bridge

`ArchipelagoBridge.cs`, the file to copy. It binds all of `ModBridge`.

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using Timberborn.BaseComponentSystem;
using UnityEngine;
using UnityEngine.UIElements;

// Change the namespace to the mod's own
namespace YourMod.Bridge
{
    /**
     * Talks to Archipelago without referencing it: finds its ModBridge class by name at runtime and binds
     * each method to a delegate. Every type crossing over is .NET, Unity or Timberborn's. Without Archipelago
     * every call returns a default and every hook does nothing.
     *
     * This is all of ModBridge: what most mods need. A mod that needs more can ask for it.
     *
     * This file stands alone: copy it as is. Add Archipelago to the mod's OptionalMods in its manifest so it
     * loads first.
     */
    public static class ArchipelagoBridge
    {
        private static Type Find(string name) => AppDomain.CurrentDomain.GetAssemblies().Select(a => a.GetType(name, false)).FirstOrDefault(t => t != null);

        private static readonly Type Bridge = Find("Archipelago.Modding.ModBridge");

        // Whether the mod is installed
        public static bool Available => Bridge != null;

        private static readonly Dictionary<string, Delegate> Bound = new();

        private static T Bind<T>(string name) where T : Delegate
        {
            if (!Bound.TryGetValue(name, out Delegate bound)) Bound[name] = bound = Bridge?.GetMethod(name) is { } method ? Delegate.CreateDelegate(typeof(T), method, false) : null;
            return (T)bound;
        }

        public static int Version => Bind<Func<int>>("GetVersion")?.Invoke() ?? 0;

        // ---- Ships ----

        // Says something about boats, or hears of them: the hook names and their handlers' types are on the wiki page
        public static bool AddHook(string name, Delegate handler) => Bind<Func<string, Delegate, bool>>("AddHook")?.Invoke(name, handler) ?? false;

        // A section of the mod's in a ship's side panel, under the goods it loads
        public static void AddShipPanelSection(string id, Func<VisualElement> initialize, Action<BaseComponent> show, Action update, Action clear) =>
            Bind<Action<string, Func<VisualElement>, Action<BaseComponent>, Action, Action>>("AddShipPanelSection")?.Invoke(id, initialize, show, update, clear);

        // Boats are named by any component of their entity
        public static bool IsBoat(BaseComponent component) => Bind<Func<BaseComponent, bool>>("IsBoat")?.Invoke(component) ?? false;

        public static IEnumerable<BaseComponent> Boats() => Bind<Func<IEnumerable<BaseComponent>>>("Boats")?.Invoke() ?? Enumerable.Empty<BaseComponent>();

        public static bool BoatAfloat(BaseComponent boat) => Bind<Func<BaseComponent, bool>>("BoatAfloat")?.Invoke(boat) ?? false;

        public static bool BoatAtSea(BaseComponent boat) => Bind<Func<BaseComponent, bool>>("BoatAtSea")?.Invoke(boat) ?? false;

        public static bool BoatSailing(BaseComponent boat) => Bind<Func<BaseComponent, bool>>("BoatSailing")?.Invoke(boat) ?? false;

        // Whether a player may give a boat orders
        public static bool CanCommand(BaseComponent boat, string playerID) => Bind<Func<BaseComponent, string, bool>>("CanCommand")?.Invoke(boat, playerID) ?? false;

        // ---- Orders (on this machine only: a mod that takes orders sends them to every machine itself) ----

        // Out to a spot of the drawn sea
        public static void Sail(BaseComponent boat, Vector2 to) => Bind<Action<BaseComponent, Vector2>>("Sail")?.Invoke(boat, to);

        // To a cell of an island, to beach there
        public static void BeachAt(BaseComponent boat, Vector3Int cell) => Bind<Action<BaseComponent, Vector3Int>>("BeachAt")?.Invoke(boat, cell);

        public static void Halt(BaseComponent boat) => Bind<Action<BaseComponent>>("Halt")?.Invoke(boat);

        // ---- The hold ----

        // Puts goods in a ship's hold past what it's set to load: they stay aboard until the good is set to unload
        public static bool HoldGive(BaseComponent boat, string goodId, int amount) => Bind<Func<BaseComponent, string, int, bool>>("HoldGive")?.Invoke(boat, goodId, amount) ?? false;

        // Takes goods out if that much is there and no hauler is after it
        public static bool HoldTake(BaseComponent boat, string goodId, int amount) => Bind<Func<BaseComponent, string, int, bool>>("HoldTake")?.Invoke(boat, goodId, amount) ?? false;

        public static int HoldStock(BaseComponent boat, string goodId) => Bind<Func<BaseComponent, string, int>>("HoldStock")?.Invoke(boat, goodId) ?? 0;

        // ---- The sea ----

        public static bool IsArchipelago => Bind<Func<bool>>("IsArchipelago")?.Invoke() ?? false;

        // Where a point of the grid shows on screen. Anything a mod draws over the world (cursors, pings, labels) goes through it first
        public static Vector3 ToDrawn(Vector3 world) => Bind<Func<Vector3, Vector3>>("ToDrawn")?.Invoke(world) ?? world;

        // Where a point of the drawn world is on the grid
        public static Vector2 ToCompact2D(Vector2 drawn) => Bind<Func<Vector2, Vector2>>("ToCompact2D")?.Invoke(drawn) ?? drawn;
    }
}
```
