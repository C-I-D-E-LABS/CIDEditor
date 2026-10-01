import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import sys.FileSystem;
import sys.io.File;
import haxe.Json;
import haxe.Timer;
import funkin.backend.assets.GamesFolder;
import sys.Http;

import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.events.Event;
import openfl.geom.Rectangle;

import funkin.backend.utils.ZipUtil;
import funkin.backend.utils.ZipProgress;

import StringTools;

import Loader;
import DlcUtils;

var PORTRAIT_SCALE:Float = 0.8;
var COLS:Int             = 3;
var H_SPACING:Float      = 230;
var V_SPACING:Float      = 300;
var GRID_CENTER_X:Float  = FlxG.width / 2;
var LABEL_FONT:String    = "sonic3TitleCard.ttf";
var LABEL_SIZE:Int       = 36;

// Each DLC folder under here is scaffolded with the same songs/ + data/ +
// images/ shape a real top-level Codename mod has (see createLocalDlc()),
// and is loaded through the engine's own GamesFolder.loadModLib() — the
// exact primitive real mods use — rather than a custom loader. The only
// X-Eternal-specific bit is the small dlc.json manifest at each folder's
// root (name/type/song list), since Codename has no concept of that on
// its own. That's what "recognized as its own separated thing" means here.
var mainPath:String = 'games/' + GamesFolder.currentModFolder + "/dlc/";

var dlcs:Array<Dynamic>        = [];
var portraits:Array<FlxSprite> = [];
var portraitFrames:Array<FlxSprite>     = [];
var cardHeaderStrips:Array<FlxSprite>   = [];
var labels:Array<FlxText>      = [];
var localBadges:Array<FlxText>     = [];
var deleteBadges:Array<FlxText>    = [];
var placeholderMarks:Array<FlxText> = [];
var selectionBox:FlxSprite;
var statusText:FlxText;
var descriptionText:FlxText;
var progressText:FlxText;
var speedText:FlxText;

var hoveredIndex:Int = -1;
var lastHoveredIndex:Int = -2;
var menuState:String = "loading";

var curDlcId:String         = "";
var zipProgress:ZipProgress = new ZipProgress();
var zipReader               = null;
var lastBytes:Float         = 0;
var lastTime:Float          = 0;
var speedMBps:Float         = 0;
var crtShader = null;

var dlcContentSubTxt:FlxText;

// ---------------------------------------------------------------------
// "Analog horror" palette — one place to tune the whole menu's look.
// Everything my additions draw (top bar, cards, modals, scrollbar)
// pulls from here instead of scattering grey/green magic numbers.
// ---------------------------------------------------------------------

var COLOR_ACCENT:Int        = 0xFFAA2020; // bright red — borders, scrollbar thumb, selected state
var COLOR_ACCENT_DIM:Int    = 0xFF501212; // dark red — card frames, idle borders
var COLOR_BG_PANEL:Int      = 0xEB100606; // near-black red-tinted panel background
var COLOR_BTN_IDLE:Int      = 0xEB200A0A;
var COLOR_BTN_HOVER:Int     = 0xF5601616;
var COLOR_BTN_SELECTED:Int  = 0xFAC32828;
var COLOR_TEXT_DIM:Int      = 0xFFBE9696;
var COLOR_LOCKED_FRAME:Int  = 0xFF464646;
var COLOR_STRIP_BG:Int      = 0xAA000000;
var COLOR_STATIC_BG:Int     = 0xFF230808;
var COLOR_STATIC_LINE:Int   = 0xFF551212;

// ---------------------------------------------------------------------
// Top bar / tools additions
// ---------------------------------------------------------------------

var TOP_BAR_HEIGHT:Float = 40;

var topBarBg:FlxSprite;
var storageText:FlxText;
var toolHintText:FlxText;

var topBarButtons:Array<FlxSprite> = [];
var topBarLabels:Array<FlxText>    = [];
var topBarActions:Array<String>    = [];
var hoveredTopBarIndex:Int         = -1;

var deleteMode:Bool         = false;
var pendingDeleteIndex:Int  = -1;
var pendingDeleteTimer:Float = 0;
var PENDING_DELETE_TIMEOUT:Float = 3.0;

// The "New Local DLC" name-entry/type-toggle UI used to live inline here
// (creatingLocalDlc gate + newDlc* fields). It's now its own substate —
// see data/states/XEternalNewDlcSubstate.hx — opened via openSubState()
// from the top bar's "createLocal" action below. This script only needs
// to notice FlxG.save.data.pendingNewDlcName once the substate closes
// (checked at the top of update()) and do the actual folder/dlc.json
// creation via createLocalDlc().

// The week song-select submenu (shown once a "full week" DLC has been
// fully played) used to live inline here, the same way the New Local DLC
// modal used to. It's now its own substate too — see
// data/states/XEternalSongSelectSubstate.hx — opened via openSubState()
// from the portrait click handler below. Hand-off is the same FlxG.save.data
// pattern: this script stashes the DLC's id/name/song list before opening
// it, and picks up which song (if any) got picked once it closes, at the
// top of update().

// ---------------------------------------------------------------------
// Grid scrolling (COLS is fixed, but rows can now run past the screen)
// ---------------------------------------------------------------------

// GRID_VIEWPORT_TOP is a fallback here — postCreate() recomputes it from
// the actual measured height of the header/title text once that's built,
// instead of guessing a font's rendered height in advance (which is what
// caused the title to overlap the top bar/grid earlier).
var GRID_VIEWPORT_TOP:Float    = 170;
var GRID_VIEWPORT_BOTTOM:Float = FlxG.height - 130;
var SCROLL_STEP:Float          = 80;

var gridScrollY:Float   = 0;
var gridMaxScroll:Float = 0;

var FRAME_PADDING:Float = 10;
var STRIP_HEIGHT:Float  = 26;

