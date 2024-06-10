/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '/src/sokoban_view/components/grided.dart';

class PlayerShadow extends SpriteAnimationComponent
    with HasGameRef, GridElement {
  final String playerImg = 'bot_shadow_spritesheet.png';
  final double _animationSpeed = 0.1;

  late final SpriteAnimation _walkSouthAnim;
  late final SpriteAnimation _walkEastAnim;
  late final SpriteAnimation _walkNorthAnim;
  late final SpriteAnimation _walkWestAnim;
  late final SpriteAnimation _blink1Anim;
  late final SpriteAnimation _blink2Anim;
  late final SpriteAnimation _earWobble;
  late final SpriteAnimation _headSpin;
  late final SpriteAnimation _surprise;
  late final SpriteAnimation _idleWait;

  PlayerShadow(
    Vector2 playerSize,
    Vector2 playerPosition,
    Vector2 gridPos,
    Vector2 gridPixelDim,
    Vector2 gridPixelOff,
    int layerIdx,
  ) : super(size: Vector2.all(32.0)) {
    spriteSize = playerSize;
    spritePosition = playerPosition;
    gridPosition = gridPos;
    gridPixelDimensions = gridPixelDim;
    gridPixelOffset = gridPixelOff;
    layer = layerIdx;
  }

  @override
  Future<void> onLoad() async {
    await _loadAnimations().then((_) => {animation = _blink1Anim});

    position.add(Vector2(
        ((gridPosition.x * gridPixelDimensions.x) + gridPixelOffset.x),
        ((gridPosition.y * gridPixelDimensions.y) + gridPixelOffset.y)));
  }

  Future<void> _loadAnimations() async {
    final spriteSheet = SpriteSheet(
      image: game.images.fromCache(playerImg),
      srcSize: Vector2.all(32.0),
    );

    _walkNorthAnim =
        spriteSheet.createAnimation(row: 5, stepTime: _animationSpeed, to: 3);

    _walkWestAnim = spriteSheet.createAnimation(
        row: 6, stepTime: _animationSpeed, from: 3, to: 6);

    _walkEastAnim = spriteSheet.createAnimation(
        row: 5, stepTime: _animationSpeed, from: 3, to: 6);

    _walkSouthAnim =
        spriteSheet.createAnimation(row: 6, stepTime: _animationSpeed, to: 3);

    _blink1Anim =
        spriteSheet.createAnimation(row: 0, stepTime: _animationSpeed, to: 6);

    _blink2Anim = spriteSheet.createAnimation(
        row: 0, stepTime: _animationSpeed, from: 4, to: 9);

    _earWobble =
        spriteSheet.createAnimation(row: 1, stepTime: _animationSpeed, to: 6);

    _headSpin = spriteSheet.createAnimation(
        row: 3, stepTime: _animationSpeed / 1.5, to: 9);

    _surprise = spriteSheet.createAnimation(
        row: 4, stepTime: _animationSpeed / 1.5, to: 9);

    _idleWait =
        spriteSheet.createAnimation(row: 0, stepTime: 3.0, from: 3, to: 4);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (getLayeredGridValue() != priority) {
      priority = getLayeredGridValue();
    }
  }

  void setAnimation(String anim) {
    animation = switch (anim) {
      '_walkSouthAnim' => _walkSouthAnim,
      '_walkEastAnim' => _walkEastAnim,
      '_walkNorthAnim' => _walkNorthAnim,
      '_walkWestAnim' => _walkWestAnim,
      '_blink1Anim' => _blink1Anim,
      '_blink2Anim' => _blink2Anim,
      '_earWobble' => _earWobble,
      '_headSpin' => _headSpin,
      '_surprise' => _surprise,
      '_idleWait' => _idleWait,
      _ => _idleWait,
    };
  }

  void setPosition(Vector2 pos) {
    position = pos;
  }

  void setGridPos(Vector2 gridPos) {
    gridPosition = gridPos;
  }
}
