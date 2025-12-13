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
  int hp = 100;

  Player()
      : super(
    size: Vector2(75, 100),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      game.selectedSkin,
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.2,
        textureSize: Vector2(96, 96),
      ),
    );

    position = game.size / 2;

    // Хитбокс (один, точный)
    add(RectangleHitbox.relative(
      Vector2(0.7, 0.8),
      parentSize: size,
      anchor: Anchor.center,
    ));

    _shootTimer = Timer(0.25, repeat: true, onTick: _spawnBullets);

    _shieldAnimation = await game.loadSpriteAnimation(
      'shield.png',
      SpriteAnimationData.sequenced(
        amount: 12,
        stepTime: 1,
        textureSize: Vector2(60, 60),
      ),
    );
  }

  void moveTo(Vector2 delta) => position.add(delta);


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

    position.clamp(
      Vector2(width / 2, height / 2),
      game.size - Vector2(width / 2, height / 2),
    );
  }
}
