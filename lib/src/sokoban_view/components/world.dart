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
import 'package:flutter/services.dart';

import '/src/app_state.dart';
import '/src/helpers/enums.dart';
import '/src/log/log.dart';
import '/src/sokoban_view/components/battery.dart';
import '/src/sokoban_view/components/box.dart';
import '/src/sokoban_view/components/box_shadow.dart';
import '/src/sokoban_view/components/player.dart';
import '/src/sokoban_view/components/player_shadow.dart';
import 'battery_shadow.dart';
import 'level_data_bundle.dart';
import 'tile.dart';

class SokobanWorld extends World with HasGameRef {
  List<Tile> tiles = [];
  List<Box> boxes = [];
  List<Battery> batteries = [];
  late Player player;
  Vector2 size = Vector2.all(0);

  @override
  Future<void> onLoad() async {
    var levelIdx = appState.getLevel();
    var response = await readJson(getLevelUri(levelIdx));

    if (response.isEmpty) {
      logger.e('Failed To Retrieve Json Level');
      return;
    }

    var level = LevelDataBundle(response);
    var levelImages = List<LevelImage>.from(level.levelImages);

    for (var index = 0; index < levelImages.length; index++) {
      //eventually this becomes two passes for shadow tiles...
      var li = levelImages[index];
      var dimensions = Vector2(li.imgWidth * 1.0, li.imgHeight * 1.0);

      if (li.type == 'tile') {
        var tile = Tile(
            li.imgName,
            Vector2(
                li.xPos * (1.0 / dimensions.x), li.yPos * (1.0 / dimensions.y)),
            dimensions,
            Vector2(li.gridXPos * 1.0, li.gridYPos * 1.0),
            li.layer);
        tiles.add(tile);
        add(tile);
      } else if (li.type == 'box') {
        var box = Box(
          Vector2.all(32.0),
          Vector2(li.xPos * 1.0, li.yPos * 1.0),
          Vector2(li.gridXPos * 1.0, li.gridYPos * 1.0),
          Vector2(16.0, 14.0),
          Vector2(16.0, 22.0),
          3,
        );
        boxes.add(box);
        add(box);
        var shadow = BoxShadow(
            Vector2.all(32.0),
            Vector2(li.xPos * 1.0, li.yPos * 1.0),
            Vector2(li.gridXPos * 1.0, li.gridYPos * 1.0),
            Vector2(16.0, 14.0),
            Vector2(16.0, 18.0),
            2,
            box.spriteIndex);
        add(shadow);
        box.shadow = shadow;
      } else if (li.type == 'player') {
        player = Player(
          Vector2.all(32.0),
          Vector2(li.xPos * 1.0, li.yPos * 1.0),
          Vector2(li.gridXPos * 1.0, li.gridYPos * 1.0),
          Vector2(16.0, 14.0),
          Vector2(16.0, 22.0),
          3,
        );
        add(player);

        var shadow = PlayerShadow(
          Vector2.all(32.0),
          Vector2(li.xPos * 1.0, li.yPos * 1.0),
          Vector2(li.gridXPos * 1.0, li.gridYPos * 1.0),
          Vector2(16.0, 14.0),
          Vector2(16.0, 22.0),
          2,
        );
        add(shadow);
        player.shadow = shadow;
      } else if (li.type == 'coin') {
        var battery = Battery(
          Vector2.all(32.0),
          Vector2(li.xPos * 1.0, li.yPos * 1.0),
          Vector2(li.gridXPos * 1.0, li.gridYPos * 1.0),
          Vector2(16.0, 14.0),
          Vector2(17.0, 17.0),
          4,
        );
        add(battery);
        batteries.add(battery);

        var shadow = BatteryShadow(
          Vector2.all(32.0),
          Vector2(li.xPos * 1.0, li.yPos * 1.0),
          Vector2(li.gridXPos * 1.0, li.gridYPos * 1.0),
          Vector2(16.0, 14.0),
          Vector2(16.0, 25.0),
          2,
        );
        add(shadow);
        battery.shadow = shadow;
      } else {
        continue;
      }
    }
    return super.onLoad();
  }

  Future<String> readJson(String location) async {
    var response = await rootBundle.loadString(location);
    return response.isEmpty ? '' : response;
  }

  String getLevelUri(int levelIdx) {
    var result = switch (levelIdx) {
      1 => 'assets/level_visual/level01_viz.json',
      2 => 'assets/level_visual/level02_viz.json',
      3 => 'assets/level_visual/level03_viz.json',
      4 => 'assets/level_visual/level04_viz.json',
      5 => 'assets/level_visual/level05_viz.json',
      _ => '',
    };
    return result;
  }

  void moveBox(String moveCommand) {
    var split = moveCommand.split(' ');

    for (var idx = 0; idx < boxes.length; idx++) {
      var box = boxes[idx];
      var initialIdx = int.parse(split[1]);
      var nextIdx = int.parse(split[2]);
      var goalHit = bool.parse(split[3]);
      var gridValue = box.getGridValue();

      logger.i('box $idx $gridValue');
      if (gridValue == initialIdx) {
        logger.i('box moving $initialIdx $nextIdx');
        if (nextIdx < (initialIdx - 1)) {
          box.moveBox(Direction.north, goalHit);
        } else if (nextIdx == (initialIdx - 1)) {
          box.moveBox(Direction.west, goalHit);
        } else if (nextIdx == (initialIdx + 1)) {
          box.moveBox(Direction.east, goalHit);
        } else if (nextIdx > (initialIdx + 1)) {
          box.moveBox(Direction.south, goalHit);
        }
        break;
      }
    }
  }

  void removeBattery(String command) {
    var split = command.split(' ');
    var initialIdx = int.parse(split[1]);

    for (var idx = 0; idx < batteries.length; idx++) {
      var battery = batteries[idx];
      var gridValue = battery.getGridValue();

      if (gridValue == initialIdx) {
        battery.hide();
      }
    }
  }

  void teleport() {
    for (var idx = 0; idx < boxes.length; idx++) {
      boxes[idx].teleport();
    }
  }
}
