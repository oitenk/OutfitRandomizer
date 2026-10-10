// Outfit Randomizer: the button and panel inside the Equipment-EX wardrobe screen.
//
// A die button in the row of small buttons opens the panel, which has the Randomize
// button; slots are locked on their own rows in the wardrobe list. Pieces are drawn from the wardrobe's item source, narrowed by its
// search text and, with WEAVE, its slot and tag filters. Toggles and cyberware are
// left out unless the panel allows them.
//
// The wardrobe screen belongs to another mod and its class can't be extended from
// here, so the panel is a separate object that attaches itself when the screen opens.
module OutfitRandomizer

@if(ModuleExists("EquipmentEx"))
import EquipmentEx.*

@if(ModuleExists("EquipmentEx"))
import Codeware.UI.*

@if(ModuleExists("StreetSense"))
import StreetSense.*

// The wardrobe screen sets up its tooltips as it opens, which is the one step of
// its start-up that goes through a base-game class.
@if(ModuleExists("EquipmentEx"))
@wrapMethod(gameuiTooltipsManager)
public final func Setup(tooltipStyle: ETooltipsStyle, opt isDisplayCentered: Bool) -> Void {
  wrappedMethod(tooltipStyle, isDisplayCentered);
  OR_OnTooltipsSetup(this.GetRootWidget() as inkCompoundWidget);
}

@if(ModuleExists("EquipmentEx"))
func OR_OnTooltipsSetup(root: wref<inkCompoundWidget>) -> Void {
  let system: ref<ORSystem>;
  if !IsDefined(root) || !IsDefined(root.GetWidget(n"wrapper/wrapper/vendorPanel/vendorHeader/vendoHeaderWrapper")) {
    return;
  }
  system = ORSystem.Get(GetGameInstance());
  if IsDefined(system) {
    // The system keeps the panel alive until the next time the wardrobe opens.
    system.SetPanel(ORPanel.Create(system, root));
  }
}

@if(ModuleExists("EquipmentEx"))
public enum ORPanelAction {
  Attach = 0,
  Refresh = 1,
  Tick = 2
}

@if(ModuleExists("EquipmentEx"))
public class ORPanelCallback extends DelayCallback {
  public let m_panel: wref<ORPanel>;
  public let m_action: ORPanelAction;

  public func Call() -> Void {
    if IsDefined(this.m_panel) {
      this.m_panel.OnDelay(this.m_action);
    }
  }
}

@if(ModuleExists("EquipmentEx"))
public class ORPanel {
  private let m_system: wref<ORSystem>;
  private let m_root: wref<inkCompoundWidget>;
  private let m_screen: wref<WardrobeScreenController>;
  private let m_player: wref<PlayerPuppet>;
  private let m_outfitSystem: wref<OutfitSystem>;
  private let m_panel: wref<inkCanvas>;
  private let m_button: wref<inkCanvas>;
  private let m_togglesOption: wref<SimpleButton>;
  private let m_cyberwareOption: wref<SimpleButton>;
  private let m_addonsOption: wref<SimpleButton>;
  private let m_districtButton: wref<SimpleButton>;
  private let m_popupToken: ref<inkGameNotificationToken>;
  private let m_pendingName: CName;
  private let m_content: wref<inkVerticalPanel>;
  private let m_status: wref<inkText>;
  private let m_info: wref<inkText>;
  private let m_attachTries: Int32;
  private let m_readout: String;

  // The outfit slots and the names their rows in the wardrobe list are shown under.
  private let m_slotIDs: array<TweakDBID>;
  private let m_slotNames: array<String>;

  public static func Create(system: ref<ORSystem>, root: wref<inkCompoundWidget>) -> ref<ORPanel> {
    let self: ref<ORPanel> = new ORPanel();
    self.m_system = system;
    self.m_root = root;
    // The screen builds its own buttons after it has been spawned.
    self.Delay(ORPanelAction.Attach, 0.1);
    return self;
  }

  private func Delay(action: ORPanelAction, seconds: Float) -> Void {
    let callback: ref<ORPanelCallback> = new ORPanelCallback();
    callback.m_panel = this;
    callback.m_action = action;
    GameInstance.GetDelaySystem(GetGameInstance()).DelayCallback(callback, seconds, false);
  }

  public func OnDelay(action: ORPanelAction) -> Void {
    switch action {
      case ORPanelAction.Attach:
        this.TryAttach();
        break;
      case ORPanelAction.Refresh:
        this.Refresh(true);
        break;
      case ORPanelAction.Tick:
        this.Tick();
        break;
    }
  }

  // The wardrobe screen whose root widget this is, looked up among the open screens.
  private func FindScreen() -> wref<WardrobeScreenController> {
    let layers: array<ref<inkLayerWrapper>> = GameInstance.GetInkSystem().GetLayers();
    let controllers: array<wref<inkIGameController>>;
    let screen: wref<WardrobeScreenController>;
    let i: Int32 = 0;
    let j: Int32;
    while i < ArraySize(layers) {
      controllers = layers[i].GetGameControllers();
      j = 0;
      while j < ArraySize(controllers) {
        screen = controllers[j] as WardrobeScreenController;
        if IsDefined(screen) && screen.GetRootCompoundWidget() == this.m_root {
          return screen;
        }
        j += 1;
      }
      i += 1;
    }
    return null;
  }