// Un-scrolled ("base") y for every tracked grid sprite, captured at build
// time so scrolling can just reposition existing sprites instead of
// rebuilding the whole grid every tick. (Card frames/header strips are
// derived from the portrait's live x/y instead — see applyGridScroll.)
var portraitBaseY:Array<Float>    = [];
var labelBaseY:Array<Float>       = [];
var localBadgeBaseY:Array<Float>  = [];
var deleteBadgeBaseY:Array<Float> = [];
var placeholderBaseY:Array<Float> = [];

var scrollTrack:FlxSprite;
var scrollThumb:FlxSprite;
var scrollUpButton:FlxSprite;
var scrollUpLabel:FlxText;
var scrollDownButton:FlxSprite;
var scrollDownLabel:FlxText;

// ---------------------------------------------------------------------
// Small shared helper: a solid box with a thin accent border, built from
// two layered sprites. Returns the inner box (the one whose .color you
// change for hover feedback) — the border is decorative and static.
// ---------------------------------------------------------------------

function makeBorderedBox(x:Float, y:Float, w:Float, h:Float, idleColor:Int):FlxSprite
{
    var border = new FlxSprite(x - 3, y - 3);
    border.makeGraphic(Std.int(w + 6), Std.int(h + 6), COLOR_ACCENT_DIM);
    border.scrollFactor.set(0, 0);
    add(border);

    var box = new FlxSprite(x, y);
    box.makeGraphic(Std.int(w), Std.int(h), idleColor);
    box.scrollFactor.set(0, 0);
    add(box);

    return box;
}

function postCreate()
{
    FlxG.sound.cache(Paths.sound('menu/denied'));
    for (asset in [
        "menus/dlc/Sky", "menus/dlc/Trees", "menus/dlc/selectBox",
        "menus/dlc/locked", "menus/TitleScreen/redactedFiles/blackVG"
    ])
        graphicCache.cache(Paths.image(asset));

    crtShader = new CustomShader("vcrDistort");
    //FlxG.camera.addShader(crtShader);
    crtShader.noiseOn = false;
    crtShader.scanlinesOn = true;

    FlxG.mouse.visible = true;

    if (!FileSystem.exists(mainPath))
        FileSystem.createDirectory(mainPath);

    // NOTE: intentionally NOT calling preloadLocalDLCs() here anymore.
    // It used to eagerly addLibrary() every DLC folder's full asset tree
    // (songs/images/data) on menu open, regardless of whether the player
    // was going to play that DLC. That's what caused the fps spikes/drops —
    // libraries are now only registered lazily in playDlcSong() when a DLC
    // is actually clicked and played.

    bg = new FlxSprite(0, 0).loadGraphic(Paths.image("menus/dlc/Sky"));
    bg.scrollFactor.set(0.1, 0.1);
    add(bg);

    bgTrees = new FlxSprite(0, 0).loadGraphic(Paths.image("menus/dlc/Trees"));
    bgTrees.scrollFactor.set(0.4, 0.4);
    add(bgTrees);

    selectionBox = new FlxSprite();
    selectionBox.loadGraphic(Paths.image('menus/dlc/selectBox'));
    selectionBox.scale.set(0.75, 0.75);
    selectionBox.updateHitbox();
    selectionBox.visible = false;
    selectionBox.scrollFactor.set(0, 0);
    add(selectionBox);

    statusText = new FlxText(0, FlxG.height - 80, FlxG.width, "Loading DLC list...");
    statusText.setFormat(Paths.font(LABEL_FONT), 28, FlxColor.WHITE, "center");
    add(statusText);

    descriptionText = new FlxText(0, FlxG.height - 110, FlxG.width, "");
    descriptionText.setFormat(Paths.font(LABEL_FONT), 30, FlxColor.fromRGB(200, 200, 200), "center");
    descriptionText.visible = false;
    add(descriptionText);

    progressText = new FlxText(20, FlxG.height - 55, 600, "");
    progressText.setFormat(Paths.font(LABEL_FONT), 16, FlxColor.WHITE, "left");
    progressText.visible = false;
    add(progressText);

    speedText = new FlxText(20, FlxG.height - 30, 600, "");
    speedText.setFormat(Paths.font(LABEL_FONT), 16, FlxColor.WHITE, "left");
    speedText.visible = false;
    add(speedText);

    rfVG = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/TitleScreen/redactedFiles/blackVG'));
    rfVG.screenCenter();
    rfVG.alpha = 0.75;
    rfVG.scale.set(1.2, 1.2);
    add(rfVG);

    // Title + subtitle as two separate lines (bigger/brighter title, small
    // dim subtitle) instead of one big two-line block — reads cleaner and
    // leaves GRID_VIEWPORT_TOP room to be computed from real measured
    // height below rather than a guessed constant.
    dlcContentMenuTxt = new FlxText(0, TOP_BAR_HEIGHT + 30, FlxG.width, "DLC MENU");
    dlcContentMenuTxt.setFormat(Paths.font(LABEL_FONT), 40, FlxColor.WHITE, "center");
    dlcContentMenuTxt.scrollFactor.set(0, 0);
    add(dlcContentMenuTxt);

    dlcContentSubTxt = new FlxText(0, dlcContentMenuTxt.y + dlcContentMenuTxt.height + 2, FlxG.width, "Click a portrait to download or play");
    dlcContentSubTxt.setFormat(Paths.font(LABEL_FONT), 18, COLOR_TEXT_DIM, "center");
    dlcContentSubTxt.scrollFactor.set(0, 0);
    add(dlcContentSubTxt);

    // Now that the title/subtitle are actually built, measure them instead
    // of guessing — this is what used to overlap the grid whenever the
    // font rendered taller than the hardcoded constant assumed.
    GRID_VIEWPORT_TOP = dlcContentSubTxt.y + dlcContentSubTxt.height + 26;

    buildTopBar();
    buildScrollUI();
    refreshStorageDisplay();

    // Called last on purpose: sys.Http.request() runs synchronously on
    // native targets and fires onData/onError before returning, and
    // buildPortraitGrid() (invoked from those callbacks) now touches the
    // scrollbar sprites above — they have to exist first.
    fetchDLCList();
}

// ---------------------------------------------------------------------
// Scroll UI (mouse wheel + up/down buttons + a thin scrollbar)
// ---------------------------------------------------------------------

