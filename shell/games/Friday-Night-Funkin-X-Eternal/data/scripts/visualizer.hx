import funkin.backend.utils.AudioAnalyzer;
import flixel.util.FlxGradient;

// Credit Dancetrap for any uses. There may be some bugs, which I will get to fixing

/**
    How a Visualizer Is Made

    Visualizer is dependant on the Waveform and Frequency Info

    The waveform is a series of numbers representing the loudness of the sound at moments in time. 
    The waveform level is loosely related the the beat of the music. The loudness values are typically higher during a beat.

    The frequency information describes the levels of various pitches within the audio signal at moments in time. 
    A technique called Fourier transform extracts frequency information from the waveform. The frequency information 
    is loosely related to the notes of the music, but may not correspond to actual musical notes. It does provide 
    information about distribution of high and low pitches at moments in time.

    Waveform displays amplitude

    For the waveform, we need to use the BPM in order to help out with that

**/

var analyzer:AudioAnalyzer;

var audioPoints:Array<Array<Float>> = []; //All the amplitudes used for your visualizer

public var bgColor:FlxColor = FlxColor.BLACK;
public var numberOfBars:Int = 20; //How many bars you want for your visualizer
public var milliseconds:Float = 100; //The interval difference between your amps. I highly recommend NOT going to 1 or below
public var exponent:Int = 2; //The exponent of your milliseconds. Make sure it matches your milliseconds digits. For a quick guide, 10^0 = 1, 10^1 = 10, 10^2 = 100, 10^3 = 1000
public var barAlpha:Float = 0.2;
public var barGradient:Array<FlxColor> = [FlxColor.RED, FlxColor.YELLOW];
var length:Float; //Audio length
static var secondCount:Int = 0; //The area of 

public var audioBars:FlxTypedGroup<FlxSprite>;


function create()
{
    // var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, bgColor);
    // add(bg);

    analyzer = new AudioAnalyzer(FlxG.sound.music);
    length = FlxG.sound.music.length;

    var previousNum:Float = 0;
    var num:Float = 0;

    for(i in 0...length/milliseconds)
    {
        var seconds:Array<Float> = [];
        for(j in 0...numberOfBars)
        {
            num += milliseconds/numberOfBars;
            seconds.push(analyzer.analyze(previousNum, num));
            previousNum = num;
        }
        audioPoints.push(seconds);
    }

    audioBars = new FlxTypedGroup();
    add(audioBars);

    for(i in 0...numberOfBars)
    {
        var bar:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width/numberOfBars, FlxG.height, barGradient);
        bar.x = i * (FlxG.width/numberOfBars);
        bar.setGraphicSize(bar.width - 25, bar.height);
        bar.scale.y = audioPoints[secondCount][i];
        bar.alpha = barAlpha;
        bar.updateHitbox();
        bar.y = FlxG.height - bar.height;
        audioBars.add(bar);
    }

    for (i in audioBars.members){
        i.x -= 700;
    }
}

function update(elapsed:Float)
{
    if(FlxG.sound.music.time >= length)
    {
        secondCount = 0;
    }
    
    if((Math.floor(FlxG.sound.music.time/Math.pow(10, exponent)) * Math.pow(10, exponent)) % milliseconds == 0 || (Math.floor(FlxG.sound.music.time/Math.pow(10, exponent)) * Math.pow(10, exponent)) == 0)
    {
        secondCount = (Math.floor(FlxG.sound.music.time/Math.pow(10, exponent)) * Math.pow(10, exponent))/milliseconds;
    }

    if(FlxG.sound.music.time <= length && FlxG.sound.music != null)
    {
        for(i in 0...audioBars.length)
            {
                audioBars.members[i].scale.y = FlxMath.lerp(audioBars.members[i].scale.y, audioPoints[secondCount][i], FlxMath.bound(elapsed * 5, 0, 1));
                audioBars.members[i].updateHitbox();
                audioBars.members[i].y = FlxG.height - audioBars.members[i].height;
            }
    }
}