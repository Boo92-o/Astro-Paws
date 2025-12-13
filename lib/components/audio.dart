import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';

class AudioManager extends Component {
  bool musicEnabled = true;
  bool soundsEnabled = true;

  /// Названия всех коротких эффектов, которые будут предварительно загружены
  final List<String> _soundEffects = [
    'click.ogg',
    'collect.ogg',
    'explode1.ogg',
    'explode2.ogg',
    'fire.ogg',
    'hit.ogg',
    'laser.ogg',
    'start.ogg',
  ];

  @override
  FutureOr<void> onLoad() async {
    // Инициализация фоновой музыки
    FlameAudio.bgm.initialize();

    // Предзагрузка всех коротких звуков
    await FlameAudio.audioCache.loadAll(_soundEffects);
    return super.onLoad();
  }

  /// 🎵 Воспроизведение фоновой музыки (в цикле)
  Future<void> playMusic(String fileName) async {
    if (!musicEnabled) return;

    try {
      await FlameAudio.bgm.stop();
      await FlameAudio.bgm.play(fileName, volume: 0.8);
    } catch (e) {
      print('Ошибка при воспроизведении музыки: $e');
    }
  }

  /// ⏸️ Остановка фоновой музыки
  Future<void> stopMusic() async {
    await FlameAudio.bgm.stop();
  }

  /// 🔊 Воспроизведение короткого эффекта
  void playSound(String soundFile) {
    if (!soundsEnabled) return;

    try {
      FlameAudio.play(soundFile, volume: 0.8);
    } catch (e) {
      print('Ошибка при воспроизведении звука: $e');
    }
  }

  /// 🔁 Переключение фоновой музыки
  void toggleMusic() {
    musicEnabled = !musicEnabled;
    if (!musicEnabled) {
      FlameAudio.bgm.stop();
    }
  }

  /// 🔇 Переключение звуков
  void toggleSounds() {
    soundsEnabled = !soundsEnabled;
  }

  /// 💥 Удобные ярлыки для конкретных звуков
  void playExplosion() => playSound('explode1.ogg');
  void playExplosionBig() => playSound('explode2.ogg');
  void playShoot() => playSound('laser.ogg');
  void playHit() => playSound('hit.ogg');
  void playCollect() => playSound('collect.ogg');
}
