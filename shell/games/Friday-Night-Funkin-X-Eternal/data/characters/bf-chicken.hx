var self = this;
var baseX:Float = 0;
var chickencrosstheroad:Bool = false;

function update(elapsed:Float) {
    if (self.visible && !chickencrosstheroad) {
        chickencrosstheroad = true;
        baseX = self.x;
        FlxTween.tween(self, {x: baseX + 160}, 1.15, {type: FlxTween.PINGPONG, ease: FlxEase.sineInOut});
    }

    if (!self.visible && chickencrosstheroad) {
        chickencrosstheroad = false;
        FlxTween.cancelTweensOf(self, ["x"]);
        self.x = baseX;
    }
}
