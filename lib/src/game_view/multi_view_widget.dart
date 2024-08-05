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
import '/src/editor/editor.dart';
import '/src/game_manager/game_manager.dart';
import '/src/game_manager/level_data.dart';
import '/src/game_view/page_indicator.dart';
import '/src/log/log.dart';
import '/src/sokoban_view/sokoban_game.dart';
import 'multi_view.dart';

class MultiViewWidget extends StatefulWidget {
  late final SokobanGame game;
  late final GameManager gameManager;

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

class ScoringThresholds {
  int threeStars = 100;
  int twoStars = 50;
  int oneStar = 0;
}

class _MultiviewWidgetState extends State<MultiViewWidget>
    with TickerProviderStateMixin {
  bool setupComplete = false;
  String modalBannerFailedPath = 'assets/ui_images/purrfect_code_failure.png';
  String modalBannerTutorialPath =
      'assets/ui_images/purrfect_code_tutorial.png';

  ScoringThresholds thresholds = ScoringThresholds();

  final textController = TextEditingController();
  late PageController _pageViewController;
  late TabController _introTabController;
  late void Function(int) callback;

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _introTabController = TabController(length: 4, vsync: this);
    widget.game = SokobanGame((value) {
      var steps = widget.gameManager.steps;
      var semicolons = widget.editor.getSemicolonCount();
      var braces = widget.editor.getBracesCount();
      var batteries = widget.gameManager.player!.getBatteryCount();
      var score =
          100 - (semicolons * 3) - (braces * 2) - steps + (batteries * 5);
      var stars = 0;
      if (score > thresholds.oneStar) stars++;
      if (score > thresholds.twoStars) stars++;
      if (score > thresholds.threeStars) stars++;

      if (value.contains('victory')) {
        _showVictoryModal(
            context, stars, score, steps, semicolons, braces, batteries);
      } else {
        _showFailureModal(context);
      }
    });
    widget.gameManager.setGameReference(widget.game);
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _introTabController.dispose();
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
        callback: (int value) {
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
            case 4:
              _showIntro(context);
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

    thresholds.threeStars = metaData.threeStars;
    thresholds.twoStars = metaData.twoStars;
    thresholds.oneStar = metaData.oneStar;

    setAppDataLoaded();
    logger.i('LEVEL CREATED!');
  }

  void _showVictoryModal(BuildContext context, int stars, int score, int steps,
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

    var mainImageAsset = switch (appState.getLevel()) {
      5 => 'assets/ui_images/Modal_Art_Game_Victory_Banner_560x175px.png',
      _ => 'assets/ui_images/Modal_Art_Level_Complete_560x175px.png',
    };

    var badgeImageAsset = switch (appState.getLevel()) {
      1 => 'assets/ui_images/level_1_badge.png',
      2 => 'assets/ui_images/level_2_badge.png',
      3 => 'assets/ui_images/level_3_badge.png',
      4 => 'assets/ui_images/level_4_badge.png',
      5 => 'assets/ui_images/level_5_badge.png',
      _ => 'assets/ui_images/level_1_badge.png',
    };

    var badgeUrl = switch (appState.getLevel()) {
      1 => 'https://developers.google.com/purrfect-code/level-1',
      2 => 'https://developers.google.com/purrfect-code/level-2',
      3 => 'https://developers.google.com/purrfect-code/level-3',
      4 => 'https://developers.google.com/purrfect-code/level-4',
      5 => 'https://developers.google.com/purrfect-code/level-5',
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 10),
              Flexible(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: 575, maxHeight: 175),
                  child: Image.asset(mainImageAsset),
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints:
                    const BoxConstraints(minHeight: 225.0, maxHeight: 250.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
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
                                0: FixedColumnWidth(125),
                                1: FixedColumnWidth(125),
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
                                        child: Text('Semicolons used:'),
                                      ),
                                    ),
                                    TableCell(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text('$semicolons x -3'),
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
                      child: Column(
                        children: [
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

  void _showFailureModal(BuildContext context) {
    var bodyFontSize =
        min(24.0, (MediaQuery.sizeOf(context).height / 768.0) * 15.0);

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
          titlePadding: const EdgeInsets.all(10.0),
          title: const Align(
            alignment: Alignment(0.0, -2.0),
            child: Text(
              'Level Failed!',
              textHeightBehavior: TextHeightBehavior(
                  leadingDistribution: TextLeadingDistribution.even),
            ),
          ),
          content: Column(
            // Make the column only as big as its children need it to be
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                flex: 1,
                fit: FlexFit.loose,
                child: Image.asset(modalBannerFailedPath),
              ),
              const SizedBox(height: 10),
              Flexible(
                flex: 1,
                fit: FlexFit.loose,
                child: Container(
                  // Make the container fill the modal horizontally
                  width: double.infinity,
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Left justify the text
                      children: <Widget>[
                        Text(
                          'Sorry, you have not completed the level. '
                          'Try again to win the level!',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: bodyFontSize),
                        ),
                      ],
                    ),
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
                  child: const Text('Retry!'),
                  onPressed: () {
                    _retry();
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

  void _showTutorial(
      BuildContext context, String title, String body, String headerImagePath) {
    var bodyFontSize =
        min(24.0, (MediaQuery.sizeOf(context).height / 768.0) * 15.0);

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
                  // Make the container fill the modal horizontally
                  width: double.infinity,
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: SingleChildScrollView(
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

  void _showIntro(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    var maxBoxHeight = 600.0;
    var boxHeight = MediaQuery.of(context).size.height * 0.5;
    var calculatedHeight = min(maxBoxHeight, boxHeight);
    var introScreen1 = 'assets/ui_images/Purrfect_Code_Screen_01.png';
    var introScreen2 = 'assets/ui_images/Purrfect_Code_Screen_02.png';
    var introScreen3 = 'assets/ui_images/Purrfect_Code_Screen_03.png';
    var introScreen4 = 'assets/ui_images/Purrfect_Code_Screen_04.png';

    var imgContainer1 = calculatedHeight > 300.0
        ? Flexible(
            fit: FlexFit.tight,
            flex: 2,
            child: Image.asset(introScreen1),
          )
        : Container();

    var imgContainer2 = calculatedHeight > 300.0
        ? Flexible(
            fit: FlexFit.tight,
            flex: 2,
            child: Image.asset(introScreen2),
          )
        : Container();

    var imgContainer3 = calculatedHeight > 300.0
        ? Flexible(
            fit: FlexFit.tight,
            flex: 2,
            child: Image.asset(introScreen3),
          )
        : Container();

    var imgContainer4 = calculatedHeight > 300.0
        ? Flexible(
            fit: FlexFit.tight,
            flex: 2,
            child: Image.asset(introScreen4),
          )
        : Container();

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
              borderRadius: BorderRadius.all(Radius.circular(5))),
          content: Column(
            // Make the column only as big as its children need it to be
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 8.0),
                child: Container(
                  width: 600,
                  height: calculatedHeight,
                  child: Column(
                    children: <Widget>[
                      Flexible(
                        child: PageView(
                          controller: _pageViewController,
                          onPageChanged: _handlePageViewChanged,
                          children: <Widget>[
                            Center(
                              child: Column(
                                children: <Widget>[
                                  Text('📦 Cat-rescuing Javascript 😼',
                                      style: textTheme.titleLarge),
                                  const SizedBox(height: 20),
                                  imgContainer1,
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        24.0, 20.0, 24.0, 8.0),
                                    child: Text(
                                        '''You need to program the robot to save adorable cats stranded in the spaceship. Your weapon? JavaScript! Write the most efficient code to rescue them all.
''',
                                        style: textTheme.bodyMedium),
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: Column(
                                children: <Widget>[
                                  Text('⭐ Understanding Your Score ⭐',
                                      style: textTheme.titleLarge),
                                  const SizedBox(height: 20),
                                  imgContainer2,
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        24.0, 20.0, 24.0, 8.0),
                                    child: Text(
                                        '''Fewer moves, less code, more points! Master the art of efficient coding to boost your score and show off your skills.
''',
                                        style: textTheme.bodyMedium),
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: Column(
                                children: <Widget>[
                                  Text(
                                      '👩🏽‍💻 Conquer Stages, Claim Badges 🏅',
                                      style: textTheme.titleLarge),
                                  const SizedBox(height: 20),
                                  imgContainer3,
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        24.0, 20.0, 24.0, 8.0),
                                    child: Text(
                                        '''Earn badges and show off your coding skills on your Developer Program profile. Share your solutions with Google for Developers for a chance to be featured!
''',
                                        style: textTheme.bodyMedium),
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: Column(
                                children: <Widget>[
                                  Text('🚨 Your Progress, Your Choice ✅',
                                      style: textTheme.titleLarge),
                                  const SizedBox(height: 20),
                                  imgContainer4,
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        24.0, 20.0, 24.0, 8.0),
                                    child: Text(
                                        '''We value your privacy and don't store game data. This means refreshing the page may reset your progress, but you can always jump back to your favorite stage!
''',
                                        style: textTheme.bodyMedium),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      PageIndicator(
                        tabController: _introTabController,
                        onUpdateCurrentPageIndex: _updateCurrentPageIndex,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(60, 0, 60, 20),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                OutlinedButton(
                  child: const Text('Play now'),
                  onPressed: () {
                    appState.introComplete();
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

  void _retry() {
    widget.game.reset();
    _setAppStateUnloaded();
  }

  void _handlePageViewChanged(int currentPageIndex) {
    _introTabController.index = currentPageIndex;
  }

  void _updateCurrentPageIndex(int index) {
    _introTabController.index = index;
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}
