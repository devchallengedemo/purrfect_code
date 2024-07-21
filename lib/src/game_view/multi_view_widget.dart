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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:url_launcher/url_launcher.dart';
import '/src/app_state.dart';
import '/src/game_manager/level_data.dart';
import '/src/editor/editor.dart';
import '/src/game_manager/level_tile.dart';
import '/src/game_manager/game_manager.dart';
import '/src/sokoban_view/sokoban_game.dart';
import '/src/log/log.dart';
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
  createState() => _MultiviewWidgetState();
}

class ScoringThresholds {
  int threeStars = 100;
  int twoStars = 50;
  int oneStar = 0;
}

class _MultiviewWidgetState extends State<MultiViewWidget> {
  bool setupComplete = false;
  String modalBannerFailedPath = 'assets/ui_images/purrfect_code_failure.png';
  String modalBannerTutorialPath =
      'assets/ui_images/purrfect_code_tutorial.png';

  ScoringThresholds thresholds = ScoringThresholds();
  late Function(int) callback;

  @override
  initState() {
    super.initState();
    widget.game = SokobanGame((value) {
      int steps = widget.gameManager.steps;
      int semicolons = widget.editor.getSemicolonCount();
      int braces = widget.editor.getBracesCount();
      int batteries = widget.gameManager.player!.getBatteryCount();
      int score =
          100 - (semicolons * 2) - (braces * 2) - steps + (batteries * 5);
      int stars = 0;
      if (score > thresholds.oneStar) stars++;
      if (score > thresholds.twoStars) stars++;
      if (score > thresholds.threeStars) stars++;

      if (value) {
        _showModalWindow(
            context, stars, score, steps, semicolons, braces, batteries);
      } else {
        //FAILURE DIALOG
        logger.i('Failure Dialog here plz.');
        _retry();
      }
    });
    widget.gameManager.setGameReference(widget.game);
  }

