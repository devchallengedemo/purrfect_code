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
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '/src/game_view/page_indicator.dart';
import '../log/log.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final textController = TextEditingController();
  late PageController _pageViewController;
  late TabController _tabController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var widthOffset = width * 0.66;
    var heightOffset = height * 0.25;
    var maxBoxHeight = 600.0;
    var calculatedHeight =
        min(maxBoxHeight, MediaQuery.of(context).size.height * 0.4);
    var placeHolderImage = 'assets/ui_images/placeholder.png';
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/ui_images/purrfect_code_splash.png'),
            fit: BoxFit.fitHeight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: heightOffset),
            Container(
              width: min(widthOffset, 720),
              height: 40,
              color: const Color.fromARGB(192, 32, 32, 32),
              child: TextField(
                controller: textController,
                autocorrect: false,
                enableSuggestions: false,
                decoration: const InputDecoration(
                  labelText: 'Enter Password',
                ),
                obscureText: true,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              width: 732,
              height: calculatedHeight,
              decoration: BoxDecoration(
                color: const Color.fromARGB(192, 30, 30, 30),
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                children: <Widget>[
                  // ignore: sized_box_for_whitespace
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 8.0),
                    child: SizedBox(
                      width: 700,
                      height: calculatedHeight * 0.7,
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: PageView(
                              controller: _pageViewController,
                              onPageChanged: _handlePageViewChanged,
                              children: <Widget>[
                                Center(
                                  child: Column(
                                    children: <Widget>[
                                      Text('Cat-rescuing Javascript',
                                          style: textTheme.titleLarge),
                                      const SizedBox(height: 10),
                                      Flexible(
                                        child: Image.asset(placeHolderImage),
                                      ),
                                      const SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            24.0, 8.0, 24.0, 8.0),
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
                                      Text('Understanding Your Score',
                                          style: textTheme.titleLarge),
                                      const SizedBox(height: 10),
                                      Flexible(
                                        child: Image.asset(placeHolderImage),
                                      ),
                                      const SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            24.0, 8.0, 24.0, 8.0),
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
                                      Text('Conquer Stages, Claim Badges',
                                          style: textTheme.titleLarge),
                                      const SizedBox(height: 10),
                                      Flexible(
                                        child: Image.asset(placeHolderImage),
                                      ),
                                      const SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            24.0, 8.0, 24.0, 8.0),
                                        child: Text(
                                            '''After each stage, claim badges to showcase your coding prowess on your Developer Program profile. Share your brilliant solutions on social media and tag Google for Developers to get a chance to be showcased and inspire other players.
''',
                                            style: textTheme.bodyMedium),
                                      ),
                                    ],
                                  ),
                                ),
                                Center(
                                  child: Column(
                                    children: <Widget>[
                                      Text('Your Progress, Your Choice',
                                          style: textTheme.titleLarge),
                                      const SizedBox(height: 10),
                                      Flexible(
                                        child: Image.asset(placeHolderImage),
                                      ),
                                      const SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            24.0, 8.0, 24.0, 8.0),
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
                            tabController: _tabController,
                            currentPageIndex: _currentPageIndex,
                            onUpdateCurrentPageIndex: _updateCurrentPageIndex,
                            isOnDesktopAndWeb: _isOnDesktopAndWeb,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  OutlinedButton(
                    style: ButtonStyle(
                      side: WidgetStateProperty.all(const BorderSide(
                          color: Colors.black,
                          width: 2.0,
                          style: BorderStyle.solid)),
                      backgroundColor:
                          WidgetStateProperty.resolveWith<Color>((states) {
                        if (states.contains(WidgetState.disabled)) {
                          return Colors.transparent;
                        }
                        return Colors.lightBlue;
                      }),
                      overlayColor:
                          WidgetStateProperty.resolveWith<Color>((states) {
                        if (states.contains(WidgetState.pressed)) {
                          return Colors.lightBlue;
                        }
                        return Colors.lightBlue;
                      }),
                    ),
                    onPressed: () {
                      //Navigator.pushNamed(context, 'game');
                      _validatePassword(textController.text, context);
                    },
                    child: const Text(
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24.0,
                        ),
                        'Play Purrfect Code'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _validatePassword(String text, BuildContext context) {
    final str = utf8.decode(base64.decode('OXFlaWJFS3JzVlZMMmppeWFpWWI='));
    logger.i('decoded string= $str, password= $text');
    if (text == str) {
      Navigator.pushNamed(context, 'Z2FtZQ==');
    } else {
      showDialog<void>(
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
            title: const Text('Invalid Password'),
            actions: <Widget>[
              TextButton(
                child: const Text('Retry'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _handlePageViewChanged(int currentPageIndex) {
    if (!_isOnDesktopAndWeb) {
      return;
    }
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  bool get _isOnDesktopAndWeb {
    if (kIsWeb) {
      return true;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return true;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return false;
    }
  }
}