function buildScrollUI()
{
    var trackX = FlxG.width - 30;
    var viewportHeight = GRID_VIEWPORT_BOTTOM - GRID_VIEWPORT_TOP;

    scrollTrack = new FlxSprite(trackX, GRID_VIEWPORT_TOP);
    scrollTrack.makeGraphic(8, Std.int(viewportHeight), COLOR_ACCENT_DIM);
    scrollTrack.scrollFactor.set(0, 0);
    scrollTrack.alpha = 0.45;
    scrollTrack.visible = false;
    add(scrollTrack);

    scrollThumb = new FlxSprite(trackX, GRID_VIEWPORT_TOP);
    scrollThumb.makeGraphic(8, Std.int(viewportHeight), COLOR_ACCENT);
    scrollThumb.scrollFactor.set(0, 0);
    scrollThumb.visible = false;
    add(scrollThumb);

    scrollUpButton = makeBorderedBox(trackX - 9, GRID_VIEWPORT_TOP - 38, 26, 26, COLOR_BTN_IDLE);
    scrollUpButton.visible = false;
    add(scrollUpButton);

    scrollUpLabel = new FlxText(scrollUpButton.x, scrollUpButton.y + 4, 26, "^");
    scrollUpLabel.setFormat(Paths.font(LABEL_FONT), 18, FlxColor.WHITE, "center");
    scrollUpLabel.scrollFactor.set(0, 0);
    scrollUpLabel.visible = false;
    add(scrollUpLabel);

    scrollDownButton = makeBorderedBox(trackX - 9, GRID_VIEWPORT_BOTTOM + 12, 26, 26, COLOR_BTN_IDLE);
    scrollDownButton.visible = false;
    add(scrollDownButton);

    scrollDownLabel = new FlxText(scrollDownButton.x, scrollDownButton.y + 4, 26, "v");
    scrollDownLabel.setFormat(Paths.font(LABEL_FONT), 18, FlxColor.WHITE, "center");
    scrollDownLabel.scrollFactor.set(0, 0);
    scrollDownLabel.visible = false;
    add(scrollDownLabel);
}

function updateScrollbarVisual()
{
    var viewportHeight = GRID_VIEWPORT_BOTTOM - GRID_VIEWPORT_TOP;

    if (gridMaxScroll <= 0)
    {
        scrollTrack.visible      = false;
        scrollThumb.visible      = false;
        scrollUpButton.visible   = false;
        scrollUpLabel.visible    = false;
        scrollDownButton.visible = false;
        scrollDownLabel.visible  = false;
        return;
    }

    scrollTrack.visible      = true;
    scrollThumb.visible      = true;
    scrollUpButton.visible   = true;
    scrollUpLabel.visible    = true;
    scrollDownButton.visible = true;
    scrollDownLabel.visible  = true;

    var totalHeight      = viewportHeight + gridMaxScroll;
    var thumbHeightRatio = viewportHeight / totalHeight;
    var thumbHeight       = Math.max(24, viewportHeight * thumbHeightRatio);
    var scrollRatio        = gridScrollY / gridMaxScroll;
    var thumbY             = GRID_VIEWPORT_TOP + (viewportHeight - thumbHeight) * scrollRatio;

    scrollThumb.makeGraphic(8, Std.int(thumbHeight), COLOR_ACCENT);
    scrollThumb.y = thumbY;
}

// Repositions every already-built grid sprite from its stored base Y minus
// the current scroll offset, and hides anything that's scrolled out of the
// viewport. Doesn't touch dlcs/portraits arrays — safe to call every frame
// the scroll changes without rebuilding anything.
function applyGridScroll()
{
    for (i in 0...portraits.length)
    {
        var p = portraits[i];
        p.y = portraitBaseY[i] - gridScrollY;

        var frame = portraitFrames[i];
        frame.x = p.x - FRAME_PADDING;
        frame.y = p.y - FRAME_PADDING;

        var strip = cardHeaderStrips[i];
        strip.x = frame.x;
        strip.y = frame.y;

        var lbl = labels[i];
        lbl.y = labelBaseY[i] - gridScrollY;

        var badge = localBadges[i];
        badge.y = localBadgeBaseY[i] - gridScrollY;

        var delBadge = deleteBadges[i];
        delBadge.y = deleteBadgeBaseY[i] - gridScrollY;

        var mark = placeholderMarks[i];
        mark.y = placeholderBaseY[i] - gridScrollY;

        var lblBottom = lbl.y + lbl.height;
        var onScreen  = (lblBottom >= GRID_VIEWPORT_TOP) && (p.y <= GRID_VIEWPORT_BOTTOM);

        p.visible     = onScreen;
        frame.visible = onScreen;
        lbl.visible   = onScreen && (lbl.text != "");
        mark.visible  = onScreen && (mark.text != "");

        var dlc     = dlcs[i];
        var isOwned = DlcUtils.dlcOwned(dlc, mainPath);
        badge.visible    = onScreen && (badge.text != "");
        delBadge.visible = onScreen && deleteMode && isOwned;
        strip.visible     = onScreen && (badge.visible || delBadge.visible);
    }
}

function updateGridScroll()
{
    var changed = false;

    if (FlxG.mouse.wheel != 0)
    {
        gridScrollY -= FlxG.mouse.wheel * SCROLL_STEP;
        changed = true;
    }

    if (gridMaxScroll > 0)
    {
        var scrollUpHovered   = FlxG.mouse.overlaps(scrollUpButton);
        var scrollDownHovered = FlxG.mouse.overlaps(scrollDownButton);
        scrollUpButton.color   = scrollUpHovered   ? COLOR_BTN_HOVER : COLOR_BTN_IDLE;
        scrollDownButton.color = scrollDownHovered ? COLOR_BTN_HOVER : COLOR_BTN_IDLE;

        if (FlxG.mouse.justReleased)
        {
            if (scrollUpHovered)   { gridScrollY -= SCROLL_STEP; changed = true; }
            if (scrollDownHovered) { gridScrollY += SCROLL_STEP; changed = true; }
        }
    }

    if (!changed) return;

    if (gridScrollY < 0) gridScrollY = 0;
    if (gridScrollY > gridMaxScroll) gridScrollY = gridMaxScroll;

    applyGridScroll();
    updateScrollbarVisual();
}

