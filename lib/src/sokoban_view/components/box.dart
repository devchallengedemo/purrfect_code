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

import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/sprite.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/animation.dart';

import '/src/helpers/enums.dart';
import '/src/log/log.dart';
import '/src/sokoban_view/components/grided.dart';
import '../../app_state.dart';
import 'box_shadow.dart';

enum BoxState { closed, goalHit, open, teleport, complete }

class Box extends SpriteAnimationComponent
    with HasGameRef, GridElement, HasVisibility {
  BoxState boxState = BoxState.closed;
  int spriteIndex = 0;
  double _timer = 0;
  double _nextIdle = 0;

  final String boxImg = 'box_spritesheet.png';
  final String boxTeleportImg = 'box_teleport_spritesheet.png';

  late BoxShadow shadow;
  late final SpriteAnimation _boxClosed;
  late final SpriteAnimation _boxOpenAnim;
  late final SpriteAnimation _boxOpen;
  late final SpriteAnimation _idle1Anim;
  late final SpriteAnimation _idle2Anim;
  late final SpriteAnimation _teleportAnim;
  late final AudioPool _audioPool;

  Box(
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
    _audioPool = await FlameAudio.createPool('catscored.mp3', maxPlayers: 4);
    await _loadAnimations().then((_) => {animation = _boxClosed});

    position.add(getPosition());
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

    var random = Random();
    spriteIndex = random.nextInt(5);

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

    var randomNumber = random.nextDouble() * 3.0;
    _nextIdle = 1.0 + randomNumber;
  }

  @override
  void update(double dt) async {
    super.update(dt);

    if (getLayeredGridValue() != priority) {
      priority = getLayeredGridValue();
    }

    _timer += dt;

    if (boxState == BoxState.closed) {
      if (_timer > _nextIdle) {
        if (animation != _boxClosed) {
          var random = Random();
          var randomNumber = random.nextDouble() * 6.0;
          _nextIdle = 6.0 + randomNumber;
          animation = _boxClosed;
          shadow.setAnimation('_boxClosed');
          _timer = 0;
        } else {
          _timer = 0;
          var random = Random();
          var randomNumber = random.nextInt(2);
          animation = randomNumber == 0 ? _idle1Anim : _idle2Anim;
          shadow.setAnimation(randomNumber == 0 ? '_idle1Anim' : '_idle2Anim');
          _nextIdle = randomNumber == 0 ? 1.25 : 1.375;
        }
      }
    }

    if (boxState == BoxState.goalHit) {
      if (_timer > 0.5) {
        animation = _boxOpenAnim;
        shadow.setAnimation('_boxOpenAnim');
      }
      if (_timer > 1.25 && animation == _boxOpenAnim) {
        _audioPool.start(volume: appState.volume).ignore();
        animation = _boxOpen;
        shadow.setAnimation('_boxOpen');
        boxState = BoxState.open;
      }
    }

    if (boxState == BoxState.teleport) {
      if (_timer > 2.25) {
        isVisible = false;
      }
    }

    shadow.setPosition(position);
    shadow.setVisibillity(isVisible);
    shadow.setGridPos(gridPosition);
  }

  void _moveEast() {
    gridPosition = Vector2(gridPosition.x + 1, gridPosition.y);
    add(MoveEffect.by(
        Vector2(gridPixelDimensions.x, 0),
        EffectController(
          duration: 0.5,
          curve: Curves.linear,
        )));
  }

  void _moveWest() {
    gridPosition = Vector2(gridPosition.x - 1, gridPosition.y);
    add(MoveEffect.by(
        Vector2(-gridPixelDimensions.x, 0),
        EffectController(
          duration: 0.5,
          curve: Curves.linear,
        )));
  }

  void _moveNorth() {
    gridPosition = Vector2(gridPosition.x, gridPosition.y - 1);
    add(MoveEffect.by(
        Vector2(0, -gridPixelDimensions.y),
        EffectController(
          duration: 0.5,
          curve: Curves.linear,
        )));
  }

  void _moveSouth() {
    gridPosition = Vector2(gridPosition.x, gridPosition.y + 1);
    add(MoveEffect.by(
        Vector2(0, gridPixelDimensions.y),
        EffectController(
          duration: 0.5,
          curve: Curves.linear,
        )));
  }

  void moveBox(Direction dir, bool goalHit) {
    if (goalHit) {
      boxState = BoxState.goalHit;
      _timer = 0;
    } else {
      if (boxState == BoxState.open) {
        animation = _boxOpenAnim.reversed();
        shadow.setAnimation('_boxCloseAnim');
        _timer = 0;
        _nextIdle = 0.5;
      }
      boxState = BoxState.closed;
    }
    switch (dir) {
      case Direction.north:
        _moveNorth();
        break;
      case Direction.south:
        _moveSouth();
        break;
      case Direction.east:
        _moveEast();
        break;
      case Direction.west:
        _moveWest();
        break;
      default:
        logger.e('Not implemented in box::moveBox');
        break;
    }
  }

  void teleport() {
    _timer = 0;

    if (boxState == BoxState.closed) {
      boxState = BoxState.goalHit;
    }

    if (boxState == BoxState.open) {
      boxState = BoxState.teleport;
      animation = _teleportAnim;
      shadow.setAnimation('_teleportAnim');
    }
  }
}
