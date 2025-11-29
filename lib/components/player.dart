import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '/components/bullet.dart';
import '/astro_paws.dart';
import 'audio.dart';

class Player extends SpriteAnimationComponent
    with HasGameReference<AstroPawsGame>, CollisionCallbacks {
  late Timer _shootTimer;
  SpriteAnimationComponent? _shieldComponent;
  late SpriteAnimation _shieldAnimation;
  final AudioManager audioManager = AudioManager();
  int hp = 3;

  Player(param0)
      : super(
    size: Vector2(70, 120),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Загружаем анимацию игрока
    animation = await game.loadSpriteAnimation(
      'player.png',
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.2,
        textureSize: Vector2(96, 96),
      ),
    );

    position = game.size / 2;

    // Таймер стрельбы
    _shootTimer = Timer(
      0.25,
      repeat: true,
      onTick: _spawnBullets,
      autoStart: false,
    );

    // Хитбокс
    add(RectangleHitbox());

    // Загружаем анимацию щита (не компонент)
    _shieldAnimation = await game.loadSpriteAnimation(
      'shield.png',
      SpriteAnimationData.sequenced(
        amount: 12,
        stepTime: 1,
        textureSize: Vector2(60, 60),
      ),
    );
  }

  void moveTo(Vector2 delta) {
    position.add(delta);
  }

  void startShooting() => _shootTimer.start();

  void stopShooting() => _shootTimer.stop();

  void _spawnBullets() {
    final shootingPosition = position + Vector2(0, -height / 2);
    game.add(Bullet(position: shootingPosition));

    if (game.hasKibble &&
        game.kibbleTime
            .isAfter(DateTime.now().subtract(const Duration(seconds: 20)))) {
      game.add(Bullet(position: shootingPosition, angleOffset: -0.2));
      game.add(Bullet(position: shootingPosition, angleOffset: 0.2));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _shootTimer.update(dt);


    // Ограничиваем игрока в пределах экрана
    position.clamp(
      Vector2(width / 2, height / 2),
      game.size - Vector2(width / 2, height / 2),
    );

    // ======== ЛОГИКА ЩИТА ========

    if (game.hasPawShield && _shieldComponent == null) {
      // Создаём компонент щита с анимацией
      _shieldComponent = SpriteAnimationComponent(
        animation: _shieldAnimation,
        size: Vector2(60, 60),
        anchor: Anchor.center,
        position: Vector2(size.x / 2, size.y / 2),
      )..opacity = 0; // начинаем с прозрачности 0

      add(_shieldComponent!);
    }

    // Если щит должен исчезнуть
    else if (!game.hasPawShield && _shieldComponent != null) {
      _shieldComponent!.removeFromParent();
      _shieldComponent = null;
    }

    // Обновляем позицию и эффект прозрачности, если щит активен
    if (_shieldComponent != null) {
      _shieldComponent!.position = Vector2(size.x / 2, size.y / 2);

      final double elapsed =
      DateTime.now().difference(game.pawShieldTime).inSeconds.toDouble();



      final double opacity = (1 - (elapsed / 10)).clamp(0, 1);
      _shieldComponent!.opacity = opacity;

      // Плавное появление щита (fade in)
      if (_shieldComponent!.opacity < 1 && elapsed < 1) {
        _shieldComponent!.opacity = elapsed;
      }

      // Если щит полностью потух — удаляем
      if (opacity <= 0) {
        _shieldComponent!.removeFromParent();
        _shieldComponent = null;
        game.hasPawShield = false;
      }
    }
  }
}