// ---------------------------------------------------------------------
// Top bar
// ---------------------------------------------------------------------

function buildTopBar()
{
    topBarBg = new FlxSprite(0, 0);
    topBarBg.makeGraphic(FlxG.width, Std.int(TOP_BAR_HEIGHT), FlxColor.fromRGB(0, 0, 0, 150));
    topBarBg.scrollFactor.set(0, 0);
    add(topBarBg);

    var topBarAccent = new FlxSprite(0, TOP_BAR_HEIGHT - 2);
    topBarAccent.makeGraphic(FlxG.width, 2, COLOR_ACCENT);
    topBarAccent.scrollFactor.set(0, 0);
    add(topBarAccent);

    addTopBarButton("createLocal", "+ NEW LOCAL DLC", 160);
    addTopBarButton("deleteMode",  "DELETE MODE",     150);
    addTopBarButton("refresh",     "REFRESH",         110);
    addTopBarButton("cleanZips",   "CLEAN ZIPS",      120);
    addTopBarButton("openFolder",  "OPEN FOLDER",     130);

    storageText = new FlxText(0, 12, 260, "");
    storageText.setFormat(Paths.font(LABEL_FONT), 18, FlxColor.WHITE, "right");
    storageText.scrollFactor.set(0, 0);
    storageText.x = FlxG.width - storageText.fieldWidth - 18;
    add(storageText);

    toolHintText = new FlxText(0, TOP_BAR_HEIGHT + 4, FlxG.width, "");
    toolHintText.setFormat(Paths.font(LABEL_FONT), 17, FlxColor.fromRGB(230, 190, 90, 255), "center");
    toolHintText.scrollFactor.set(0, 0);
    toolHintText.visible = false;
    add(toolHintText);
}

function addTopBarButton(action:String, label:String, width:Int)
{
    var x:Float = 20;
    for (i in 0...topBarButtons.length)
        x += topBarButtons[i].width + 14;

    var btn = makeBorderedBox(x, 7, width, 26, COLOR_BTN_IDLE);

    var txt = new FlxText(x, 13, width, label);
    txt.setFormat(Paths.font(LABEL_FONT), 14, FlxColor.WHITE, "center");
    txt.scrollFactor.set(0, 0);
    add(txt);

    topBarButtons.push(btn);
    topBarLabels.push(txt);
    topBarActions.push(action);
}

function refreshStorageDisplay()
{
    var totalBytes = DlcUtils.getFolderSize(mainPath);
    storageText.text = "DLC STORAGE: " + DlcUtils.formatBytes(totalBytes);
    storageText.x = FlxG.width - storageText.fieldWidth - 18;
}

function showToolHint(msg:String)
{
    toolHintText.text = msg;
    toolHintText.visible = (msg != "");
}

// ---------------------------------------------------------------------
// Storage / file helpers — the stateless parts (size/byte-formatting,
// recursive delete, id sanitizing) now live in DlcUtils; what's
// left here still needs statusText/refreshStorageDisplay/clearAndRebuildGrid.
// ---------------------------------------------------------------------

function createLocalDlc(rawName:String, dlcType:String)
{
    var displayName = StringTools.trim(rawName);
    if (displayName == "") displayName = "New Local DLC";

    var id     = DlcUtils.sanitizeDlcId(displayName, mainPath);
    var folder = mainPath + id;

    try
    {
        FileSystem.createDirectory(folder);
        FileSystem.createDirectory(folder + "/data");
        FileSystem.createDirectory(folder + "/songs");
        FileSystem.createDirectory(folder + "/images");
        FileSystem.createDirectory(folder + "/sounds");

        var meta:Dynamic;
        if (dlcType == "week")
        {
            meta = {
                id: id,
                name: displayName,
                description: "Local DLC — drop your assets in this folder.",
                zipUrl: null,
                type: "week",
                songs: [],
                songName: null
            };

            File.saveContent(folder + "/songs/README.txt",
                "Drop one folder per song in here (same layout Codename normally expects " +
                "under a mod's songs/ folder), then list each song's folder name, in play " +
                "order, in this DLC's dlc.json under \"songs\": [\"song1\", \"song2\", ...].\n");
        }
        else
        {
            meta = {
                id: id,
                name: displayName,
                description: "Local DLC — drop your assets in this folder.",
                zipUrl: null,
                type: "song",
                songName: null
            };
        }

        File.saveContent(folder + "/dlc.json", Json.stringify(meta, null, "  "));

        statusText.text = "Created local DLC: " + displayName
            + " (" + (dlcType == "week" ? "full week" : "single song") + ")";
    }
    catch (e:Dynamic)
    {
        statusText.text = "Failed to create DLC folder: " + Std.string(e);
    }

    refreshStorageDisplay();
    clearAndRebuildGrid();
}

function cleanLeftoverZips()
{
    if (!FileSystem.exists(mainPath))
    {
        showToolHint("");
        return;
    }

    var removed = 0;
    for (entry in FileSystem.readDirectory(mainPath))
    {
        var full = mainPath + entry;
        if (!FileSystem.isDirectory(full) && StringTools.endsWith(entry, ".zip"))
        {
            try { FileSystem.deleteFile(full); removed++; } catch (e:Dynamic) {}
        }
    }

    showToolHint(removed > 0 ? "Cleaned " + removed + " leftover zip file(s)." : "No leftover zip files found.");
    refreshStorageDisplay();
}

function openDlcFolderOnDisk()
{
    try
    {
        Sys.command("explorer", [mainPath.split("/").join("\\")]);
    }
    catch (e:Dynamic)
    {
        showToolHint("Couldn't open the folder automatically — it's at: " + mainPath);
    }
}

