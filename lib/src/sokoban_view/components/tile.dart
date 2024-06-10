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

class Tile extends SpriteComponent with HasGameRef, GridElement {
  final String spriteName;

  Tile(this.spriteName, tilePosition, tileSize, tileGridPosition, tileLayer)
      : super(
          size: Vector2(tileSize.x, tileSize.y),
        ) {
    spriteSize = tileSize;
    spritePosition = tilePosition;
    gridPosition = tileGridPosition;
    layer = tileLayer;
  }

  @override
  Future<void> onLoad() async {
    var img = game.images.fromCache(spriteName);
    sprite = Sprite(img);
    position = Vector2(
      (spritePosition.x * size.x),
      (spritePosition.y * size.y),
    );
    priority = getLayeredGridValue();
  }
}
