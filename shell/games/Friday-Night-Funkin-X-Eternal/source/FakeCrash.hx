package source;

// FakeCrash.hx
import sys.io.Process;

class FakeCrash {
    public static function trigger(delaySeconds:Float = 1.5):Void {
        var exePath = Sys.programPath();
        new Process(exePath, ["--fakecrash-delay=" + delaySeconds]);
        Sys.exit(1);
    }
}