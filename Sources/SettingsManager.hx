import kha.Storage;

class SettingsManager {
  static inline var FILENAME = 'settings';
  static inline var VERSION = 1;

  static var defaults:Settings = {
    v: VERSION,
    highScore: 0,
  };

  public static function read():Settings {
    var file = Storage.namedFile(FILENAME);
    var data:Settings = file.readObject();
    if (data != null && data.v == VERSION) {
      return data;
    }
    return defaults;
  }

  public static function write(settings:Settings):Void {
    var file = Storage.namedFile(FILENAME);
    settings.v = VERSION;
    file.writeObject(settings);
  }
}
