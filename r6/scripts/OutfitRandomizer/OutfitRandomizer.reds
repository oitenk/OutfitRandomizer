// Outfit Randomizer
// Builds a random outfit from the clothes in the Equipment-EX wardrobe, one piece
// per slot, and wears it through Equipment-EX's outfit system. Equipped gear is
// untouched. The wardrobe button, panel and slot locks are in OutfitRandomizerUI.reds.
module OutfitRandomizer

@if(ModuleExists("EquipmentEx"))
import EquipmentEx.OutfitSystem

// Player-facing options. With the Mod Settings mod installed they appear in its
// in-game menu; without it the defaults below apply.
public class ORSettings {
  @runtimeProperty("ModSettings.mod", "Outfit Randomizer")
  @runtimeProperty("ModSettings.category", "Layers")
  @runtimeProperty("ModSettings.displayName", "Jacket chance (%)")
  @runtimeProperty("ModSettings.description", "Chance to add a jacket or coat (the outer torso slot) over the torso layer that is always worn.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  @runtimeProperty("ModSettings.step", "5")
  public let jacketChance: Int32 = 60;

  @runtimeProperty("ModSettings.mod", "Outfit Randomizer")
  @runtimeProperty("ModSettings.category", "Layers")
  @runtimeProperty("ModSettings.displayName", "Extra layer chance (%)")
  @runtimeProperty("ModSettings.description", "Chance, rolled for each remaining torso and legs slot, to add another layer to the one that is always worn. Pieces that would overlap what is already worn, going by their names, are skipped.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  @runtimeProperty("ModSettings.step", "5")
  public let extraLayerChance: Int32 = 25;

  @runtimeProperty("ModSettings.mod", "Outfit Randomizer")
  @runtimeProperty("ModSettings.category", "Layers")
  @runtimeProperty("ModSettings.displayName", "Headwear chance (%)")
  @runtimeProperty("ModSettings.description", "Chance to add a hat or helmet.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  @runtimeProperty("ModSettings.step", "5")
  public let headwearChance: Int32 = 35;

  @runtimeProperty("ModSettings.mod", "Outfit Randomizer")
  @runtimeProperty("ModSettings.category", "Layers")
  @runtimeProperty("ModSettings.displayName", "Eyewear chance (%)")
  @runtimeProperty("ModSettings.description", "Chance to add glasses or a visor.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  @runtimeProperty("ModSettings.step", "5")
  public let eyewearChance: Int32 = 35;

  @runtimeProperty("ModSettings.mod", "Outfit Randomizer")
  @runtimeProperty("ModSettings.category", "Layers")
  @runtimeProperty("ModSettings.displayName", "Face mask chance (%)")
  @runtimeProperty("ModSettings.description", "Chance to add a face mask or balaclava.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  @runtimeProperty("ModSettings.step", "5")
  public let maskChance: Int32 = 15;

  @runtimeProperty("ModSettings.mod", "Outfit Randomizer")
  @runtimeProperty("ModSettings.category", "Layers")
  @runtimeProperty("ModSettings.displayName", "Accessory chance (%)")
  @runtimeProperty("ModSettings.description", "Chance, rolled separately for each accessory slot (necklaces, earrings, wrists, gloves, belt, scarf), to fill it.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  @runtimeProperty("ModSettings.step", "5")
  public let accessoryChance: Int32 = 45;

  @runtimeProperty("ModSettings.mod", "Outfit Randomizer")
  @runtimeProperty("ModSettings.category", "Layers")
  @runtimeProperty("ModSettings.displayName", "Full-body chance (%)")
  @runtimeProperty("ModSettings.description", "Chance to wear a jumpsuit or other one-piece. When one is worn the torso and legs are left empty, so this is off by default.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  @runtimeProperty("ModSettings.step", "5")
  public let fullBodyChance: Int32 = 0;

  @runtimeProperty("ModSettings.mod", "Outfit Randomizer")
  @runtimeProperty("ModSettings.category", "Layers")
  @runtimeProperty("ModSettings.displayName", "Other slots chance (%)")
  @runtimeProperty("ModSettings.description", "Chance, rolled for each slot not covered above (shoulders, rings, nails and so on), to fill it; otherwise the slot is emptied. At 0 those slots are left exactly as they are.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  @runtimeProperty("ModSettings.step", "5")
  public let otherChance: Int32 = 20;

  @runtimeProperty("ModSettings.mod", "Outfit Randomizer")
  @runtimeProperty("ModSettings.category", "District")
  @runtimeProperty("ModSettings.displayName", "District tag strength (%)")
  @runtimeProperty("ModSettings.description", "When districts are chosen in the panel, how often a piece is picked from the pieces tagged for them. At least four pieces always are, when there are enough, as Street Sense counts a disguise as complete at four.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  @runtimeProperty("ModSettings.step", "5")
  public let districtStrength: Int32 = 70;

  @runtimeProperty("ModSettings.mod", "Outfit Randomizer")
  @runtimeProperty("ModSettings.category", "Panel")
  @runtimeProperty("ModSettings.displayName", "Panel position X")
  @runtimeProperty("ModSettings.description", "How far from the left edge of the screen the randomizer panel sits in the wardrobe. Takes effect the next time the wardrobe is opened.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "3000")
  @runtimeProperty("ModSettings.step", "10")
  public let panelX: Int32 = 115;

  @runtimeProperty("ModSettings.mod", "Outfit Randomizer")
  @runtimeProperty("ModSettings.category", "Panel")
  @runtimeProperty("ModSettings.displayName", "Panel position Y")
  @runtimeProperty("ModSettings.description", "How far from the top of the screen the randomizer panel sits in the wardrobe. Takes effect the next time the wardrobe is opened.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "1500")
  @runtimeProperty("ModSettings.step", "10")
  public let panelY: Int32 = 1120;

  @runtimeProperty("ModSettings.mod", "Outfit Randomizer")
  @runtimeProperty("ModSettings.category", "Troubleshooting")
  @runtimeProperty("ModSettings.displayName", "Debug logging")
  @runtimeProperty("ModSettings.description", "Writes each randomized outfit to the Cyber Engine Tweaks game log.")
  public let debugLogging: Bool = false;

  public static func Get() -> ref<ORSettings> {
    let system: ref<ORSystem> = ORSystem.Get(GetGameInstance());
    if IsDefined(system) {
      return system.GetSettings();
    }
    return new ORSettings();
  }
}

// Owns the settings and the slot locks, and keeps the settings in step with the
// Mod Settings menu.
public class ORSystem extends ScriptableSystem {
  private let m_settings: ref<ORSettings>;

  // Outfit slots the randomizer must leave alone, saved with the game.
  private persistent let m_lockedSlots: array<TweakDBID>;

  // Pieces that are normally left out of the random pool, saved with the game.
  private persistent let m_allowToggles: Bool;
  private persistent let m_allowCyberware: Bool;
  private persistent let m_allowAddons: Bool;

  // The districts chosen in the panel, by id ("current" follows where the player is).
  private persistent let m_districts: array<CName>;

  // How many pieces of the last randomize came from the district tags.
  private let m_lastTagged: Int32;

  // The slot and piece of every automatic lock made so far, so that a slot the player
  // has unlocked is not locked again for the same piece. Saved with the game.
  private persistent let m_autoLockSlots: array<TweakDBID>;
  private persistent let m_autoLockItems: array<TweakDBID>;

  // The panel in the wardrobe screen that is open, or was open last.
  private let m_panel: ref<IScriptable>;

  public static func Get(game: GameInstance) -> ref<ORSystem> {
    return GameInstance.GetScriptableSystemsContainer(game).Get(n"OutfitRandomizer.ORSystem") as ORSystem;
  }

  private func OnAttach() -> Void {
    this.GetSettings();
  }

  private func OnDetach() -> Void {
    this.m_panel = null;
    if IsDefined(this.m_settings) {
      OR_UnregisterSettings(this.m_settings);
    }
  }

  public func GetSettings() -> ref<ORSettings> {
    if !IsDefined(this.m_settings) {
      this.m_settings = new ORSettings();
      OR_RegisterSettings(this.m_settings);
    }
    return this.m_settings;
  }

  public func SetPanel(panel: ref<IScriptable>) -> Void {
    this.m_panel = panel;
  }

  public func IsLocked(slotID: TweakDBID) -> Bool {
    return ArrayContains(this.m_lockedSlots, slotID);
  }

  public func ToggleLock(slotID: TweakDBID) -> Void {
    if ArrayContains(this.m_lockedSlots, slotID) {
      ArrayRemove(this.m_lockedSlots, slotID);
    } else {
      ArrayPush(this.m_lockedSlots, slotID);
    }
  }

  public func ClearLocks() -> Void {
    ArrayClear(this.m_lockedSlots);
  }

  public func LockCount() -> Int32 {
    return ArraySize(this.m_lockedSlots);
  }

  public func AllowsToggles() -> Bool {
    return this.m_allowToggles;
  }

  public func AllowsCyberware() -> Bool {
    return this.m_allowCyberware;
  }

  public func GetDistricts() -> array<CName> {
    return this.m_districts;
  }

  public func HasDistrict(id: CName) -> Bool {
    return ArrayContains(this.m_districts, id);
  }

  public func ToggleDistrict(id: CName) -> Void {
    if ArrayContains(this.m_districts, id) {
      ArrayRemove(this.m_districts, id);
    } else {
      ArrayPush(this.m_districts, id);
    }
  }

  public func ClearDistricts() -> Void {
    ArrayClear(this.m_districts);
  }

  public func DistrictCount() -> Int32 {
    return ArraySize(this.m_districts);
  }

  public func SetLastTagged(count: Int32) -> Void {
    this.m_lastTagged = count;
  }

  public func LastTagged() -> Int32 {
    return this.m_lastTagged;
  }

  public func AllowsAddons() -> Bool {
    return this.m_allowAddons;
  }

  public func SetAllowAddons(allow: Bool) -> Void {
    this.m_allowAddons = allow;
  }

  // Locks a slot because it is worn with a piece that is not allowed in the pool.
  // Each slot and piece pair is only locked once, so the player can unlock the slots
  // they want changed. Returns true if this locked a slot that was not locked.
  public func AutoLockOnce(slotID: TweakDBID, recordID: TweakDBID) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_autoLockSlots) {
      if this.m_autoLockSlots[i] == slotID && this.m_autoLockItems[i] == recordID {
        return false;
      }
      i += 1;
    }
    ArrayPush(this.m_autoLockSlots, slotID);
    ArrayPush(this.m_autoLockItems, recordID);
    if ArrayContains(this.m_lockedSlots, slotID) {
      return false;
    }
    ArrayPush(this.m_lockedSlots, slotID);
    return true;
  }

  public func SetAllowToggles(allow: Bool) -> Void {
    this.m_allowToggles = allow;
  }

  public func SetAllowCyberware(allow: Bool) -> Void {
    this.m_allowCyberware = allow;
  }

  public func Log(message: String) -> Void {
    if this.GetSettings().debugLogging {
      FTLog("[OutfitRandomizer] " + message);
    }
  }
}

@if(ModuleExists("ModSettingsModule"))
func OR_RegisterSettings(settings: ref<ORSettings>) -> Void {
  ModSettings.RegisterListenerToClass(settings);
}

@if(!ModuleExists("ModSettingsModule"))
func OR_RegisterSettings(settings: ref<ORSettings>) -> Void {}

@if(ModuleExists("ModSettingsModule"))
func OR_UnregisterSettings(settings: ref<ORSettings>) -> Void {
  ModSettings.UnregisterListenerToClass(settings);
}

@if(!ModuleExists("ModSettingsModule"))
func OR_UnregisterSettings(settings: ref<ORSettings>) -> Void {}

// Text from the mod's localization (OutfitRandomizerLocalization.reds), in the
// language the game is set to.
func OR_Text(key: String) -> String {
  let text: String = GetLocalizedTextByKey(StringToName(key));
  return Equals(text, "") || Equals(text, key) ? key : text;
}

// Everything below needs Equipment-EX. Without it the mod still compiles and
// simply does nothing.

@if(ModuleExists("EquipmentEx"))
func OR_Roll(chance: Int32) -> Bool {
  return RandRange(0, 100) < chance;
}

// The Zenitex clothing packs (item IDs starting items.scorpion_) name their clothes
// with a quality at the end, such as _legendary. The cosmetic parts that go with
// them, such as lenses, LEDs, visor glass and goggles, have none, and the older ones
// were never named toggle, so they are told apart by that.
@if(ModuleExists("EquipmentEx"))
func OR_IsZenitexPart(path: String) -> Bool {
  let qualities: array<String> = ["common", "uncommon", "rare", "epic", "legendary", "iconic", "legendaryplusplus"];
  let tokens: array<String>;
  if !StrBeginsWith(path, "items.scorpion_") {
    return false;
  }
  tokens = OR_Tokens(path);
  return ArraySize(tokens) > 0 && !ArrayContains(qualities, tokens[ArraySize(tokens) - 1]);
}

// Toggles and adjusters switch parts of other pieces on and off.
@if(ModuleExists("EquipmentEx"))
func OR_IsToggle(name: String, path: String) -> Bool {
  return StrContains(name, "toggle") || StrContains(path, "toggle") || StrContains(name, "adjust") || StrContains(path, "adjust") || OR_IsZenitexPart(path);
}

// Cyberware shown as clothing: everything from the KiasuBurger cyberware mods (their
// item IDs start with kiasu_burger) and anything else that says cyberware.
@if(ModuleExists("EquipmentEx"))
func OR_IsCyberware(name: String, path: String) -> Bool {
  return StrContains(path, "kiasu_burger") || StrContains(path, "kiasuburger") || StrContains(path, "cyberware") || StrContains(name, "cyberware") || StrContains(path, "raid_psy");
}

// Things that are worn but are not clothes: weapon and holster add-ons, decals and
// cosmetics such as lip colour and nails. Aldecaldos is not a decal.
@if(ModuleExists("EquipmentEx"))
func OR_IsAddon(name: String, path: String) -> Bool {
  let words: array<String> = ["weapon", "holster", "bandolier", "addon", "add-on", "decal", "cosmetic", "lipstick", "eyeshadow", "eyeliner", "mascara", "makeup", "pedicure", "manicure"];
  let tokens: array<String> = ["lips", "nails", "nail", "blush"];
  let text: String = StrReplace(StrReplace(name + " " + path, "aldecaldos", ""), "-", " ");
  let found: array<String> = OR_Tokens(text);
  let i: Int32 = 0;
  while i < ArraySize(words) {
    if StrContains(text, StrReplace(words[i], "-", " ")) {
      return true;
    }
    i += 1;
  }
  i = 0;
  while i < ArraySize(tokens) {
    if ArrayContains(found, tokens[i]) {
      return true;
    }
    i += 1;
  }
  return false;
}

// Whether a piece carries the OMIT tag. The player adds it in WEAVE's tag editor (as a
// custom tag), or any other mod can put it on an item; it is not case sensitive.
@if(ModuleExists("EquipmentEx"))
func OR_HasOmitTag(itemID: ItemID) -> Bool {
  let record: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID));
  let tags: array<CName>;
  let i: Int32 = 0;
  if !IsDefined(record) {
    return false;
  }
  tags = record.Tags();
  while i < ArraySize(tags) {
    if Equals(StrLower(NameToString(tags[i])), "omit") {
      return true;
    }
    i += 1;
  }
  return false;
}

// A piece's item ID, such as "items.kiasu_burger_arm", in lower case. The game only
// knows record names when CET or RedFunctions is installed. Without them the record's
// appearance name stands in, which for modded clothing usually matches its ID.
func OR_ItemPath(itemID: ItemID) -> String {
  let id: TweakDBID = ItemID.GetTDBID(itemID);
  let path: String = TDBID.ToStringDEBUG(id);
  let record: ref<Item_Record>;
  if StrLen(path) == 0 {
    record = TweakDBInterface.GetItemRecord(id);
    if IsDefined(record) {
      path = NameToString(record.AppearanceName());
    }
  }
  return UTF8StrLower(path);
}

// Whether a piece is a toggle, cyberware piece or add-on that the player has not
// allowed in the panel. Such pieces are left out of the pool, and a slot worn with
// one is locked.
@if(ModuleExists("EquipmentEx"))
func OR_IsKindExcluded(system: ref<ORSystem>, outfitSystem: ref<OutfitSystem>, itemID: ItemID) -> Bool {
  let name: String;
  let path: String;
  if system.AllowsToggles() && system.AllowsCyberware() && system.AllowsAddons() {
    return false;
  }
  name = UTF8StrLower(outfitSystem.GetItemName(itemID));
  path = OR_ItemPath(itemID);
  return (!system.AllowsToggles() && OR_IsToggle(name, path))
    || (!system.AllowsCyberware() && OR_IsCyberware(name, path))
    || (!system.AllowsAddons() && OR_IsAddon(name, path));
}

// Whether a piece is left out of the random pool: anything tagged OMIT, and the kinds
// above. A piece tagged OMIT is only ever left out of the pool. Its slot is not locked,
// so a randomize can still replace it when it is worn.
@if(ModuleExists("EquipmentEx"))
func OR_IsExcluded(system: ref<ORSystem>, outfitSystem: ref<OutfitSystem>, itemID: ItemID) -> Bool {
  return OR_HasOmitTag(itemID) || OR_IsKindExcluded(system, outfitSystem, itemID);
}

// Whether a slot can be rerolled: not locked, and the pool has a piece for it.
@if(ModuleExists("EquipmentEx"))
func OR_IsOpen(system: ref<ORSystem>, poolSlots: script_ref<array<TweakDBID>>, slotID: TweakDBID) -> Bool {
  return !system.IsLocked(slotID) && ArrayContains(Deref(poolSlots), slotID);
}

// Locks every slot that is worn with a toggle, cyberware piece or add-on while that
// kind is not allowed, so it stays as it is and the player can see it is kept. A slot is locked once for each piece; if the player unlocks it, it stays
// unlocked. Returns how many slots were locked now.
@if(ModuleExists("EquipmentEx"))
func OR_AutoLock(game: GameInstance) -> Int32 {
  let system: ref<ORSystem> = ORSystem.Get(game);
  let outfitSystem: ref<OutfitSystem> = OutfitSystem.GetInstance(game);
  let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(game);
  let player: ref<GameObject> = GetPlayer(game);
  let usedSlots: array<TweakDBID>;
  let worn: ref<ItemObject>;
  let added: Int32 = 0;
  let i: Int32 = 0;
  if !IsDefined(system) || !IsDefined(outfitSystem) || !IsDefined(player) {
    return 0;
  }
  usedSlots = outfitSystem.GetUsedSlots();
  while i < ArraySize(usedSlots) {
    worn = transactionSystem.GetItemInSlot(player, usedSlots[i]);
    if IsDefined(worn) && OR_IsKindExcluded(system, outfitSystem, worn.GetItemID()) {
      if system.AutoLockOnce(usedSlots[i], ItemID.GetTDBID(worn.GetItemID())) {
        added += 1;
        system.Log("locked " + outfitSystem.GetSlotName(usedSlots[i]) + ": worn with " + outfitSystem.GetItemName(worn.GetItemID()));
      }
    }
    i += 1;
  }
  return added;
}

// Whether a piece has any of the wanted tags.
@if(ModuleExists("EquipmentEx"))
func OR_AnyTag(itemTags: array<CName>, wanted: array<CName>) -> Bool {
  let i: Int32 = 0;
  while i < ArraySize(wanted) {
    if ArrayContains(itemTags, wanted[i]) {
      return true;
    }
    i += 1;
  }
  return false;
}

// A random piece from the pool for the given slot, as an index, or -1 if there is
// none that fits. Pieces that overlap what is already chosen (the cover codes in
// accepted) are skipped, and the piece already worn is only used when nothing else
// fits. With prefer on, pieces carrying one of the tags (gang or style) come first, then
// ones carrying a wealth tag, then the rest; tagged says whether the choice carries one
// of the first kind.
@if(ModuleExists("EquipmentEx"))
func OR_Pick(outfitSystem: ref<OutfitSystem>, poolItems: script_ref<array<ItemID>>, poolSlots: script_ref<array<TweakDBID>>, slotID: TweakDBID, accepted: array<Int32>, factions: array<CName>, wealth: array<CName>, prefer: Bool, out tagged: Bool) -> Int32 {
  let candidates: array<Int32>;
  let ranks: array<Int32>;
  let tiers: array<Int32>;
  let list: array<Int32>;
  let record: ref<Item_Record>;
  let itemTags: array<CName>;
  let tier: Int32;
  let attempts: Int32;
  let at: Int32;
  let position: Int32;
  let index: Int32;
  let rank: Int32;
  let i: Int32 = 0;
  tagged = false;
  while i < ArraySize(Deref(poolItems)) {
    if Deref(poolSlots)[i] == slotID {
      tier = 0;
      if prefer {
        record = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(Deref(poolItems)[i]));
        if IsDefined(record) {
          itemTags = record.Tags();
          if OR_AnyTag(itemTags, factions) {
            tier = 2;
          } else {
            if OR_AnyTag(itemTags, wealth) {
              tier = 1;
            }
          }
        }
      }
      ArrayPush(candidates, i);
      ArrayPush(tiers, tier);
      // Better tiers first, and within a tier the pieces not already worn.
      ArrayPush(ranks, tier * 2 + (outfitSystem.IsEquipped(Deref(poolItems)[i]) ? 0 : 1));
    }
    i += 1;
  }
  rank = prefer ? 5 : 1;
  while rank >= 0 {
    ArrayClear(list);
    i = 0;
    while i < ArraySize(candidates) {
      if ranks[i] == rank {
        ArrayPush(list, i);
      }
      i += 1;
    }
    // Looking at a piece means reading its name, so there is a limit.
    attempts = 0;
    while ArraySize(list) > 0 && attempts < 60 {
      at = RandRange(0, ArraySize(list));
      position = list[at];
      ArrayErase(list, at);
      index = candidates[position];
      if !OR_Conflicts(OR_CoverOf(outfitSystem, Deref(poolItems)[index], slotID), accepted) {
        tagged = tiers[position] == 2;
        return index;
      }
      attempts += 1;
    }
    rank -= 1;
  }
  return -1;
}

// One slot, filled or emptied on a roll.
@if(ModuleExists("EquipmentEx"))
func OR_PlanSlot(system: ref<ORSystem>, poolSlots: script_ref<array<TweakDBID>>, slotID: TweakDBID, chance: Int32, out fills: array<TweakDBID>, out clears: array<TweakDBID>) -> Void {
  if !OR_IsOpen(system, poolSlots, slotID) {
    return;
  }
  if OR_Roll(chance) {
    ArrayPush(fills, slotID);
  } else {
    ArrayPush(clears, slotID);
  }
}

// Slots that share one roll: on a success one of them is filled, and the rest are
// emptied either way.
@if(ModuleExists("EquipmentEx"))
func OR_PlanOneOf(system: ref<ORSystem>, poolSlots: script_ref<array<TweakDBID>>, slots: array<TweakDBID>, chance: Int32, out fills: array<TweakDBID>, out clears: array<TweakDBID>) -> Void {
  let open: array<TweakDBID>;
  let chosen: TweakDBID;
  let i: Int32 = 0;
  while i < ArraySize(slots) {
    if OR_IsOpen(system, poolSlots, slots[i]) {
      ArrayPush(open, slots[i]);
    }
    i += 1;
  }
  if ArraySize(open) == 0 {
    return;
  }
  if OR_Roll(chance) {
    chosen = open[RandRange(0, ArraySize(open))];
    ArrayPush(fills, chosen);
  }
  i = 0;
  while i < ArraySize(open) {
    if open[i] != chosen {
      ArrayPush(clears, open[i]);
    }
    i += 1;
  }
}

// Whether any slot in the list is in the other list.
@if(ModuleExists("EquipmentEx"))
func OR_AnyOf(slots: array<TweakDBID>, among: array<TweakDBID>) -> Bool {
  let i: Int32 = 0;
  while i < ArraySize(slots) {
    if ArrayContains(among, slots[i]) {
      return true;
    }
    i += 1;
  }
  return false;
}

// Empties every slot in the set that is not locked.
@if(ModuleExists("EquipmentEx"))
func OR_PlanClear(system: ref<ORSystem>, slots: array<TweakDBID>, out clears: array<TweakDBID>) -> Void {
  let i: Int32 = 0;
  while i < ArraySize(slots) {
    if !system.IsLocked(slots[i]) {
      ArrayPush(clears, slots[i]);
    }
    i += 1;
  }
}

// Whether a locked slot in the set is worn.
@if(ModuleExists("EquipmentEx"))
func OR_LockedAndWorn(system: ref<ORSystem>, outfitSystem: ref<OutfitSystem>, slots: array<TweakDBID>) -> Bool {
  let i: Int32 = 0;
  while i < ArraySize(slots) {
    if system.IsLocked(slots[i]) && outfitSystem.IsOccupied(slots[i]) {
      return true;
    }
    i += 1;
  }
  return false;
}

// A set of layered slots (torso or legs) that must never end up empty. Unless a
// locked slot in the set is already worn, one slot is always filled, from mainSlots
// when possible. The outer slot and the rest are then added on their own chances.
@if(ModuleExists("EquipmentEx"))
func OR_PlanLayers(system: ref<ORSystem>, outfitSystem: ref<OutfitSystem>, poolSlots: script_ref<array<TweakDBID>>, slots: array<TweakDBID>, mainSlots: array<TweakDBID>, outerSlot: TweakDBID, outerChance: Int32, extraChance: Int32, out fills: array<TweakDBID>, out clears: array<TweakDBID>) -> Void {
  let open: array<TweakDBID>;
  let mains: array<TweakDBID>;
  let chosen: array<TweakDBID>;
  let covered: Bool = false;
  let i: Int32 = 0;
  while i < ArraySize(slots) {
    if system.IsLocked(slots[i]) {
      if outfitSystem.IsOccupied(slots[i]) {
        covered = true;
      }
    } else {
      if ArrayContains(Deref(poolSlots), slots[i]) {
        ArrayPush(open, slots[i]);
        if ArrayContains(mainSlots, slots[i]) {
          ArrayPush(mains, slots[i]);
        }
      }
    }
    i += 1;
  }
  if ArraySize(open) == 0 {
    return;
  }
  // The layer that is always worn goes first, so it is picked before the optional ones.
  if !covered {
    if ArraySize(mains) > 0 {
      ArrayPush(chosen, mains[RandRange(0, ArraySize(mains))]);
    } else {
      ArrayPush(chosen, open[RandRange(0, ArraySize(open))]);
    }
    ArrayPush(fills, chosen[0]);
  }
  i = 0;
  while i < ArraySize(open) {
    if !ArrayContains(chosen, open[i]) {
      if OR_Roll(open[i] == outerSlot ? outerChance : extraChance) {
        ArrayPush(fills, open[i]);
      } else {
        ArrayPush(clears, open[i]);
      }
    }
    i += 1;
  }
}

// Rerolls every unlocked slot from the given pool of pieces (item and the outfit
// slot it goes in, as parallel arrays). A slot with nothing in the pool is left as
// it is. Returns how many pieces were put on, or -1 if outfits can't be changed.
@if(ModuleExists("EquipmentEx"))
func OR_Randomize(game: GameInstance, poolItems: array<ItemID>, poolSlots: array<TweakDBID>, factions: array<CName>, wealth: array<CName>) -> Int32 {
  let system: ref<ORSystem> = ORSystem.Get(game);
  let settings: ref<ORSettings> = system.GetSettings();
  let outfitSystem: ref<OutfitSystem> = OutfitSystem.GetInstance(game);
  let torsoSlots: array<TweakDBID> = [t"OutfitSlots.TorsoUnder", t"OutfitSlots.TorsoInner", t"OutfitSlots.TorsoMiddle", t"OutfitSlots.TorsoOuter"];
  let legsSlots: array<TweakDBID> = [t"OutfitSlots.LegsInner", t"OutfitSlots.LegsMiddle", t"OutfitSlots.LegsOuter"];
  let bodySlots: array<TweakDBID> = [t"OutfitSlots.BodyUnder", t"OutfitSlots.BodyInner", t"OutfitSlots.BodyMiddle", t"OutfitSlots.BodyOuter"];
  let maskSlots: array<TweakDBID> = [t"OutfitSlots.Mask", t"OutfitSlots.Balaclava"];
  let accessorySlots: array<TweakDBID> = [
    t"OutfitSlots.Neckwear", t"OutfitSlots.NecklaceTight", t"OutfitSlots.NecklaceShort", t"OutfitSlots.NecklaceLong",
    t"OutfitSlots.EarLeft", t"OutfitSlots.EarRight", t"OutfitSlots.WristLeft", t"OutfitSlots.WristRight",
    t"OutfitSlots.Hands", t"OutfitSlots.Waist"
  ];
  let singleSlots: array<TweakDBID> = [t"OutfitSlots.Feet", t"OutfitSlots.Head", t"OutfitSlots.Glasses"];
  let fills: array<TweakDBID>;
  let clears: array<TweakDBID>;
  let allSlots: array<TweakDBID>;
  let usedSlots: array<TweakDBID>;
  let accepted: array<Int32>;
  let picks: array<Int32>;
  let pickSlots: array<TweakDBID>;
  let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(game);
  let player: ref<GameObject> = GetPlayer(game);
  let worn: ref<ItemObject>;
  let cover: ORCover;
  let summary: String;
  let pick: Int32;
  let count: Int32 = 0;
  let taggedCount: Int32 = 0;
  let hasTags: Bool = ArraySize(factions) > 0 || ArraySize(wealth) > 0;
  let prefer: Bool;
  let wasTagged: Bool;
  let i: Int32;
  if !IsDefined(outfitSystem) || outfitSystem.IsBlocked() {
    system.Log("skipped: outfit changes are blocked");
    return -1;
  }


  // A one-piece covers the torso and legs, so when one is worn (picked now, or locked
  // and kept) the layers under and over it are emptied instead of piled on top.
  OR_PlanOneOf(system, poolSlots, bodySlots, settings.fullBodyChance, fills, clears);
  if OR_AnyOf(fills, bodySlots) || OR_LockedAndWorn(system, outfitSystem, bodySlots) {
    OR_PlanClear(system, torsoSlots, clears);
    OR_PlanClear(system, legsSlots, clears);
  } else {
    OR_PlanLayers(system, outfitSystem, poolSlots, torsoSlots, [t"OutfitSlots.TorsoInner", t"OutfitSlots.TorsoMiddle"], t"OutfitSlots.TorsoOuter", settings.jacketChance, settings.extraLayerChance, fills, clears);
    OR_PlanLayers(system, outfitSystem, poolSlots, legsSlots, [t"OutfitSlots.LegsMiddle", t"OutfitSlots.LegsOuter"], TDBID.None(), 0, settings.extraLayerChance, fills, clears);
  }
  OR_PlanSlot(system, poolSlots, t"OutfitSlots.Feet", 100, fills, clears);
  OR_PlanSlot(system, poolSlots, t"OutfitSlots.Head", settings.headwearChance, fills, clears);
  OR_PlanSlot(system, poolSlots, t"OutfitSlots.Glasses", settings.eyewearChance, fills, clears);
  OR_PlanOneOf(system, poolSlots, maskSlots, settings.maskChance, fills, clears);
  i = 0;
  while i < ArraySize(accessorySlots) {
    OR_PlanSlot(system, poolSlots, accessorySlots[i], settings.accessoryChance, fills, clears);
    i += 1;
  }
  // Every other slot is only touched when the player has asked for it.
  if settings.otherChance > 0 {
    allSlots = outfitSystem.GetOutfitSlots();
    i = 0;
    while i < ArraySize(allSlots) {
      if !ArrayContains(torsoSlots, allSlots[i]) && !ArrayContains(legsSlots, allSlots[i]) && !ArrayContains(bodySlots, allSlots[i])
        && !ArrayContains(maskSlots, allSlots[i]) && !ArrayContains(accessorySlots, allSlots[i]) && !ArrayContains(singleSlots, allSlots[i]) {
        OR_PlanSlot(system, poolSlots, allSlots[i], settings.otherChance, fills, clears);
      }
      i += 1;
    }
  }

  // What stays as it is (locked slots and slots left alone) already covers part of
  // the body, so new pieces are chosen around it.
  usedSlots = outfitSystem.GetUsedSlots();
  i = 0;
  while i < ArraySize(usedSlots) {
    if !ArrayContains(fills, usedSlots[i]) && !ArrayContains(clears, usedSlots[i]) {
      worn = transactionSystem.GetItemInSlot(player, usedSlots[i]);
      if IsDefined(worn) {
        cover = OR_CoverOf(outfitSystem, worn.GetItemID(), usedSlots[i]);
        if NotEquals(cover, ORCover.None) {
          ArrayPush(accepted, EnumInt(cover));
        }
      }
    }
    i += 1;
  }

  // Choose a piece for each slot, in order, skipping any that overlap the ones chosen
  // so far. A slot with no piece that fits is emptied.
  i = 0;
  while i < ArraySize(fills) {
    // Chosen districts steer the picks: the first four slots with a tagged piece to offer
    // take one, as Street Sense counts a disguise as complete at four, and after that
    // each slot does on the strength setting's chance.
    prefer = hasTags && (taggedCount < 4 || OR_Roll(settings.districtStrength));
    pick = OR_Pick(outfitSystem, poolItems, poolSlots, fills[i], accepted, factions, wealth, prefer, wasTagged);
    if pick >= 0 {
      if wasTagged {
        taggedCount += 1;
      }
      cover = OR_CoverOf(outfitSystem, poolItems[pick], fills[i]);
      if NotEquals(cover, ORCover.None) {
        ArrayPush(accepted, EnumInt(cover));
      }
      ArrayPush(picks, pick);
      ArrayPush(pickSlots, fills[i]);
    } else {
      ArrayPush(clears, fills[i]);
      system.Log("no piece fits slot " + outfitSystem.GetSlotName(fills[i]));
    }
    i += 1;
  }

  // Put the new pieces on first and clear slots after, so the player is never
  // shown undressed in between.
  i = 0;
  while i < ArraySize(picks) {
    if outfitSystem.EquipItem(poolItems[picks[i]]) {
      count += 1;
      summary += outfitSystem.GetSlotName(pickSlots[i]) + "=" + outfitSystem.GetItemName(poolItems[picks[i]]) + " [" + ToString(OR_CoverOf(outfitSystem, poolItems[picks[i]], pickSlots[i])) + "]; ";
    }
    i += 1;
  }
  i = 0;
  while i < ArraySize(clears) {
    if outfitSystem.IsOccupied(clears[i]) {
      outfitSystem.UnequipSlot(clears[i]);
    }
    i += 1;
  }
  system.SetLastTagged(taggedCount);
  system.Log("pool=" + IntToString(ArraySize(poolItems)) + " tagged=" + IntToString(taggedCount) + " outfit: " + summary);
  return count;
}
