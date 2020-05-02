import kha.Assets;
import kha.Image;

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
    if (images.length == 0) {
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
    };
  }

  public static function pulsateAnimation(id:String, step:Int, cycle:Int = 0):Animation {
    var animation1 = loadAnimation(id, step, cycle);
    var animation2 = loadAnimation(id, step, cycle);
    animation2.images.reverse();
    animation1.images = animation1.images.concat(animation2.images);
    return animation1;
  }

  public static function over(animation:Animation):Bool {
    return animation.cycle < 0 && animation.heartbeat == animation.images.length * animation.step;
  }

  public static function tick(animation:Animation):Null<Image> {
    if (animation.images.length == 0) return null;

    // Cycle?
    if ((animation.cycle > 0 && animation.heartbeat == animation.cycle) ||
        (animation.cycle == 0 && animation.heartbeat == animation.images.length * animation.step)) {
      animation.heartbeat = 0;
    }

    // Take a breath
    if (!over(animation)) {
      animation.heartbeat++;
    }

    // Animate
    var heartbeat = Math.min(animation.heartbeat, animation.images.length * animation.step);
    var i = Math.ceil(heartbeat / animation.step) - 1;
    var image = animation.images[i];
    return image;
  }
}
