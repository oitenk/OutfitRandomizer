// Outfit Randomizer: the districts the player can dress for, and the pop-out that
// lists them.
//
// Each district has the gangs that are most present there, a wealth tier, and the
// region it belongs to (corpo, street or wild, as in Dynamic Wardrobe). The gangs and
// wealth tier become tag preferences when picking, using the same tag names WEAVE
// shows in its tag filter. Corpo, street, wild and club can also be chosen on their
// own, and prefer pieces with WEAVE's style tags instead. The table is this mod's
// own, written from the game's lore.
module OutfitRandomizer

@if(ModuleExists("EquipmentEx"))
import Codeware.UI.*

public class ORDistrict {
  public let id: CName;
  public let region: String;
  public let factions: array<CName>;
  public let wealth: CName;
  // Starts of the location names the game reports while the player is in the district.
  public let prefixes: array<String>;

  public static func Make(id: CName, region: String, factions: array<CName>, wealth: CName, prefixes: array<String>) -> ref<ORDistrict> {
    let district: ref<ORDistrict> = new ORDistrict();
    district.id = id;
    district.region = region;
    district.factions = factions;
    district.wealth = wealth;
    district.prefixes = prefixes;
    return district;
  }
}

public abstract class ORDistricts {
  // The ids are the words Dynamic Wardrobe uses for these places, so an outfit named
  // with one is matched there.
  public static func All() -> array<ref<ORDistrict>> {
    let list: array<ref<ORDistrict>>;
    ArrayPush(list, ORDistrict.Make(n"corpoplaza", "corpo", [n"Arasaka", n"Militech"], n"Rich", ["corpoplaza", "citycenter"]));
    ArrayPush(list, ORDistrict.Make(n"downtown", "corpo", [n"Arasaka", n"Militech"], n"Rich", ["downtown"]));
    ArrayPush(list, ORDistrict.Make(n"arasakawaterfront", "corpo", [n"Arasaka"], n"Rich", ["arasakawaterfront"]));
    ArrayPush(list, ORDistrict.Make(n"charterhill", "corpo", [n"Arasaka"], n"Rich", ["charterhill"]));
    ArrayPush(list, ORDistrict.Make(n"northoaks", "corpo", [n"Arasaka"], n"Rich", ["northoak"]));
    ArrayPush(list, ORDistrict.Make(n"japantown", "corpo", [n"TygerClaws"], n"Simple", ["japantown"]));
    ArrayPush(list, ORDistrict.Make(n"glen", "street", [n"Valentinos"], n"Simple", ["glen"]));
    ArrayPush(list, ORDistrict.Make(n"vistadelrey", "street", [n"Valentinos"], n"Poor", ["vistadelrey", "vista_del"]));
    ArrayPush(list, ORDistrict.Make(n"wellsprings", "street", [n"Valentinos"], n"Simple", ["wellsprings"]));
    ArrayPush(list, ORDistrict.Make(n"kabuki", "street", [n"TygerClaws", n"Maelstrom", n"Moxies"], n"Poor", ["kabuki"]));
    ArrayPush(list, ORDistrict.Make(n"littlechina", "street", [n"TygerClaws", n"Maelstrom"], n"Poor", ["littlechina"]));
    ArrayPush(list, ORDistrict.Make(n"northside", "street", [n"Maelstrom"], n"Poor", ["northside"]));
    ArrayPush(list, ORDistrict.Make(n"arroyo", "street", [n"SixthStreet"], n"Poor", ["arroyo"]));
    ArrayPush(list, ORDistrict.Make(n"ranchocoronado", "street", [n"SixthStreet"], n"Simple", ["ranchocoronado", "rancho"]));
    ArrayPush(list, ORDistrict.Make(n"coastview", "wild", [n"VoodooBoys", n"Animals"], n"Poor", ["coastview"]));
    ArrayPush(list, ORDistrict.Make(n"westwindestate", "wild", [n"VoodooBoys", n"Animals"], n"Poor", ["westwind"]));
    ArrayPush(list, ORDistrict.Make(n"badlands", "wild", [n"Aldecaldos", n"Wraiths", n"Scavengers"], n"Poor", ["badlands", "northbadlands", "southbadlands", "lagunabend"]));
    ArrayPush(list, ORDistrict.Make(n"dogtown", "wild", [n"Barghest"], n"Poor", ["dogtown"]));
    return list;
  }

