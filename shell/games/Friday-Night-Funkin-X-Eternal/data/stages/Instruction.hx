var glitchShader:CustomShader = null;
var elapsed:Float = 0.0;

// ── Tweak these to taste ──────────────────────────────────────────
var INTENSITY:Float    = 1.0;   // 0.0 = off, 1.0 = full, 2.0 = extreme
var GLITCH_HEIGHT:Float = 0.35; // fraction of screen height that glitches
// ─────────────────────────────────────────────────────────────────

function create() {
    boyfriend.alpha = 0;

    if (FlxG.save.data.modShaders) {
        glitchShader = new CustomShader("error");

        glitchShader.iTime       = 0.0;
        glitchShader.intensity   = INTENSITY;
        glitchShader.glitchHeight = GLITCH_HEIGHT;

        for (cam in [camGame, camHUD])
            cam.addShader(glitchShader);
    }

}
var localTime:Float = 0;
function update(elapsed:Float) {
    if (glitchShader == null) return;
    localTime += elapsed;
    glitchShader.iTime = localTime;
}

// Call this from a song event or another script to toggle the effect
function setGlitchIntensity(value:Float) {
    INTENSITY = value;
    if (glitchShader != null)
        glitchShader.intensity = value;
}
