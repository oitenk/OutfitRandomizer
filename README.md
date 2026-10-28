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

### Dressing for a district

Press **DISTRICT** in the panel to open a pop-out, laid out like WEAVE's tag pop-out, and tick one or more of:

- **Any** clears the choice, and **Where I am** follows the district you are standing in when you press Randomize.
- **Corpo**, **Street**, **Wild** and **Club** are kinds of place. Each prefers pieces with some of WEAVE's style tags: Corpo prefers Corpo and Formal; Street prefers Streetwear, Casual and Sports; Wild prefers Biker, Cowboy, Industrial and Military; Club prefers Stylish, Formal, Rocker and Punk.
- Districts: Corpo Plaza, Downtown, Arasaka Waterfront, Charter Hill, North Oak and Japantown; Glen, Vista del Rey, Wellsprings, Kabuki, Little China, Northside, Arroyo and Rancho Coronado; Coastview, West Wind Estate, Badlands and Dogtown.

Each district has the gangs that are most present there and a wealth tier, and the randomizer prefers pieces carrying those tags (the same gang and Rich / Simple / Poor tags WEAVE shows in its tag filter, though WEAVE is not needed for them to count). For example, Kabuki prefers Tyger Claws, Maelstrom and Moxes pieces, and Glen prefers Valentinos. The tables, including the style tags for the kinds of place, are this mod's own.

It is a preference, not a filter, so a slot with nothing tagged still gets a piece. At least four pieces come from the district's tags when there are enough, as [Street Sense](https://www.nexusmods.com/cyberpunk2077/mods/28989) counts a disguise as complete at four, and after that each piece does on the **District tag strength** setting's chance. The status line says how many pieces carried the tags. WEAVE's own tag filter still works on top of this and narrows the pool first.

### Saving the result

Press **SAVE OUTFIT** after a randomize and the wardrobe's own save pop-up opens with a name already filled in, which you can change before confirming. The name uses the words [Dynamic Wardrobe](https://strahlimeier.gitbook.io/dynamic-wardrobe) matches on: any kinds of place you chose (`corpo`, `street`, `wild`, `club`), then the districts, such as `STREET KABUKI`. Corpo, street, wild and club are only added when you chose them, and a district is only added when you chose one or picked **Where I am**. With nothing chosen it suggests `RANDOM`. A number is added if the name is taken, and saving over an existing outfit asks first.

Dynamic Wardrobe is not needed. Outfits swap on their own when it is installed and you enter a matching place, and it can replace a randomized outfit the next time you cross a district boundary.

### Leaving pieces out