function deleteDlcAtIndex(index:Int)
{
    if (index < 0 || index >= dlcs.length) return;

    var dlc  = dlcs[index];
    var path = mainPath + dlc.id;

    try
    {
        DlcUtils.deleteDlcFolder(path);
        statusText.text = "Deleted " + dlc.name + " — storage freed.";
    }
    catch (e:Dynamic)
    {
        statusText.text = "Failed to delete " + dlc.name + ": " + Std.string(e);
    }

    // NOTE: if this DLC's library was already registered with
    // Paths.assetsTree.addLibrary() earlier this session (i.e. it was
    // played before being deleted), Codename doesn't expose a safe way to
    // unregister a library from a scripted state. The files on disk are
    // gone and it'll disappear from the grid below, but a full restart is
    // recommended after deleting something you've already played this
    // session so nothing stale stays cached in memory.

    pendingDeleteIndex = -1;
    refreshStorageDisplay();
    clearAndRebuildGrid();
}

// ---------------------------------------------------------------------
// Week-progress tracking, ownership checks, and DLC-list normalizing/
// merging now all live in DlcUtils (see that file for why —
// mainly: real static fields for the per-DLC FlxSave cache instead of an
// HScript instance's own arrays). findDlcById stays here since it reaches
// into this state's own `dlcs` array.
// ---------------------------------------------------------------------

// Recovers a full dlc entry by id — used after the song-select substate
// closes, since only plain values (id/name/song list) were stashed into
// FlxG.save.data for it to read, not the live dlc object itself.
function findDlcById(id:String):Dynamic
{
    for (d in dlcs) if (d.id == id) return d;
    return null;
}

function mergeInLocalDlcs()
{
    dlcs = DlcUtils.mergeInLocalDlcs(dlcs, mainPath);
}

function fetchDLCList()
{
    var request = new Http("https://gist.githubusercontent.com/fleet15/13889ee59fbb64db353be01b28ba526d/raw/dlc.json");

    request.onData = function(data)
    {
        try {
            var parsed = Json.parse(data);
            dlcs = parsed.dlcs;
            for (d in dlcs) DlcUtils.normalizeDlcEntry(d);
            mergeInLocalDlcs();
            statusText.text = "";
            menuState = "selecting";
            buildPortraitGrid();
        } catch(e:Dynamic) {
            statusText.text = "Failed to parse DLC list.";
        }
    };

    request.onError = function(err) {
        statusText.text = "Offline — showing local DLCs only.";
        dlcs = DlcUtils.dedupeDlcsById(DlcUtils.buildLocalDLCList(mainPath));
        menuState = "selecting";
        buildPortraitGrid();
    };

    request.request();
}

function clearAndRebuildGrid()
{
    // Re-derive the list so newly created/deleted local DLCs show up
    // immediately without needing to re-hit the network. buildPortraitGrid()
    // clears the old sprites itself, so nothing else to do here.
    mergeInLocalDlcs();
    buildPortraitGrid();
}

// Draws a dim "static/no signal" scanline texture directly into a
// sprite's bitmap — used for DLCs that don't have portrait art yet
// instead of a flat colored box.
function paintStaticTexture(spr:FlxSprite, w:Int, h:Int)
{
    spr.makeGraphic(w, h, COLOR_STATIC_BG);
    var ly = 0;
    while (ly < h)
    {
        spr.pixels.fillRect(new Rectangle(0, ly, w, 2), COLOR_STATIC_LINE);
        ly += 6;
    }
    spr.dirty = true;
}

