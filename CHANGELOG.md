# Changelog

## 1.0

- Initial release: a randomizer panel in the Equipment-EX wardrobe that builds an outfit from owned clothes, one piece per slot, with locks for the slots to keep.
- Follows WEAVE's slot and tag filters and shows Street Sense's reading of the outfit when those mods are installed.
- The button is a small die icon the size of the other buttons in the row, so it no longer squeezes the filters.
- Locks are set per slot on the wardrobe list's own rows (R), with a LOCKED label.
- Overlap is avoided by name: pieces are placed in a layer (under, top, jacket, bottom, under-legs or full) from the words in their name and item ID, and the randomizer keeps to one piece per layer, with only a jacket over a full piece. The slot is only used when the name says nothing.
- All text goes through Codeware's localization, so it can be translated.
- Two switches in the panel, off by default: Allow toggles and Allow cyberware. Cyberware covers the KiasuBurger cyberware mods and anything with "cyberware" in its name or ID.
