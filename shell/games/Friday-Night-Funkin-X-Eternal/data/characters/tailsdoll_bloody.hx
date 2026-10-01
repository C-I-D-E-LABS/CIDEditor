var self = this;
var baseX:Float = 0;
var baseY:Float = 0;
var hoverTime:Float = 0;

function postCreate() {
    baseX = self.x;
    baseY = self.y;
}

function update(elapsed:Float) {
    hoverTime += elapsed;
    self.x = baseX + Math.cos(hoverTime * 1.8) * 18;
    self.y = baseY + Math.sin(hoverTime * 1.8) * 18;
}
