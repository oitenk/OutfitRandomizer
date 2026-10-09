// Outfit Randomizer: text shown by the mod, registered with Codeware's localization
// system so it can be translated.
//
// To add a language, copy ORLanguageEnglish into a new class (in a file of its own),
// translate the second string of every line and leave the first alone, then return
// the new class for that language from ORLocalizationProvider.GetPackage below.
// {COUNT}, {POOL}, {SLOTS} and {TAGS} are filled in by the mod, so keep them in.
// Slot names and item names come from the game and are already translated.
//
// The Mod Settings page is written in English only.
module OutfitRandomizer

@if(ModuleExists("Codeware.Localization"))
import Codeware.Localization.*

@if(ModuleExists("Codeware.Localization"))
public class ORLocalizationProvider extends ModLocalizationProvider {
  public func GetPackage(language: CName) -> ref<ModLocalizationPackage> {
    switch language {
      // case n"fr-fr": return new ORLanguageFrench();
      default: return new ORLanguageEnglish();
    }
  }

  public func GetFallback() -> CName {
    return n"en-us";
  }
}

@if(ModuleExists("Codeware.Localization"))
public class ORLanguageEnglish extends ModLocalizationPackage {
  protected func DefineTexts() -> Void {
    // Wardrobe button panel
    this.Text("OutfitRandomizer-Title", "Outfit Randomizer");
    this.Text("OutfitRandomizer-Help", "Picks from your wardrobe, narrowed by the search text and the slot and tag filters. To keep a slot as it is, point at its row in the list and press R; locked slots are marked LOCKED.");
    this.Text("OutfitRandomizer-Randomize", "Randomize");
    this.Text("OutfitRandomizer-UnlockAll", "Unlock all slots");
    this.Text("OutfitRandomizer-AllowToggles", "Allow toggles");
    this.Text("OutfitRandomizer-AllowCyberware", "Allow cyberware");
    this.Text("OutfitRandomizer-On", "On");
    this.Text("OutfitRandomizer-Off", "Off");
    this.Text("OutfitRandomizer-Locked", "Locked");
    this.Text("OutfitRandomizer-LockSlot", "Lock slot");
    this.Text("OutfitRandomizer-UnlockSlot", "Unlock slot");

    // Status line
    this.Text("OutfitRandomizer-Blocked", "The outfit can't be changed right now.");
    this.Text("OutfitRandomizer-NothingToPick", "Nothing to pick from: no pieces match the search and filters.");
    this.Text("OutfitRandomizer-Done", "Put on {COUNT} pieces. {POOL} pieces match, across {SLOTS} slots.");

    // Info under the buttons
    this.Text("OutfitRandomizer-LockedSlots", "Locked slots: {COUNT}");
    this.Text("OutfitRandomizer-TagFilter", "Tag filter: {TAGS}");
    this.Text("OutfitRandomizer-SlotFilter", "Slot filter: {COUNT} slots");

    // Street Sense readout
    this.Text("OutfitRandomizer-SS-Title", "Street Sense");
    this.Text("OutfitRandomizer-SS-Revealing", "Revealing");
    this.Text("OutfitRandomizer-SS-Intimidation", "Intimidation");
    this.Text("OutfitRandomizer-SS-Fear", "Fear");
    this.Text("OutfitRandomizer-SS-FaceExposed", "Face exposed");
    this.Text("OutfitRandomizer-SS-BestDisguise", "Best disguise");
    this.Text("OutfitRandomizer-SS-None", "none");
  }
}
