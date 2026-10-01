function onPlaySingAnim(e) {
    if (visible && alpha > 0) {
        PlayState.instance.camGame.shake(0.004, 0.05, true, true);
        PlayState.instance.camHUD.shake(0.004, 0.05, true, true);
    }
}
