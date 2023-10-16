import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SingleChat extends StatefulWidget {
  // const SingleChat(this.title, {Key? key}) : super(key: key);
  const SingleChat({Key? key}) : super(key: key);

  // final String title;

  @override
  State<SingleChat> createState() => _SingleChatState();
}

class _SingleChatState extends State<SingleChat> {
  String? _apiText;
  final apiKey = dotenv.get('CHATGPT_API_KEY');
  String searchText = '';

  @override
  void initState() {
    super.initState();

    // callApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Builder(builder: (context) {
                  final text = _apiText;

                  if (text == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  );
                }),
              ),
              TextField(
                decoration: const InputDecoration(
                  hintText: '検索したいテキスト',
                ),
                onChanged: (text) {
                  searchText = text;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  // 検索
                  callApi();
                },
                child: const Text('検索'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void callApi() async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(<String, dynamic>{
        'model': 'gpt-3.5-turbo',
        'messages': [
          {"role": "user", "content": searchText}
        ]
      }),
    );
    final body = response.bodyBytes;
    final jsonString = utf8.decode(body);
    final json = jsonDecode(jsonString);
    final content = json['choices'][0]['message']['content'];

    setState(() {
      _apiText = content;
    });
  }
}
