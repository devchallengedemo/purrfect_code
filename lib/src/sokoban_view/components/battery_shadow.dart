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
import '/src/sokoban_view/components/grided.dart';

class BatteryShadow extends SpriteComponent
    with HasGameRef, GridElement, HasVisibility {
  int spriteIndex = 0;
  final String batteryShadowImg = 'battery_shadow.png';

  BatteryShadow(
    Vector2 boxSize,
    Vector2 boxPosition,
    Vector2 gridPos,
    Vector2 gridPixelDim,
    Vector2 gridPixelOff,
    int layerIdx,
  ) : super(
          size: Vector2(boxSize.x, boxSize.y),
        ) {
    spriteSize = boxSize;
    spritePosition = boxPosition;
    gridPosition = gridPos;
    gridPixelDimensions = gridPixelDim;
    gridPixelOffset = gridPixelOff;
    layer = 2;
  }

  @override
  Future<void> onLoad() async {
    var img = game.images.fromCache(batteryShadowImg);
    sprite = Sprite(img);
    position.add(Vector2(
        ((gridPosition.x * gridPixelDimensions.x) + gridPixelOffset.x),
        ((gridPosition.y * gridPixelDimensions.y) + gridPixelOffset.y)));
    priority = getLayeredGridValue();
  }
}
