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
    Interest(name: 'Naturaleza', value: 'naturaleza'),
    Interest(name: 'Arte y museos', value: 'arte_museos'),
    Interest(name: 'Compras', value: 'compras'),
    Interest(name: 'Gastronomia', value: 'gastronomia'),
    Interest(name: 'Deportes', value: 'deportes'),
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

    var prompt = "Assume that I am a software engineer and your answer must only be a valid json,nothing else. You're an REST API that return recommendations for women trvelers, at least 5"
        " the api calculates a estimated vacation cost from the origin and must return recommended cities for the trip that are inside budget, the sum of plane tickets,hotels,foods must be inside budget. "
        "The recommendations must be inside budget with all costs included,p lane ticket price is around 0.17 usd dollars per mile and you have tu calculate the distance betwwen origin and destination. Distance of origin from destination in miles * mile price, cant exceed 50% of budget "
        " \n Result must include list of al least 5 recommended cities for the trip, and at least a list of 5  activites recommended for the trip of the city,the recomendation must have a minimun lenght of 50 characters, having in mind that the interest is" + interest+ ".Also for each city add a list of f dangerous/high criminality neighborhoods in field called avoid_neighborhoods  ,with the name of avoided neighborhood and the latitude and longitude info of each dangerous/high criminality not recommended neighborhood "
        ".Take some reference values before 2021 to get estimated plane tickets price and hotels price info that is ok with the budget."
        "The origin in this case is " +
        origin +
        " and the budget is " +
        moneySpent.toString() +
        " usd dollars for "+travelers.toString() + " person and " +days.toString() +"days."
            "An example of returned json format: {“results“:[{“city“:“Buenos Aires“,“recommendations“:[“a night club in buenos Aires“,“Go to Casa Rosada“],“avoid_neighborhoods“:{“lat“:-34.6343603,“long“:-58.4059233,“name“:“danger neighborhoods“ }}] }";
    ".\n Note that this are mocked values,and you can't use the sample as a result and only provide a  RFC8259 compliant JSON response following this format without deviation";

    final chatCompletion = await OpenAI.instance.completion.create(
      model: 'text-davinci-003',
      maxTokens: 2000,
      prompt: prompt,
    );
    logger.i(chatCompletion.choices.first.text);
    setState(() {
      isLoading = false;
    });
    chatgptResponse = chatCompletion.choices.first.text;
    return chatgptResponse;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hackathon'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(labelText: 'Origin'),
                    onChanged: (value) {
                      setState(() {
                        origin = value;
                      });
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Budget'),
                    onChanged: (value) {
                      setState(() {
                        moneySpent = double.tryParse(value);
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(labelText: 'Number of days'),
                    onChanged: (value) {
                      setState(() {
                        days = int.parse(value);
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(labelText: 'Number of travelers'),
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
                              Navigator.of(context).push(MaterialPageRoute<void>(
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
                        : const Text('Buscar Destinos'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
