---
title: Timber Empires
parent: Modding
nav_order: 1
---

# Modding Timber Empires

Faction mods can play in Timber Empires. The mod says which base its faction is built on (Folktails or Iron Teeth), and the faction gets that base's barracks, walls, siege machines, troop outfits and models. Anything the faction mod ships of its own replaces the borrowed version.

A faction needs no code, just one blueprint file. Mods with code get a small API on top, found by reflection, so they don't reference Timber Empires to build.

Timber Empires runs on [BeaverBuddies Co-Op/PvP Edition](https://github.com/FezVrasta/BeaverBuddies-CoOp-PvP-Edition). Anything a mod changes in a multiplayer game has to follow BeaverBuddies' rules or the game desyncs: read its [Modding.md](https://github.com/FezVrasta/BeaverBuddies-CoOp-PvP-Edition/blob/master/BeaverBuddies/Doc/Modding.md) too.

The files this page mentions (`Troops/TroopStats.blueprint.json`, `FactionProfiles/`, `WorkerOutfits/`) are in Timber Empires' mod folder once it's installed.

## Adding a faction

Ship a blueprint like this in your mod, in a file of its own (`TimberEmpires/TimberEmpiresFaction.Emberpelts.blueprint.json`, say):

```json
{
  "TimberEmpiresFactionSpec": {
    "FactionId": "Emberpelts",
    "Base": "Folktails",
    "Barracks": [ "Spearman", "Warrior", "Berserker" ],
    "Range": [ "Archer", "Slinger" ],
    "Goods": [
      { "Good": "TreatedPlank", "With": "Brick" },
      { "Good": "Paper", "With": "Brick" },
      { "Good": "Dandelion", "With": "Pepper" }
    ]
  }
}
```

| Field | What it does |
|---|---|
| `FactionId` | Your faction's `Id`, as in its `FactionSpec` |
| `Base` | `Folktails` or `IronTeeth`: whose Timber Empires buildings, models and outfits your faction uses |
| `Barracks` | The troop kinds its barracks train, in the order the barracks lists them. A new barracks trains spearmen if the list has them, else the first. Left out, the base's |
| `Range` | The kinds its archery range trains. Left out, the base's |
| `BanditShooters`, `BanditElite` | The shooters bandit camps have in a game of your faction, and the heavy hitter the strongest camps add. Left out, the base's |
| `Goods` | Goods your faction uses where Timber Empires' buildings use one it doesn't have (see below) |
| `AIPlayable` | AI opponents can play your faction. Leave it out unless you've watched the AI build and fight with it |
| `Default` | Only for profiles a mod ships for someone else's faction: any profile without it takes its place |

The kinds for `Barracks` and `Range` are `Warrior`, `Spearman`, `Archer`, `Herbalist`, `Sapper`, `Arquebusier`, `Slinger` and `Berserker`. Any of them works for any faction. An unknown name logs a warning, and a list with nothing valid trains spearmen.

`Monk` is a kind too, but monks train at the Monastery, which every faction gets. Don't list them in `Barracks` or `Range`.

How each kind fights and what it costs is in `Troops/TroopStats.blueprint.json`, and your faction can change any of it (see below). Spearmen and archers cost no science and the rest need unlocking, so list a free kind first or a new barracks can't train anyone until the player pays for it.

**Why its own file.** The game reads a blueprint only when something asks for a spec in it. Without Timber Empires nothing asks for `TimberEmpiresFactionSpec`, so the file sits unread. Put the spec inside your faction's own blueprint and the game reads it while loading factions, doesn't know the spec, and stops.

**What the base gives you.** Timber Empires adds its base's buildings to your faction's toolbar, and the base's material collection to your faction's materials (those buildings are drawn with them). Its troops start from the base's numbers too (a faction built on Folktails walks as fast as Folktails do). Your faction keeps its own District Center, homes, food and goods. Timber Empires' weapons and siege goods are in the `Common` good collection, which every faction gets.

**Goods.** A few of the base's buildings cost or use goods only that base has: Treated Planks and Paper for Folktails, Treated Planks and Metal Parts for Iron Teeth, and some recipes use Dandelions. The game won't load a building that costs a good it doesn't know, so as a game starts Timber Empires swaps each good your faction lacks for the one `Goods` names. A good with no substitute is left out of the cost or recipe. The log lists every swap (`[Factions]` lines). In a mixed-factions game every faction's goods are loaded, so nothing is swapped.

A troop's `Upkeep` good (the monk's books) isn't swapped. If your faction has no books, set your monks' `Upkeep` in your stats (see below), as Iron Teeth do with coffee.

**Without a profile.** A faction with no profile plays as Folktails, with a warning in the log. Timber Empires ships one for Emberpelts, marked `"Default": true`. A profile a faction mod ships for its own faction replaces it.

