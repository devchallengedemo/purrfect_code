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

import '/src/game_manager/level_tile.dart';

class Level {
  String levelName;
  int height;
  int width;

  //levels tiles are sorted top left to bottom right;
  List<LevelTile> levelTiles = [];

  Level(this.levelName, this.height, this.width);

  LevelTile? queryTile(int index) {
    return index < levelTiles.length && index >= 0 ? levelTiles[index] : null;
  }

  bool setWalkableValue(int index, bool walkable) =>
      levelTiles[index].walkable = walkable;
  bool setBoxValue(int index, bool hasBox) => levelTiles[index].box = hasBox;
  bool setGoalValue(int index, bool hasGoal) =>
      levelTiles[index].goal = hasGoal;
  bool setKeyValue(int index, bool hasCoin) => levelTiles[index].coin = hasCoin;
  bool setDoorValue(int index, bool hasDoor) =>
      levelTiles[index].door = hasDoor;
}
