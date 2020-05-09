package states;

import scenes.RoundScene;

class RoundPlayState extends RoundState {
  public function new(scene:RoundScene) {
    super(scene);
  }

  override function update():Void {
    if (round.win()) {
      // You win!
      scene.state = new RoundEndState(scene);
    }
    else if (round.lose()) {
      // You lose!
      scene.state = new BallOffScreenState(scene);
    }
  }
}
