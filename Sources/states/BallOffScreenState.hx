package states;

class BallOffScreenState extends State {
  public function new(game:Game) {
    super(game);
  }

  override function update():Void {
    game.switchToRound(0);
  }
}
