import kha.Assets;
import kha.Image;

class AnimationTools {
  public static function loadAnimation(id:String):Animation {
    var anim = new Animation();
    while (true) {
      var image = Assets.images.get('${id}_${anim.length + 1}');
      if (image == null) {
        break;
      }
      anim.add(image);
    }
    return anim;
  }

  public static function cycle(animation:Animation):Null<Image> {
    if (animation.length == 1) {
      return animation.first();
    }

    var image = animation.pop();
    if (image != null) {
      animation.add(image);
    }
    return image;
  }

  public static function reverse(animation:Animation):Animation {
    var anim = new Animation();
    for (image in animation) {
      anim.push(image);
    }
    return anim;
  }

  public static function chain(animation1:Animation, animation2:Animation):Animation {
    var anim = new Animation();
    for (image in animation1) {
      anim.add(image);
    }
    for (image in animation2) {
      anim.add(image);
    }
    return anim;
  }
}