  private func TryAttach() -> Void {
    let header: ref<inkCompoundWidget>;
    let buttons: ref<inkHorizontalPanel>;
    let i: Int32;
    if !IsDefined(this.m_root) {
      // Closed again before the panel was added.
      return;
    }
    if !IsDefined(this.m_screen) {
      this.m_screen = this.FindScreen();
    }
    if IsDefined(this.m_screen) {
      header = this.m_root.GetWidget(n"wrapper/wrapper/vendorPanel/vendorHeader/vendoHeaderWrapper") as inkCompoundWidget;
    }
    if IsDefined(header) {
      // The row of small buttons at the top right of the item list.
      i = header.GetNumChildren() - 1;
      while i >= 0 && !IsDefined(buttons) {
        buttons = header.GetWidgetByIndex(i) as inkHorizontalPanel;
        i -= 1;
      }
    }
    if !IsDefined(buttons) {
      this.m_attachTries += 1;
      if this.m_attachTries < 30 {
        this.Delay(ORPanelAction.Attach, 0.1);
      } else {
        FTLog("[OutfitRandomizer] the randomizer button was not added: " + (IsDefined(this.m_screen) ? "the wardrobe's button row was not found" : "the wardrobe screen was not found"));
      }
      return;
    }
    this.m_player = GetPlayer(GetGameInstance());
    this.m_outfitSystem = OutfitSystem.GetInstance(GetGameInstance());
    this.m_slotIDs = this.m_outfitSystem.GetOutfitSlots();
    ArrayClear(this.m_slotNames);
    i = 0;
    while i < ArraySize(this.m_slotIDs) {
      ArrayPush(this.m_slotNames, this.m_outfitSystem.GetSlotName(this.m_slotIDs[i]));
      i += 1;
    }
    this.CreateButton(buttons);
    this.CreatePanel();
    this.m_system.Log("wardrobe opened: button added after " + IntToString(this.m_attachTries) + " retries");
    this.Tick();
  }

  // A small square button with a die on it, the same size as the other buttons in the
  // row so it does not squeeze the filters.
  private func CreateButton(parent: ref<inkHorizontalPanel>) -> Void {
    let button: ref<inkCanvas> = new inkCanvas();
    let background: ref<inkImage> = new inkImage();
    let frame: ref<inkImage> = new inkImage();
    let pip: ref<inkRectangle>;
    let positions: array<Vector2> = [Vector2(18.0, 18.0), Vector2(52.0, 18.0), Vector2(35.0, 35.0), Vector2(18.0, 52.0), Vector2(52.0, 52.0)];
    let i: Int32 = 0;

    button.SetName(n"orToggleButton");
    button.SetSize(80.0, 80.0);
    button.SetInteractive(true);
    button.SetOpacity(0.85);
    button.Reparent(parent);

    background.SetAnchor(inkEAnchor.Fill);
    background.SetNineSliceScale(true);
    background.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
    background.SetTexturePart(n"cell_bg");
    background.SetStyle(r"base\\gameplay\\gui\\common\\components\\toggles_style.inkstyle");
    background.BindProperty(n"tintColor", n"FilterButton.backgroundColor");
    background.BindProperty(n"opacity", n"FilterButton.backgroundOpacity");
    background.Reparent(button);

    frame.SetAnchor(inkEAnchor.Fill);
    frame.SetNineSliceScale(true);
    frame.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
    frame.SetTexturePart(n"cell_fg");
    frame.SetStyle(r"base\\gameplay\\gui\\common\\components\\toggles_style.inkstyle");
    frame.BindProperty(n"tintColor", n"FilterButton.frameColor");
    frame.BindProperty(n"opacity", n"FilterButton.frameOpacity");
    frame.Reparent(button);

    // The five spots of a die, drawn as small squares.
    while i < ArraySize(positions) {
      pip = new inkRectangle();
      pip.SetAnchor(inkEAnchor.TopLeft);
      pip.SetAnchorPoint(Vector2(0.0, 0.0));
      pip.SetMargin(inkMargin(positions[i].X, positions[i].Y, 0.0, 0.0));
      pip.SetSize(10.0, 10.0);
      pip.SetStyle(r"base\\gameplay\\gui\\common\\components\\toggles_style.inkstyle");
      pip.BindProperty(n"tintColor", n"FilterButton.iconColor");
      pip.Reparent(button);
      i += 1;
    }

    this.m_button = button;
    button.RegisterToCallback(n"OnRelease", this, n"OnToggleRelease");
    button.RegisterToCallback(n"OnEnter", this, n"OnToggleEnter");
    button.RegisterToCallback(n"OnLeave", this, n"OnToggleLeave");
  }

  private func AddText(parent: ref<inkCompoundWidget>, text: String, size: Int32, color: CName) -> ref<inkText> {
    let widget: ref<inkText> = new inkText();
    widget.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    widget.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
    widget.BindProperty(n"tintColor", color);
    widget.SetFontSize(size);
    widget.SetWrapping(true, 700.0);
    widget.SetText(text);
    widget.SetMargin(inkMargin(0.0, 0.0, 0.0, 10.0));
    widget.Reparent(parent);
    return widget;
  }

  private func AddRow(parent: ref<inkCompoundWidget>) -> ref<inkHorizontalPanel> {
    let row: ref<inkHorizontalPanel> = new inkHorizontalPanel();
    row.SetMargin(inkMargin(0.0, 0.0, 0.0, 10.0));
    row.SetChildMargin(inkMargin(0.0, 0.0, 20.0, 0.0));
    row.Reparent(parent);
    return row;
  }

  private func AddRowButton(parent: ref<inkCompoundWidget>, name: CName, text: String, callback: CName, width: Float, height: Float, fontSize: Int32) -> ref<SimpleButton> {
    let button: ref<SimpleButton> = SimpleButton.Create();
    button.SetName(name);
    button.SetText(text);
    (button.GetRootCompoundWidget().GetWidget(n"label") as inkText).SetFontSize(fontSize);
    button.GetRootWidget().SetSize(width, height);
    button.GetRootWidget().SetAnchorPoint(Vector2(0.0, 0.0));
    button.RegisterToCallback(n"OnBtnClick", this, callback);
    button.Reparent(parent);
    return button;
  }