  @override
  dispose() {
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

        //if (widget.editor.controller.text.isEmpty) {
        widget.editor.setText(txt);
        // }

        _loadLevelData(appState.getLevel(), () => _setAppStateLoaded());
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
              _retry();
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
            case 3:
              _setAppStateUnloaded();
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

  _loadLevelData(int level, Function() setAppDataLoaded) async {
    var path = switch (level) {
      1 => 'assets/level_base/level01.json',
      2 => 'assets/level_base/level02.json',
      3 => 'assets/level_base/level03.json',
      4 => 'assets/level_base/level04.json',
      5 => 'assets/level_base/level05.json',
      _ => ''
    };

    String response = await rootBundle.loadString(path);
    if (response.isEmpty) {
      logger.e('Failed to load json data');
      return;
    }
    var levelData = LevelData(response);
    var metaData = levelData.levelMetaData;

    List<LevelTile> processedTiles = widget.gameManager
        .processLevelTilesFromJson(levelData.levelArray.tiles);

    widget.gameManager.createLevel(
      metaData.levelName,
      metaData.tileCountHeight,
      metaData.tileCountWidth,
      metaData.playerStartX,
      metaData.playerStartY,
      processedTiles,
    );

    thresholds.threeStars = metaData.threeStars;
    thresholds.twoStars = metaData.twoStars;
    thresholds.oneStar = metaData.oneStar;

    setAppDataLoaded();
    logger.i('LEVEL CREATED!');
  }

  void _showModalWindow(BuildContext context, int stars, int score, int steps,
      int semicolons, int braces, int batteries) {
    _setAppStateLoaded();

    var prevButton = appState.getLevel() == 1
        ? TextButton(
            child: const Text('Previous Level',
                overflow: TextOverflow.visible,
                softWrap: false,
                style: TextStyle(
                  color: Colors.white24,
                )),
            onPressed: () {},
          )
        : TextButton(
            child: const Text(
              'Previous Level',
              overflow: TextOverflow.visible,
              softWrap: false,
            ),
            onPressed: () {
              {
                appState.setLevel(appState.getLevel() - 1);
                widget.editor.resetText();
                widget.game.reset();
                _setAppStateUnloaded();
                Navigator.of(context).pop();
              }
            },
          );

    var nextButton = appState.getLevel() == appState.lastLevel
        ? TextButton(
            child: const Text('Next Level',
                overflow: TextOverflow.visible,
                softWrap: false,
                style: TextStyle(
                  color: Colors.white24,
                )),
            onPressed: () {},
          )
        : TextButton(
            child: const Text(
              'Next Level',
              overflow: TextOverflow.visible,
              softWrap: false,
            ),
            onPressed: () {
              appState.setLevel(appState.getLevel() + 1);
              widget.editor.resetText();
              widget.game.reset();
              _setAppStateUnloaded();
              Navigator.of(context).pop();
            },
          );

    String mainImageAsset = switch (appState.getLevel()) {
      5 => 'assets/ui_images/purrfect_code_game_victory.png',
      _ => 'assets/ui_images/purrfect_code_level_victory.png',
    };

    String badgeImageAsset = switch (appState.getLevel()) {
      1 => 'assets/ui_images/level_1_badge.png',
      2 => 'assets/ui_images/level_2_badge.png',
      3 => 'assets/ui_images/level_3_badge.png',
      4 => 'assets/ui_images/level_4_badge.png',
      5 => 'assets/ui_images/level_5_badge.png',
      _ => 'assets/ui_images/level_1_badge.png',
    };

    String badgeUrl = switch (appState.getLevel()) {
      1 => 'https://developers.google.com/purrfect-code/level-1',
      2 => 'https://developers.google.com/purrfect-code/level-2',
      3 => 'https://developers.google.com/purrfect-code/level-3',
      4 => 'https://developers.google.com/purrfect-code/level-4',
      5 => 'https://developers.google.com/purrfect-code/level-5',
      _ => 'assets/ui_images/level_1_badge.png',
    };

    showDialog(
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
          title: const Text(''),
          content: Column(
            mainAxisSize: MainAxisSize
                .min, // Make the column only as big as its children need it to be
            children: <Widget>[
              Image.asset(mainImageAsset),
              const SizedBox(height: 20),
              IntrinsicHeight(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const SizedBox(width: 20),
                              Icon(
                                  stars > 0
                                      ? Icons.star
                                      : Icons.star_border_outlined,
                                  size: 64),
                              Icon(
                                  stars > 1
                                      ? Icons.star
                                      : Icons.star_border_outlined,
                                  size: 64),
                              Icon(
                                  stars > 2
                                      ? Icons.star
                                      : Icons.star_border_outlined,
                                  size: 64),
                              const SizedBox(width: 20),
                            ],
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(32.0, 0.0, 32.0, 0.0),
                            child: Table(
                              columnWidths: const <int, TableColumnWidth>{
                                0: FlexColumnWidth(),
                                1: FlexColumnWidth(),
                              },
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: <TableRow>[
                                TableRow(
                                  children: <Widget>[
                                    const TableCell(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Score:',
                                          style: TextStyle(
                                              height: 1.5, fontSize: 36),
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          '$score',
                                          style: const TextStyle(
                                              height: 1.5, fontSize: 36),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: <Widget>[
                                    const TableCell(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text('Total moves:'),
                                      ),
                                    ),
                                    TableCell(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text('$steps x -1'),
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: <Widget>[
                                    const TableCell(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text('Semicolons used:'),
                                      ),
                                    ),
                                    TableCell(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text('$semicolons x -2'),
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: <Widget>[
                                    const TableCell(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text('Braces used:'),
                                      ),
                                    ),
                                    TableCell(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text('$braces x -2'),
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: <Widget>[
                                    const TableCell(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text('Bonus batteries:'),
                                      ),
                                    ),
                                    TableCell(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text('$batteries x 5'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 3,
                      indent: 0,
                      endIndent: 0,
                      color: Colors.white24,
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          // ignore: sized_box_for_whitespace
                          Container(
                            height: 96,
                            child: Image.asset(badgeImageAsset),
                          ),
                          const Text(
                            'Congratulations!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                height: 1.25,
                                fontSize: 18,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 10),
                          const Align(
                            alignment: Alignment.center,
                            child: Text(
                              'You earned a Developer\n Profile Badge!',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),
                          OutlinedButton(
                            child: const Text(
                              'Redeem badge',
                              overflow: TextOverflow.visible,
                              softWrap: false,
                            ),
                            onPressed: () => launchUrl(Uri.parse(badgeUrl)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(60, 20, 60, 20),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: prevButton,
                ),
                const Spacer(),
                Expanded(
                  flex: 2,
                  child: nextButton,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _retry() {
    widget.game.reset();
    _setAppStateUnloaded();
  }

  void _showTutorial(
      BuildContext context, String title, String body, String headerImagePath) {
    var bodyFontSize =
        min(24.0, (MediaQuery.sizeOf(context).height / 768.0) * 15.0);

    showDialog(
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
            mainAxisSize: MainAxisSize
                .min, // Make the column only as big as its children need it to be
            children: <Widget>[
              Flexible(
                flex: 1,
                fit: FlexFit.loose,
                child: Image.asset(headerImagePath),
              ),
              const SizedBox(height: 10),
              Flexible(
                flex: 1,
                fit: FlexFit.loose,
                child: Container(
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
                      Text(
                        body,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: bodyFontSize),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