  public static func Find(id: CName) -> ref<ORDistrict> {
    let list: array<ref<ORDistrict>> = ORDistricts.All();
    let i: Int32 = 0;
    while i < ArraySize(list) {
      if Equals(list[i].id, id) {
        return list[i];
      }
      i += 1;
    }
    return null;
  }

  // The name of the place the player is in, as the game reports it.
  public static func CurrentLocation(game: GameInstance) -> String {
    let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_Map);
    if !IsDefined(blackboard) {
      return "";
    }
    return blackboard.GetString(GetAllBlackboardDefs().UI_Map.currentLocationEnumName);
  }

  public static func FromLocation(location: String) -> ref<ORDistrict> {
    let list: array<ref<ORDistrict>> = ORDistricts.All();
    let lower: String = StrLower(location);
    let i: Int32 = 0;
    let j: Int32;
    if StrLen(lower) == 0 {
      return null;
    }
    while i < ArraySize(list) {
      j = 0;
      while j < ArraySize(list[i].prefixes) {
        if StrBeginsWith(lower, list[i].prefixes[j]) {
          return list[i];
        }
        j += 1;
      }
      i += 1;
    }
    return null;
  }

  public static func Name(id: CName) -> String {
    return OR_Text("OutfitRandomizer-District-" + NameToString(id));
  }

  // The choices that are a kind of place, not a district. Their ids are the words
  // Dynamic Wardrobe matches outfit names on.
  public static func GroupIds() -> array<CName> {
    return [n"corpo", n"street", n"wild", n"club"];
  }

  public static func IsGroup(id: CName) -> Bool {
    return Equals(id, n"corpo") || Equals(id, n"street") || Equals(id, n"wild") || Equals(id, n"club");
  }

  // The WEAVE style tags a kind of place prefers.
  public static func GroupStyles(id: CName) -> array<CName> {
    let styles: array<CName>;
    if Equals(id, n"corpo") {
      styles = [n"Corpo", n"Formal"];
    }
    if Equals(id, n"street") {
      styles = [n"Streetwear", n"Casual", n"Sports"];
    }
    if Equals(id, n"wild") {
      styles = [n"Biker", n"Cowboy", n"Industrial", n"Military"];
    }
    if Equals(id, n"club") {
      styles = [n"Stylish", n"Formal", n"Rocker", n"Punk"];
    }
    return styles;
  }

  public static func GroupName(id: CName) -> String {
    return OR_Text("OutfitRandomizer-Region-" + NameToString(id));
  }
}

// The districts the player has picked, with "current" resolved to where they are now.
func OR_ResolveDistricts(system: ref<ORSystem>, game: GameInstance) -> array<ref<ORDistrict>> {
  let result: array<ref<ORDistrict>>;
  let ids: array<CName> = system.GetDistricts();
  let district: ref<ORDistrict>;
  let i: Int32 = 0;
  let j: Int32;
  let known: Bool;
  while i < ArraySize(ids) {
    if Equals(ids[i], n"current") {
      district = ORDistricts.FromLocation(ORDistricts.CurrentLocation(game));
    } else {
      district = ORDistricts.Find(ids[i]);
    }
    if IsDefined(district) {
      known = false;
      j = 0;
      while j < ArraySize(result) {
        if Equals(result[j].id, district.id) {
          known = true;
        }
        j += 1;
      }
      if !known {
        ArrayPush(result, district);
      }
    }
    i += 1;
  }
  return result;
}

// The kinds of place (corpo, street, wild, club) that have been picked.
func OR_SelectedGroups(system: ref<ORSystem>) -> array<CName> {
  let result: array<CName>;
  let ids: array<CName> = system.GetDistricts();
  let i: Int32 = 0;
  while i < ArraySize(ids) {
    if ORDistricts.IsGroup(ids[i]) {
      ArrayPush(result, ids[i]);
    }
    i += 1;
  }
  return result;
}

// The tags the picks prefer: the gangs of the districts and the style tags of the kinds
// of place for the main ones, and the districts' wealth tiers for the second choice.
func OR_DistrictTags(districts: array<ref<ORDistrict>>, groups: array<CName>, out tags: array<CName>, out wealth: array<CName>) -> Void {
  let styles: array<CName>;
  let i: Int32 = 0;
  let j: Int32;
  while i < ArraySize(districts) {
    j = 0;
    while j < ArraySize(districts[i].factions) {
      if !ArrayContains(tags, districts[i].factions[j]) {
        ArrayPush(tags, districts[i].factions[j]);
      }
      j += 1;
    }
    if !ArrayContains(wealth, districts[i].wealth) {
      ArrayPush(wealth, districts[i].wealth);
    }
    i += 1;
  }
  i = 0;
  while i < ArraySize(groups) {
    styles = ORDistricts.GroupStyles(groups[i]);
    j = 0;
    while j < ArraySize(styles) {
      if !ArrayContains(tags, styles[j]) {
        ArrayPush(tags, styles[j]);
      }
      j += 1;
    }
    i += 1;
  }
}

