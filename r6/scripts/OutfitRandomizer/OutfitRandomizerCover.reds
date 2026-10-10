// Outfit Randomizer: works out what part of the body a piece covers, from its name
// and item ID, so pieces that would overlap are not worn together.
//
// The slot a piece is listed under is not reliable for this: modded clothing is filed
// under whatever slot its author or the player chose, so a dress can sit in a torso
// slot. The name says what it is. When the name says nothing, the slot is used.
module OutfitRandomizer

@if(ModuleExists("EquipmentEx"))
import EquipmentEx.OutfitSystem

public enum ORCover {
  None = 0,
  Under = 1,
  Top = 2,
  Jacket = 3,
  Bottom = 4,
  UnderLegs = 5,
  Full = 6
}

// Lower-case words of a name or item ID. Letters, digits and camelCase changes
// separate words, so "Items.Crop_Top" and "CropTop" both give crop, top.
func OR_Tokens(text: String) -> array<String> {
  let tokens: array<String>;
  let current: String = "";
  let prevLower: Bool = false;
  let c: String;
  let lower: String;
  let upper: String;
  let isLetter: Bool;
  let isUpper: Bool;
  let i: Int32 = 0;
  let count: Int32 = StrLen(text);
  while i < count {
    c = StrMid(text, i, 1);
    lower = StrLower(c);
    upper = StrUpper(c);
    isLetter = NotEquals(lower, upper);
    isUpper = isLetter && Equals(c, upper);
    if isLetter || StrContains("0123456789", c) {
      if isUpper && prevLower && NotEquals(current, "") {
        ArrayPush(tokens, current);
        current = "";
      }
      current += lower;
      prevLower = isLetter && !isUpper;
    } else {
      if NotEquals(current, "") {
        ArrayPush(tokens, current);
        current = "";
      }
      prevLower = false;
    }
    i += 1;
  }
  if NotEquals(current, "") {
    ArrayPush(tokens, current);
  }
  return tokens;
}

func OR_EndsWithAny(word: String, suffixes: array<String>) -> Bool {
  let length: Int32 = StrLen(word);
  let i: Int32 = 0;
  while i < ArraySize(suffixes) {
    if length >= StrLen(suffixes[i]) && Equals(StrMid(word, length - StrLen(suffixes[i]), StrLen(suffixes[i])), suffixes[i]) {
      return true;
    }
    i += 1;
  }
  return false;
}

// What a piece covers going by its words alone, or None if they say nothing.
func OR_NameCover(text: String) -> ORCover {
  let tokens: array<String> = OR_Tokens(text);
  // A garment that follows "dress" makes it a different piece (dress shirt, dress shoes).
  let dressGarments: array<String> = ["shirt", "shirts", "pants", "shoe", "shoes", "boot", "boots", "coat", "jacket", "vest", "trousers", "slacks", "belt", "gloves", "glove", "socks", "sock", "hat", "code", "sandals", "sandal", "blazer", "skirt"];
  let fullWords: array<String> = ["gown", "jumpsuit", "jumpsuits", "catsuit", "romper", "overall", "overalls", "coverall", "coveralls", "playsuit", "tracksuit", "unitard", "onesie", "swimwear", "robe", "bathrobe"];
  let notDress: array<String> = ["address", "headdress", "redress"];
  let jacketWords: array<String> = ["blazer", "parka", "poncho", "cape", "cloak", "trench", "windbreaker", "bomber", "anorak", "shrug", "duster", "puffer", "gilet", "vest", "vests", "waistcoat"];
  let bottomWords: array<String> = ["pants", "pant", "jeans", "trousers", "trouser", "shorts", "skirt", "skirts", "skort", "slacks", "chinos", "joggers", "culottes", "kilt", "capris", "bloomers", "bottoms", "bottom"];
  let topWords: array<String> = ["tee", "tees", "tshirt", "tshirts", "top", "tops", "blouse", "blouses", "tank", "tanks", "hoodie", "hoodies", "hoody", "sweater", "sweaters", "sweatshirt", "pullover", "cardigan", "turtleneck", "polo", "tunic", "jersey", "henley", "halter", "bustier", "corset", "jumper", "bodysuit", "bodysuits", "leotard", "swimsuit"];
  let notTop: array<String> = ["laptop", "desktop", "rooftop", "hilltop", "tabletop", "treetop", "stop", "atop"];
  let underWords: array<String> = ["bra", "bras", "bralette", "cami", "camisole", "undershirt"];
  let underLegsWords: array<String> = ["panties", "panty", "thong", "briefs", "boxers", "boxer", "leggings", "legging", "jeggings", "tights", "pantyhose", "hosiery", "stockings", "fishnet", "fishnets"];
  let full: Bool = false;
  let jacket: Bool = false;
  let bottom: Bool = false;
  let top: Bool = false;
  let under: Bool = false;
  let underLegs: Bool = false;
  let underwear: Bool = false;
  let word: String;
  let next: String;
  let i: Int32 = 0;
  while i < ArraySize(tokens) {
    word = tokens[i];
    next = i + 1 < ArraySize(tokens) ? tokens[i + 1] : "";
    if Equals(word, "dress") {
      if !ArrayContains(dressGarments, next) {
        full = true;
      }
    } else {
      if ArrayContains(fullWords, word) || (!ArrayContains(notDress, word) && OR_EndsWithAny(word, ["dress"])) {
        full = true;
      }
    }
    if ArrayContains(jacketWords, word) || OR_EndsWithAny(word, ["jacket", "coat"]) {
      jacket = true;
    }
    if ArrayContains(bottomWords, word) || OR_EndsWithAny(word, ["pants", "skirt", "shorts"]) {
      bottom = true;
    }
    if ArrayContains(topWords, word) || (!ArrayContains(notTop, word) && OR_EndsWithAny(word, ["shirt", "top"])) {
      if !(Equals(word, "top") && Equals(next, "hat")) {
        top = true;
      }
    }
    if ArrayContains(underWords, word) {
      under = true;
    }
    if Equals(word, "underwear") {
      underwear = true;
    } else {
      if ArrayContains(underLegsWords, word) {
        underLegs = true;
      }
    }
    i += 1;
  }
  // "Underwear top" is a bra, "underwear bottom" is panties, plain underwear is panties.
  if underwear {
    if top || under {
      top = false;
      under = true;
    } else {
      if bottom {
        bottom = false;
      }
      underLegs = true;
    }
  }
  // Pieces sold as a set cover everything.
  if full || (bottom && (jacket || top)) {
    return ORCover.Full;
  }
  if jacket {
    return ORCover.Jacket;
  }
  if bottom {
    return ORCover.Bottom;
  }
  if top {
    return ORCover.Top;
  }
  if underLegs {
    return ORCover.UnderLegs;
  }
  if under {
    return ORCover.Under;
  }
  return ORCover.None;
}

