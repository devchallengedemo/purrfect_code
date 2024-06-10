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

class BoxShadow extends SpriteAnimationComponent
    with HasGameRef, GridElement, HasVisibility {
  int spriteIndex = 0;

  final String boxImg = 'box_shadow_spritesheet.png';
  final String boxTeleportImg = 'box_teleport_shadow_spritesheet.png';

  late final SpriteAnimation _boxClosed;
  late final SpriteAnimation _boxOpenAnim;
  late final SpriteAnimation _boxOpen;
  late final SpriteAnimation _idle1Anim;
  late final SpriteAnimation _idle2Anim;
  late final SpriteAnimation _teleportAnim;

  BoxShadow(Vector2 boxSize, Vector2 boxPosition, Vector2 gridPos,
      Vector2 gridPixelDim, Vector2 gridPixelOff, int layerIdx, int spriteIdx)
      : super(
          size: Vector2(boxSize.x, boxSize.y),
        ) {
    spriteSize = boxSize;
    spritePosition = boxPosition;
    gridPosition = gridPos;
    gridPixelDimensions = gridPixelDim;
    gridPixelOffset = gridPixelOff;
    layer = 2;
    spriteIndex = spriteIdx;
  }

  @override
  Future<void> onLoad() async {
    await _loadAnimations().then((_) => {animation = _boxClosed});

    position.add(Vector2(
        ((gridPosition.x * gridPixelDimensions.x) + gridPixelOffset.x),
        ((gridPosition.y * gridPixelDimensions.y) + gridPixelOffset.y)));
    priority = getLayeredGridValue();
  }

  Future<void> _loadAnimations() async {
    var boxImage = game.images.fromCache(boxImg);
    var boxTeleportImage = game.images.fromCache(boxTeleportImg);

    final boxSpriteSheet = SpriteSheet(
      image: boxImage,
      srcSize: Vector2.all(32.0),
    );

    final teleportSpriteSheet = SpriteSheet(
      image: boxTeleportImage,
      srcSize: Vector2.all(32.0),
    );

    _boxClosed =
        boxSpriteSheet.createAnimation(row: spriteIndex, stepTime: 0.1, to: 1);

    _boxOpenAnim =
        boxSpriteSheet.createAnimation(row: spriteIndex, stepTime: 0.25, to: 6);

    _boxOpen = boxSpriteSheet.createAnimation(
        row: spriteIndex, stepTime: 0.25, from: 6, to: 7);

    _idle1Anim =
        boxSpriteSheet.createAnimation(row: 5, stepTime: 0.125, to: 10);

    _idle2Anim =
        boxSpriteSheet.createAnimation(row: 6, stepTime: 0.125, to: 11);

    _teleportAnim = teleportSpriteSheet.createAnimation(
        row: spriteIndex, stepTime: 0.125, to: 18);
  }

  @override
  void update(double dt) async {
    super.update(dt);

    if (getLayeredGridValue() != priority) {
      priority = getLayeredGridValue();
    }
  }

  void setAnimation(String anim) {
    animation = switch (anim) {
      '_boxClosed' => _boxClosed,
      '_boxOpenAnim' => _boxOpenAnim,
      '_boxOpen' => _boxOpen,
      '_idle1Anim' => _idle1Anim,
      '_idle2Anim' => _idle2Anim,
      '_teleportAnim' => _teleportAnim,
      '_boxCloseAnim' => _boxOpenAnim.reversed(),
      _ => _boxClosed
    };
  }

  void setPosition(Vector2 pos) {
    position = pos;
  }

  void setVisibillity(bool viz) {
    isVisible = viz;
  }

  void setGridPos(Vector2 gridPos) {
    gridPosition = gridPos;
  }
}