function buildPortraitGrid()
{
    // Always clear whatever grid is currently on screen before drawing a
    // new one — every caller used to have to remember to do this
    // themselves, and a caller that forgot (fetchDLCList's callbacks) is
    // exactly what caused duplicate portraits to pile up after a refresh.
    var clearLists:Array<Dynamic> = [portraits, portraitFrames, cardHeaderStrips, labels, localBadges, deleteBadges, placeholderMarks];
    for (list in clearLists)
        for (item in list)
            remove(item);

    portraits        = [];
    portraitFrames    = [];
    cardHeaderStrips  = [];
    labels           = [];
    localBadges      = [];
    deleteBadges     = [];
    placeholderMarks = [];

    portraitBaseY    = [];
    labelBaseY       = [];
    localBadgeBaseY  = [];
    deleteBadgeBaseY = [];
    placeholderBaseY = [];

    var count  = dlcs.length;
    var rows   = Math.ceil(count / COLS);
    var totalW = (COLS - 1) * H_SPACING;
    var startX = GRID_CENTER_X - totalW / 2;
    // Rows now scroll instead of being centered as a block — the grid
    // always starts just under the viewport's top edge, and however many
    // rows don't fit are reached via the scrollbar/wheel/buttons below.
    var startY = GRID_VIEWPORT_TOP + V_SPACING / 2;

    for (i in 0...count)
    {
        var dlc  = dlcs[i];
        var col  = i % COLS;
        var row  = Math.floor(i / COLS);
        var cx   = startX + col * H_SPACING;
        var cy   = startY + row * V_SPACING;

        var isOwned  = DlcUtils.dlcOwned(dlc, mainPath);
        var isLocked = DlcUtils.dlcLocked(dlc, mainPath);
        var isLocal  = isOwned && (dlc.zipUrl == null || dlc.zipUrl == "");

        var portrait = new FlxSprite();
        portrait.antialiasing = true;

        // Placeholder art support: freshly-created local DLCs (and any
        // entry missing its bundled portrait) get a scanline "no signal"
        // card instead of a broken/missing-texture sprite.
        var hasArt = false;
        var portraitPath = "";

        if (isLocked)
        {
            portraitPath = Paths.image('menus/dlc/locked');
            hasArt = true; // bundled with the base mod
        }
        else
        {
            portraitPath = Paths.image('menus/dlc/' + dlc.id);
            // Assumes Paths.image() resolves under mods/<mod>/images/... —
            // double check against the real Paths implementation if a DLC
            // with real art ends up showing the placeholder incorrectly.
            var rawArtCheck = 'games/' + GamesFolder.currentModFolder + '/images/menus/dlc/' + dlc.id + '.png';
            hasArt = FileSystem.exists(rawArtCheck);
        }

        if (hasArt)
        {
            graphicCache.cache(portraitPath);
            portrait.loadGraphic(portraitPath);
        }
        else
        {
            paintStaticTexture(portrait, 220, 220);
        }

        portrait.scale.set(PORTRAIT_SCALE, PORTRAIT_SCALE);
        portrait.updateHitbox();
        portrait.x = cx - portrait.width  / 2;
        portrait.y = cy - portrait.height / 2;

        if (isLocked) portrait.color = 0xFF888888;

        // Grid sprites are screen-fixed (not affected by the mouse-look
        // camera parallax) so the scroll math below stays in plain screen
        // coordinates instead of having to account for camera.scroll too.
        portrait.scrollFactor.set(0, 0);

        // Card frame — a colored border sitting behind the art, red for
        // anything playable/ownable, grey to match the existing "locked"
        // tint convention.
        var frame = new FlxSprite();
        frame.makeGraphic(
            Std.int(portrait.width  + FRAME_PADDING * 2),
            Std.int(portrait.height + FRAME_PADDING * 2),
            isLocked ? COLOR_LOCKED_FRAME : COLOR_ACCENT_DIM
        );
        frame.x = portrait.x - FRAME_PADDING;
        frame.y = portrait.y - FRAME_PADDING;
        frame.scrollFactor.set(0, 0);
        add(frame);
        portraitFrames.push(frame);

        add(portrait);
        portraits.push(portrait);
        portraitBaseY.push(portrait.y);

        var placeholderMark = new FlxText(0, 0, portrait.width, "");
        if (!hasArt)
        {
            placeholderMark.text = "???";
            placeholderMark.setFormat(Paths.font(LABEL_FONT), 42, FlxColor.WHITE, "center");
            placeholderMark.x = portrait.x;
            placeholderMark.y = portrait.y + portrait.height / 2 - 24;
        }
        placeholderMark.scrollFactor.set(0, 0);
        add(placeholderMark);
        placeholderMarks.push(placeholderMark);
        placeholderBaseY.push(placeholderMark.y);

        // Header strip — a dark banner across the top of the card, drawn
        // over the art, that carries the LOCAL/INSTALLED tag and (in
        // delete mode) the remove button, so they read clearly regardless
        // of what's underneath instead of floating directly on the art.
        var strip = new FlxSprite(frame.x, frame.y);
        strip.makeGraphic(Std.int(frame.width), Std.int(STRIP_HEIGHT), COLOR_STRIP_BG);
        strip.scrollFactor.set(0, 0);
        add(strip);
        cardHeaderStrips.push(strip);

        var labelText = isLocked ? "Locked" : "" + dlc.name;
        if (!isLocked && isOwned && dlc.type == "week")
            labelText += DlcUtils.isWeekFullyPlayed(dlc) ? "\n(Select Song)" : "\n(Full Week)";

        var label = new FlxText(0, frame.y + frame.height + 18, 400, labelText);
        label.setFormat(Paths.font(LABEL_FONT), LABEL_SIZE, FlxColor.WHITE, "center");
        label.x = cx - label.width / 2;
        label.scrollFactor.set(0, 0);
        add(label);
        labels.push(label);
        labelBaseY.push(label.y);

        var badgeLabel:String = "";
        var badgeColor:Int    = 0xFFFFFFFF;
        if (isOwned)
        {
            if (isLocal) {
                badgeLabel = "LOCAL";
                badgeColor = 0xFFFFE600;
            } else {
                badgeLabel = "INSTALLED";
                badgeColor = 0xFFF2F2F2;
            }
        }
        var badge = new FlxText(frame.x + 6, frame.y + 4, 0, badgeLabel);
        badge.setFormat(Paths.font(LABEL_FONT), 16, badgeColor, "left");
        badge.visible = (badgeLabel != "");
        badge.scrollFactor.set(0, 0);
        add(badge);
        localBadges.push(badge);
        localBadgeBaseY.push(badge.y);

        // Delete badge — only ever shown while deleteMode is on, and only
        // for DLCs the player actually owns (nothing to delete otherwise).
        var delBadge = new FlxText(frame.x + frame.width - 26, frame.y + 3, 22, "X");
        delBadge.setFormat(Paths.font(LABEL_FONT), 18, FlxColor.RED, "center");
        delBadge.visible = deleteMode && isOwned;
        delBadge.scrollFactor.set(0, 0);
        add(delBadge);
        deleteBadges.push(delBadge);
        deleteBadgeBaseY.push(delBadge.y);

        strip.visible = (badge.visible || delBadge.visible);
    }

    // Figure out how far the list can scroll, clamp wherever we currently
    // are (the dlc count may have shrunk since the last build), then push
    // every sprite to its correct on-screen position for that offset.
    var contentBottom  = (rows > 0)
        ? (startY + (rows - 1) * V_SPACING + V_SPACING / 2 + FRAME_PADDING + LABEL_SIZE * 2 + 40)
        : 0;
    gridMaxScroll = Math.max(0, contentBottom - GRID_VIEWPORT_BOTTOM);

    if (gridScrollY < 0) gridScrollY = 0;
    if (gridScrollY > gridMaxScroll) gridScrollY = gridMaxScroll;

    applyGridScroll();
    updateScrollbarVisual();
}

