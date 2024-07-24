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

import '/src/helpers/enums.dart';
import '/src/log/log.dart';
import '/src/sokoban_view/sokoban_game.dart';
import 'level.dart';
import 'level_tile.dart';
import 'player.dart';

class GameManager {
  Level? level;
  Player? player;
  int steps = 0;
  String commandQueue = '';
  late final SokobanGame game;

  void setGameReference(SokobanGame ref) => game = ref;

  List<LevelTile> processLevelTilesFromJson(dynamic levelArray) {
    var data = List<int>.from(levelArray as List);
    var result = <LevelTile>[];
    for (var index = 0; index < data.length; index++) {
      var levelTile = LevelTile(data[index] == 0 ? false : true);
      levelTile.goal = data[index] & 2 == 2;
      levelTile.box = data[index] & 4 == 4;
      levelTile.coin = data[index] & 8 == 8;
      levelTile.door = data[index] & 16 == 16;

      result.add(levelTile);
    }
    return result;
  }

  void createLevel(String name, int height, int width, int playerStartX,
      int playerStartY, List<LevelTile> tiles) {
    player = Player(playerStartX, playerStartY);
    level = Level(name, height, width);
    level!.levelTiles.clear();
    level!.levelTiles.addAll(tiles);
  }

  void resetLevel() {
    level = null;
    player = null;
    steps = 0;
    commandQueue = '';
  }

  void move(Direction dir) {
    switch (dir) {
      case Direction.north:
        _moveNorth();
      case Direction.south:
        _moveSouth();
      case Direction.east:
        _moveEast();
      case Direction.west:
        _moveWest();
      default:
        throw UnimplementedError();
    }
    steps++;
    commandQueue += 'step $steps\n';
  }

  void _moveNorth() {
    //early out if at the top of the map
    if (player?.yPos == 0) return;

    var playerTileIdx = (player!.yPos * level!.width) + player!.xPos;
    var northTileIdx = playerTileIdx - level!.width;
    var northTile = level!.queryTile(northTileIdx);

    //early out if tile is not walkable
    if (northTile!.walkable == false) return;

    //check for box in north square
    if (northTile.box == true) {
      //check the bounds of the tile north of the box
      var northBoxIdx = playerTileIdx - (level!.width * 2);

      //if the index is less than one no movement can happen
      if (northBoxIdx < 0) return;
      var northBoxTile = level!.queryTile(northBoxIdx);

      if (northBoxTile!.walkable && northBoxTile.box == false) {
        if (northTile.coin == true) player!.incrementBatteryCount();
        player!.yPos--;
        level!.setBoxValue(northTileIdx, false);
        level!.setBoxValue(northBoxIdx, true);
        commandQueue +=
            'moveBox $northTileIdx $northBoxIdx ${northBoxTile.goal}\n';
        commandQueue += 'movePlayer ${player!.xPos} ${player!.yPos}\n';
      }
    } else {
      player!.yPos--;
      if (northTile.coin == true) {
        player!.incrementBatteryCount();
        commandQueue += 'removeBattery $northTileIdx\n';
      }
      commandQueue += 'movePlayer ${player!.xPos} ${player!.yPos}\n';
    }
  }

  void _moveSouth() {
    //early out if at the bottom of the map
    if (player?.yPos == level!.height - 1) return;

    var tileCount = level!.width * level!.height;
    var playerTileIdx = (player!.yPos * level!.width) + player!.xPos;
    var southTileIdx = playerTileIdx + level!.width;
    var southTile = level!.queryTile(southTileIdx);

    //early out if tile is not walkable
    if (southTile!.walkable == false) return;

    //check for box in south square
    if (southTile.box == true) {
      //check the bounds of the tile south of the box
      var southBoxIdx = playerTileIdx + (level!.width * 2);

      //if the index is greater than the total tiles no movement can happen
      if (southBoxIdx >= tileCount) return;
      var southBoxTile = level!.queryTile(southBoxIdx);

      if (southBoxTile!.walkable && southBoxTile.box == false) {
        player!.yPos++;
        if (southTile.coin == true) player!.incrementBatteryCount();
        level!.setBoxValue(southTileIdx, false);
        level!.setBoxValue(southBoxIdx, true);
        commandQueue +=
            'moveBox $southTileIdx $southBoxIdx ${southBoxTile.goal}\n';
        commandQueue += 'movePlayer ${player!.xPos} ${player!.yPos}\n';
      }
    } else {
      player!.yPos++;
      if (southTile.coin == true) {
        player!.incrementBatteryCount();
        commandQueue += 'removeBattery $southTileIdx\n';
      }
      commandQueue += 'movePlayer ${player!.xPos} ${player!.yPos}\n';
    }
  }