// --- The pop-out ---

@if(ModuleExists("EquipmentEx"))
public class ORDistrictChange extends Event {
  public let id: CName;
}

// One checkbox row in the pop-out. It is built from the same row the Equipment-EX
// wardrobe uses for its own pop-outs, so it looks like them.
@if(ModuleExists("EquipmentEx"))
public class ORDistrictOption extends inkLogicController {
  private let m_id: CName;
  private let m_text: String;
  private let m_root: wref<inkCompoundWidget>;
  private let m_label: wref<inkText>;
  private let m_checkbox: wref<inkWidget>;
  private let m_selection: wref<inkWidget>;
  private let m_hovered: Bool;
  private let m_selected: Bool;

  protected cb func OnInitialize() {
    this.m_root = this.GetRootCompoundWidget();
    this.m_label = this.GetChildWidgetByPath(n"titleAndCheckbox/FilterName") as inkText;
    this.m_label.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
    this.m_checkbox = this.GetChildWidgetByPath(n"titleAndCheckbox/checkbox");
    this.m_selection = this.GetChildWidgetByPath(n"titleAndCheckbox/checkbox/checkbox");
    this.RegisterToCallback(n"OnRelease", this, n"OnRelease");
    this.RegisterToCallback(n"OnEnter", this, n"OnHoverOver");
    this.RegisterToCallback(n"OnLeave", this, n"OnHoverOut");
  }

  protected cb func OnRelease(evt: ref<inkPointerEvent>) {
    let change: ref<ORDistrictChange>;
    if evt.IsAction(n"click") {
      change = new ORDistrictChange();
      change.id = this.m_id;
      this.QueueEvent(change);
    }
  }

  protected cb func OnHoverOver(evt: ref<inkPointerEvent>) {
    this.m_hovered = true;
    this.UpdateState();
  }

  protected cb func OnHoverOut(evt: ref<inkPointerEvent>) {
    this.m_hovered = false;
    this.UpdateState();
  }

  // Sizes the row to its text, which can only be measured once the pop-out is laid out.
  public func UpdateView() {
    this.m_root.SetSize(Vector2(this.m_label.GetDesiredWidth() + 170.0, 80.0));
    this.m_label.BindProperty(n"fontStyle", n"MainColors.BodyFontWeight");
    this.m_label.BindProperty(n"fontSize", n"MainColors.ReadableSmall");
    this.m_checkbox.SetVisible(true);
    this.m_label.SetMargin(inkMargin(20.0, 0.0, 0.0, 0.0));
    this.GetChildWidgetByPath(n"titleAndCheckbox").SetMargin(inkMargin(0.0, 0.0, 0.0, 0.0));
    this.GetChildWidgetByPath(n"background").SetVisible(false);
  }

  protected func UpdateState() {
    this.m_selection.SetVisible(this.m_selected);
    this.m_root.SetOpacity(1.0);
    if this.m_hovered {
      this.m_root.SetState(n"Hover");
    } else {
      this.m_root.SetState(this.m_selected ? n"Selected" : n"Default");
    }
    this.m_label.BindProperty(n"tintColor", this.m_selected ? n"MainColors.Blue" : n"MainColors.Red");
  }

  public func SetData(id: CName, text: String, selected: Bool) {
    this.m_id = id;
    this.m_text = text;
    this.m_selected = selected;
    this.m_label.SetText(text);
    this.UpdateState();
  }

  public func SetSelected(selected: Bool) {
    this.m_selected = selected;
    this.UpdateState();
  }

  public func GetId() -> CName {
    return this.m_id;
  }
}

// The pop-out for choosing districts, in the style of WEAVE's tag pop-out. Choices are
// applied as they are made.
@if(ModuleExists("EquipmentEx"))
public class ORDistrictPopup extends InMenuPopup {
  private let m_system: wref<ORSystem>;
  private let m_options: array<wref<ORDistrictOption>>;
  private let m_arranged: Bool;