var mouseInfluence = 0.06;
var camLerpSpeed = 0.1;
var localTime:Float = 0;
function update(elapsed:Float) {
    localTime += elapsed;
    if (crtShader != null) crtShader.iTime = localTime;

    // The "New Local DLC" substate hands its result back through
    // FlxG.save.data (cross-script instances don't share fields directly —
    // see the comment near the top of this file). Pick it up here, once,
    // right after the substate closes and this update() resumes.
    if (FlxG.save.data.pendingNewDlcName != null)
    {
        var newName = FlxG.save.data.pendingNewDlcName;
        var newType = FlxG.save.data.pendingNewDlcType;
        FlxG.save.data.pendingNewDlcName = null;
        FlxG.save.data.pendingNewDlcType = null;
        FlxG.save.flush();

        if (newName != null && newName.length > 0)
            createLocalDlc(newName, newType);
    }

    // Same hand-off pattern for the song-select substate: it stashes the
    // picked song id (or nothing, if the player hit BACK) before closing.
    if (FlxG.save.data.songSelectPickedSong != null)
    {
        var pickedDlc  = findDlcById(FlxG.save.data.songSelectDlcId);
        var pickedSong = FlxG.save.data.songSelectPickedSong;
        FlxG.save.data.songSelectDlcId      = null;
        FlxG.save.data.songSelectPickedSong = null;
        FlxG.save.flush();

        if (pickedDlc != null) playDlcSong(pickedDlc, pickedSong);
    }

    var mouseX = FlxG.mouse.screenX - FlxG.width / 2;
    var mouseY = FlxG.mouse.screenY - FlxG.height / 2;

    var targetX = mouseX * mouseInfluence;
    var targetY = mouseY * mouseInfluence;

    FlxG.camera.scroll.x += (targetX - FlxG.camera.scroll.x) * camLerpSpeed;
    FlxG.camera.scroll.y += (targetY - FlxG.camera.scroll.y) * camLerpSpeed;

    if (controls.BACK)
    {
        FlxG.switchState(new GameState("XEternalDlcMenu"));
        return;
    }

    // Top bar only usable while not mid-download/extract.
    updateTopBar();

    if (pendingDeleteIndex >= 0)
    {
        pendingDeleteTimer -= elapsed;
        if (pendingDeleteTimer <= 0)
        {
            if (pendingDeleteIndex < deleteBadges.length)
                deleteBadges[pendingDeleteIndex].text = "X";
            pendingDeleteIndex = -1;
        }
    }

    if (menuState == "loading") return;

    if (menuState == "extracting")
    {
        var pct = Std.int(zipProgress.percentage * 100);
        progressText.text = "Extracting: " + pct + "% (" + zipProgress.curFile + "/" + zipProgress.fileCount + ")";

        if (zipProgress.done)
        {
            menuState = "selecting";
            zipReader.i.close();
            zipReader = null;

            var zipPath = mainPath + curDlcId + ".zip";
            if (FileSystem.exists(zipPath)) FileSystem.deleteFile(zipPath);

            if (!Paths.assetsTree.exists(GamesFolder.loadModLib(mainPath + curDlcId, curDlcId)))
                Paths.assetsTree.addLibrary(GamesFolder.loadModLib(mainPath + curDlcId, curDlcId));

            curDlcId = "";
            progressText.visible = speedText.visible = false;
            statusText.text = "Download complete! Click to play.";

            refreshStorageDisplay();
            clearAndRebuildGrid();
        }
        return;
    }

    if (menuState != "selecting") return;

    updateGridScroll();

    // Delete-mode badge clicks take priority over portrait clicks.
    if (deleteMode)
    {
        var hoveredDelete = -1;
        for (i in 0...deleteBadges.length)
        {
            if (deleteBadges[i].visible && FlxG.mouse.overlaps(deleteBadges[i]))
            {
                hoveredDelete = i;
                break;
            }
        }

        if (hoveredDelete >= 0)
        {
            deleteBadges[hoveredDelete].color = FlxColor.YELLOW;

            if (FlxG.mouse.justReleased)
            {
                if (pendingDeleteIndex == hoveredDelete)
                {
                    deleteDlcAtIndex(hoveredDelete);
                }
                else
                {
                    if (pendingDeleteIndex >= 0 && pendingDeleteIndex < deleteBadges.length)
                        deleteBadges[pendingDeleteIndex].text = "X";

                    pendingDeleteIndex = hoveredDelete;
                    pendingDeleteTimer = PENDING_DELETE_TIMEOUT;
                    deleteBadges[hoveredDelete].text = "OK?";
                }
            }

            selectionBox.visible = false;
            return;
        }
        else
        {
            for (b in deleteBadges) if (b.visible) b.color = FlxColor.RED;
        }
    }

    hoveredIndex = -1;
    for (i in 0...portraits.length)
    {
        if (!portraits[i].visible) continue; // scrolled out of the viewport
        if (FlxG.mouse.overlaps(portraits[i]))
        {
            hoveredIndex = i;
            break;
        }
    }

    if (hoveredIndex >= 0)
    {
        var p = portraits[hoveredIndex];
        selectionBox.x = p.x - 20;
        selectionBox.y = p.y - 20;
        selectionBox.visible = true;

        if (hoveredIndex != lastHoveredIndex) {
            var hoveredDlc = dlcs[hoveredIndex];
            var desc:String = (hoveredDlc.description != null && hoveredDlc.description != "")
                ? hoveredDlc.description
                : "";
            descriptionText.text = desc;
            descriptionText.visible = (desc != "");
        }
    }
    else
    {
        selectionBox.visible = false;
        if (hoveredIndex != lastHoveredIndex) descriptionText.visible = false;
    }
    lastHoveredIndex = hoveredIndex;

    // In delete mode, don't let a click-through also trigger play/download.
    if (deleteMode) return;

    if (FlxG.mouse.justReleased && hoveredIndex >= 0)
    {
        var dlc      = dlcs[hoveredIndex];
        var isOwned  = DlcUtils.dlcOwned(dlc, mainPath);
        var isLocked = DlcUtils.dlcLocked(dlc, mainPath);

        if (isLocked)
        {
            var lbl = labels[hoveredIndex];
            lbl.color = FlxColor.RED;
            var snd = FlxG.sound.play(Paths.sound("menu/denied"));
            FlxG.camera.shake(0.01, 0.15);
            snd.onComplete = function() { lbl.color = FlxColor.WHITE; };
        }
        else if (isOwned)
        {
            if (dlc.type == "week" && dlc.songs != null && dlc.songs.length > 0 && DlcUtils.isWeekFullyPlayed(dlc))
            {
                FlxG.save.data.songSelectDlcId   = dlc.id;
                FlxG.save.data.songSelectDlcName = dlc.name;
                FlxG.save.data.songSelectSongs   = dlc.songs;
                FlxG.save.flush();
                      persistentUpdate = !(persistentDraw = true);
                openSubState(new GameSubState("XEternalDlcFreeplay"));
            }
            else
                playDlcSong(dlc);
        }
        else
        {
            startDownload(dlc);
        }
    }
}

