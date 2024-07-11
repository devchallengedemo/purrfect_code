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

import 'package:flutter_test/flutter_test.dart';
import 'package:purrfect_code/src/game_manager/game_manager.dart';
import 'package:purrfect_code/src/game_manager/level_data.dart';
import 'package:purrfect_code/src/helpers/enums.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var gameManager = GameManager(); //_MockGameManager();
  late LevelData levelData;
  late LevelMetadata metaData;

  setUpAll(() async {
    var response = '''
{
    "levelMetadata": {
        "levelName": "LEVEL TEST",
        "tileCountWidth": 13,
        "tileCountHeight": 13,
        "playerStartX": 6,
        "playerStartY": 6
    },
    "levelArray": {
        "tiles": [
        1,1,1,1,1,1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,3,1,1,1,1,1,1,
        1,1,1,1,1,1,5,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,1,1,1,1,1,
        1,1,1,3,5,1,1,1,5,3,1,1,1,
        1,1,1,1,1,1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,5,1,1,1,1,1,1,
        1,1,1,1,1,1,3,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,1,1,1,1,1
        ]
    }
}
''';
    levelData = LevelData(response);
    metaData = levelData.levelMetaData;
  });

  group('GameManager Tests', () {
    test(
      'Load JSON data and create level',
      () {
        var processedTiles =
            gameManager.processLevelTilesFromJson(levelData.levelArray.tiles);

        gameManager.createLevel(
          metaData.levelName,
          metaData.tileCountHeight,
          metaData.tileCountWidth,
          metaData.playerStartX,
          metaData.playerStartY,
          processedTiles,
        );

        expect(gameManager.level!.levelName, 'LEVEL TEST');
        expect(gameManager.level!.height, 13);
        expect(gameManager.level!.width, 13);
        expect(gameManager.player!.xPos, 6);
        expect(gameManager.player!.yPos, 6);
      },
    );

    test(
      'Move player north',
      () {
        gameManager.move(Direction.north);
        expect(gameManager.player!.yPos, 5);
      },
    );

    test(
      'Move box north',
      () {
        var queryTile = gameManager.detectTile(Direction.north);
        var tileContainsBox = queryTile.contains('box');
        gameManager.move(Direction.north);
        var playerYPos = gameManager.player!.yPos;
        gameManager.move(Direction.south);
        gameManager.move(Direction.south);

        expect(tileContainsBox, true);
        expect(playerYPos, 4);
      },
    );
    test(
      'Move player south',
      () {
        gameManager.move(Direction.south);

        expect(gameManager.player!.yPos, 7);
      },
    );

    test(
      'Move box south',
      () {
        var queryTile = gameManager.detectTile(Direction.south);
        var tileContainsBox = queryTile.contains('box');
        gameManager.move(Direction.south);
        var playerYPos = gameManager.player!.yPos;
        gameManager.move(Direction.north);
        gameManager.move(Direction.north);

        expect(tileContainsBox, true);
        expect(playerYPos, 8);
      },
    );

    test(
      'Move player west',
      () {
        gameManager.move(Direction.west);

        expect(gameManager.player!.xPos, 5);
      },
    );

    test(
      'Move box west',
      () {
        var queryTile = gameManager.detectTile(Direction.west);
        var tileContainsBox = queryTile.contains('box');
        gameManager.move(Direction.west);
        var playerXPos = gameManager.player!.xPos;
        gameManager.move(Direction.east);
        gameManager.move(Direction.east);

        expect(tileContainsBox, true);
        expect(playerXPos, 4);
      },
    );

    test(
      'Move player east',
      () {
        gameManager.move(Direction.east);
        expect(gameManager.player!.xPos, 7);
      },
    );

    test(
      'Move box east',
      () {
        var queryTile = gameManager.detectTile(Direction.east);
        var tileContainsBox = queryTile.contains('box');
        gameManager.move(Direction.east);
        var playerXPos = gameManager.player!.xPos;
        expect(tileContainsBox, true);
        expect(playerXPos, 8);
      },
    );

    test(
      'Teleport boxes',
      () {
        var boxesTeleported = false;
        gameManager.teleport((value) {
          boxesTeleported = value.contains('Victory');
        });
        expect(boxesTeleported, true);
        expect(gameManager.steps, 14);
      },
    );

    test(
      'Reset level',
      () {
        gameManager.resetLevel();
        expect(gameManager.player, null);
        expect(gameManager.level, null);
        expect(gameManager.steps, 0);
        expect(gameManager.commandQueue, '');
      },
      skip: true,
    );
  });
}