  // Randomize and Save side by side, then Unlock All and the district choice.
  private func AddMainRows(parent: ref<inkCompoundWidget>) -> Void {
    let first: ref<inkHorizontalPanel> = this.AddRow(parent);
    let second: ref<inkHorizontalPanel> = this.AddRow(parent);
    first.SetMargin(inkMargin(0.0, 10.0, 0.0, 10.0));
    this.AddRowButton(first, n"orRandomizeButton", UTF8StrUpper(OR_Text("OutfitRandomizer-Randomize")), n"OnRandomizeClick", 340.0, 80.0, 36);
    this.AddRowButton(first, n"orSaveButton", UTF8StrUpper(OR_Text("OutfitRandomizer-Save")), n"OnSaveClick", 340.0, 80.0, 36);
    this.AddRowButton(second, n"orUnlockButton", UTF8StrUpper(OR_Text("OutfitRandomizer-UnlockAll")), n"OnUnlockClick", 260.0, 70.0, 26);
    this.m_districtButton = this.AddRowButton(second, n"orDistrictButton", "", n"OnDistrictClick", 420.0, 70.0, 26);
    this.RefreshDistrictButton();
  }

  // What the district button says: nothing chosen, where I am, a district, or how many.
  private func RefreshDistrictButton() -> Void {
    let ids: array<CName> = this.m_system.GetDistricts();
    let name: String;
    if !IsDefined(this.m_districtButton) {
      return;
    }
    if ArraySize(ids) == 0 {
      name = OR_Text("OutfitRandomizer-DistrictAny");
    } else {
      if ArraySize(ids) == 1 {
        if Equals(ids[0], n"current") {
          name = OR_Text("OutfitRandomizer-DistrictCurrent");
        } else {
          name = ORDistricts.IsGroup(ids[0]) ? ORDistricts.GroupName(ids[0]) : ORDistricts.Name(ids[0]);
        }
      } else {
        name = StrReplace(OR_Text("OutfitRandomizer-DistrictCount"), "{COUNT}", IntToString(ArraySize(ids)));
      }
    }
    this.m_districtButton.SetText(UTF8StrUpper(OR_Text("OutfitRandomizer-DistrictButton") + ": " + name));
  }

  // The two switches for what may be picked, side by side to keep the panel short.
  private func AddOptions(parent: ref<inkCompoundWidget>) -> Void {
    let row: ref<inkHorizontalPanel> = new inkHorizontalPanel();
    row.SetName(n"orOptions");
    row.SetMargin(inkMargin(0.0, 0.0, 0.0, 10.0));
    row.SetChildMargin(inkMargin(0.0, 0.0, 20.0, 0.0));
    row.Reparent(parent);
    this.m_togglesOption = this.AddOption(row, n"orAllowToggles", n"OnAllowTogglesClick", 340.0);
    this.m_cyberwareOption = this.AddOption(row, n"orAllowCyberware", n"OnAllowCyberwareClick", 340.0);
    this.m_addonsOption = this.AddOption(parent, n"orAllowAddons", n"OnAllowAddonsClick", 700.0);
    this.m_addonsOption.GetRootWidget().SetMargin(inkMargin(0.0, 0.0, 0.0, 10.0));
    this.RefreshOptions();
  }

  private func AddOption(parent: ref<inkCompoundWidget>, name: CName, callback: CName, width: Float) -> ref<SimpleButton> {
    let button: ref<SimpleButton> = SimpleButton.Create();
    button.SetName(name);
    button.SetText("");
    (button.GetRootCompoundWidget().GetWidget(n"label") as inkText).SetFontSize(28);
    button.GetRootWidget().SetSize(width, 70.0);
    button.GetRootWidget().SetAnchorPoint(Vector2(0.0, 0.0));
    button.RegisterToCallback(n"OnBtnClick", this, callback);
    button.Reparent(parent);
    return button;
  }

  private func OptionText(key: String, on: Bool) -> String {
    return UTF8StrUpper(OR_Text(key) + ": " + OR_Text(on ? "OutfitRandomizer-On" : "OutfitRandomizer-Off"));
  }

  private func RefreshOptions() -> Void {
    if IsDefined(this.m_togglesOption) {
      this.m_togglesOption.SetText(this.OptionText("OutfitRandomizer-AllowToggles", this.m_system.AllowsToggles()));
    }
    if IsDefined(this.m_cyberwareOption) {
      this.m_cyberwareOption.SetText(this.OptionText("OutfitRandomizer-AllowCyberware", this.m_system.AllowsCyberware()));
    }
    if IsDefined(this.m_addonsOption) {
      this.m_addonsOption.SetText(this.OptionText("OutfitRandomizer-AllowAddons", this.m_system.AllowsAddons()));
    }
  }

  private func CreatePanel() -> Void {
    let panel: ref<inkCanvas> = new inkCanvas();
    let background: ref<inkImage> = new inkImage();
    let frame: ref<inkImage> = new inkImage();
    let content: ref<inkVerticalPanel> = new inkVerticalPanel();

    panel.SetName(n"orPanel");
    panel.SetAnchor(inkEAnchor.TopLeft);
    panel.SetAnchorPoint(Vector2(0.0, 0.0));
    // Below the outfit list by default, which leaves the weather readout, the outfit
    // buttons and the item list uncovered. The position is set in Mod Settings.
    panel.SetMargin(inkMargin(Cast<Float>(this.m_system.GetSettings().panelX), Cast<Float>(this.m_system.GetSettings().panelY), 0.0, 0.0));
    panel.SetSize(760.0, 940.0);
    panel.SetVisible(false);
    panel.Reparent(this.m_root);

    background.SetAnchor(inkEAnchor.Fill);
    background.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
    background.BindProperty(n"tintColor", n"MainColors.Fullscreen_PrimaryBackgroundDarkest");
    background.SetAtlasResource(r"base\\gameplay\\gui\\common\\tooltip\\tooltips_new.inkatlas");
    background.SetTexturePart(n"generic_background");
    background.Reparent(panel);

    frame.SetAnchor(inkEAnchor.Fill);
    frame.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
    frame.BindProperty(n"tintColor", n"MainColors.Blue");
    frame.SetAtlasResource(r"base\\gameplay\\gui\\common\\tooltip\\tooltips_new.inkatlas");
    frame.SetTexturePart(n"generic_background_fg");
    frame.Reparent(panel);

    content.SetName(n"orContent");
    content.SetAnchor(inkEAnchor.Fill);
    content.SetPadding(inkMargin(30.0, 20.0, 30.0, 20.0));
    content.Reparent(panel);

    this.AddText(content, UTF8StrUpper(OR_Text("OutfitRandomizer-Title")), 42, n"MainColors.Blue");
    this.AddText(content, OR_Text("OutfitRandomizer-Help"), 30, n"MainColors.Red");
    this.AddMainRows(content);
    this.AddOptions(content);
    this.m_status = this.AddText(content, "", 32, n"MainColors.Blue");
    this.m_info = this.AddText(content, "", 30, n"MainColors.Blue");
    this.m_info.SetMargin(inkMargin(0.0, 14.0, 0.0, 0.0));

    this.m_panel = panel;
    this.m_content = content;
  }