  void _moveEast() {
    //early out if at the far side of the map
    if (player?.yPos == level!.width - 1) {
      return;
    }
    var eastBound = level!.width * (player!.yPos + 1);
    var playerTileIdx = (player!.yPos * level!.width) + player!.xPos;
    if (playerTileIdx >= eastBound - 1) {
      return;
    }
    var eastTileIdx = playerTileIdx + 1;
    var eastTile = level!.queryTile(eastTileIdx);

    //early out if tile is not walkable
    if (eastTile!.walkable == false) {
      return;
    }
    //check for box in south square
    if (eastTile.box == true) {
      //check the bounds of the tile south of the box
      var eastBoxIdx = playerTileIdx + 2;
      if (playerTileIdx >= eastBound - 2) return;

      //if the index is greater than the total tiles no movement can happen
      var eastBoxTile = level!.queryTile(eastBoxIdx);

      if (eastBoxTile!.walkable && eastBoxTile.box == false) {
        player!.xPos++;
        if (eastTile.coin == true) player!.incrementBatteryCount();
        level!.setBoxValue(eastTileIdx, false);
        level!.setBoxValue(eastBoxIdx, true);
        commandQueue +=
            'moveBox $eastTileIdx $eastBoxIdx ${eastBoxTile.goal}\n';
        commandQueue += 'movePlayer ${player!.xPos} ${player!.yPos}\n';
      }
    } else {
      player!.xPos++;
      if (eastTile.coin == true) {
        player!.incrementBatteryCount();
        commandQueue += 'removeBattery $eastTileIdx\n';
      }
      commandQueue += 'movePlayer ${player!.xPos} ${player!.yPos}\n';
    }
  }

  void _moveWest() {
    //early out if at the far side of the map
    if (player?.yPos == 0) return;

    var playerTileIdx = (player!.yPos * level!.width) + player!.xPos;
    var westTileIdx = playerTileIdx - 1;
    if (westTileIdx < 0) return;
    var westTile = level!.queryTile(westTileIdx);

    //early out if tile is not walkable
    if (westTile!.walkable == false) return;

    //check for box in south square
    if (westTile.box == true) {
      //check the bounds of the tile south of the box
      var westBoxIdx = playerTileIdx - 2;
      if (westBoxIdx < 0) return;

      //if the index is greater than the total tiles no movement can happen
      var westBoxTile = level!.queryTile(westBoxIdx);

      if (westBoxTile!.walkable && westBoxTile.box == false) {
        player!.xPos--;
        if (westTile.coin == true) player!.incrementBatteryCount();
        level!.setBoxValue(westTileIdx, false);
        level!.setBoxValue(westBoxIdx, true);
        commandQueue +=
            'moveBox $westTileIdx $westBoxIdx ${westBoxTile.goal}\n';
        commandQueue += 'movePlayer ${player!.xPos} ${player!.yPos}\n';
      }
    } else {
      player!.xPos--;
      if (westTile.coin == true) {
        player!.incrementBatteryCount();
        commandQueue += 'removeBattery $westTileIdx\n';
      }
      commandQueue += 'movePlayer ${player!.xPos} ${player!.yPos}\n';
    }
  }

  void teleport(void Function(String)? onComplete) {
    var incompleteGoalCount = 0;
    if (level == null) {
      logger.e('NULL LEVEL');
      return;
    }

    for (var index = 0; index < level!.levelTiles.length; index++) {
      var levelTile = level!.queryTile(index);

      if (levelTile == null) continue;

      if (levelTile.goal == true) {
        if (levelTile.box == false) incompleteGoalCount++;
      }
    }

    if (incompleteGoalCount == 0) {
      var returnString = 'teleport\nstep $steps\nlevelVictory\n';
      commandQueue += returnString;
      onComplete!(returnString);
    } else {
      var returnString = 'teleport\nstep $steps\nlevelFailed\n';
      commandQueue += returnString;
      onComplete!(returnString);
    }
  }

  void errorHit(String error) {
    var errorString = 'error\n $error\n';
    commandQueue += errorString;
    game.parseCommandQueue(commandQueue);
    commandQueue = '';
  }

  void completionHit() {
    game.parseCommandQueue(commandQueue);
    logger.i(commandQueue);
    commandQueue = '';
  }

  String detectTile(Direction dir) {
    var result = '';
    var tileInfo = switch (dir) {
      Direction.east => {
          if (player!.xPos < level!.width - 1)
            level!.queryTile(((player!.yPos * level!.width) + player!.xPos) + 1)
        },
      Direction.west => {
          if (player!.xPos > 0)
            level!.queryTile(((player!.yPos * level!.width) + player!.xPos) - 1)
        },
      Direction.south => {
          if (player!.yPos < level!.height - 1)
            level!.queryTile(
                ((player!.yPos * level!.width) + player!.xPos) + level!.width)
        },
      Direction.north => {
          if (player!.yPos > 0)
            level!.queryTile(
                ((player!.yPos * level!.width) + player!.xPos) - level!.width)
        },
      _ => null,
    };

    if (tileInfo == null) result = 'wall';
    if (tileInfo!.isNotEmpty) {
      var innerTile = tileInfo.elementAt(0);
      if (innerTile == null) {
        result = 'wall';
      } else {
        if (innerTile.walkable) {
          result = 'floor';
          if (innerTile.box!) result = 'box';
          if (innerTile.goal!) result = 'goal';
          if (innerTile.coin!) result = 'battery';
          if (innerTile.door!) result = 'door';
        } else {
          result = 'wall';
        }
      }
    }
    return result;
  }
}