// What a slot is for, used when a piece's name says nothing. None for slots that
// are not part of the main body layers, which are not checked for overlap (except
// the torso aux slot, see OR_CoverOf).
func OR_SlotCover(slotID: TweakDBID) -> ORCover {
  if slotID == t"OutfitSlots.TorsoUnder" {
    return ORCover.Under;
  }
  if slotID == t"OutfitSlots.TorsoInner" || slotID == t"OutfitSlots.TorsoMiddle" {
    return ORCover.Top;
  }
  if slotID == t"OutfitSlots.TorsoOuter" {
    return ORCover.Jacket;
  }
  if slotID == t"OutfitSlots.LegsInner" {
    return ORCover.UnderLegs;
  }
  if slotID == t"OutfitSlots.LegsMiddle" || slotID == t"OutfitSlots.LegsOuter" {
    return ORCover.Bottom;
  }
  if slotID == t"OutfitSlots.BodyUnder" || slotID == t"OutfitSlots.BodyInner" || slotID == t"OutfitSlots.BodyMiddle" || slotID == t"OutfitSlots.BodyOuter" {
    return ORCover.Full;
  }
  return ORCover.None;
}

// Whether a piece covering this part can be worn with the ones already chosen:
// one piece per kind of layer, and nothing but a jacket over a one-piece.
func OR_Conflicts(cover: ORCover, accepted: array<Int32>) -> Bool {
  let i: Int32 = 0;
  if Equals(cover, ORCover.None) {
    return false;
  }
  if Equals(cover, ORCover.Full) {
    while i < ArraySize(accepted) {
      if accepted[i] != EnumInt(ORCover.Jacket) {
        return true;
      }
      i += 1;
    }
    return false;
  }
  if NotEquals(cover, ORCover.Jacket) && ArrayContains(accepted, EnumInt(ORCover.Full)) {
    return true;
  }
  return ArrayContains(accepted, EnumInt(cover));
}

// What a piece covers when worn in the given slot.
@if(ModuleExists("EquipmentEx"))
func OR_CoverOf(outfitSystem: ref<OutfitSystem>, itemID: ItemID, slotID: TweakDBID) -> ORCover {
  let fallback: ORCover = OR_SlotCover(slotID);
  let named: ORCover;
  // The aux slot (vests, puffers, harnesses) has no layer of its own, but a vest there
  // is still a jacket, so it is checked by name alone.
  if Equals(fallback, ORCover.None) && slotID != t"OutfitSlots.TorsoAux" {
    return ORCover.None;
  }
  named = OR_NameCover(outfitSystem.GetItemName(itemID) + " " + TDBID.ToStringDEBUG(ItemID.GetTDBID(itemID)));
  return Equals(named, ORCover.None) ? fallback : named;
}
