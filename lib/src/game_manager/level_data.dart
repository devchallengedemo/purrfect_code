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

class LevelData {
  final Map<String, Object?> _json;
  LevelData(String json) : _json = jsonDecode(json);

  LevelMetadata get levelMetaData {
    if (_json
        case {
          'levelMetadata': {
            'levelName': String levelName,
            'tileCountWidth': int tileCountWidth,
            'tileCountHeight': int tileCountHeight,
            'playerStartX': int playerStartX,
            'playerStartY': int playerStartY,
            'threeStars': int threeStars,
            'twoStars': int twoStars,
            'oneStar': int oneStar
          }
        }) {
      return (LevelMetadata(levelName, tileCountWidth, tileCountHeight,
          playerStartX, playerStartY, threeStars, twoStars, oneStar));
    } else {
      throw const FormatException('Unexpected JSON');
    }
  }

  LevelArray get levelArray {
    if (_json case {'levelArray': {'tiles': dynamic tiles}}) {
      return (LevelArray(tiles));
    } else {
      throw const FormatException('Unexpected JSON');
    }
  }
}

class LevelMetadata {
  String levelName;
  int tileCountWidth;
  int tileCountHeight;
  int playerStartX;
  int playerStartY;
  int threeStars;
  int twoStars;
  int oneStar;

  LevelMetadata(
    this.levelName,
    this.tileCountWidth,
    this.tileCountHeight,
    this.playerStartX,
    this.playerStartY,
    this.threeStars,
    this.twoStars,
    this.oneStar,
  );
}

class LevelArray {
  dynamic tiles;

  LevelArray(this.tiles);
}
