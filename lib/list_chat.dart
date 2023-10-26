import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Message {
  const Message(this.message, this.sendTime, {required this.fromChatGpt});

  final String message;
  final bool fromChatGpt;
  final DateTime sendTime;

  // 名前付きコンストラクタ
  Message.waitResponse(DateTime now)
      : this('', DateTime.now(), fromChatGpt: true);
}

class ListChat extends StatefulWidget {
  const ListChat({super.key, required this.title});

  final String title;

  @override
  State<ListChat> createState() => _ListChatState();
}

class _ListChatState extends State<ListChat> {
  final openAI = OpenAI.instance.build(
    token: dotenv.get('CHATGPT_API_KEY'),
    enableLog: true,
  );

  final _textEditingController = TextEditingController(
    text: '検索したいテキスト',
  );
  final _scrollController = ScrollController();

  bool _isLoading = false;
  final _messages = <Message>[];

  static Color colorMyMessage = Color.fromARGB(0xFF, 0x8a, 0xe1, 0x7e);
  static Color colorOthersMessage = Color.fromARGB(0xFF, 0xff, 0xff, 0xff);
  static Color colorAvatar = Color.fromARGB(0xFF, 0x76, 0x5a, 0x44);
  static Color colorInput = Color.fromARGB(0xFF, 0xf5, 0xf5, 0xf5);

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final showLoadingIcon =
                          _isLoading && index == _messages.length - 1;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: message.fromChatGpt
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (message.fromChatGpt)
                              SizedBox(
                                  // width: deviceWidth * 0.1,
                                  width: 40,
                                  child: CircleAvatar(
                                      backgroundColor: colorAvatar,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Image.asset(
                                            'assets/images/openai.png'),
                                      ))),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (!message.fromChatGpt)
                                  Text(_formatDateTime(message.sendTime)),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    constraints: BoxConstraints(
                                        maxWidth: deviceWidth * 0.7),
                                    decoration: BoxDecoration(
                                      color: message.fromChatGpt
                                          ? colorOthersMessage
                                          : colorMyMessage,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: showLoadingIcon
                                          ? const CircularProgressIndicator()
                                          : Text(
                                              message.message,
                                              style: TextStyle(fontSize: 16),
                                            ),
                                    ),
                                  ),
                                ),
                                if (message.fromChatGpt)
                                  Text(_formatDateTime(message.sendTime)),
                              ],
                            ),
                          ],
                        ),
                      );
                    })),
            Row(
              children: [
                Expanded(
                    child: TextField(
                  style: TextStyle(fontSize: 14),
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    fillColor: colorInput,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                )),
                IconButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            _onTapSend(_textEditingController.text);
                          },
                    icon: Icon(
                      Icons.send,
                      color: _isLoading ? Colors.grey : Colors.black,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _onTapSend(String userMessage) async {
    setState(() {
      _isLoading = true;
      _messages.addAll([
        Message("$userMessage", DateTime.now(), fromChatGpt: false),
        Message.waitResponse(DateTime.now()),
      ]);
      _scrollDown();
    });

    try {
      final chatGptMessage = await _sendMessage(userMessage);
      setState(() {
        _messages.last =
            Message(chatGptMessage.trim(), DateTime.now(), fromChatGpt: true);
        _isLoading = false;
      });
      _scrollDown();
    } catch (error) {
      print("Error sending message: $error");
      // エラー処理を追加する場合はここに記述
    }
  }

  Future<String> _sendMessage(String message) async {
    try {
      final request = CompleteText(
        prompt: message,
        model: TextDavinci3Model(),
        maxTokens: 200,
      );

      final response = await openAI.onCompletion(request: request);
      return response!.choices.first.text;
    } catch (error) {
      print("Error sending message: $error");
      // エラー処理を追加する場合はここに記述
      rethrow;
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn);
    });
  }
}
