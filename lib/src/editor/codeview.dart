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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'theme.dart';

class CodeView extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  CodeView({
    required this.controller,
    required this.scrollController,
    required this.focusNode,
    super.key,
  });

  final ScrollController scrollController;
  final FocusNode focusNode;
  final CodeController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: viewportConstraints.maxHeight,
          ),
          child: CodeTheme(
            data: CodeThemeData(styles: purrfectCodeTheme),
            child: SingleChildScrollView(
              child: CodeField(
                textStyle:
                    const TextStyle(fontFamily: 'ptmono', fontSize: 18.0),
                //note: hiding line numbers due to issues with gutter text alignment;
                //https://github.com/akvelon/flutter-code-editor/issues/260
                gutterStyle: const GutterStyle(
                  width: 0.0,
                  showLineNumbers: false,
                  textStyle: TextStyle(
                    color: Color(0xff7e6e79),
                  ),
                ),
                controller: controller,
              ),
            ),
          ),
        ),
      );
    });
  }
}
