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

class LevelDataBundle {
  final Map<String, Object?> _json;
  LevelDataBundle(String response)
      : _json = jsonDecode(response) as Map<String, dynamic>;

  LevelData get levelData {
    if (_json
        case {
          'levelData': {
            'gridPixelWidth': int gridPixelWidth,
            'gridPixelHeight': int gridPixelHeight,
            'gridPixelXOffset': int gridPixelXOffset,
            'gridPixelYOffset': int gridPixelYOffset,
          }
        }) {
      return LevelData(
        gridPixelWidth,
        gridPixelHeight,
        gridPixelXOffset,
        gridPixelYOffset,
      );
    } else {
      throw const FormatException('Unexpected JSON in levelData');
    }
  }

  List<LevelImage> get levelImages {
    if (_json case {'levelAssets': List levelImages}) {
      return levelImages
          .cast<Map<String, dynamic>>()
          .map(_parseJsonObjectToLevelImage)
          .toList();
    } else {
      throw const FormatException('Unexpected JSON in levelAssets');
    }
  }

  LevelImage _parseJsonObjectToLevelImage(Map<String, dynamic> jsonObject) {
    return switch (jsonObject) {
      {
        'type': String type,
        'imgName': String imgName,
        'xPos': int xPos,
        'yPos': int yPos,
        'imgWidth': int imgWidth,
        'imgHeight': int imgHeight,
        'gridXIdx': int gridXPos,
        'gridYIdx': int gridYPos,
        'layer': int layer,
      } =>
        LevelImage(type, imgName.toLowerCase(), xPos, yPos, imgWidth, imgHeight,
            gridXPos, gridYPos, layer),
      _ => throw const FormatException(),
    };
  }
}

class LevelData {
  int gridPixelWidth;
  int gridPixelHeight;
  int gridPixelXOffset;
  int gridPixelYOffset;

  LevelData(this.gridPixelWidth, this.gridPixelHeight, this.gridPixelXOffset,
      this.gridPixelYOffset);
}

class LevelImage {
  String type;
  String imgName;
  int xPos;
  int yPos;
  int imgWidth;
  int imgHeight;
  int gridXPos;
  int gridYPos;
  int layer;

  LevelImage(this.type, this.imgName, this.xPos, this.yPos, this.imgWidth,
      this.imgHeight, this.gridXPos, this.gridYPos, this.layer);
}
