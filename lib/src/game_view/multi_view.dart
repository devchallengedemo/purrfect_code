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

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '/src/api_module/game_api.dart';
import '/src/app_state.dart';
import '/src/editor/editor.dart';
import '/src/log/log.dart';
import '/src/sokoban_view/sokoban_game.dart';

// ignore: must_be_immutable
class MultiView extends StatefulWidget {
  BuildContext context;
  SokobanGame game;
  CommandEditor editor;
  void Function(int) callback;
  bool showCommandEditor = true;

  MultiView({
    super.key,
    required this.context,
    required this.game,
    required this.editor,
    required this.callback,
    bool showCommandEditor = true,
  });

  @override
  State<StatefulWidget> createState() => _ThreeItemViewState();
}

class _ThreeItemViewState extends State<MultiView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 4);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    var volumeIcon =
        appState.muted() ? Icons.volume_mute_rounded : Icons.volume_up_rounded;
    var codeTxt =
        appState.state == AppCurrentState.running ? 'Running...' : 'Run Code';
    const lowerBarHeight = 72.0;
    var lowerBarInset = width / 64.0;
    var gameViewWidth = 256.0;
    var gameViewHeight = 240.0;
    var minEditorWidth = 500;

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
                widget.callback(3);
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
              widget.callback(3);
            },
          );

    if (width > minEditorWidth + 512 && height > lowerBarHeight + 480) {
      gameViewWidth = 512;
      gameViewHeight = 480;
    }
    if (width > minEditorWidth + 768 && height > lowerBarHeight + 720) {
      gameViewWidth = 768;
      gameViewHeight = 720;
    }
    if (width > minEditorWidth + 1024 && height > lowerBarHeight + 960) {
      gameViewWidth = 1024;
      gameViewHeight = 960;
    }

    var editorWidth = min(1000.0, width - gameViewWidth - 64);
    var geminiHeight = height - gameViewHeight - 48;
    if (geminiHeight < gameViewHeight * 2) geminiHeight = gameViewHeight * 2.0;

    final flatButtonStyle = TextButton.styleFrom(
      minimumSize: const Size(258, 38),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
      ),
    );

    return Column(
      children: [
        Expanded(
          child: Container(
            color: const Color.fromARGB(255, 32, 32, 32),
            height: height,
            width: width,
            alignment: Alignment.center,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: editorWidth,
                      height: height,
                      child: Container(
                        color: const Color.fromARGB(255, 32, 32, 32),
                        alignment: Alignment.center,
                        child: DefaultTabController(
                          length: 4,
                          child: Scaffold(
                            appBar: AppBar(
                              toolbarHeight: 0,
                              bottom: TabBar(
                                //note: https://github.com/flutter/flutter/pull/96252
                                //had to disable splash and overlay color
                                splashFactory: NoSplash.splashFactory,
                                overlayColor:
                                    WidgetStateProperty.resolveWith<Color?>(
                                        (Set<WidgetState> states) {
                                  // Use the default focused overlay color
                                  return states.contains(WidgetState.focused)
                                      ? null
                                      : Colors.transparent;
                                }),
                                controller: _tabController,
                                onTap: (index) {
                                  if (_tabController.indexIsChanging) {
                                    if (index > 0) {
                                      _tabController.index =
                                          _tabController.previousIndex;
                                    } else {
                                      setState(() {
                                        _tabController.index = index;
                                      });
                                    }
                                  }
                                },
                                tabs: [
                                  const Tab(
                                      child: Text(
                                    'Code The Robot',
                                    overflow: TextOverflow.clip,
                                    softWrap: false,
                                  )),
                                  Tab(
                                    child: ElevatedButton(
                                      style: flatButtonStyle,
                                      onPressed: _runCode,
                                      child: Text(codeTxt,
                                          overflow: TextOverflow.clip,
                                          softWrap: false),
                                    ),
                                  ),
                                  Tab(
                                    child: ElevatedButton(
                                      style: flatButtonStyle,
                                      onPressed: () {
                                        widget.callback(1);
                                      },
                                      child: const Text(
                                        'Retry',
                                        overflow: TextOverflow.clip,
                                        softWrap: false,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            body: TabBarView(
                              physics: const NeverScrollableScrollPhysics(),
                              controller: _tabController,
                              children: [
                                SizedBox(
                                  width: editorWidth,
                                  height: height,
                                  child: Container(
                                    color:
                                        const Color.fromARGB(200, 72, 80, 88),
                                    alignment: Alignment.center,
                                    child: widget.editor,
                                  ),
                                ),
                                const Icon(Icons.dangerous_outlined),
                                const Icon(Icons.dangerous_outlined),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: gameViewWidth,
                    height: gameViewHeight,
                    child: Stack(children: <Widget>[
                      GameWidget(game: widget.game, autofocus: false),
                      Positioned.fill(
                        child: Align(
                          alignment: const Alignment(0.95, -0.95),
                          child: SizedBox(
                            height: 32.0,
                            width: 64.0,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 32, 32, 32),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  side: const BorderSide(
                                    color: Color.fromARGB(255, 78, 80, 82),
                                    width: 3.0,
                                  ),
                                ),
                              ),
                              child: Icon(volumeIcon),
                              onPressed: () {
                                _setMute(appState.muted());
                              },
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: width,
          height: lowerBarHeight,
          child: Container(
            color: const Color.fromARGB(255, 32, 32, 32),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: lowerBarInset),
                    child: TextButton(
                      child: const Text(
                        'API Reference',
                        overflow: TextOverflow.visible,
                        softWrap: false,
                      ),
                      onPressed: () {
                        widget.callback(2);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: lowerBarInset),
                    child: prevButton,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: lowerBarInset),
                    child: nextButton,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: lowerBarInset),
                    child: TextButton(
                      child: const Text(
                        'How This Was Made',
                        overflow: TextOverflow.visible,
                        softWrap: false,
                      ),
                      onPressed: () => launchUrl(
                          Uri.parse('https://developers.google.com/')),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: lowerBarInset),
                    child: TextButton(
                      child:
                          Image.asset('assets/ui_images/g4d_logo_lockup.png'),
                      onPressed: () => launchUrl(
                          Uri.parse('https://developers.google.com/')),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  void _runCode() {
    if (appState.state == AppCurrentState.running) return;
    widget.callback(0);
    var code = widget.editor.getText();
    code += '\n__completionHit__();';
    logger.i('CODE TO RUN:\n$code');
    evalJs(code);
  }

  void _setMute(bool muted) {
    setState(() {
      appState.setMute(muted);
    });
  }
}
