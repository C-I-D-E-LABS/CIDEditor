
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;

var scrollGroup:FlxGroup;
var scrollSpeed:Float = 100; // px/sec, tuned below for ~73 sec total
var bg:FlxSprite;

var creditsData:Array<Dynamic> = [
    {header: "X-ETERNAL CREW", entries: [
        {role: "Director / Pixel Artist / Lead Programer", name: "N1ckolasN4me"},
        {role: "Programmer", name: "El1teOutc4st"},
        {role: "Composer", name: "Telephone_11"},
        {role: "Composer", name: "ChronDelta"},
        {role: "Composer", name: "Binalt"},
        {role: "Composer", name: "DroCalebRose"},
        {role: "Composer", name: "EzaxVGM"},
        {role: "Composer", name: "Ouie5th"},
        {role: "Composer", name: "Aerozity"},
        {role: "Composer", name: "Dyno"},
        {role: "Artist", name: "[Mister G]"},
        {role: "Artist", name: "Doorbun"},
        {role: "Artist", name: "Emmagain"},
        {role: "Artist", name: "GemLight"},
        {role: "Artist", name: "FA Z GAMER"},
        {role: "Artist/Animator", name: "Sebas1554"},
        {role: "Charting", name: "Cherrinum"},
        {role: "Charting", name: "StarszinArk"}
    ]},
    {header: "EXETERNAL TEAM", entries: [
        {role: "Director/Owner", name: "Neutroa"},
        {role: "Co-Director", name: "Raenablaize"},
        {role: "Artist", name: "InklingCurry"},
        {role: "Artist", name: "Torrmate"},
        {role: "Artist", name: "BlueFox"},
        {role: "Artist", name: "JonnyTest"},
        {role: "Artist", name: "Nori"},
        {role: "Artist", name: "VoidEyedPanda"},
        {role: "Artist", name: "StoneSteve"},
        {role: "Artist", name: "Serebeat"},
        {role: "Artist", name: "Noveni⑨"},
        {role: "Composer", name: "DanlyTheMusician"},
        {role: "Composer", name: "Phantasma"},
        {role: "Composer", name: "PorkNDogs"},
        {role: "Composer", name: "ChurgneyGurgney"}
    ]},
    {header: "SPECIAL THANKS", entries: [
        {role: "", name: "The FNF Community"},
        {role: "", name: "The Sonic.EXE Community"},
        {role: "", name: "VS Sonic.exe Definitive Experience"},
        {role: "", name: "VS Sonic.exe Familiar Encounters"},
        {role: "", name: "VS Sonic.exe Do-Over"},
        {role: "", name: "Thank you for playing!!"}
    ]}
];

function create() {
    FlxG.sound.playMusic(Paths.music('extras/S2Ending'), 0);
    FlxG.sound.music.fadeIn(2, 0, 1);
    // bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    // add(bg);

    bgSonic = new FlxSprite(0, 0, Paths.image('menus/freeplay/backgroundloolBlur'));
    bgSonic.antialiasing = false;
    bgSonic.screenCenter();
    bgSonic.setGraphicSize(FlxG.width, FlxG.height);
    add(bgSonic);

    scrollGroup = new FlxGroup();
    add(scrollGroup);

    buildCreditsText();
}

function buildCreditsText() {
    var yPos:Float = FlxG.height + 100;
    var centerX = FlxG.width / 2;

    var title = new FlxText(0, 0, FlxG.width, "CREDITS", 64);
    title.alignment = "center";
    title.font = Paths.font('greenm03.ttf');
    title.color = FlxColor.WHITE;
    add(title);
    //yPos += 160;

    for (section in creditsData) {
        var header = new FlxText(0, yPos, FlxG.width, section.header, 40);
        header.alignment = "center";
        header.font = Paths.font('greenm03.ttf');
        header.color = FlxColor.YELLOW;
        scrollGroup.add(header);
        yPos += 90;

        for (entry in section.entries) {
            if (entry.role != "") {
                var roleText = new FlxText(0, yPos, FlxG.width, entry.role, 22);
                roleText.alignment = "center";
                roleText.font = Paths.font('greenm03.ttf');
                roleText.color = FlxColor.GRAY;
                scrollGroup.add(roleText);
                yPos += 34;
            }

            var nameText = new FlxText(0, yPos, FlxG.width, entry.name, 32);
            nameText.alignment = "center";
            nameText.font = Paths.font('greenm03.ttf');
            nameText.color = FlxColor.WHITE;
            scrollGroup.add(nameText);
            yPos += 70;
        }

        yPos += 60; // gap between sections
    }

    var totalDistance = yPos + FlxG.height;
    scrollSpeed = totalDistance / 73;
}

function update(elapsed:Float) {
    for (member in scrollGroup) {
        var spr:FlxSprite = cast member;
        spr.y -= scrollSpeed * elapsed;
    }

    if (FlxG.keys.justPressed.ESCAPE) {
        FlxG.switchState(new GameState("XEternalExtras"));
    }
}