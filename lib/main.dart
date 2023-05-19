import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:hacka_flutter_app/AIRecommendations.dart';
import 'package:hacka_flutter_app/PlacesScreen.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:multi_select_flutter/multi_select_flutter.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
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

    var prompt =
        "Your response must only by a json.Assume that I am a software engineer and your answer must only be a valid json,nothing else. You’re an REST API that returns a json with the best travel recommendations."
        "Can you give trip recomendations ? Im departing from $origin,the budget for the trip is $moneySpent usd dollars ,total passengers are $travelers, the activites recommended must be related to $interest only, the length of trip is going to be $days days."
        " The format of returned json must be: {“results“:[{“city“:“Buenos Aires,Argentina“,“estimated_cost“:200,“activities“:[“a night club in buenos Aires“,“Go to Casa Rosada“],“avoid_neighborhoods“:[{“lat“:-34.6343603,“long“:-58.4059233,“name“:“danger neighborhoods“ }]}] }."
        "You must provide a RFC8259 compliant JSON response following this format without deviation.You only must return a json object and nothing else."
        "you must recommend the best cities price quality ratio that are appropriate for the given budget,the plane ticket,accommodations,transportation etc must be within given budget,at least 5 cities must be recommended."
        " you can't recommend the same city of departure.You must recommend 5 activities according to interests given. The budget includes plane tickets, hotels, and food."
        "the total cost of the trip cannot exceed the given budget,the sum of plane tickets, hotels, foods and activities must be in budget range with all costs included for the quantity persons going in the trip."
        "You must calculate an average price for the flight ticket, the formula is:the distance between city of departure and city of destination in miles multiplied it for 0,40 USD dollars per mile.The flight ticket price can not exceed 50% of budget.You must add hotels,foods and activities prices also."
        "you can use the values for existing trips in google until 2021."
        "Add a field named 'estimated_cost' that must be always a integer type object, with an estimated total cost of the for the trip given including transportation,flights,food,etc."
        "Result must return at least 5 recommended cities for the trip, and return a list of at least 5 activities related to interest given. "
        "in field ‘activities’ explaining as a tourist guide what to do at each city.Also for each city add a list of at least 2 dangerous/high criminality neighborhoods in field called avoid_neighborhoods , with the name of avoided neighborhood and the latitude and longitude info of most dangerous/high criminality not recommended neighborhood for womens to stay. ";

    logger.i(prompt);

    final chatCompletion = await OpenAI.instance.chat
        .create(model: "gpt-3.5-turbo", maxTokens: 2000, messages: [
      OpenAIChatCompletionChoiceMessageModel(
          content: prompt, role: OpenAIChatMessageRole.user)
    ]);

    // final chatCompletion = await OpenAI.instance.completion.create(
    //   model: 'text-davinci-003',
    //   maxTokens: 2000,
    //   prompt: prompt,
    // );
    logger.i(chatCompletion.choices.first.message.content);

    chatgptResponse = chatCompletion.choices.first.message.content;
    if (isValidJson(chatgptResponse)) {
      setState(() {
        isLoading = false;
      });
      return chatgptResponse;
    } else {
      setState(() {
        isLoading = true;
      });
      return callChatGPTAPI();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg3.jpeg"),
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
                      decoration: const InputDecoration(
                          labelText: 'Origin',
                          hintStyle: TextStyle(color: Colors.white)),
                      onChanged: (value) {
                        setState(() {
                          origin = value;
                        });
                      },
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Budget USD'),
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
                      decoration: const InputDecoration(
                          labelText: 'Number of travelers'),
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
                              FocusScope.of(context).unfocus();

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

  bool isValidJson(String jsonString) {
    try {
      jsonDecode(jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }
}
