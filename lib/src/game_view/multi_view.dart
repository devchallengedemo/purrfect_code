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
  final void Function(int) callback;
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

    var codeTxt =
        appState.state == AppCurrentState.running ? 'Running...' : 'Run Code';
    const lowerBarHeight = 72.0;
    var lowerBarInset = width / 16.0;
    var gameViewWidth = 256.0;
    var gameViewHeight = 240.0;
    var minEditorWidth = 500;

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

    var editorWidth = width - gameViewWidth - 64;
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
                Padding(
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
                                const Tab(child: Text('Code The Robot')),
                                Tab(
                                  child: ElevatedButton(
                                    style: flatButtonStyle,
                                    onPressed: () {
                                      widget.callback(1);
                                    },
                                    child: const Text('Restart'),
                                  ),
                                ),
                                Tab(
                                  child: ElevatedButton(
                                    style: flatButtonStyle,
                                    onPressed: _runCode,
                                    child: Text(codeTxt),
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
                                  color: const Color.fromARGB(200, 72, 80, 88),
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: gameViewWidth,
                    height: gameViewHeight,
                    child: GameWidget(game: widget.game, autofocus: false),
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
                      child: const Text('API Reference'),
                      onPressed: () {
                        widget.callback(2);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: lowerBarInset),
                    child: TextButton(
                      child: const Text(''),
                      onPressed: () {},
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: lowerBarInset),
                    child: TextButton(
                      child: const Text(''),
                      onPressed: () {},
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
}
