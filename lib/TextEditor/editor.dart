import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class EditorTextSong extends StatefulWidget {
  const EditorTextSong({super.key});


  @override
  State<EditorTextSong> createState() => _EditorTextSongState();
}

QuillController _controller = QuillController.basic();

class _EditorTextSongState extends State<EditorTextSong> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QuillToolbar.basic(controller: _controller),
        Expanded(
          child: Container(
            child: QuillEditor.basic(
              controller: _controller,
              readOnly: false, // true for view only mode
            ),
          ),
        )
      ],
    );
  }
}