  // Sizes the panel to what is in it, as the text under the buttons changes length.
  private func FitPanel() -> Void {
    let height: Float;
    if !IsDefined(this.m_content) || !IsDefined(this.m_panel) {
      return;
    }
    height = this.m_content.GetDesiredHeight();
    // Before the first layout pass there is nothing to measure, so the starting size stays.
    if height > 300.0 {
      this.m_panel.SetHeight(height + 30.0);
    }
  }

  private func IsOpen() -> Bool {
    return IsDefined(this.m_screen) && IsDefined(this.m_panel) && this.m_panel.IsVisible();
  }

  // --- Locks on the wardrobe list's slot rows ---

  // The widget holding a slot row's name, in WEAVE's layout or the stock one.
  private func HeaderRow(header: wref<inkCompoundWidget>) -> wref<inkCompoundWidget> {
    let row: wref<inkCompoundWidget>;
    if !IsDefined(header) {
      return null;
    }
    row = header.GetWidget(n"vstack/row") as inkCompoundWidget;
    if !IsDefined(row) {
      row = header.GetWidget(n"content") as inkCompoundWidget;
    }
    if IsDefined(row) && IsDefined(row.GetWidget(n"slot_name") as inkText) {
      return row;
    }
    return null;
  }

  // The outfit slot a slot row stands for, worked out from the name it shows.
  private func HeaderSlot(header: wref<inkCompoundWidget>) -> TweakDBID {
    let row: wref<inkCompoundWidget> = this.HeaderRow(header);
    let name: String;
    let i: Int32 = 0;
    if !IsDefined(row) {
      return TDBID.None();
    }
    name = (row.GetWidget(n"slot_name") as inkText).GetText();
    while i < ArraySize(this.m_slotNames) {
      if Equals(this.m_slotNames[i], name) {
        return this.m_slotIDs[i];
      }
      i += 1;
    }
    return TDBID.None();
  }

  // Adds the LOCKED marker to a slot row the first time it is seen and keeps it in
  // step with the lock. Returns false if the widget is not a slot row.
  private func MarkHeader(header: wref<inkCompoundWidget>) -> Bool {
    let row: wref<inkCompoundWidget> = this.HeaderRow(header);
    // WEAVE lays a slot out on one line, so the label goes in that line. The stock
    // wardrobe stacks the name over two more lines, so there it sits at the right edge
    // of the row instead, left of the fold arrow.
    let inline: Bool = IsDefined(header.GetWidget(n"vstack/row"));
    let holder: wref<inkCompoundWidget> = inline ? row : header;
    let marker: ref<inkText>;
    let slotID: TweakDBID;
    if !IsDefined(row) {
      return false;
    }
    marker = holder.GetWidget(n"orLock") as inkText;
    if !IsDefined(marker) {
      marker = new inkText();
      marker.SetName(n"orLock");
      marker.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
      marker.SetFontSize(34);
      marker.SetTintColor(new HDRColor(1.0, 0.78, 0.2, 1.0));
      marker.SetFitToContent(true);
      marker.SetVAlign(inkEVerticalAlign.Center);
      marker.SetText(UTF8StrUpper(OR_Text("OutfitRandomizer-Locked")));
      marker.Reparent(holder);
      if inline {
        marker.SetMargin(inkMargin(0.0, 0.0, 14.0, 0.0));
        // After the fold arrow, where the row has one.
        row.ReorderChild(marker, IsDefined(row.GetWidget(n"arrow")) ? 1 : 0);
      } else {
        marker.SetAnchor(inkEAnchor.CenterRight);
        marker.SetAnchorPoint(Vector2(1.0, 0.5));
        marker.SetMargin(inkMargin(0.0, 0.0, 110.0, 0.0));
      }
      header.RegisterToCallback(n"OnRelease", this, n"OnHeaderRelease");
      header.RegisterToCallback(n"OnEnter", this, n"OnHeaderEnter");
      header.RegisterToCallback(n"OnLeave", this, n"OnHeaderLeave");
    }
    slotID = this.HeaderSlot(header);
    marker.SetVisible(TDBID.IsValid(slotID) && this.m_system.IsLocked(slotID));
    return true;
  }

  // The list reuses a small set of row widgets as it scrolls, so the rows on
  // screen are looked over again on every tick.
  private func MarkHeaders(parent: wref<inkCompoundWidget>, depth: Int32) -> Void {
    let child: wref<inkCompoundWidget>;
    let i: Int32 = 0;
    if !IsDefined(parent) {
      return;
    }
    while i < parent.GetNumChildren() {
      child = parent.GetWidgetByIndex(i) as inkCompoundWidget;
      if IsDefined(child) && !this.MarkHeader(child) && depth < 2 {
        this.MarkHeaders(child, depth + 1);
      }
      i += 1;
    }
  }

