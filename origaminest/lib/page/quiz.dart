import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:origaminest/page/quiz_result.dart';

class Quiz extends StatefulWidget {
  final String cls;
  const Quiz({super.key, required this.cls});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  int currentQuestionIndex = 0;
  int mark = 0;

  Future<List<_MCQ>> fetchMcqs() async {
    final response = await http.post(
      Uri.parse('${dotenv.env['BACKEND_BASE_URL']}/mcqs'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'cls': "cow",
      }),
    );

    //print(MCQ.fromJsonList(jsonDecode(response.body)));
    return _MCQ.fromJsonList(jsonDecode(response.body));
  }

  void onOptionSelected(
      String option, String answer, BuildContext context, int length) {
    if (option == answer) mark += 1;

    if (currentQuestionIndex == length - 1) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => QuizResult(
                mark: mark,
              )));
      return;
    }
    setState(() {
      currentQuestionIndex += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cls} Quiz'),
      ),
      body: FutureBuilder<List<_MCQ>>(
        future: fetchMcqs(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              final mcq = snapshot.data![currentQuestionIndex];
              final options = mcq.options;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(mcq.question),
                    const SizedBox(
                      height: 30,
                    ),
                    for (final option in options)
                      ElevatedButton(
                          onPressed: () => {
                                onOptionSelected(
                                    option, mcq.answer, context, options.length)
                              },
                          child: Text(option))
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}

class _MCQ {
  final String question;
  final List<String> options;
  final String answer;

  _MCQ(this.question, List<String> options)
      : answer = options[0],
        options = shuffleoptions(options);

  static List<String> shuffleoptions(List<String> options) {
    options.shuffle();
    return options;
  }

  factory _MCQ.fromJson(Map<String, dynamic> json) {
    try {
      return _MCQ(
        json['question'] as String,
        List<String>.from(json['options'] as List),
      );
    } catch (e) {
      print('Exception during MCQ.fromJson: $e');
      print('Problematic JSON: $json');
      rethrow;
    }
  }

  static List<_MCQ> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => _MCQ.fromJson(json)).toList();
  }

  List<String> getOptions() {
    return options;
  }
}
