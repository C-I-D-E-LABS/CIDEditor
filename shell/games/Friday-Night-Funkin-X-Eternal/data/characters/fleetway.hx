var self = this;
var hoverTime:Float = 0;

function update(elapsed:Float) {
    hoverTime += elapsed;
    var ampX = 6;
    var ampY = 3;
    var speed = 1;
    var baseX = self.x;
    var baseY = self.y;

        //self.x = baseX - ampX * Math.sin(hoverTime * speed);
        self.y = baseY - ampY * Math.sin(hoverTime * speed) * Math.cos(hoverTime * speed);
}
