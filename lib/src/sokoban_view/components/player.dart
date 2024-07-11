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

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/sprite.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/animation.dart';

import '/src/helpers/enums.dart';
import '/src/sokoban_view/components/grided.dart';
import '/src/sokoban_view/components/player_shadow.dart';
import '../../app_state.dart';

class Player extends SpriteAnimationComponent with HasGameRef, GridElement {
  final String playerImg = 'bot_spritesheet.png';
  final double _animationSpeed = 0.1;
  final double _walkAnimDuration = 0.5;
  late PlayerShadow shadow;

  Direction _direction = Direction.none;
  double idleSwitchTime = -1.0;

  late final SpriteAnimation _walkSouthAnim;
  late final SpriteAnimation _walkEastAnim;
  late final SpriteAnimation _walkNorthAnim;
  late final SpriteAnimation _walkWestAnim;
  late final SpriteAnimation _blink1Anim;
  late final SpriteAnimation _blink2Anim;
  late final SpriteAnimation _earWobble;
  //late final SpriteAnimation _headTilt; //failure!
  late final SpriteAnimation _headSpin; //victory!
  late final SpriteAnimation _surprise; //error!
  late final SpriteAnimation _idleWait;
  late final AudioPool _audioPool;

  Player(
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
    _audioPool = await FlameAudio.createPool('walk.mp3', maxPlayers: 4);
    await _loadAnimations().then((_) => {animation = _blink1Anim});

    position.add(Vector2(
        (gridPosition.x * gridPixelDimensions.x) + gridPixelOffset.x,
        (gridPosition.y * gridPixelDimensions.y) + gridPixelOffset.y));
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

    //_headTilt =
    //    spriteSheet.createAnimation(row: 2, stepTime: _animationSpeed/1.5, to: 9);

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

    if (_direction != Direction.none) {
      animation = switch (_direction) {
        Direction.north => _walkNorthAnim,
        Direction.south => _walkSouthAnim,
        Direction.east => _walkEastAnim,
        Direction.west => _walkWestAnim,
        _ => _idleWait
      };

      var nextDir = switch (_direction) {
        Direction.north => '_walkNorthAnim',
        Direction.south => '_walkSouthAnim',
        Direction.east => '_walkEastAnim',
        Direction.west => '_walkWestAnim',
        _ => '_idleWait'
      };
      shadow.setAnimation(nextDir);
    } else {
      if (idleSwitchTime < 0) {
        if (animation == _blink1Anim ||
            animation == _blink2Anim ||
            animation == _earWobble) {
          var random = Random();
          var randomNumber = random.nextDouble() * 2.0;
          idleSwitchTime = 0.75 + randomNumber;
          animation = _idleWait;
          shadow.setAnimation('_idleWait');
        } else {
          idleSwitchTime = 0.5;
          var random = Random();
          var randomNumber = random.nextInt(3);
          var animList = [_blink1Anim, _blink2Anim, _earWobble];
          animation = animList[randomNumber];
          var animNameList = ['_blink1Anim', '_blink2Anim', '_earWobble'];
          shadow.setAnimation(animNameList[randomNumber]);
        }
      }
      idleSwitchTime -= dt;
    }

    shadow.setPosition(position);
    shadow.setGridPos(gridPosition);
  }

  void _moveWest() {
    gridPosition = Vector2(gridPosition.x - 1, gridPosition.y);
    _direction = Direction.west;
    add(MoveEffect.by(
        Vector2(-gridPixelDimensions.x, 0),
        EffectController(
          duration: _walkAnimDuration,
          curve: Curves.linear,
        )));
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      _direction = Direction.none;
    });
  }

  void _moveEast() {
    gridPosition = Vector2(gridPosition.x + 1, gridPosition.y);
    _direction = Direction.east;
    add(MoveEffect.by(
        Vector2(gridPixelDimensions.x, 0),
        EffectController(
          duration: _walkAnimDuration,
          curve: Curves.linear,
        )));
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      _direction = Direction.none;
    });
  }

  void _moveSouth() {
    gridPosition = Vector2(gridPosition.x, gridPosition.y + 1);
    _direction = Direction.south;
    add(MoveEffect.by(
        Vector2(0, gridPixelDimensions.y),
        EffectController(
          duration: _walkAnimDuration,
          curve: Curves.linear,
        )));
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      _direction = Direction.none;
    });
  }

  void _moveNorth() {
    gridPosition = Vector2(gridPosition.x, gridPosition.y - 1);
    _direction = Direction.north;
    add(MoveEffect.by(
        Vector2(0, -gridPixelDimensions.y),
        EffectController(
          duration: _walkAnimDuration,
          curve: Curves.linear,
        )));
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      _direction = Direction.none;
    });
  }

  void movePlayer(String moveCommand) {
    _audioPool.start(volume: appState.volume);
    var split = moveCommand.split(' ');
    var nextGridPosition =
        Vector2(double.parse(split[1]), double.parse(split[2]));
    if (nextGridPosition.y < gridPosition.y) {
      _moveNorth();
    } else if (nextGridPosition.y > gridPosition.y) {
      _moveSouth();
    } else if (nextGridPosition.x < gridPosition.x) {
      _moveWest();
    } else if (nextGridPosition.x > gridPosition.x) {
      _moveEast();
    }
    gridPosition = nextGridPosition;
  }

  void victory() {
    idleSwitchTime = 0.65;
    animation = _surprise;
    shadow.setAnimation('_surprise');
  }

  void failure() {
    idleSwitchTime = 5.0;
    animation = _headSpin;
    shadow.setAnimation('_headSpin');
  }
}
