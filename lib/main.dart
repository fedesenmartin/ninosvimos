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
  String? origin;
  double? moneySpent;
  bool isLoading = false;

  String chatgptResponse = "";

  Future<String> callChatGPTAPI() async {
    setState(() {
      isLoading = true;
    });
    OpenAI.apiKey = "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";

    const prompt =
        "Assume that I am a software engineer and your answer must only be a json,nothing else. You're an REST API of a top ten worldwide IT tech that provides info to a flutter client, this api must return a valid Json object; that contains a"
        " list of al least 5 cities, and at least 5 recommendation of places for visit while traveling in this city; having in mind that the interest is sports,and for each city. Also add to the json info of dangerous or not recommended to visit neiberhoods in the field avoid_neiberhoods ,with the latitude and longitude info of each avoided neiberhoods  "
        "the name danger neiberhoods.The origin is buenos aires and the budget for all the trip is 100 usd. Take some reference values beofre 2021 to get estimated plane tickets and hotels info that is ok with the budget.The trip cost if about 3 dollars a mile via plane so take in mind that at moment of picking cities"
        ".Double check that the json MUST be valid and well formed json. An example of the json could be : {“results“:[{“city“:“Buenos Aires“,“recommendations“:“a night club in buenos Aires“,“avoid_neiberhoods“:{“lat“:-34.6343603,“long“:-58.4059233,“name“:“villa 1 11 14“}}]}";
    ".Note that you can't use the sample as a result";

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
        title: const Text('Hackaton'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration:
                  const InputDecoration(labelText: 'Origin'),
                  onChanged: (value) {
                    setState(() {
                      origin = value;
                    });
                  },
                ),

                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Money to Spend'),
                  onChanged: (value) {
                    setState(() {
                      moneySpent = double.tryParse(value);
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
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                const SizedBox(height: 16.0),
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
    );
  }
}
