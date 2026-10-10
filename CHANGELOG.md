# Changelog

## 1.0

- Initial release: a randomizer panel in the Equipment-EX wardrobe that builds an outfit from owned clothes, one piece per slot, with locks for the slots to keep.
- Follows WEAVE's slot and tag filters and shows Street Sense's reading of the outfit when those mods are installed.
- The button is a small die icon the size of the other buttons in the row, so it no longer squeezes the filters.
- Locks are set per slot on the wardrobe list's own rows (R), with a LOCKED label.
- Overlap is avoided by name: pieces are placed in a layer (under, top, jacket, bottom, under-legs or full) from the words in their name and item ID, and the randomizer keeps to one piece per layer, with only a jacket over a full piece. The slot is only used when the name says nothing.
- All text goes through Codeware's localization, so it can be translated.
- The cosmetic parts of the Zenitex clothing packs (lenses, LEDs, visor glass, goggles) count as toggles.
- Three switches in the panel, off by default: Allow toggles, Allow cyberware and Allow add-ons. Cyberware covers the KiasuBurger cyberware mods and anything with "cyberware" in its name or ID; add-ons covers weapon and holster add-ons, decals and cosmetics. A slot worn with something that is not allowed is locked automatically, once per piece, and can be unlocked to change it.
- A DISTRICT pop-out, in the style of WEAVE's tag pop-out, to pick districts to dress for (or "where I am"), or a kind of place: Corpo, Street, Wild or Club, each preferring WEAVE's style tags. Each district prefers pieces with the gang and wealth tags of the gangs most present there, with at least four from them when possible and a Mod Settings strength for the rest.
- SAVE OUTFIT opens the wardrobe's save pop-up with a name filled in, using the words of the chosen kinds of place and districts that Dynamic Wardrobe matches on, which can be changed before saving.
- Any piece tagged OMIT (a custom tag in WEAVE's tag editor) is never picked. Nothing is locked for it, so a worn one can still be replaced.
- The panel starts below the outfit list so it no longer covers the Sync and Sort buttons or the weather readout, sizes itself to its content, and can be moved in Mod Settings.
- Bodysuits and leotards are treated as tops, and the torso aux slot (vests, puffers) is checked for overlap by name.
