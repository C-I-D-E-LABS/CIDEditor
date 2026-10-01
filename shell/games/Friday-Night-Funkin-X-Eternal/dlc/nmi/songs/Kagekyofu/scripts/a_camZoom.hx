/**
 * DONT TOUCH.
 */
public var bfZoom:Float;
public var dadZoom:Float;

public var bfOff:Float;
public var dadOff:Float;

//ok maybe you could touch this
public var manualZoom:Bool = false;

function create() {
    if (boyfriend != null && boyfriend.xml != null){
		if (boyfriend.xml.exists("zoomAmt")) bfZoom = boyfriend.xml.get("zoomAmt");
		if (boyfriend.xml.exists("offAmt")) bfOff = boyfriend.xml.get("offAmt");
        if (bfZoom == null) bfZoom = defaultCamZoom;
        if (bfOff == null) bfOff = 0;
	}

	if (dad != null && dad.xml != null){
		if (dad.xml.exists("zoomAmt")) dadZoom = dad.xml.get("zoomAmt");
        if (dad.xml.exists("offAmt")) dadOff = dad.xml.get("offAmt");
        if (dadZoom == null) dadZoom = defaultCamZoom;
        if (dadOff == null) dadOff = 0;
	}
}

function postUpdate() {
    final _curCamOffset:Float = (curCameraTarget == 0 ? (dadOff != null ? dadOff : 1) : (bfOff != null ? bfOff : 1));
    
    switch(strumLines.members[curCameraTarget].characters[0].getAnimName()) {

        case "singLEFT", "singLEFT-alt", "singLEFT-loop": 
            camFollow.x -= Std.int(_curCamOffset);

        case "singDOWN", "singDOWN-alt", "singDOWN-loop": 
            camFollow.y += Std.int(_curCamOffset);
        
        case "singUP", "singUP-alt", "singUP-loop": 
            camFollow.y -= Std.int(_curCamOffset);
        
        case "singRIGHT", "singRIGHT-alt", "singRIGHT-loop":
            camFollow.x += Std.int(_curCamOffset);
    }

    if (!manualZoom) defaultCamZoom = lerp(defaultCamZoom, (curCameraTarget == 0 ? dadZoom : bfZoom), camGameZoomLerp);
}

/**
 * hi is me luscious, use is allowed if credited
 */
