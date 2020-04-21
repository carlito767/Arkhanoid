package states;

import kha.Color;
import kha.graphics2.Graphics;
import kha.input.KeyCode;

import paddle_states.MaterializeState;
import paddle_states.PaddleStateManager;

class RoundStartState extends State {
  var displayCount:Int = 0;

  public function new(game:Game) {
    super(game);
  }

  override function update():Void {
    game.round.update();
  }

  override function render(g2:Graphics):Void {
    game.round.render(g2);

    g2.color = Color.White;
    g2.font = game.MAIN_FONT;
    g2.fontSize = 18;
    // Display round name
    if (displayCount > 100 && displayCount < 311) {
      g2.centerString(game.round.name, 600);
    }
    // Display 'ready'
    if (displayCount > 200 && displayCount < 311) {
      g2.centerString('ready', 650);
      game.round.paddle.visible = true;
      game.round.ball.visible = true;
    }
    if (displayCount == 201) {
      // Animate the paddle materializing onto the screen
      PaddleStateManager.transition(game.round.paddle, new MaterializeState());
    }
    if (displayCount == 340) {
      // Normal gameplay begins
      game.state = new RoundPlayState(game);
    }

    // Update display count
    displayCount++;
  }
}
