import kha.Assets;

import components.Animation;
import components.Image;

class AnimationExtension {
  public static function loadAnimation(id:String, step:Int, cycle:Int = 0):Animation {
    // Load images id_*.png
    var images:Array<Image> = [];
    while (true) {
      var image = Assets.images.get('${id}_${images.length + 1}');
      if (image == null) {
        break;
      }
      images.push(image);
    }
    // Backup strategy: id.png
    if (images.isEmpty()) {
      var image = Assets.images.get(id);
      if (image != null) {
        images.push(image);
      }
    }
    return {
      images:images,
      step:step,
      cycle:cycle,
      heartbeat:0,
      paused:false,
    };
  }

  public static function pulsateAnimation(id:String, step:Int, cycle:Int = 0):Animation {
    var animation = loadAnimation(id, step, cycle);
    var n = animation.images.length;
    for (i in 1...n+1) {
      animation.images.push(animation.images[n - i]);
    }
    return animation;
  }

  public static function over(animation:Animation):Bool {
    return animation.cycle < 0 && animation.heartbeat == animation.images.length * animation.step;
  }

  public static function reset(animation:Animation):Void {
    animation.heartbeat = 0;
    animation.paused = false;
  }

  public static function reverse(animation:Animation):Void {
    if (animation.cycle >= 0) return;

    animation.images.reverse();
    if (animation.heartbeat > 0) {
      animation.heartbeat = animation.images.length * animation.step - animation.heartbeat;
    }
  }

  public static function tick(animation:Animation):Null<Image> {
    if (animation.images.isEmpty()) return null;

    // Cycle?
    if ((animation.cycle > 0 && animation.heartbeat == animation.cycle) ||
        (animation.cycle == 0 && animation.heartbeat == animation.images.length * animation.step)) {
      animation.heartbeat = 0;
    }

    // Take a breath
    if (!over(animation) && !animation.paused) {
      animation.heartbeat++;
    }

    // Animate
    var heartbeat = Math.min(animation.heartbeat, animation.images.length * animation.step);
    var i = Math.ceil(heartbeat / animation.step) - 1;
    var image = animation.images[i];
    return image;
  }
}
