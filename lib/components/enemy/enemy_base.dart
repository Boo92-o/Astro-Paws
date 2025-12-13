import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '/components/player.dart';
import '/astro_paws.dart';
import 'dart:async';
import '../bullet.dart';
import '../explosion.dart';

enum EnemyType { one, two, three, four }

class EnemyBase extends SpriteAnimationComponent
    with HasGameReference<AstroPawsGame>, CollisionCallbacks {
  final double enemySize;
  int enemyLife;
  final String enemySpritePath;
  final EnemyType enemySpeed;
  final bool enemyNeedsAnimation;
  bool _canDealDamage = true;
  final double damageCooldown = 1.0;
  final int damageAmount = 20;

  EnemyBase({
    super.position,
    required this.enemySize,
    required this.enemyLife,
    required this.enemySpritePath,
    required this.enemySpeed,
    this.enemyNeedsAnimation = true,
  }) : super(size: Vector2.all(enemySize), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    if (enemyNeedsAnimation) {
      animation = await game.loadSpriteAnimation(
        enemySpritePath,
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.5,
          textureSize: Vector2(62, 62),
        ),
      );
    } else {
      animation = SpriteAnimation.spriteList(
        [await game.loadSprite(enemySpritePath)],
        stepTime: double.infinity,
      );
    }

    add(RectangleHitbox.relative(
      Vector2(0.8, 0.8),
      parentSize: size,
      anchor: Anchor.center,
    ));
  }

  double get speed {
    switch (enemySpeed) {
      case EnemyType.one:
        return 60;
      case EnemyType.two:
        return 120;
      case EnemyType.three:
        return 180;
      case EnemyType.four:
        return 240;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += dt * speed;
    if (position.y > game.size.y) removeFromParent();
  }

  @override
  void onCollision(Set<Vector2> _, PositionComponent other) {
    if (other is Player && _canDealDamage) {
      game.PlayerHP -= damageAmount;
      game.audioManager?.playSound('explode1.ogg');
      if (game.PlayerHP <= 0) {
        game.gameOver();
      }

      _canDealDamage = false;
      Future.delayed(const Duration(seconds: 1), () {
        _canDealDamage = true;
      });
    }

    if (other is Bullet && position.y > 8) {
      enemyLife -= 1;
      other.removeFromParent();
      if (enemyLife <= 0) {
        removeFromParent();
        game.add(Explosion(position: position));
        game.audioManager?.playSound('explode2.ogg');
        game.currentScore++;
      }
    }

    super.onCollision(_, other);
  }
}
