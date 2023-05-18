import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:hacka_flutter_app/AIRecommendations.dart';
import 'package:hacka_flutter_app/PlacesScreen.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:multi_select_flutter/multi_select_flutter.dart';

void main() {
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class Interest {
  final String name;
  final String value;

  Interest({required this.name, required this.value});
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var logger = Logger(
    printer: PrettyPrinter(),
  );

  final List<Interest> _interests = [
    Interest(name: 'Nature', value: 'Nature'),
    Interest(name: 'Art and Museums', value: 'Art and Museums'),
    Interest(name: 'Shopping', value: 'Shopping'),
    Interest(name: 'Gastronomy', value: 'Gastronomy'),
    Interest(name: 'Sports', value: 'Sports'),
  ];
  List<String> selectedInterests = [];
  String interest = "";
  String origin = "";
  double? moneySpent = 0;
  bool isLoading = false;

  String chatgptResponse = "";

  int days = 0;
  int travelers = 0;

  Future<String> callChatGPTAPI() async {
    setState(() {
      isLoading = true;
    });
    OpenAI.apiKey = "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";

    var prompt = "Assume that I am a software engineer and your answer must only be a valid json,nothing else. You're an REST API that return recommendations for travelers, at least 5 cities must be recommended and 5  activites must be recommended according to interests given."
            " the api calculates a estimated vacation cost from the origin and must return recommended cities for the trip that are inside budget, the sum of plane tickets,hotels,foods must be in budget range  with all costs included,plane ticket price is around 0.17 usd dollars per mile and you have tu calculate the distance betwwen origin and destination."
        " Distance of origin from destination in miles * mile price, cant exceed 50% of budget.Add a field named estimated_cost of type double, with an estimated cost of trip"
            " \n Result must return at least 5 recommended cities for the trip, and return a list of at least 5 activities related to interest given. (with a lenght of 50 characters at least) in field 'activities' explaining as a tourist guide what to do at each city" +
        ".Also for each city add a list of at least 2 dangerous/high criminality neighborhoods in field called avoid_neighborhoods , with the name of avoided neighborhood and the latitude and longitude info of most dangerous/high criminality not recommended neighborhood for womens to stay."
            "The origin in this case is " +
        origin +
        " and the budget is " +
        moneySpent.toString() +
        " usd dollars,for " +
        travelers.toString() +
        " person and " +
        "you must recommend 5 activities related with " + interest + ", the lenght of trip is going to be " +
        days.toString() +
        " days of vacations. The format of returned json must be: {“results“:[{“city“:“Buenos Aires“,“estimated_cost“:200,“activities“:[“a night club in buenos Aires“,“Go to Casa Rosada“],“avoid_neighborhoods“:[{“lat“:-34.6343603,“long“:-58.4059233,“name“:“danger neighborhoods“ }]}] }"
    ".Note that this are mocked values,and you can't use the sample as a result and only provide a  RFC8259 compliant JSON response following this format without deviation.You only must return a json object and nothing else";

    logger.i(prompt);

    final chatCompletion =
        await OpenAI.instance.chat.create(model: "gpt-3.5-turbo", messages: [
      OpenAIChatCompletionChoiceMessageModel(
          content: prompt, role: OpenAIChatMessageRole.user)
    ]);


    // final chatCompletion = await OpenAI.instance.completion.create(
    //   model: 'text-davinci-003',
    //   maxTokens: 2000,
    //   prompt: prompt,
    // );
    logger.i(chatCompletion.choices.first.message.content);
    setState(() {
      isLoading = false;
    });
    chatgptResponse = chatCompletion.choices.first.message.content;
    return chatgptResponse;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/1.jpeg"),
            fit: BoxFit.fill,
          ),
        ),
          child: Container(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(labelText: 'Origin',hintStyle: TextStyle(color: Colors.white)),
                        onChanged: (value) {
                          setState(() {
                            origin = value;
                          });
                        },
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Budget USD'),
                        onChanged: (value) {
                          setState(() {
                            moneySpent = double.tryParse(value);
                          });
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        decoration:
                            const InputDecoration(labelText: 'Number of days'),
                        onChanged: (value) {
                          setState(() {
                            days = int.parse(value);
                          });
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        decoration:
                            const InputDecoration(labelText: 'Number of travelers'),
                        onChanged: (value) {
                          setState(() {
                            travelers = int.parse(value);
                          });
                        },
                      ),
                      const SizedBox(height: 16.0),
                      MultiSelectDialogField<String>(
                        title: const Text('Interest'),
                        buttonText: const Text('Select Interests'),
                        items: _interests
                            .map((interest) => MultiSelectItem<String>(
                                  interest.value,
                                  interest.name,
                                ))
                            .toList(),
                        listType: MultiSelectListType.CHIP,
                        onConfirm: (values) {
                          setState(() {
                            selectedInterests = values;
                            interest = selectedInterests.join(', ');
                          });
                        },
                      ),
                      const SizedBox(height: 32.0),
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                callChatGPTAPI().then((response) {
                                  Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                          builder: (BuildContext context) {
                                    return PlacesScreen(
                                        placesList: PlacesAI.fromJson(
                                                jsonDecode(chatgptResponse))
                                            .results);
                                  }));
                                }).catchError((error) {
                                  logger.e(error);

                                  // Handle API error here
                                });
                              },
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Search AI Destinations'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ),
      ),
    );
  }
}