function updateTopBar()
{
    hoveredTopBarIndex = -1;
    for (i in 0...topBarButtons.length)
    {
        if (FlxG.mouse.overlaps(topBarButtons[i]))
        {
            hoveredTopBarIndex = i;
            break;
        }
    }

    for (i in 0...topBarButtons.length)
        topBarButtons[i].color = (i == hoveredTopBarIndex) ? COLOR_BTN_HOVER : COLOR_BTN_IDLE;

    if (hoveredTopBarIndex == -1) return;
    if (!FlxG.mouse.justReleased) return;

    // Downloading/extracting: block tool actions so we don't stomp on an
    // in-progress zip/library operation.
    if (menuState == "downloading" || menuState == "extracting") return;

    var action = topBarActions[hoveredTopBarIndex];
    switch (action)
    {
        case "createLocal":
            persistentUpdate = !(persistentDraw = true);
            openSubState(new GameSubState("XEternalDlcCreator"));

        case "deleteMode":
            deleteMode = !deleteMode;
            pendingDeleteIndex = -1;
            for (i in 0...deleteBadges.length)
            {
                var dlc = dlcs[i];
                var isOwned = DlcUtils.dlcOwned(dlc, mainPath);
                deleteBadges[i].text = "X";
                deleteBadges[i].color = FlxColor.RED;
                deleteBadges[i].visible = deleteMode && isOwned;
                cardHeaderStrips[i].visible = (localBadges[i].visible || deleteBadges[i].visible);
            }
            topBarLabels[hoveredTopBarIndex].text = deleteMode ? "DONE" : "DELETE MODE";
            showToolHint(deleteMode ? "Click a red X to delete that DLC (click again to confirm)." : "");

        case "refresh":
            menuState = "loading";
            statusText.text = "Refreshing DLC list...";
            deleteMode = false;
            pendingDeleteIndex = -1;
            showToolHint("");
            // The old grid stays on screen (and inert, since menuState is
            // "loading") until fetchDLCList()'s callback swaps it out —
            // buildPortraitGrid() clears the old sprites itself, so no
            // need to blank the screen here first.
            fetchDLCList();
            refreshStorageDisplay();

        case "cleanZips":
            cleanLeftoverZips();

        case "openFolder":
            openDlcFolderOnDisk();
    }
}

// Covers both entry points: click a portrait (songId omitted — picks the
// next unplayed song for a week, or the DLC's single song) and pick a
// specific song from the song-select submenu (songId given explicitly).
function playDlcSong(dlc:Dynamic, ?songId:String)
{
    if (songId == null)
    {
        if (dlc.type == "week" && dlc.songs != null && dlc.songs.length > 0)
            songId = DlcUtils.getNextUnplayedSong(dlc);
        else
            songId = (dlc.songName != null ? dlc.songName : dlc.id);
    }

    var libName = dlc.id;
    if (!Paths.assetsTree.existsSpecific(songId, "songs", libName))
        Paths.assetsTree.addLibrary(GamesFolder.loadModLib(mainPath + dlc.id + "/", libName));

    DlcUtils.markSongPlayed(dlc.id, songId);

    FlxG.save.data.cameFromDLCMenu = true;
    FlxG.save.flush();

    // Loader.loadSongWithReturn(name, difficulty, returnTo, opponentMode, coopMode)
    // has no library-name parameter — the song's library was already
    // resolved above via Paths.assetsTree, so this just needed the real
    // 5-arg shape instead of a stray libName in the coopMode slot.
    Loader.loadSongWithReturn(songId, "hard", "XEternalDlcSelector");
    FlxG.switchState(new PlayState());
}

function startDownload(dlc:Dynamic)
{
    menuState = "downloading";
    curDlcId  = dlc.id;

    statusText.text      = "Downloading " + dlc.name + "...";
    progressText.visible = true;
    speedText.visible    = true;
    progressText.text    = "Downloading...";

    var zipUrl       = dlc.zipUrl;
    var targetFolder = mainPath;
    var zipPath      = targetFolder + dlc.id + ".zip";

    var request = new URLRequest(zipUrl);
    var loader:URLLoader = new URLLoader();
    loader.dataFormat = 0;

    loader.addEventListener('complete', (event:Event) -> {
        menuState = "extracting";
        speedText.visible = false;

        var data = event.target.data;
        File.saveBytes(zipPath, data);

        zipReader = ZipUtil.openZip(zipPath);
        ZipUtil.uncompressZipAsync(zipReader, targetFolder, zipProgress);
    });

    loader.addEventListener('progress', (e:Event) -> {
        var now = Timer.stamp();
        var deltaTime = now - lastTime;
        if (deltaTime >= 1) {
            var bytesNow   = e.bytesLoaded;
            var deltaBytes = bytesNow - lastBytes;
            speedMBps = (deltaBytes / deltaTime) / (1024 * 1024);

            var actualSpeed = Math.round(speedMBps * 1000) / 1000 < 1
                ? Std.string(Math.round(speedMBps * 1000)) + " KB/s"
                : Std.string(Math.round(speedMBps * 1000) / 1000) + " MB/s";

            speedText.text = actualSpeed;
            lastBytes = bytesNow;
            lastTime  = now;
        }

        var progress = Std.int(e.bytesLoaded / e.bytesTotal * 100);
        progressText.text = "Downloading: " + Std.string(progress) + "% ("
            + Std.string(Std.int(e.bytesLoaded / 1000000)) + "MB/"
            + Std.string(Std.int(e.bytesTotal  / 1000000)) + "MB)";
    });

    loader.addEventListener('ioError', (e:Event) -> {
        menuState       = "selecting";
        statusText.text = "Download failed — check your connection.";
        progressText.visible = speedText.visible = false;
    });

    loader.load(request);
    lastTime = Timer.stamp();
}

function destroy() {
    if (crtShader != null) {
        FlxG.camera.removeShader(crtShader);
        crtShader = null;
    }
}