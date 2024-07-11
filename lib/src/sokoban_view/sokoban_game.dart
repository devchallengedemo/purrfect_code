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

import 'dart:convert';

import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

import '/src/app_state.dart';
import '/src/log/log.dart';
import 'components/world.dart';

class SokobanGame extends FlameGame {
  SokobanWorld _world = SokobanWorld();
  late final ValueChanged<bool> onGameEnd;
  bool _cancel = false;

  SokobanGame(ValueChanged<bool> gameEndCallback) : super() {
    onGameEnd = gameEndCallback;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    await FlameAudio.audioCache.loadAll([
      'catscored.mp3',
      'catteleport.mp3',
      'start.mp3',
      'victory.mp3',
      'walk.mp3',
    ]);

    await images.loadAll([
      'android_statue_left.png',
      'android_statue_right.png',
      'android_statue_shadow.png',
      'backwall_01.png',
      'backwall_02.png',
      'backwall_03.png',
      'backwall_04.png',
      'backwall_05.png',
      'battery_shadow.png',
      'battery_spritesheet.png',
      'bookcase_1_lefthalf.png',
      'bookcase_1_righthalf.png',
      'bookcase_2_lefthalf.png',
      'bookcase_2_righthalf.png',
      'bookcase_shadow.png',
      'bot_spritesheet.png',
      'bot_shadow_spritesheet.png',
      'box_spritesheet.png',
      'box_shadow_spritesheet.png',
      'box_teleport_spritesheet.png',
      'box_teleport_shadow_spritesheet.png',
      'button_down.png',
      'button_up_shadow.png',
      'button_up.png',
      'cat_1.png',
      'cat_2.png',
      'cat_3.png',
      'cat_4.png',
      'cat_5.png',
      'cone_croppedside.png',
      'cone_shadow.png',
      'cone_whole.png',
      'decal_0.png',
      'decal_1.png',
      'decal_2.png',
      'decal_3.png',
      'decal_4.png',
      'decal_5.png',
      'desk_lefthalf.png',
      'desk_righthalf.png',
      'desk_shadow.png',
      'floor_0_grid_ref.png',
      'floor_0.png',
      'floor_01.png',
      'floor_02.png',
      'floor_03.png',
      'floor_04.png',
      'floor_05.png',
      'floor_button_down.png',
      'floor_button_up_shadow.png',
      'floor_button_up.png',
      'floor_decal_0.png',
      'floor_decal_1.png',
      'floor_decal_2.png',
      'floor_decal_3.png',
      'floor_decal_4.png',
      'floor_decal_5.png',
      'floor.png',
      'front_wall.png',
      'low_wall_shadow.png',
      'low_wall.png',
      'lowwall_0.png',
      'lowwall_0s.png',
      'lowwall_1.png',
      'lowwall_1s.png',
      'lowwall_2.png',
      'lowwall_2s.png',
      'lowwall_3.png',
      'lowwall_3s.png',
      'lowwall_4.png',
      'lowwall_4s.png',
      'lowwall_5.png',
      'lowwall_5s.png',
      'lowwall_6.png',
      'lowwall_6s.png',
      'lowwall_h1.png',
      'lowwall_h1s.png',
      'lowwall_h2.png',
      'lowwall_h2s.png',
      'lowwall_h3.png',
      'lowwall_h3s.png',
      'lowwall_v1.png',
      'lowwall_v1s.png',
      'lowwall_v2.png',
      'lowwall_v2s.png',
      'lowwall_v3.png',
      'lowwall_v3s.png',
      'monitor_1.png',
      'monitor_2.png',
      'monitor_3.png',
      'monitor_4.png',
      'monitor_5.png',
      'monitor_6.png',
      'monitor_7.png',
      'monitor_8.png',
      'monitor_transition_frame.png',
      'obstacle_android_statue_left.png',
      'obstacle_android_statue_right.png',
      'obstacle_android_statue_shadow.png',
      'obstacle_bookcase_1_lefthalf.png',
      'obstacle_bookcase_1_righthalf.png',
      'obstacle_bookcase_2_lefthalf.png',
      'obstacle_bookcase_2_righthalf.png',
      'obstacle_bookcase_shadow-v2.png',
      'obstacle_chair_shadow.png',
      'obstacle_chair.png',
      'obstacle_cone_croppedside.png',
      'obstacle_cone_shadow.png',
      'obstacle_cone_whole.png',
      'obstacle_desk_lefthalf.png',
      'obstacle_desk_righthalf.png',
      'obstacle_desk_shadow.png',
      'obstacle_plant_1_shadow.png',
      'obstacle_plant_1.png',
      'obstacle_plant_2_shadow.png',
      'obstacle_plant_2.png',
      'obstacle_trashcan_1.png',
      'obstacle_trashcan_2.png',
      'obstacle_trashcan_3.png',
      'obstacle_trashcan_shadow.png',
      'plant_1_shadow.png',
      'plant_1.png',
      'shadow_e.png',
      'shadow_n.png',
      'shadow_ne.png',
      'shadow_nw.png',
      'shadow_s.png',
      'shadow_se.png',
      'shadow_sw.png',
      'shadow_w.png',
      'trashcan_1.png',
      'trashcan_2.png',
      'trashcan_3.png',
      'trashcan_shadow.png',
      'walk_s_spritesheet.png',
      'walls_behind.png',
      'walls_front.png',
    ]);
    camera = CameraComponent.withFixedResolution(width: 256, height: 240);
    camera.world = _world;
    camera.moveTo(Vector2(128, 120));
    add(_world);
  }