  private func ShowLockHint(header: wref<inkCompoundWidget>) -> Void {
    let slotID: TweakDBID = this.HeaderSlot(header);
    if IsDefined(this.m_screen.m_buttonHints) && TDBID.IsValid(slotID) {
      this.m_screen.m_buttonHints.AddButtonHint(n"reload", OR_Text(this.m_system.IsLocked(slotID) ? "OutfitRandomizer-UnlockSlot" : "OutfitRandomizer-LockSlot"));
    }
  }

  protected cb func OnHeaderEnter(evt: ref<inkPointerEvent>) -> Bool {
    if IsDefined(this.m_screen) {
      this.ShowLockHint(evt.GetCurrentTarget() as inkCompoundWidget);
    }
    return false;
  }

  protected cb func OnHeaderLeave(evt: ref<inkPointerEvent>) -> Bool {
    if IsDefined(this.m_screen) && IsDefined(this.m_screen.m_buttonHints) {
      this.m_screen.m_buttonHints.RemoveButtonHint(n"reload");
    }
    return false;
  }

  protected cb func OnHeaderRelease(evt: ref<inkPointerEvent>) -> Bool {
    let header: wref<inkCompoundWidget> = evt.GetCurrentTarget() as inkCompoundWidget;
    let slotID: TweakDBID;
    if !evt.IsAction(n"reload") || !IsDefined(this.m_screen) {
      return false;
    }
    slotID = this.HeaderSlot(header);
    if !TDBID.IsValid(slotID) {
      return false;
    }
    this.m_system.ToggleLock(slotID);
    this.m_screen.PlaySound(n"Button", n"OnPress");
    this.MarkHeader(header);
    this.ShowLockHint(header);
    this.Refresh(false);
    return true;
  }

  // --- Panel ---

  // Updates the text on the panel. The readout from other mods is only re-read
  // when asked, as they work it out a moment after the outfit changes.
  private func Refresh(readout: Bool) -> Void {
    let info: String;
    let filters: String;
    if !this.IsOpen() {
      return;
    }
    this.RefreshDistrictButton();
    if readout {
      this.m_readout = OR_StreetSenseReadout(this.m_player);
    }
    info = StrReplace(OR_Text("OutfitRandomizer-LockedSlots"), "{COUNT}", IntToString(this.m_system.LockCount()));
    filters = OR_DescribeFilters(this.m_screen);
    if NotEquals(filters, "") {
      info += "\n" + filters;
    }
    if NotEquals(this.m_readout, "") {
      info += "\n\n" + this.m_readout;
    }
    this.m_info.SetText(info);
  }

  // Runs for as long as the wardrobe is open.
  private func Tick() -> Void {
    if !IsDefined(this.m_root) || !IsDefined(this.m_screen) {
      return;
    }
    this.MarkHeaders(this.m_screen.m_inventoryGridArea as inkCompoundWidget, 0);
    this.Refresh(false);
    this.FitPanel();
    this.Delay(ORPanelAction.Tick, 0.3);
  }

  // Locks the slots worn with pieces that are not allowed and says so. Returns how many.
  private func AutoLockWorn(report: Bool) -> Int32 {
    let count: Int32 = OR_AutoLock(GetGameInstance());
    if count > 0 && report && IsDefined(this.m_status) {
      this.m_status.SetText(StrReplace(OR_Text("OutfitRandomizer-AutoLocked"), "{COUNT}", IntToString(count)));
    }
    return count;
  }

  protected cb func OnToggleEnter(evt: ref<inkPointerEvent>) -> Bool {
    if IsDefined(this.m_button) {
      this.m_button.SetState(n"Hover");
    }
    return true;
  }

  protected cb func OnToggleLeave(evt: ref<inkPointerEvent>) -> Bool {
    if IsDefined(this.m_button) {
      this.m_button.SetState(n"Default");
    }
    return true;
  }

  protected cb func OnToggleRelease(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsAction(n"click") || !IsDefined(this.m_screen) || !IsDefined(this.m_panel) {
      return false;
    }
    this.m_screen.PlaySound(n"Button", n"OnPress");
    this.m_panel.SetVisible(!this.m_panel.IsVisible());
    if this.m_panel.IsVisible() {
      this.AutoLockWorn(true);
    }
    this.Refresh(true);
    return true;
  }

  protected cb func OnAllowTogglesClick(widget: wref<inkWidget>) -> Bool {
    this.m_system.SetAllowToggles(!this.m_system.AllowsToggles());
    this.AutoLockWorn(true);
    this.RefreshOptions();
    return true;
  }

  protected cb func OnAllowCyberwareClick(widget: wref<inkWidget>) -> Bool {
    this.m_system.SetAllowCyberware(!this.m_system.AllowsCyberware());
    this.AutoLockWorn(true);
    this.RefreshOptions();
    return true;
  }

  protected cb func OnAllowAddonsClick(widget: wref<inkWidget>) -> Bool {
    this.m_system.SetAllowAddons(!this.m_system.AllowsAddons());
    this.AutoLockWorn(true);
    this.RefreshOptions();
    return true;
  }

  protected cb func OnDistrictClick(widget: wref<inkWidget>) -> Bool {
    if !this.IsOpen() {
      return false;
    }
    ORDistrictPopup.Show(this.m_screen, this.m_system);
    return true;
  }

