package states;

class GameStartState extends State {
  public function new(game:Game) {
    super(game);

    // Input bindings
    game.input.clearBindings();
    #if debug
    game.input.bind(Key(Backspace), (_)->{ game.backToTitle(); });
    #end
    game.input.bind(Mouse(Left), (_)->{ game.switchMouseLock(); });
  }

  override function update():Void {
    game.state = new RoundStartState(game);
  }
}
