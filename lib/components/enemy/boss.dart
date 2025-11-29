import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '/astro_paws.dart';
import '../bullet.dart';
import '../explosion.dart';

class Boss extends SpriteComponent with HasGameReference<AstroPawsGame>, CollisionCallbacks {
  int health = 30;
  bool movingRight = true;
  double speed = 50;
  late Timer _attackTimer;

  Boss() : super(
    size: Vector2(120, 120),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await game.loadSprite('boss1.png');
    position = Vector2(game.size.x / 2, -100);

    // Таймер для атак
    _attackTimer = Timer(2.0, repeat: true, onTick: _shootAtPlayer);
    _attackTimer.start();

    add(RectangleHitbox());
  }

  void _shootAtPlayer() {
    // Простая атака - две пули по бокам
    final leftBullet = Bullet(
      position: position + Vector2(-40, 40),
      isEnemyBullet: true,
    );

    final rightBullet = Bullet(
      position: position + Vector2(40, 40),
      isEnemyBullet: true,
    );

    game.add(leftBullet);
    game.add(rightBullet);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _attackTimer.update(dt);

    // Движение из стороны в сторону
    if (movingRight) {
      position.x += speed * dt;
      if (position.x > game.size.x - width / 2) {
        movingRight = false;
      }
    } else {
      position.x -= speed * dt;
      if (position.x < width / 2) {
        movingRight = true;
      }
    }

    // Плавное появление сверху
    if (position.y < 100) {
      position.y += 30 * dt;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Bullet) {
      // Проверяем, что это пуля игрока (не вражеская)
      if (!other.isEnemyBullet) {
        game.BossHp --;
        other.removeFromParent();

        if (game.BossHp <= 0) {
          removeFromParent();
          game.add(Explosion(position: position));
          game.currentScore += 300;

          // Вызываем метод завершения боя
          if (game is AstroPawsGame) {
            (game as AstroPawsGame).onBossDefeated();
          }
        }
      }
    }
    super.onCollision(intersectionPoints, other);
  }
}