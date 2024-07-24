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
import 'package:flame_audio/flame_audio.dart';
import '../../app_state.dart';
import '/src/sokoban_view/components/grided.dart';
import 'battery_shadow.dart';

class Battery extends SpriteAnimationComponent
    with HasGameRef, GridElement, HasVisibility {
  final String batteryImg = 'battery_spritesheet.png';
  late final SpriteAnimation _idleAnim;
  late final BatteryShadow shadow;
  late final AudioPool _audioPool;

  Battery(
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
    layer = layerIdx;
  }

  @override
  Future<void> onLoad() async {
    _audioPool = await FlameAudio.createPool('battery.mp3', maxPlayers: 2);
    await _loadAnimations().then((_) => {animation = _idleAnim});

    position.add(getPosition());
  }

  Future<void> _loadAnimations() async {
    var batteryImage = game.images.fromCache(batteryImg);

    final batterySpriteSheet = SpriteSheet(
      image: batteryImage,
      srcSize: Vector2.all(32.0),
    );

    _idleAnim = batterySpriteSheet.createAnimation(row: 0, stepTime: 0.1);
  }

  @override
  void update(double dt) async {
    super.update(dt);
    if (getLayeredGridValue() != priority) {
      priority = getLayeredGridValue();
    }
  }

  void hide() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _audioPool.start(volume: appState.volume);
      isVisible = false;
      shadow.isVisible = false;
    });
  }
}
