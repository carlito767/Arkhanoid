package states;

class GameStartState extends State {
  public function new(game:Game) {
    super(game);

    // Input bindings
    game.input.clearBindings();
    game.input.bind(Mouse(Left), (_)->{ game.switchMouseLock(); });
    game.input.bind(Key(Escape), (_)->{ game.backToTitle(); });
  }

  override function update():Void {
    game.state = new RoundStartState(game);
  }
}
