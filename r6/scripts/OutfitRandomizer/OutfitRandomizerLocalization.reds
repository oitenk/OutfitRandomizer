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
    this.Text("OutfitRandomizer-Help", "Picks from your wardrobe, narrowed by the search text and the slot and tag filters. To keep a slot as it is, point at its row in the list and press R; locked slots are marked LOCKED. Slots worn with toggles, cyberware or add-ons that are switched off are locked for you; unlock any you want changed.");
    this.Text("OutfitRandomizer-Randomize", "Randomize");
    this.Text("OutfitRandomizer-UnlockAll", "Unlock all slots");
    this.Text("OutfitRandomizer-AllowToggles", "Allow toggles");
    this.Text("OutfitRandomizer-AllowCyberware", "Allow cyberware");
    this.Text("OutfitRandomizer-AllowAddons", "Allow add-ons");
    this.Text("OutfitRandomizer-On", "On");
    this.Text("OutfitRandomizer-Off", "Off");
    this.Text("OutfitRandomizer-Save", "Save outfit");
    this.Text("OutfitRandomizer-Locked", "Locked");
    this.Text("OutfitRandomizer-LockSlot", "Lock slot");
    this.Text("OutfitRandomizer-UnlockSlot", "Unlock slot");

    // Status line
    this.Text("OutfitRandomizer-Blocked", "The outfit can't be changed right now.");
    this.Text("OutfitRandomizer-NothingToPick", "Nothing to pick from: no pieces match the search and filters.");
    this.Text("OutfitRandomizer-Done", "Put on {COUNT} pieces. {POOL} pieces match, across {SLOTS} slots.");
    this.Text("OutfitRandomizer-AutoLocked", "Locked {COUNT} slots worn with toggles, cyberware or add-ons. Unlock any you want changed.");

    this.Text("OutfitRandomizer-NothingToSave", "There is no outfit to save yet. Randomize first.");
    this.Text("OutfitRandomizer-Saved", "Saved as {NAME}.");
    this.Text("OutfitRandomizer-DistrictResult", "{TAGGED} of {COUNT} pieces carry the chosen tags.");
    this.Text("OutfitRandomizer-DistrictUnknown", "No district recognised here, so the pieces were picked freely.");
    this.Text("OutfitRandomizer-Region-club", "Club");

    // Districts
    this.Text("OutfitRandomizer-DistrictButton", "District");
    this.Text("OutfitRandomizer-DistrictTitle", "District");
    this.Text("OutfitRandomizer-DistrictAny", "Any");
    this.Text("OutfitRandomizer-DistrictCurrent", "Where I am");
    this.Text("OutfitRandomizer-DistrictCount", "{COUNT} chosen");
    this.Text("OutfitRandomizer-Region-corpo", "Corpo");
    this.Text("OutfitRandomizer-Region-street", "Street");
    this.Text("OutfitRandomizer-Region-wild", "Wild");
    this.Text("OutfitRandomizer-District-corpoplaza", "Corpo Plaza");
    this.Text("OutfitRandomizer-District-downtown", "Downtown");
    this.Text("OutfitRandomizer-District-arasakawaterfront", "Arasaka Waterfront");
    this.Text("OutfitRandomizer-District-charterhill", "Charter Hill");
    this.Text("OutfitRandomizer-District-northoaks", "North Oak");
    this.Text("OutfitRandomizer-District-japantown", "Japantown");
    this.Text("OutfitRandomizer-District-glen", "Glen");
    this.Text("OutfitRandomizer-District-vistadelrey", "Vista del Rey");
    this.Text("OutfitRandomizer-District-wellsprings", "Wellsprings");
    this.Text("OutfitRandomizer-District-kabuki", "Kabuki");
    this.Text("OutfitRandomizer-District-littlechina", "Little China");
    this.Text("OutfitRandomizer-District-northside", "Northside");
    this.Text("OutfitRandomizer-District-arroyo", "Arroyo");
    this.Text("OutfitRandomizer-District-ranchocoronado", "Rancho Coronado");
    this.Text("OutfitRandomizer-District-coastview", "Coastview");
    this.Text("OutfitRandomizer-District-westwindestate", "West Wind Estate");
    this.Text("OutfitRandomizer-District-badlands", "Badlands");
    this.Text("OutfitRandomizer-District-dogtown", "Dogtown");

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