## Your own numbers

A faction can have its own troop and building numbers. Ship them as another blueprint of its own (`TimberEmpires/TimberEmpiresStats.Emberpelts.blueprint.json`), with lines like the ones in `Troops/TroopStats.blueprint.json` but only the numbers you change:

```json
{
  "TimberEmpiresFactionStatsSpec": {
    "FactionId": "Emberpelts",
    "Kinds": [
      { "Kind": "Spearman", "Damage": 90 },
      { "Kind": "Berserker", "Pace": 1.1, "ScienceCost": 800 }
    ],
    "Buildings": [
      { "Name": "Catapult", "Health": 160, "ReloadHours": 1.4 }
    ]
  }
}
```

**Kind lines** (by `Kind`) can change any field the stats file has for that kind:

| Field | What it is |
|---|---|
| `Damage` | Damage per hour of fighting. Troops have 100 health |
| `Taken` | Multiplies the damage it takes |
| `Reach`, `MinRange` | How far it hits from, and how close is too close for a shooter |
| `Aggro` | How far it goes after enemies on its own |
| `Pace` | Walking speed against a beaver's |
| `Shoots` | Whether it's a shooter (shots are stopped by walls, turned aside by shields) |
| `MachineDamage`, `StructureDamage` | Damage per hour to machines and to buildings |
| `Heal` | Health per hour it heals others |
| `StrongAgainst`, `StrongFactor` | Kinds it hits harder (a comma-separated list) and by how much |
| `ZombieFactor` | Multiplier on its damage against the Horde's zombies (1 when left out). It kills `Damage` times this over the stats file's `ZombieHealth` (12) zombies an hour |
| `Worth` | Rank points for bringing it down |
| `TrainingHours`, `ScienceCost`, `TrainingScience` | Training time, the science to unlock it, and science paid per recruit (monks) |
| `Weapon`, `Recruit`, `RecruitAmount`, `Upkeep`, `Outfit` | The good it trains with, the plain good each recruit uses up once as it starts training (militia's logs, scouts' berries) and how many (1 if left out), the good it uses up (monks), and its outfit's `Id` |
| `Sight` | How far it sees in tiles when that's further than it reaches and notices enemies from (scouts) |

**Building lines** (by `Name`) work the same for siege machines, walls, hoardings and the infirmary. A line matches like the stats file does: `Catapult.Folktails` for one faction's catapult, `WallTower.Round` for the round tower, `Catapult` for every catapult. A faction can only change buildings the stats file has a line for.

A siege machine's line (`Catapult`, `Ballista` and `SiegeTrebuchet`) has these:

| Field | What it is |
|---|---|
| `Health`, `TilesPerHour` | How much battering it takes, and how fast its crew rolls it, in tiles an hour |
| `CrewCapacity`, `MinCrew` | How many troops fit aboard, and how many it needs to work |
| `MinRange`, `MaxRange` | How close is too close and how far it reaches, in tiles |
| `MinRangeOnTower`, `MaxRangeOnTower` | The same when it stands on a round tower. Leave them out and it's the same as on the ground |
| `TurnDegreesPerHour`, `TurnDegreesPerHourOnTower` | How fast its crew swings it round, on the ground and on a tower (0 on a tower: the same) |
| `AmmoCapacity`, `AmmoCapacityOnTower` | How much of its good its store holds, on the ground and on a tower (0 on a tower: the same). The good is in its building blueprint |
| `ReloadHours`, `FlightHours`, `Spread`, `SplashRadius`, `Damage`, `StructureDamage` | Reload time, the shot's flight, how far it strays, how wide it hits, and the damage to beavers and to buildings |
| `ZombieFactor` | Multiplier on its damage against the Horde's zombies (shots, a hoarding's logs or oil, a flamethrower's flames), 1 when left out. Kills `Damage` times this over `ZombieHealth` on every tile of the splash. Fire works best: the flamethrower's is 6, any weapon that doesn't burn is 2 at most |

Numbers stack in order: the stats file's, then your base's, then yours. `FactionProfiles/TimberEmpiresStats.Folktails.blueprint.json` and `TimberEmpiresStats.IronTeeth.blueprint.json` show how the bases differ (Folktails walk faster and hit a little harder, Iron Teeth take less damage and their monks use coffee).

A line only changes your faction's troops and buildings. Bandits use the stats file's numbers, and the rest of it (ranks, high ground, healing, supply ranges, building health) is shared.

A siege machine's ammunition good comes from its own building blueprint (`GoodConsumingBuildingSpec`). How much the machine holds is `AmmoCapacity` in the stats, which replaces what the blueprint's hours of work would give. Machines your faction mod ships with no line in the stats file keep their blueprint's.

## Your own look

