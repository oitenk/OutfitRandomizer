# Outfit Randomizer

A Cyberpunk 2077 mod that adds a randomizer to the [Equipment-EX](https://github.com/psiberx/cp2077-equipment-ex) wardrobe. It builds an outfit from the clothes you own, one piece per slot, and lets you lock the slots you want to keep. Your equipped gear and its stats are untouched.

## How it works

Open the Equipment-EX wardrobe and press the die button in the row of small buttons above the item list, then **RANDOMIZE** in the panel that opens. Each press rerolls every slot that is not locked:

| Slots | Rolled |
|---|---|
| Torso (under, inner, middle, outer) | One is always filled, an inner or middle layer when there is one. The outer slot is added on the jacket chance and the others on the extra layer chance. |
| Legs (inner, middle, outer) | One is always filled, a middle or outer layer when there is one. The others are added on the extra layer chance. |
| Footwear | Always |
| Headwear, eyewear, face mask | By chance |
| Accessories | By chance, each slot on its own |
| Full-body | Off by default. See below for how it combines with the other layers. |
| Every other slot | By chance, each slot on its own |

A slot with nothing to pick from is left as it is.

### Toggles and cyberware

Two switches in the panel, both off by default, decide what may be picked:

- **Allow toggles** - toggles and adjusters (pieces with "toggle" or "adjust" in their name or ID).
- **Allow cyberware** - cyberware shown as clothing: everything from the KiasuBurger cyberware mods (their item IDs start with `kiasu_burger`) and any piece with "cyberware" in its name or ID.

While a switch is off, those pieces are left out of the random pool. The switches are saved with the game and do not affect pieces you equip by hand.

### Avoiding overlap

Pieces are checked by name and item ID, not by slot, because modded clothing is often filed under whatever slot its author or the player chose. A dress in a torso slot is still a dress. From the words in the name and ID, each piece in the torso, legs and full-body slots is placed in one of these layers: under (bras and the like), top, jacket, bottom, under-legs (leggings, tights, underwear) or full (dresses, jumpsuits, bodysuits, or a name that lists a top and a bottom). When the name says nothing, the slot decides.

The randomizer keeps to one piece per layer, and a full piece goes with nothing but a jacket. A one-piece from one of the body slots is worn alone, with the torso and legs left empty. Pieces already worn in locked slots are counted. If no piece fits a slot it is left empty.

### Locking slots

Point at a slot's row in the wardrobe list and press **R** (the reload key) to lock or unlock it. Locked slots show **LOCKED** on their row and keep whatever they have, including nothing. **UNLOCK ALL SLOTS** in the panel clears every lock. Locks are saved with the game.

### What it picks from

Pieces come from the item source the wardrobe is set to, narrowed by its search text. If you like a result, save it as an outfit in the wardrobe as usual.

With [WEAVE](https://www.nexusmods.com/cyberpunk2077/mods/28273) installed, the randomizer also follows the wardrobe's **Slot** and **Tag** filters. Set the tag filter to a style, faction, wealth tier, reaction or custom tag and the outfit is built only from pieces that match, the same way the list filters them. The category filter and the All / Equipped tabs are not followed.

### With Street Sense

With [Street Sense](https://www.nexusmods.com/cyberpunk2077/mods/28989) installed, the panel shows how it reads the outfit you end up with: revealing, intimidation, fear and face scores, and the best faction disguise.

## Translations

The mod's text is registered with Codeware's localization system, so it can be translated without touching the scripts. The English text and a how-to are in `OutfitRandomizerLocalization.reds`; to add a language, copy the English class, translate it and return it for that language. Translations are welcome. The Mod Settings page is English only.

## Requirements

- [Equipment-EX](https://github.com/psiberx/cp2077-equipment-ex) and its own requirements (ArchiveXL, TweakXL, Codeware, redscript)

Optional:
- [Mod Settings](https://github.com/jackhumbert/mod_settings) - adds an in-game options page (see below). Without it the defaults apply.
- [WEAVE](https://www.nexusmods.com/cyberpunk2077/mods/28273) and [Street Sense](https://www.nexusmods.com/cyberpunk2077/mods/28989), as above.

Without Equipment-EX the mod loads but does nothing.

## Options

With Mod Settings installed, under **Outfit Randomizer**:

| Section | Option | Default |
|---|---|---|
| Layers | Jacket chance (%) | 60 |
| Layers | Extra layer chance (%) | 25 |
| Layers | Headwear chance (%) | 35 |
| Layers | Eyewear chance (%) | 35 |
| Layers | Face mask chance (%) | 15 |
| Layers | Accessory chance (%) | 45 |
| Layers | Full-body chance (%) | 0 |
| Layers | Other slots chance (%) | 20 |
| Troubleshooting | Debug logging | Off |

*Accessory chance* is rolled separately for each accessory slot: necklaces, earrings, wrists, gloves, belt and scarf. *Other slots chance* covers every slot not listed in the table above, such as shoulders, rings and nails. At 0 those slots are never touched; lock any you want kept.

## Notes

- Built and tested on game version 2.3x with Equipment-EX 1.2.9, Codeware 1.20.5 and TweakXL 1.11.4.
- Street Sense's readout uses its documented score functions, plus a refresh call and a faction-name lookup that are not in its documentation. Both are only used when Street Sense is installed.
- The Category filter and the All / Equipped tabs of WEAVE's wardrobe are not followed when picking.

## Credits

- **psiberx** for [Equipment-EX](https://github.com/psiberx/cp2077-equipment-ex), whose outfit system and wardrobe screen this mod builds on.
- **ApoKrytia** for [WEAVE](https://www.nexusmods.com/cyberpunk2077/mods/28273) and its clothing tags.
- **DigitalVixen** for [Street Sense](https://www.nexusmods.com/cyberpunk2077/mods/28989) and its clothing score API.

The code in this repository was written with Claude, an AI assistant.

## License

[MIT](LICENSE)
