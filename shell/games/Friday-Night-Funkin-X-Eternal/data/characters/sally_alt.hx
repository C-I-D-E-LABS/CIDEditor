function onPlaySingAnim(e) {
    if (visible && alpha > 0) {
        PlayState.instance.camGame.shake(0.006, 0.05, true, true);
        PlayState.instance.camHUD.shake(0.006, 0.05, true, true);
    }
}
