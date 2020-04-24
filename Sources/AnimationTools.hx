import kha.Assets;
import kha.Image;

class AnimationTools {
  public static function load(id:String):Images {
    var anim = new Images();
    var image = Assets.images.get(id);
    if (image != null) {
      anim.add(image);
    }
    return anim;
  }

  public static function loadSequence(id:String):Images {
    var anim = new Images();
    while (true) {
      var image = Assets.images.get('${id}_${anim.length + 1}');
      if (image == null) {
        break;
      }
      anim.add(image);
    }
    return anim;
  }

  public static function cycle(animation:Images):Null<Image> {
    if (animation.length == 1) {
      return animation.first();
    }

    var image = animation.pop();
    if (image != null) {
      animation.add(image);
    }
    return image;
  }

  public static function reverse(animation:Images):Images {
    var anim = new Images();
    for (image in animation) {
      anim.push(image);
    }
    return anim;
  }

  public static function chain(animation1:Images, animation2:Images):Images {
    var anim = new Images();
    for (image in animation1) {
      anim.add(image);
    }
    for (image in animation2) {
      anim.add(image);
    }
    return anim;
  }
}
