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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:url_launcher/url_launcher.dart';

import '/src/app_state.dart';
import '/src/editor/editor.dart';
import '/src/game_manager/game_manager.dart';
import '/src/game_manager/level_data.dart';
import '/src/log/log.dart';
import '/src/sokoban_view/sokoban_game.dart';
import 'multi_view.dart';

class MultiViewWidget extends StatefulWidget {
  late final SokobanGame game;
  late final GameManager gameManager;
  // ignore: prefer_const_constructors

  final editor = CommandEditor(
    path: '',
    controller: CodeController(
      text: '', // Initial code
      language: javascript,
    ),
  );

  MultiViewWidget({
    super.key,
    required this.gameManager,
  });

  @override
  State<MultiViewWidget> createState() => _MultiviewWidgetState();
}

class _MultiviewWidgetState extends State<MultiViewWidget> {
  bool setupComplete = false;
  String modalBannerFailedPath = 'assets/ui_images/purrfect_code_failure.png';
  String modalBannerTutorialPath =
      'assets/ui_images/purrfect_code_tutorial.png';

  late void Function(int) callback;

  @override
  void initState() {
    super.initState();
    widget.game = SokobanGame((value) {
      var steps = widget.gameManager.steps;
      var semicolons = widget.editor.getSemicolonCount();
      var braces = widget.editor.getBracesCount();
      var batteries = widget.gameManager.player!.getBatteryCount();
      var score =
          100 - (semicolons * 2) - (braces * 2) - steps + (batteries * 5);
      var badgeUrl = 'https://www.google.com';
      if (value) {
        _showModalWindow(
          context,
          'Victory',
          'Congratulations! You have completed the level and earned a badge!',
          score,
          steps,
          semicolons,
          braces,
          batteries,
          badgeUrl,
        );
      } else {
        _showIncomplete(
          context,
          'Incomplete',
          'Sorry, You have not completed the level. Try again to win the level badge!',
          true,
        );
      }
    });
    widget.gameManager.setGameReference(widget.game);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (appState.state != AppCurrentState.loaded &&
        appState.state != AppCurrentState.running) {
      if (appState.state != AppCurrentState.loading) {
        logger.i('LOADING LEVEL');
        appState.setState(AppCurrentState.loading);
        widget.gameManager.resetLevel();

        var txt = switch (appState.getLevel()) {
          1 => '''// Welcome to Purrfect Code!
// Write JavaScript code here using the functions below
// to help the robot get the cats home by pushing them 
// to the teleporter plates. The first solution is below,
// but has one line commented out. 
// Uncomment the final "moveSouth()"
// then click "Run" to solve the problem.\n
moveNorth();
moveNorth();
moveSouth();
moveSouth();
moveEast();
moveEast();
moveWest();
moveWest();
moveWest();
moveWest();
moveEast();
moveEast();
moveSouth();
//moveSouth();\n
activateTeleporter();''',
          2 => '''// In Purrfect Code Level 2, the solution involves
// repeating blocks of code. Use the functions below 
// to solve the puzzle.
//Move one space north
moveNorth();\n
//Move one space south
moveSouth();\n
//Move one space east
moveEast();\n
//Move one space west
moveWest();\n
//Activate the teleporter to solve the level
activateTeleporter();''',
          3 => '''// In Purrfect Code Level 3, try using JavaScript functions
// to solve the puzzle. 
//Move one space north
moveNorth();\n
//Move one space south
moveSouth();\n
//Move one space east
moveEast();\n
//Move one space west
moveWest();\n
//Activate the teleporter to solve the level
activateTeleporter();''',
          4 => '''// In Purrfect Code Level 4,  try passing unique values 
//to your functions to solve the puzzle.

//Move one space north
moveNorth();\n
//Move one space south
moveSouth();\n
//Move one space east
moveEast();\n
//Move one space west
moveWest();\n
//Activate the teleporter to solve the level
activateTeleporter();
''',
          5 => '''// In Purrfect Code Level 5,  the solution requires
// you to combine the skills you've learned thus far!
// Use JavaScript to solve the puzzle.\n 
//Move one space north
moveNorth();\n
//Move one space south
moveSouth();\n
//Move one space east
moveEast();\n
//Move one space west
moveWest();\n
//Activate the teleporter to solve the level
activateTeleporter();
''',
          _ => ''
        };
        if (widget.editor.controller.text.isEmpty) {
          widget.editor.setText(txt);
        }
        _loadLevelData(appState.getLevel(), _setAppStateLoaded);
      }
      return Container();
    } else {
      return MultiView(
        context: context,
        game: widget.game,
        editor: widget.editor,
        callback: (value) {
          switch (value) {
            case 0:
              _setAppStateRunning();
              break;
            case 1:
              _showIncomplete(
                context,
                'Restart Level',
                'You can restart the level, or skip ahead from here.',
                false,
              );
              break;
            case 2:
              _showTutorial(
                  context,
                  'Welcome!',
                  '''The cats are stranded on the space station! 
Control the robot with JavaScript to push the cats to the teleporters.
Press "Run" to run your code and solve the level.

API Reference:

moveNorth() //Move one space north
moveSouth() //Move one space south
moveEast() //Move one space east
moveWest() //Move one space west
activateTeleporter() //Call when cats are in position''',
                  modalBannerTutorialPath);
              break;
            default:
              break;
          }
        },
      );
    }
  }