  protected cb func OnCreate() {
    let content: ref<InMenuPopupContent>;
    let panel: ref<inkHorizontalPanel>;
    let footer: ref<InMenuPopupFooter>;
    let closeButton: ref<PopupButton>;
    let list: array<ref<ORDistrict>> = ORDistricts.All();
    let regions: array<String> = ["corpo", "street", "wild"];
    let groups: array<CName> = ORDistricts.GroupIds();
    let column: ref<inkVerticalPanel>;
    let i: Int32 = 0;
    let j: Int32;
    super.OnCreate();

    content = InMenuPopupContent.Create();
    content.SetTitle(OR_Text("OutfitRandomizer-DistrictTitle"));
    content.Reparent(this);

    panel = new inkHorizontalPanel();
    panel.SetMargin(inkMargin(0.0, 24.0, 0.0, 0.0));
    panel.Reparent(content.GetContainerWidget());

    // The first column clears the choice, follows where the player is, or picks a
    // kind of place.
    column = this.AddColumn(panel);
    this.AddOption(column, n"", OR_Text("OutfitRandomizer-DistrictAny"));
    this.AddOption(column, n"current", OR_Text("OutfitRandomizer-DistrictCurrent"));
    while i < ArraySize(groups) {
      this.AddOption(column, groups[i], ORDistricts.GroupName(groups[i]));
      i += 1;
    }

    // Then the districts, a column for each region.
    i = 0;
    while i < ArraySize(regions) {
      column = this.AddColumn(panel);
      j = 0;
      while j < ArraySize(list) {
        if Equals(list[j].region, regions[i]) {
          this.AddOption(column, list[j].id, ORDistricts.Name(list[j].id));
        }
        j += 1;
      }
      i += 1;
    }
    this.RefreshOptions();

    footer = InMenuPopupFooter.Create();
    footer.Reparent(this);
    closeButton = PopupButton.Create();
    closeButton.SetText(GetLocalizedTextByKey(n"Common-Access-Close"));
    closeButton.SetInputAction(n"cancel");
    closeButton.Reparent(footer);
  }

  private func AddColumn(parent: ref<inkCompoundWidget>) -> ref<inkVerticalPanel> {
    let column: ref<inkVerticalPanel> = new inkVerticalPanel();
    column.SetMargin(inkMargin(0.0, 0.0, 30.0, 0.0));
    column.Reparent(parent);
    return column;
  }

  private func AddOption(parent: ref<inkCompoundWidget>, id: CName, text: String) -> Void {
    let widget: ref<inkWidget> = this.SpawnFromExternal(parent, r"equipment_ex\\gui\\wardrobe.inkwidget", n"OutfitListEntry:OutfitRandomizer.ORDistrictOption");
    let option: ref<ORDistrictOption>;
    if !IsDefined(widget) {
      return;
    }
    option = widget.GetController() as ORDistrictOption;
    if IsDefined(option) {
      option.SetData(id, text, false);
      ArrayPush(this.m_options, option);
    }
  }

  // Ticks the rows that match what is chosen.
  private func RefreshOptions() -> Void {
    let id: CName;
    let i: Int32 = 0;
    if !IsDefined(this.m_system) {
      return;
    }
    while i < ArraySize(this.m_options) {
      id = this.m_options[i].GetId();
      if IsNameValid(id) {
        this.m_options[i].SetSelected(this.m_system.HasDistrict(id));
      } else {
        this.m_options[i].SetSelected(this.m_system.DistrictCount() == 0);
      }
      i += 1;
    }
  }

  protected cb func OnArrangeChildrenComplete() {
    let i: Int32 = 0;
    if !this.m_arranged {
      while i < ArraySize(this.m_options) {
        this.m_options[i].UpdateView();
        i += 1;
      }
      this.m_arranged = true;
    }
  }

  protected cb func OnChange(evt: ref<ORDistrictChange>) {
    if !IsDefined(this.m_system) {
      return;
    }
    if IsNameValid(evt.id) {
      this.m_system.ToggleDistrict(evt.id);
    } else {
      this.m_system.ClearDistricts();
    }
    this.RefreshOptions();
  }

  public static func Show(requester: ref<inkGameController>, system: ref<ORSystem>) {
    let popup: ref<ORDistrictPopup> = new ORDistrictPopup();
    popup.m_system = system;
    popup.Open(requester);
  }
}