Tag any piece **OMIT** and the randomizer never picks it. Nothing is locked: if you are wearing one, a randomize can still replace it, so lock the slot yourself (**R**) to keep it. With [WEAVE](https://www.nexusmods.com/cyberpunk2077/mods/28273), point at the piece in the wardrobe list, press **T** to open the tag editor and add a custom tag called OMIT. To tag several at once, mark them with **Z** first. The tag is not case sensitive, and a mod that gives its items an OMIT tag works the same way.

### Toggles, cyberware and add-ons

Three switches in the panel, all off by default, decide what may be picked:

- **Allow toggles** - toggles and adjusters (pieces with "toggle" or "adjust" in their name or ID), and the cosmetic parts of the Zenitex clothing packs, such as lenses, LEDs, visor glass and goggles, which are not named toggle.
- **Allow cyberware** - cyberware shown as clothing: everything from the KiasuBurger cyberware mods (their item IDs start with `kiasu_burger`) and any piece with "cyberware" in its name or ID.
- **Allow add-ons** - things worn that are not clothes: weapon and holster add-ons, decals, and cosmetics such as lip colour and nails.

While a switch is off, those pieces are left out of the random pool. A slot you are wearing one in is locked for you, the first time it is seen, so your makeup or cyberware is not cleared and you can see it is kept. Point at its row and press **R** to unlock any slot you do want changed; it is not locked again for the same piece. The switches are saved with the game and do not affect pieces you equip by hand.

### Avoiding overlap

Pieces are checked by name and item ID, not by slot, because modded clothing is often filed under whatever slot its author or the player chose. A dress in a torso slot is still a dress. From the words in the name and ID, each piece in the torso, legs and full-body slots is placed in one of these layers: under (bras and the like), top, jacket, bottom, under-legs (leggings, tights, underwear) or full (dresses, jumpsuits, catsuits, or a name that lists a top and a bottom). Bodysuits and leotards count as tops, so a bottom can go with them. The torso aux slot (vests, puffers) is checked by name too, so a vest does not go on top of a jacket. When the name says nothing, the slot decides.

The randomizer keeps to one piece per layer, and a full piece goes with nothing but a jacket. A one-piece from one of the body slots is worn alone, with the torso and legs left empty. Pieces already worn in locked slots are counted. If no piece fits a slot it is left empty.

### Locking slots

Point at a slot's row in the wardrobe list and press **R** (the reload key) to lock or unlock it. Locked slots show **LOCKED** on their row and keep whatever they have, including nothing. **UNLOCK ALL SLOTS** in the panel clears every lock. Locks are saved with the game.

### What it picks from

Pieces come from the item source the wardrobe is set to, narrowed by its search box. If you like a result, save it as an outfit in the wardrobe as usual.

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
- [Cyber Engine Tweaks](https://www.nexusmods.com/cyberpunk2077/mods/107) or [RedFunctions](https://www.nexusmods.com/cyberpunk2077/mods/32312) - either one lets the mod read item IDs. Without them it goes by item names and appearance names, which catch most modded pieces but can miss a few (see Notes).

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
| District | District tag strength (%) | 70 |
| Panel | Panel position X | 115 |
| Panel | Panel position Y | 1120 |
| Troubleshooting | Debug logging | Off |

*Accessory chance* is rolled separately for each accessory slot: necklaces, earrings, wrists, gloves, belt and scarf. *Other slots chance* covers every slot not listed in the table above, such as shoulders, rings and nails. At 0 those slots are never touched; lock any you want kept. *Panel position* moves the randomizer panel; it starts below the outfit list so it does not cover the buttons or the weather readout. It takes effect when the wardrobe is next opened.

## Notes

- Built and tested on game version 2.5 with Equipment-EX 1.2.10, Codeware 1.21.1, TweakXL 1.12.0 and ArchiveXL 1.28.0. Checked against WEAVE 1.6.0.
- The toggle, cyberware and add-on switches, the overlap check and the search also look at each piece's item ID (such as `kiasu_burger_...`). The game only provides item IDs when Cyber Engine Tweaks or RedFunctions is installed. Without either, the mod uses the piece's appearance name instead, which for modded clothing is usually the same or close.
- Street Sense's readout uses its documented score functions, plus a refresh call and a faction-name lookup that are not in its documentation. Both are only used when Street Sense is installed.
- The Category filter and the All / Equipped tabs of WEAVE's wardrobe are not followed when picking.
- None of WEAVE, Street Sense or Dynamic Wardrobe is needed. Without WEAVE the randomizer uses the stock Equipment-EX wardrobe: its search box applies, but the slot and tag filters and the tag editor (and so the OMIT tag) do not exist. The district and style preferences still work on the tags items already carry, which vanilla clothing has many of, but modded clothing only has them if something has tagged it. Without Street Sense there is no score readout, and Dynamic Wardrobe only matters to the names suggested when saving.

## Credits

- **psiberx** for [Equipment-EX](https://github.com/psiberx/cp2077-equipment-ex), whose outfit system and wardrobe screen this mod builds on.
- **ApoKrytia** for [WEAVE](https://www.nexusmods.com/cyberpunk2077/mods/28273) and its clothing tags.
- **DigitalVixen** for [Street Sense](https://www.nexusmods.com/cyberpunk2077/mods/28989) and its clothing score API.
- **Strahlimeier** for [Dynamic Wardrobe](https://strahlimeier.gitbook.io/dynamic-wardrobe), whose outfit naming words the suggested save name follows.

The code in this repository was written with Claude, an AI assistant.

## License

[MIT](LICENSE)
