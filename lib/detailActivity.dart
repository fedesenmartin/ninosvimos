import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';

class MyScreen extends StatefulWidget {
  final String myString;

  MyScreen({required this.myString});

  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  bool isLoading = false;

  String explianed = "";

  Future<void> callChatGPTAPI() async {
    setState(() {
      isLoading = true;
    });
    OpenAI.apiKey = "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";

    var prompt = "give more detailed about " + widget.myString;

    final chatCompletion = await OpenAI.instance.chat
        .create(model: "gpt-3.5-turbo", maxTokens: 2000, messages: [
      OpenAIChatCompletionChoiceMessageModel(
          content: prompt, role: OpenAIChatMessageRole.user)
    ]);

    setState(() {
      isLoading = false;
      explianed = chatCompletion.choices.first.message.content;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    callChatGPTAPI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.myString),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(

              child: Text(explianed)
        ),
            ),
      ),
    );
  }
}
