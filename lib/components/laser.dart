import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:astro_paws/components/enemy/enemy_base.dart';
import '../utils/assets.dart';
import '/astro_paws.dart';

class Laser extends SpriteComponent
    with HasGameReference<AstroPawsGame>
    , CollisionCallbacks {
  Laser({required super.position, super.angle = 0.0})
    : super(anchor: Anchor.center, priority: -1);

  @override
  FutureOr<void> onLoad() async {
    sprite = await game.loadSprite(Assets.assetsImagesLaser);
    size *= 0.25;
    add(RectangleHitbox());
    return super.onLoad();
  }

  @override
  void update(double dt) {
    position += Vector2(sin(angle), -cos(angle)) * 500 * dt;

    if (position.y < -size.y / 2) {
      removeFromParent();
    }
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is EnemyBase) {
      other.removeFromParent();
    }

  }
}