  // The name offered when saving: the words of the kinds of place chosen (corpo, street,
  // wild, club) and then of the districts, which are the words Dynamic Wardrobe matches
  // outfit names on. The district itself is only added when one is chosen or being
  // followed. It is made unique, and the player can change it.
  private func SuggestName() -> String {
    let districts: array<ref<ORDistrict>> = OR_ResolveDistricts(this.m_system, GetGameInstance());
    let groups: array<CName> = OR_SelectedGroups(this.m_system);
    let base: String = "";
    let name: String;
    let number: Int32 = 2;
    let i: Int32 = 0;
    while i < ArraySize(groups) {
      base += (StrLen(base) > 0 ? " " : "") + NameToString(groups[i]);
      i += 1;
    }
    i = 0;
    while i < ArraySize(districts) {
      base += (StrLen(base) > 0 ? " " : "") + NameToString(districts[i].id);
      i += 1;
    }
    if StrLen(base) == 0 {
      base = "random";
    }
    base = UTF8StrUpper(base);
    name = base;
    while this.m_outfitSystem.HasOutfit(StringToName(name)) {
      name = base + " " + IntToString(number);
      number += 1;
    }
    return name;
  }

  protected cb func OnSaveClick(widget: wref<inkWidget>) -> Bool {
    if !this.IsOpen() {
      return false;
    }
    if !this.m_outfitSystem.IsActive() {
      this.m_status.SetText(OR_Text("OutfitRandomizer-NothingToSave"));
      return false;
    }
    this.m_popupToken = OR_ShowSaveInput(this.m_screen, GetLocalizedTextByKey(n"UI-Wardrobe-SaveSet"), GetLocalizedTextByKey(n"UI-Wardrobe-NotificationSaveSet"), this.SuggestName());
    this.m_popupToken.RegisterListener(this, n"OnSavePopupClosed");
    return true;
  }

  private func SaveAs(name: CName) -> Void {
    if this.m_outfitSystem.SaveOutfit(name, true) {
      // The wardrobe's outfit list does not notice a save made from here by itself.
      GameInstance.GetUISystem(GetGameInstance()).QueueEvent(new OutfitListUpdated());
      this.m_screen.PlaySound(n"Item", n"OnBuy");
      this.m_status.SetText(StrReplace(OR_Text("OutfitRandomizer-Saved"), "{NAME}", NameToString(name)));
    }
  }

  protected cb func OnSavePopupClosed(data: ref<inkGameNotificationData>) -> Bool {
    let result: ref<GenericMessageNotificationCloseData> = data as GenericMessageNotificationCloseData;
    let name: CName;
    this.m_popupToken = null;
    if !IsDefined(result) || NotEquals(result.result, GenericMessageNotificationResult.Confirm) || Equals(result.input, "") {
      return true;
    }
    name = StringToName(result.input);
    if this.m_outfitSystem.HasOutfit(name) {
      // The same question the wardrobe asks before replacing an outfit.
      this.m_pendingName = name;
      this.m_popupToken = GenericMessageNotification.Show(this.m_screen, GetLocalizedTextByKey(n"UI-Wardrobe-SaveSet"), GetLocalizedTextByKey(n"UI-Wardrobe-NotificationReplaceSet"), GenericMessageNotificationType.ConfirmCancel);
      this.m_popupToken.RegisterListener(this, n"OnReplacePopupClosed");
      return true;
    }
    this.SaveAs(name);
    return true;
  }

  protected cb func OnReplacePopupClosed(data: ref<inkGameNotificationData>) -> Bool {
    let result: ref<GenericMessageNotificationCloseData> = data as GenericMessageNotificationCloseData;
    this.m_popupToken = null;
    if IsDefined(result) && Equals(result.result, GenericMessageNotificationResult.Confirm) {
      this.SaveAs(this.m_pendingName);
    }
    return true;
  }

  protected cb func OnUnlockClick(widget: wref<inkWidget>) -> Bool {
    if !this.IsOpen() {
      return false;
    }
    this.m_system.ClearLocks();
    this.MarkHeaders(this.m_screen.m_inventoryGridArea as inkCompoundWidget, 0);
    this.Refresh(false);
    return true;
  }

  protected cb func OnRandomizeClick(widget: wref<inkWidget>) -> Bool {
    let poolItems: array<ItemID>;
    let poolSlots: array<TweakDBID>;
    let slotsWithPieces: array<TweakDBID>;
    let autoLocked: Int32;
    let districts: array<ref<ORDistrict>>;
    let factions: array<CName>;
    let wealth: array<CName>;
    let text: String;
    let count: Int32;
    let i: Int32;
    if !this.IsOpen() {
      return false;
    }
    if this.m_outfitSystem.IsBlocked() || OR_ChangeBlocked(this.m_screen) {
      this.m_status.SetText(OR_Text("OutfitRandomizer-Blocked"));
      return false;
    }
    autoLocked = this.AutoLockWorn(false);
    OR_CollectPool(this.m_screen, poolItems, poolSlots);
    if ArraySize(poolItems) == 0 {
      this.m_status.SetText(OR_Text("OutfitRandomizer-NothingToPick"));
      return false;
    }
    districts = OR_ResolveDistricts(this.m_system, GetGameInstance());
    OR_DistrictTags(districts, OR_SelectedGroups(this.m_system), factions, wealth);
    count = OR_Randomize(GetGameInstance(), poolItems, poolSlots, factions, wealth);
    if count < 0 {
      this.m_status.SetText(OR_Text("OutfitRandomizer-Blocked"));
    } else {
      // How many slots had anything to offer, so a sparse result can be told apart
      // from a narrow filter.
      i = 0;
      while i < ArraySize(poolSlots) {
        if !ArrayContains(slotsWithPieces, poolSlots[i]) {
          ArrayPush(slotsWithPieces, poolSlots[i]);
        }
        i += 1;
      }
      text = StrReplace(StrReplace(StrReplace(OR_Text("OutfitRandomizer-Done"), "{COUNT}", IntToString(count)), "{POOL}", IntToString(ArraySize(poolItems))), "{SLOTS}", IntToString(ArraySize(slotsWithPieces)));
      if ArraySize(factions) > 0 {
        text += "\n" + StrReplace(StrReplace(OR_Text("OutfitRandomizer-DistrictResult"), "{TAGGED}", IntToString(this.m_system.LastTagged())), "{COUNT}", IntToString(count));
      } else {
        if this.m_system.DistrictCount() > 0 {
          text += "\n" + OR_Text("OutfitRandomizer-DistrictUnknown");
        }
      }
      if autoLocked > 0 {
        text += "\n" + StrReplace(OR_Text("OutfitRandomizer-AutoLocked"), "{COUNT}", IntToString(autoLocked));
      }
      this.m_status.SetText(text);
    }
    this.Refresh(false);
    this.Delay(ORPanelAction.Refresh, 0.6);
    return true;
  }
}

