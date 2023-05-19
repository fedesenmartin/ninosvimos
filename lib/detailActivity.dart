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
        .create(model: "gpt-3.5-turbo", maxTokens: 500, messages: [
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
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white),
        backgroundColor: Colors.blue,
        elevation: 0, // Remove the shadow
        title: Text(widget.myString),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/claro.jpeg"),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(

          child: isLoading
              ? CircularProgressIndicator()
              : Padding(
                padding: const EdgeInsets.fromLTRB(8,2,8,0),
                child: Container(

                child: SingleChildScrollView(child: Text(style: TextStyle(fontSize: 16),explianed))
          ),
              ),
        ),
      ),
    );
  }
}