  void reset() async {
    _cancel = true;
    camera.world = null;
    remove(_world);
    camera = CameraComponent.withFixedResolution(width: 256, height: 240);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _world = SokobanWorld();
    camera.world = _world;
    camera.moveTo(Vector2(128, 120));
    add(_world);
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    _cancel = false;
  }

  void setZoom(double zoomValue) {
    camera.viewfinder.zoom = zoomValue;
  }

  void parseCommandQueue(String queue) {
    var ls = const LineSplitter();
    processList(ls.convert(queue));
  }

  void processList(List<String> commandSet) async {
    FlameAudio.play('start.mp3', volume: appState.volume);
    var perMoveTimeMs = 500;
    var moveSpeed = Duration(milliseconds: perMoveTimeMs);
    await Future<void>.delayed(const Duration(milliseconds: 2050));

    for (var i = 0; i < commandSet.length; i++) {
      logger.i(commandSet[i]);

      if (_cancel) {
        break;
      } else if (commandSet[i].contains('step')) {
        await Future<void>.delayed(moveSpeed);
      } else if (commandSet[i].contains('Player')) {
        movePlayer(commandSet[i]);
      } else if (commandSet[i].contains('Box')) {
        moveBox(commandSet[i]);
      } else if (commandSet[i].contains('Battery')) {
        removeBattery(commandSet[i]);
      } else if (commandSet[i].contains('teleport')) {
        //wait to teleport
        await Future<void>.delayed(const Duration(milliseconds: 1500));
        FlameAudio.play('catteleport.mp3', volume: appState.volume);
        teleport();
      } else if (commandSet[i].contains('Victory')) {
        victory();
      } else if (commandSet[i].contains('Failed')) {
        failed();
      }
    }
  }

  void movePlayer(String moveCommand) {
    _world.player.movePlayer(moveCommand);
  }

  void moveBox(String moveCommand) {
    _world.moveBox(moveCommand);
  }

  void removeBattery(String moveCommand) {
    _world.removeBattery(moveCommand);
  }

  void teleport() {
    _world.teleport();
  }

  Future<void> victory() async {
    _world.player.victory();
    await Future<void>.delayed(const Duration(milliseconds: 2000), () {
      FlameAudio.play('victory.mp3', volume: appState.volume);
      onGameEnd(true);
      appState.setState(AppCurrentState.loaded);
    });
  }

  Future<void> failed() async {
    _world.player.failure();
    await Future<void>.delayed(const Duration(milliseconds: 2000), () {
      onGameEnd(false);
      appState.setState(AppCurrentState.loaded);
    });
  }
}
