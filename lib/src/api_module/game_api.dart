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

@JS()
library game_api.js;

import 'dart:js_interop';
import 'import_js_lib.dart';
import '/src/log/log.dart';
import '/src/game_manager/game_manager.dart';
import '/src/helpers/enums.dart';

//describes an interoperable function with callback into Dart
@JS('moveNorth')
external set _moveNorth(JSFunction f);

@JS('moveSouth')
external set _moveSouth(JSFunction f);

@JS('moveEast')
external set _moveEast(JSFunction f);

@JS('moveWest')
external set _moveWest(JSFunction f);

@JS('activateTeleporter')
external set _activateTeleporter(JSFunction f);

@JS('detectTiles')
external set _detectTiles(JSFunction f);

@JS('errorRoute')
external set _errorRoute(JSFunction f);

@JS('__completionHit__')
external set _completionHit(JSFunction f);

@JS()
external void evalJs(String path);

class GameApi {
  late GameManager _gameManager;

  GameApi(GameManager gameManager) {
    _gameManager = gameManager;
  }

  Future<void> initialize() async {
    await importJsLibrary('assets/assets/api/javascript_api.js');
  }

  void buildInterop() {
    _moveNorth = (dartMoveNorth).toJS;
    _moveSouth = (dartMoveSouth).toJS;
    _moveEast = (dartMoveEast).toJS;
    _moveWest = (dartMoveWest).toJS;
    _activateTeleporter = (dartActivateTeleporter).toJS;
    _detectTiles = (dartDetectTiles).toJS;
    _errorRoute = (dartErrorRoute).toJS;
    _completionHit = (dartCompletionHit).toJS;
  }

  void dartMoveNorth() {
    logger.i("moveNorth");
    _gameManager.move(Direction.north);
  }

  void dartMoveSouth() {
    logger.i("moveSouth");
    _gameManager.move(Direction.south);
  }

  void dartMoveEast() {
    logger.i("moveEast");
    _gameManager.move(Direction.east);
  }

  void dartMoveWest() {
    logger.i("moveWest");
    _gameManager.move(Direction.west);
  }

  void dartActivateTeleporter() {
    _gameManager.teleport((msg) => {
          logger.i(msg),
        });
  }

  String dartDetectTiles(String text) {
    logger.i('dartDetectTiles input: $text');
    var direction = switch (text) {
      'north' => Direction.north,
      'south' => Direction.south,
      'east' => Direction.east,
      'west' => Direction.west,
      _ => Direction.none
    };

    var result = _gameManager.detectTile(direction);
    logger.i('dartDetectTiles output: $result');
    return result;
  }

  void dartErrorRoute(String error) {
    _gameManager.errorHit(error);
    var result = 'ERROR: $error';
    logger.e(result);
  }

  void dartCompletionHit() {
    _gameManager.completionHit();
    logger.i('EOF');
  }
}
