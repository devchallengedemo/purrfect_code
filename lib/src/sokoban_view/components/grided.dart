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

import 'package:flame/game.dart';

mixin GridElement {
  late Vector2 spriteSize;
  late Vector2 spritePosition;
  late Vector2 gridPosition;
  late Vector2 gridPixelDimensions; //16,14
  late Vector2 gridPixelOffset; //17,22
  late int layer;

  getPosition() => Vector2(
      ((gridPosition.x * gridPixelDimensions.x) + gridPixelOffset.x),
      ((gridPosition.y * gridPixelDimensions.y) + gridPixelOffset.y));
  getGridValue() => ((gridPosition.y * 13.0) + gridPosition.x);
  getLayeredGridValue() => getGridValue() + (layer * 200);
}
