import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import '/astro_paws.dart';

/// Интерфейс для отображения жизни игрока.
/// Добавляется в игру как компонент HUD.
class HealthBarInterface extends PositionComponent
    with HasGameReference<AstroPawsGame> {
  double _maxHealth = 100;
  double _currentHealth = 100;

  // Фон и прогресс полосы
  late final RectangleComponent _backgroundBar;
  late final RectangleComponent _healthBar;
  late final TextComponent _textComponent;

  HealthBarInterface({
    double maxHealth = 100,
  }) : _maxHealth = maxHealth {
    size = Vector2(200, 20);
    position = Vector2(20, 20); // позиция HUD в верхнем левом углу
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Фон (тёмно-серый)
    _backgroundBar = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.grey.shade800,
    );

    // Прогресс здоровья (зелёный)
    _healthBar = RectangleComponent(
      size: Vector2(size.x, size.y),
      paint: Paint()..color = Colors.greenAccent,
    );

    // Текст (число HP)
    _textComponent = TextComponent(
      text: 'HP: $_currentHealth',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontFamily: 'RobotoMono',
        ),
      ),
      position: Vector2(0, -18),
    );

    add(_backgroundBar);
    add(_healthBar);
    add(_textComponent);
  }

  /// Обновляем значение HP
  void updateHealth(double currentHealth) {
    _currentHealth = currentHealth.clamp(0, _maxHealth);
    final double healthPercent = _currentHealth / _maxHealth;

    _healthBar.size = Vector2(size.x * healthPercent, size.y);

    // Меняем цвет в зависимости от процента HP
    if (healthPercent > 0.5) {
      _healthBar.paint.color = Colors.greenAccent;
    } else if (healthPercent > 0.25) {
      _healthBar.paint.color = Colors.orangeAccent;
    } else {
      _healthBar.paint.color = Colors.redAccent;
    }

    _textComponent.text = 'HP: ${_currentHealth.toInt()}';
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Автоматически синхронизируем с HP игрока из AstroPawsGame
    updateHealth(game.PlayerHP.toDouble());
  }
}