Timber Empires looks up every faction model under your faction's name first, then the base's. Ship an asset at the same path with your faction's ID in place of `Folktails` or `IronTeeth` and it's used instead.

| What | Timber Empires' version | Yours |
|---|---|---|
| A troop's outfit | `WorkerOutfitSpec` with `Id` `Spearman` (or any kind), `WorkerType` `Beaver`, `FactionId` `Folktails` | The same blueprint with your `FactionId`. Copy one from Timber Empires' `WorkerOutfits/` and change its textures or attachments |
| The supply cart | `Buildings/WagonYard/SupplyCart.Folktails`, `SupplyCartLoad.Folktails` | `SupplyCart.Emberpelts`, `SupplyCartLoad.Emberpelts` |

The owner's color on a District Center comes from the owner color rules (`Players/OwnerTints.blueprint.json`), like every other building's: they repaint the background of the faction symbol in the faction's details texture, so a District Center drawn from it shows its owner there.

The game only loads the outfits of the faction being played, so Timber Empires reads troop outfits itself: your faction's own, else its base's, else whichever there is. Not every kind has an outfit for both bases (Folktails have no arquebusier, Iron Teeth no berserker or slinger), so ship your own if your profile mixes them.

**Sounds.** Your blueprints can use Timber Empires' selection sounds by name: `"SelectionSoundName": "TE.Barracks"`. The names are `TE.Anvil`, `TE.Archery`, `TE.Barracks`, `TE.Boil`, `TE.Cart`, `TE.Chain`, `TE.Coins`, `TE.Gate`, `TE.Horn`, `TE.Knock`, `TE.LogRoll`, `TE.Monastery`, `TE.Monk`, `TE.SailSnap`, `TE.Siege` and `TE.Water`.

## Your own war boats

A war boat is blueprints only (it needs Archipelago installed). Copy `Buildings/Cog/Cog.Folktails.blueprint.json` or a `WarBoat` one into your mod under a template name of your own, change its model, size and ports, and ship it with:

- A template collection file of your own (`TemplateCollections/TemplateCollection.MyMod.blueprint.json`) with `"CollectionId": "TimberEmpires.Boats"` and your blueprint in `Blueprints`, so it's in the toolbar only when Archipelago is there. A file named like one of Timber Empires' replaces it.
- `Troops/TroopStats.blueprint.json` with only a `Buildings` line named after your template (without the faction): its health, speed, crew and guns' reach.

`BoatSpec` makes it a ship that goes on a Shipyard's slip (its speed numbers are the stats file's, so `{}` will do), and `WarBoatSpec` a war boat that takes troops aboard and fights. In `ShipArmamentSpec`, `Ports` are its gun ports in the model's frame, `Hull` is where the hull lies in its footprint (`X`, `Y`, `Width`, `Length`, from the bow) and `DeckSprite` is the deck drawing the panel puts the ports over, bow to the left. Without `DeckSprite` it's `Sprites/TimberEmpires/Ships/<template>Deck`.

`Tools/Tests/Fixtures/CorvetteMod` in Timber Empires' repo is a complete example.

## Mixed games

In a game with other players, everyone plays the faction they pick, and their toolbar has only that faction's buildings. A mixed game loads every installed faction, yours included, so a player can join with any of them without the host reloading. A Timber Empires building is in the toolbar of every faction built on its base: Iron Teeth and a faction built on Iron Teeth both get `Barracks.IronTeeth`. Which troops a building trains and how they walk follows the faction of the district it's in.

The "My faction" setting lists every faction the game has.

## Multiplayer

Every player needs the same mods. BeaverBuddies compares the host's factions with each player's as they join and warns when they differ. Matchmaking downloads the mods a player is missing from the Workshop before the match starts, and skips a match when the Workshop can't make them match.

A profile has to be the same on every machine. A blueprint is. From code, register it as your mod starts, on every machine (see below).

## Game modes