  void _setAppStateUnloaded() {
    setState(() => appState.setState(AppCurrentState.nil));
  }

  void _setAppStateLoaded() {
    setState(() => appState.setState(AppCurrentState.loaded));
  }

  void _setAppStateRunning() {
    setState(() => appState.setState(AppCurrentState.running));
  }

  Future<void> _loadLevelData(
      int level, void Function() setAppDataLoaded) async {
    var path = switch (level) {
      1 => 'assets/level_base/level01.json',
      2 => 'assets/level_base/level02.json',
      3 => 'assets/level_base/level03.json',
      4 => 'assets/level_base/level04.json',
      5 => 'assets/level_base/level05.json',
      _ => ''
    };

    var response = await rootBundle.loadString(path);
    if (response.isEmpty) {
      logger.e('Failed to load json data');
      return;
    }
    var levelData = LevelData(response);
    var metaData = levelData.levelMetaData;

    var processedTiles = widget.gameManager
        .processLevelTilesFromJson(levelData.levelArray.tiles);

    widget.gameManager.createLevel(
      metaData.levelName,
      metaData.tileCountHeight,
      metaData.tileCountWidth,
      metaData.playerStartX,
      metaData.playerStartY,
      processedTiles,
    );

    setAppDataLoaded();
    logger.i('LEVEL CREATED!');
  }