// --- Stock Equipment-EX wardrobe ---

// The pieces that can be picked, with the outfit slot each goes in.
@if(ModuleExists("EquipmentEx") && !ModuleExists("WEAVE"))
func OR_CollectPool(screen: ref<WardrobeScreenController>, out poolItems: array<ItemID>, out poolSlots: array<TweakDBID>) -> Void {
  let items: array<InventoryItemData> = screen.m_inventoryHelper.GetAvailableItems();
  let system: ref<ORSystem> = ORSystem.Get(GetGameInstance());
  let query: String;
  let slotID: TweakDBID;
  let i: Int32 = 0;
  if IsDefined(screen.m_searchInput) {
    query = UTF8StrLower(screen.m_searchInput.GetText());
  }
  while i < ArraySize(items) {
    slotID = screen.m_outfitSystem.GetItemSlot(items[i].ID);
    if TDBID.IsValid(slotID)
      && !OR_IsExcluded(system, screen.m_outfitSystem, items[i].ID)
      && (Equals(query, "") || StrContains(UTF8StrLower(screen.m_outfitSystem.GetItemName(items[i].ID)), query)) {
      ArrayPush(poolItems, items[i].ID);
      ArrayPush(poolSlots, slotID);
    }
    i += 1;
  }
}

@if(ModuleExists("EquipmentEx") && !ModuleExists("WEAVE"))
func OR_DescribeFilters(screen: ref<WardrobeScreenController>) -> String {
  return "";
}

@if(ModuleExists("EquipmentEx") && !ModuleExists("WEAVE"))
func OR_ChangeBlocked(screen: ref<WardrobeScreenController>) -> Bool {
  return false;
}

// --- WEAVE's wardrobe ---

// Whether a piece passes the wardrobe's tag filter. As in the wardrobe list, tags of
// the same kind are alternatives and each kind that has a tag selected must match.
@if(ModuleExists("EquipmentEx") && ModuleExists("WEAVE"))
func OR_MatchesTags(itemTags: array<CName>, filters: array<CName>) -> Bool {
  let wealthTags: array<CName> = [n"Rich", n"Simple", n"Poor"];
  let factionTags: array<CName> = [
    n"Animals", n"Aldecaldos", n"Arasaka", n"Barghest", n"KangTao", n"Maelstrom", n"Militech", n"Moxies", n"NCPD",
    n"SixthStreet", n"Scavengers", n"TraumaTeam", n"TygerClaws", n"Valentinos", n"VoodooBoys", n"Wraiths",
    n"Biotechnica", n"Zetatech"
  ];
  let styleTags: array<CName> = [
    n"Biker", n"Casual", n"Corpo", n"Cowboy", n"Formal", n"Industrial", n"Military", n"Punk", n"Rocker", n"Samurai",
    n"Sports", n"Streetwear", n"Stylish", n"Tomboy",
    n"Revealing", n"Intimidating", n"FearReaction", n"PositiveReaction", n"AnnoyedReaction"
  ];
  // Wealth, faction, style or reaction, and custom: wanted and found, per kind.
  let wanted: array<Bool> = [false, false, false, false];
  let found: array<Bool> = [false, false, false, false];
  let kind: Int32;
  let i: Int32 = 0;
  let j: Int32;
  while i < ArraySize(filters) {
    if ArrayContains(wealthTags, filters[i]) {
      kind = 0;
    } else {
      if ArrayContains(factionTags, filters[i]) {
        kind = 1;
      } else {
        kind = ArrayContains(styleTags, filters[i]) ? 2 : 3;
      }
    }
    wanted[kind] = true;
    if kind < 3 {
      if ArrayContains(itemTags, filters[i]) {
        found[kind] = true;
      }
    } else {
      // Custom tags are matched without regard to case.
      j = 0;
      while j < ArraySize(itemTags) {
        if Equals(StrLower(NameToString(itemTags[j])), StrLower(NameToString(filters[i]))) {
          found[kind] = true;
        }
        j += 1;
      }
    }
    i += 1;
  }
  i = 0;
  while i < 4 {
    if wanted[i] && !found[i] {
      return false;
    }
    i += 1;
  }
  return true;
}