Timber Empires adds PvE (`timberempires.pve`) and PvP (`timberempires.pvp`) to BeaverBuddies' Multiplayer mode list, next to its Co-op (`bb.coop`). A mod can add its own modes through BeaverBuddies' `AddGameMode`: see its [Modding.md](https://github.com/FezVrasta/BeaverBuddies-CoOp-PvP-Edition/blob/master/BeaverBuddies/Doc/Modding.md#game-modes). Timber Empires plays any mode it doesn't know as PvP. Horde (`timberempires.horde`) is a mode too.

## The API

`TimberEmpires.Modding.TimberEmpiresApi` is a static class whose methods take and return only .NET, Unity and Timberborn types. Find it by name at runtime and bind each method to a delegate once. Without Timber Empires the lookup finds nothing and every call does nothing.

```csharp
public static class TimberEmpiresBridge
{
    private static readonly Type ApiType = AppDomain.CurrentDomain.GetAssemblies()
        .Select(a => a.GetType("TimberEmpires.Modding.TimberEmpiresApi", false))
        .FirstOrDefault(t => t != null);
    private static readonly Dictionary<string, Delegate> Bound = new();

    public static bool Available => ApiType != null;

    private static T Bind<T>(string name) where T : Delegate
    {
        if (Bound.TryGetValue(name, out Delegate bound)) return (T)bound;
        MethodInfo method = ApiType?.GetMethod(name, BindingFlags.Public | BindingFlags.Static);
        T result = method == null ? null : (T)Delegate.CreateDelegate(typeof(T), method, false);
        Bound[name] = result;
        return result;
    }

    public static int Version => Bind<Func<int>>("Version")?.Invoke() ?? 0;

    public static void RegisterFaction(string factionId, string baseFaction, string[] barracks, string[] range) =>
        Bind<Action<string, string, string[], string[]>>("RegisterFaction")?.Invoke(factionId, baseFaction, barracks, range);

    public static string OwnerOf(BaseComponent entity) => Bind<Func<BaseComponent, string>>("OwnerOf")?.Invoke(entity);
}
```

Bind the rest the same way, with delegate types matching the signatures below. List Timber Empires under `OptionalMods` in your manifest (`{ "Id": "timberempires" }`) so it loads first.

| Method | What it's for |
|---|---|
| `int Version()` | The API's version, currently 1. A method that changes meaning bumps it; new methods don't |
| `void RegisterFaction(string factionId, string base, string[] barracks, string[] range)` | A faction's profile from code, over any blueprint. Null lists take the base's. Call it as your mod starts |
| `void SetAIPlayable(string factionId, bool playable)` | Whether AI opponents can play your faction, over `AIPlayable` in its profile. Call it as your mod starts |
| `void RegisterGoodSubstitute(string factionId, string good, string with)` | A good your faction uses in place of one it doesn't have, like `Goods` in the profile. Wins over the profile's for that good |
| `string BaseFactionOf(string factionId)` | `Folktails` or `IronTeeth` |
| `string[] BarracksKinds(string factionId)`, `string[] RangeKinds(string factionId)` | The troop kinds the faction trains, by name |
| `string[] TroopKinds()` | Every troop kind there is, monks included |
| `string FactionOf(BaseComponent building)` | The faction a building belongs to: its toolbar's, or in a mixed game the faction of its district |
| `string OwnerOf(BaseComponent entity)` | The player a building, beaver or machine belongs to, as their BeaverBuddies player ID, or null. A machine a monk converted belongs to the monk's side |
| `string PlayerName(string playerID)`, `Color PlayerColor(string playerID)` | What other players see. The color is clear until the player has one |
| `bool IsTroop(BaseComponent beaver)`, `string TroopKindOf(BaseComponent beaver)` | Whether a beaver is a troop (or a recruit), and its kind by name |
| `bool Friendly(string playerA, string playerB)` | Whether two players are on one side: the same player, [allies](https://fezvrasta.github.io/TimberEmpires-Docs/playing/alliances.html), or any two in PvE and Co-op |
| `string GameMode()` | The game's [mode](https://fezvrasta.github.io/TimberEmpires-Docs/game-modes.html): `gamemodes.classic` (alone), `bb.coop`, `timberempires.pve`, `timberempires.pvp` or `timberempires.horde` |

Everything that reads the game (`FactionOf`, `OwnerOf`, the troop queries) answers the same on every machine, so it's safe to call from ticks. Changes to the game still go through BeaverBuddies' events.

## Checklist

1. Add a `TimberEmpiresFactionSpec` blueprint in a file of its own.
2. Pick the base whose buildings fit your faction's look, and the troops it trains.
3. Name substitutes for the base's goods your faction doesn't have, and an `Upkeep` for its monks if it has no books.
4. Change your troops' and machines' numbers in a `TimberEmpiresFactionStatsSpec` blueprint, if they should fight differently.
5. Ship your own troop outfits, supply cart and banner where the base's look out of place.
6. Start a game with your faction and Timber Empires, read the `[Factions]` lines in the log, then a mixed one with each base faction.
7. Play it in multiplayer with BeaverBuddies' debug mode on.

## Blueprint specs

The components in Timber Empires' and Archipelago's building blueprints. Each page under [Buildings](../buildings/index.md) and [Troops](../troops/index.md) has a collapsed "For modders" section with its own blueprint.

{% for spec in site.data.specs %}
### {{ spec[0] }}
{: .no_toc }

{{ spec[1].summary }}
{% for fld in spec[1].fields %}
- `{{ fld[0] }}`: {{ fld[1] }}{% endfor %}
{% endfor %}