  void _showModalWindow(
      BuildContext context,
      String title,
      String body,
      int score,
      int steps,
      int semicolons,
      int braces,
      int batteries,
      String badgeUrl) {
    _setAppStateLoaded();

    var firstButton = appState.getLevel() == 1
        ? OutlinedButton(
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24)),
            child: const Text('Previous Level',
                style: TextStyle(
                  color: Colors.white24,
                )),
            onPressed: () {},
          )
        : OutlinedButton(
            child: const Text('Previous Level'),
            onPressed: () {
              {
                Navigator.of(context).pop();
                appState.setLevel(appState.getLevel() - 1);
                widget.game.reset();
                widget.editor.resetText();
                _setAppStateUnloaded();
              }
            },
          );

    var thirdButton = appState.getLevel() == appState.lastLevel
        ? OutlinedButton(
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24)),
            child: const Text('Next Level',
                style: TextStyle(
                  color: Colors.white24,
                )),
            onPressed: () {},
          )
        : OutlinedButton(
            child: const Text('Next Level'),
            onPressed: () {
              Navigator.of(context).pop();
              appState.setLevel(appState.getLevel() + 1);
              widget.game.reset();
              widget.editor.resetText();
              _setAppStateUnloaded();
            },
          );

    var mainImageAsset = switch (appState.getLevel()) {
      5 => 'assets/ui_images/purrfect_code_game_victory.png',
      _ => 'assets/ui_images/purrfect_code_level_victory.png',
    };

    var badgeImageAsset = switch (appState.getLevel()) {
      1 => 'assets/ui_images/level_1_badge.png',
      2 => 'assets/ui_images/level_2_badge.png',
      3 => 'assets/ui_images/level_3_badge.png',
      4 => 'assets/ui_images/level_4_badge.png',
      5 => 'assets/ui_images/level_5_badge.png',
      _ => 'assets/ui_images/level_1_badge.png',
    };

    showDialog<void>(
      barrierDismissible: false,
      barrierColor: const Color.fromARGB(168, 120, 120, 120),
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              side: BorderSide(
                color: Colors.white54,
                width: 3.0,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20))),
          titlePadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          title: Align(
            alignment: const Alignment(0.0, -2.0),
            child: Text(
              title,
              textHeightBehavior: const TextHeightBehavior(
                  leadingDistribution: TextLeadingDistribution.even),
            ),
          ),
          content: Column(
            // Make the column only as big as its children need it to be
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(mainImageAsset),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 48.0),
                      'Score: $score'),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double
                    .infinity, // Make the container fill the modal horizontally
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Left justify the text
                  children: <Widget>[
                    Text(body),
                    Text('Total Moves: $steps x -1'),
                    Text('Semicolons In Code: $semicolons x -2'),
                    Text('Braces In Code: $braces x -2'),
                    Text('Batteries Collected: $batteries x 5'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                    onTap: () async {
                      var badgeUri = Uri.parse(badgeUrl);
                      if (await canLaunchUrl(badgeUri)) {
                        await launchUrl(badgeUri);
                      } else {
                        throw StateError('Could not launch $badgeUrl');
                      }
                    },
                    child: Image.asset(
                      badgeImageAsset,
                      width: 128,
                      height: 128,
                    ),
                  ),
                  Center(
                    child: TextButton(
                      child: const Text(
                          'Add badge to your Google Developer Profile'),
                      onPressed: () async {
                        var badgeUri = Uri.parse(badgeUrl);
                        if (await canLaunchUrl(badgeUri)) {
                          await launchUrl(badgeUri);
                        } else {
                          throw StateError('Could not launch $badgeUrl');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(60, 20, 60, 20),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: firstButton,
                ),
                const Spacer(),
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    child: const Text('Retry'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.game.reset();
                      _setAppStateUnloaded();
                    },
                  ),
                ),
                const Spacer(),
                Expanded(
                  flex: 2,
                  child: thirdButton,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showIncomplete(
      BuildContext context, String title, String body, bool failed) {
    var firstButton = appState.getLevel() == 1
        ? OutlinedButton(
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24)),
            child: const Text('Previous Level',
                style: TextStyle(
                  color: Colors.white24,
                )),
            onPressed: () {},
          )
        : OutlinedButton(
            child: const Text('Previous Level'),
            onPressed: () {
              {
                Navigator.of(context).pop();
                appState.setLevel(appState.getLevel() - 1);
                widget.game.reset();
                widget.editor.resetText();
                _setAppStateUnloaded();
              }
            },
          );

    var thirdButton = appState.getLevel() == appState.lastLevel
        ? OutlinedButton(
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24)),
            child: const Text('Next Level',
                style: TextStyle(
                  color: Colors.white24,
                )),
            onPressed: () {},
          )
        : OutlinedButton(
            child: const Text('Next Level'),
            onPressed: () {
              Navigator.of(context).pop();
              appState.setLevel(appState.getLevel() + 1);
              widget.game.reset();
              widget.editor.resetText();
              _setAppStateUnloaded();
            },
          );

    showDialog<void>(
      barrierDismissible: false,
      barrierColor: const Color.fromARGB(168, 120, 120, 120),
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              side: BorderSide(
                color: Colors.white54,
                width: 3.0,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20))),
          titlePadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          title: Align(
            alignment: const Alignment(0.0, -2.0),
            child: Text(
              title,
              textHeightBehavior: const TextHeightBehavior(
                  leadingDistribution: TextLeadingDistribution.even),
            ),
          ),
          content: Column(
            // Make the column only as big as its children need it to be
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                  failed ? modalBannerFailedPath : modalBannerTutorialPath),
              const SizedBox(height: 10),
              Container(
                width: double
                    .infinity, // Make the container fill the modal horizontally
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Left justify the text
                  children: <Widget>[
                    Text(body),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(60, 20, 60, 20),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: firstButton,
                ),
                const Spacer(),
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    child: const Text('Retry'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.game.reset();
                      _setAppStateUnloaded();
                    },
                  ),
                ),
                const Spacer(),
                Expanded(
                  flex: 2,
                  child: thirdButton,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showTutorial(
      BuildContext context, String title, String body, String headerImagePath) {
    showDialog<void>(
      barrierDismissible: true,
      barrierColor: const Color.fromARGB(168, 120, 120, 120),
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              side: BorderSide(
                color: Colors.white54,
                width: 3.0,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20))),
          titlePadding: const EdgeInsets.all(10.0),
          title: Align(
            alignment: const Alignment(0.0, -2.0),
            child: Text(
              title,
              textHeightBehavior: const TextHeightBehavior(
                  leadingDistribution: TextLeadingDistribution.even),
            ),
          ),
          content: Column(
            // Make the column only as big as its children need it to be
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(headerImagePath),
              const SizedBox(height: 10),
              Container(
                width: double
                    .infinity, // Make the container fill the modal horizontally
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Left justify the text
                  children: <Widget>[
                    Text(body),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(60, 20, 60, 20),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                OutlinedButton(
                  child: const Text('Lets Go!'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