// The pieces that can be picked, with the outfit slot each goes in: everything in
// the wardrobe's item source that passes its search text, slot filter and tag filter.
// The list's own rows can't be read from here, so those three are applied again.
@if(ModuleExists("EquipmentEx") && ModuleExists("WEAVE"))
func OR_CollectPool(screen: ref<WardrobeScreenController>, out poolItems: array<ItemID>, out poolSlots: array<TweakDBID>) -> Void {
  let ids: array<ItemID>;
  let items: array<InventoryItemData>;
  let record: ref<Item_Record>;
  let system: ref<ORSystem> = ORSystem.Get(GetGameInstance());
  let query: String;
  let slotID: TweakDBID;
  let i: Int32 = 0;
  // 0 is the wardrobe store, which WEAVE lists by ID alone.
  if EnumInt(screen.m_viewManager.GetItemSource()) == 0 {
    ids = screen.m_inventoryHelper.GetWardrobeItemIDs();
  } else {
    items = screen.m_inventoryHelper.GetAvailableItems();
    while i < ArraySize(items) {
      ArrayPush(ids, items[i].ID);
      i += 1;
    }
  }
  if IsDefined(screen.m_searchInput) {
    query = UTF8StrLower(screen.m_searchInput.GetText());
  }
  i = 0;
  while i < ArraySize(ids) {
    slotID = screen.m_outfitSystem.GetItemSlot(ids[i]);
    if TDBID.IsValid(slotID)
      && !OR_IsExcluded(system, screen.m_outfitSystem, ids[i])
      && (ArraySize(screen.m_currentSlotFilters) == 0 || ArrayContains(screen.m_currentSlotFilters, slotID))
      && (Equals(query, "")
        || StrContains(UTF8StrLower(screen.m_outfitSystem.GetItemName(ids[i])), query)
        || StrContains(UTF8StrLower(TDBID.ToStringDEBUG(ItemID.GetTDBID(ids[i]))), query)) {
      if ArraySize(screen.m_currentTagFilters) == 0 {
        ArrayPush(poolItems, ids[i]);
        ArrayPush(poolSlots, slotID);
      } else {
        record = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(ids[i]));
        if IsDefined(record) && OR_MatchesTags(record.Tags(), screen.m_currentTagFilters) {
          ArrayPush(poolItems, ids[i]);
          ArrayPush(poolSlots, slotID);
        }
      }
    }
    i += 1;
  }
}

// The filters set in the wardrobe, so the panel shows what the choice is limited to.
@if(ModuleExists("EquipmentEx") && ModuleExists("WEAVE"))
func OR_DescribeFilters(screen: ref<WardrobeScreenController>) -> String {
  let text: String;
  let i: Int32 = 0;
  while i < ArraySize(screen.m_currentTagFilters) {
    text += (i > 0 ? ", " : "") + NameToString(screen.m_currentTagFilters[i]);
    i += 1;
  }
  if NotEquals(text, "") {
    text = StrReplace(OR_Text("OutfitRandomizer-TagFilter"), "{TAGS}", text);
  }
  if ArraySize(screen.m_currentSlotFilters) > 0 {
    text += (NotEquals(text, "") ? "\n" : "") + StrReplace(OR_Text("OutfitRandomizer-SlotFilter"), "{COUNT}", IntToString(ArraySize(screen.m_currentSlotFilters)));
  }
  return text;
}

@if(ModuleExists("EquipmentEx") && ModuleExists("WEAVE"))
func OR_ChangeBlocked(screen: ref<WardrobeScreenController>) -> Bool {
  if screen.m_isEquipInProgress || screen.WEAVEEquipBlocked(ItemID.None()) {
    return true;
  }
  screen.CancelPreview();
  screen.CancelOutfitPreview();
  return false;
}

// --- Street Sense ---

// How Street Sense reads the outfit being worn.
@if(ModuleExists("StreetSense"))
func OR_StreetSenseReadout(player: wref<PlayerPuppet>) -> String {
  let faction: Int32;
  if !IsDefined(player) {
    return "";
  }
  player.UNR_UpdateClothingState();
  faction = player.UNR_GetBestDisguiseFaction();
  return UTF8StrUpper(OR_Text("OutfitRandomizer-SS-Title"))
    + "\n" + OR_Text("OutfitRandomizer-SS-Revealing") + ": " + FloatToStringPrec(player.UNR_GetRevealingScore(), 2)
    + "   " + OR_Text("OutfitRandomizer-SS-Intimidation") + ": " + FloatToStringPrec(player.UNR_GetIntimidationScore(), 2)
    + "\n" + OR_Text("OutfitRandomizer-SS-Fear") + ": " + FloatToStringPrec(player.UNR_GetFearScore(), 2)
    + "   " + OR_Text("OutfitRandomizer-SS-FaceExposed") + ": " + FloatToStringPrec(player.UNR_GetFaceScore(), 2)
    + "\n" + OR_Text("OutfitRandomizer-SS-BestDisguise") + ": " + (faction >= 0 ? UNR_FactionIndex.GetName(faction) : OR_Text("OutfitRandomizer-SS-None"));
}

@if(!ModuleExists("StreetSense"))
func OR_StreetSenseReadout(player: wref<PlayerPuppet>) -> String {
  return "";
}

// --- The save pop-up, with the name filled in ---

@if(ModuleExists("EquipmentEx"))
@addField(GenericMessageNotificationData)
public let orPrefill: String;

// The same pop-up the wardrobe uses to ask for an outfit name, but with the text
// already in the box.
@if(ModuleExists("EquipmentEx"))
func OR_ShowSaveInput(controller: ref<worlduiIGameController>, title: String, message: String, prefill: String) -> ref<inkGameNotificationToken> {
  let data = GenericMessageNotification.GetBaseData();
  data.title = title;
  data.message = message;
  data.type = GenericMessageNotificationType.ConfirmCancel;
  data.isInput = true;
  data.orPrefill = prefill;
  return controller.ShowGameNotification(data);
}

@if(ModuleExists("EquipmentEx"))
public class ORPrefillCallback extends DelayCallback {
  public let m_notification: wref<GenericMessageNotification>;
  public let m_text: String;

  public func Call() -> Void {
    if IsDefined(this.m_notification) && IsDefined(this.m_notification.m_textInput) {
      this.m_notification.m_textInput.SetText(this.m_text);
    }
  }
}

// The text box is made by another mod as the pop-up opens, so the name is put in a
// moment later, whichever of the two gets to this first.
@if(ModuleExists("EquipmentEx"))
@wrapMethod(GenericMessageNotification)
protected cb func OnInitialize() -> Bool {
  let result: Bool = wrappedMethod();
  let callback: ref<ORPrefillCallback>;
  if this.m_data.isInput && NotEquals(this.m_data.orPrefill, "") {
    callback = new ORPrefillCallback();
    callback.m_notification = this;
    callback.m_text = this.m_data.orPrefill;
    GameInstance.GetDelaySystem(GetGameInstance()).DelayCallback(callback, 0.2, false);
  }
  return result;
}
