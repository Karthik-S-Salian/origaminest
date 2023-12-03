import 'package:flutter/material.dart';

class QuizResult extends StatelessWidget {
  final int mark;
  const QuizResult({super.key, required this.mark});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("mark is $mark"));
  }
}
