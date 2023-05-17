import 'dart:developer';

import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:multi_select_flutter/multi_select_flutter.dart';

void main() {
  runApp(MyApp());
}

class Interest {
  final String name;
  final String value;

  Interest({required this.name, required this.value});
}

class MyApp extends StatefulWidget {
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
  String? selectedMonth;
  double? moneySpent;
  bool isLoading = false;

  String chatgptResponse=  "";

  Future<String> callChatGPTAPI() async {
    setState(() {
      isLoading = true;
    });
    OpenAI.apiKey=  "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";

    const prompt= "Assume that I am a software engineer and your answer must only be a json,nothing else. You're an REST API that returns a valid Json object; that contains a"
        " list of top 10 cities, and at least 5 recommendation of places for visit while traveling having in mind that the interest is sports,and for each city also add avoid_neiberhoods info with their lat and long data "
        "that is the name danger neiberhoods.The origin is buenos aires and the budget is 100 usd. The trip cost if about 3 dollars a mile via plane so take in mind that at momento of picking cities"
        "The format of the json could be: {“results“:[{“city“:“Buenos Aires“,“recomendations“:“a night club in buenas Aires“,“avoid_neiberhoods“:{“lat“:1231231.2321,“long“:1231231.23,“name“:“villa 1 11 14“}}]}}";


    final chatCompletion = await OpenAI.instance.completion.create(
      model: 'text-davinci-003',
      maxTokens: 2000,
      prompt:prompt ,
    );

    logger.i(chatCompletion.choices.first.text);
    
    setState(() {
      isLoading = false;
    });
    
    chatgptResponse = chatCompletion.toString();
    
    return chatgptResponse;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Hackaton'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Month'),
                    value: selectedMonth,
                    items: const [
                      DropdownMenuItem<String>(
                          value: 'Enero', child: Text('Enero')),
                      DropdownMenuItem<String>(
                          value: 'Febrero', child: Text('Febrero')),
                      DropdownMenuItem<String>(
                          value: 'Marzo', child: Text('Marzo')),
                      DropdownMenuItem<String>(
                          value: 'Abril', child: Text('Abril')),
                      DropdownMenuItem<String>(
                          value: 'Mayo', child: Text('Mayo')),
                      DropdownMenuItem<String>(
                          value: 'Junio', child: Text('Junio')),
                      DropdownMenuItem<String>(
                          value: 'Julio', child: Text('Julio')),
                      DropdownMenuItem<String>(
                          value: 'Agosto', child: Text('Agosto')),
                      DropdownMenuItem<String>(
                          value: 'Septiembre', child: Text('Septiembre')),
                      DropdownMenuItem<String>(
                          value: 'Octubre', child: Text('Octubre')),
                      DropdownMenuItem<String>(
                          value: 'Noviembre', child: Text('Noviembre')),
                      DropdownMenuItem<String>(
                          value: 'Diciembre', child: Text('Diciembre'))
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedMonth = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            callChatGPTAPI().then((response) {
                              chatgptResponse = response;
                            }).catchError((error) {
                              logger.e(error);

                              // Handle API error here
                            });
                          },
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Buscar Destinos'),
                  ),
                  Text(chatgptResponse)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
