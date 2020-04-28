import kha.Assets;
import kha.Image;

typedef Images = List<Image>;

class AnimationExtension {
  public static function loadAnimation(id:String, step:Int, cycle:Int = 0):Animation {
    // Load images id_*.png
    var images = new Images();
    while (true) {
      var image = Assets.images.get('${id}_${images.length + 1}');
      if (image == null) {
        break;
      }
      images.add(image);
    }
    // Backup strategy: id.png
    if (images.isEmpty()) {
      var image = Assets.images.get(id);
      if (image != null) {
        images.add(image);
      }
    }
    return {
      images:images,
      step:step,
      cycle:cycle,
      heartbeat:0,
    };
  }

  public static function tick(animation:Animation):Null<Image> {
    if (animation.images.isEmpty()) return null;

    // Need animation?
    var animate = animation.heartbeat % animation.step == 0;
    if (animation.cycle > 0) {
      if (animation.heartbeat == animation.cycle) {
        animation.heartbeat = 0;
      }
      animate = animate && animation.heartbeat <= (animation.images.length - 1) * animation.step;
    }

    // Take a breath
    animation.heartbeat++;

    // Animate
    if (!animate) {
      return animation.images.first();
    }
    var image = animation.images.pop();
    if (animation.cycle >= 0) {
      animation.images.add(image);
    }
    return image;
  }

  public static function reverse(animation:Animation):Animation {
    var images = new Images();
    for (image in animation.images) {
      images.push(image);
    }
    return {
      images:images,
      step:animation.step,
      cycle:animation.cycle,
      heartbeat:0,
    };
  }

  public static function chain(animation1:Animation, animation2:Animation):Animation {
    var images = new Images();
    for (image in animation1.images) {
      images.add(image);
    }
    for (image in animation2.images) {
      images.add(image);
    }
    return {
      images:images,
      step:animation1.step,
      cycle:animation1.cycle,
      heartbeat:0,
    };
  }
}
