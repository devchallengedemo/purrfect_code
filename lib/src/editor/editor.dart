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
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'codeview.dart';

class CommandEditor extends StatefulWidget {
  const CommandEditor({
    super.key,
    this.path = '',
    required this.controller,
  });

  final String path;
  final CodeController controller;

  @override
  // ignore: library_private_types_in_public_api
  _CommandEditor createState() => _CommandEditor();

  String getText() {
    return controller.text;
  }

  void resetText() {
    controller.text = '';
  }

  void setText(String txt) {
    controller.text = txt;
  }

  int getSemicolonCount() {
    return ';'.allMatches(controller.text).length;
  }

  int getBracesCount() {
    return '}'.allMatches(controller.text).length;
  }
}

class _CommandEditor extends State<CommandEditor> {
  final _editorFocusNode = FocusNode();
  final _editorScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CodeView(
      scrollController: _editorScrollController,
      focusNode: _editorFocusNode,
      controller: widget.controller,
    );
  }
}
