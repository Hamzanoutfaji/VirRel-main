import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const apiKey =
    'AIzaSyDfBROsV_89zpLV6YaYg7_6TErTK5ECRos'; // Replace with your actual API key

class ChatAIScreen extends StatefulWidget {
  @override
  _ChatAIScreenState createState() => _ChatAIScreenState();
}

class _ChatAIScreenState extends State<ChatAIScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> chatMessages = [];
  bool isLoading = false;
  int listCounter = 1;

  Future<void> generateResponse(String prompt) async {
    if (prompt.isEmpty) return;

    setState(() {
      isLoading = true;
      chatMessages.add({"role": "user", "text": prompt});
    });

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.text(
        "You are a physiotherapy support assistant. Only answer questions about physiotherapy and exercise. Your job is to provide exercises to relieve the patient when they have pain.",
      ),
      generationConfig: GenerationConfig(
        temperature: 0.9,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 800,
        responseMimeType: 'text/plain',
      ),
    );

    final content =
        chatMessages
            .map(
              (message) =>
                  Content.text("${message['role']}: ${message['text']}"),
            )
            .toList();

    content.add(Content.text("User question: $prompt"));

    try {
      final response = await model.generateContent(content);
      String aiResponse = response.text ?? "No response received.";

      aiResponse = aiResponse.replaceAllMapped(
        RegExp(r'^(\d+)\.\s+', multiLine: true),
        (match) => "${listCounter++}. ",
      );

      aiResponse = aiResponse
          .replaceAllMapped(
            RegExp(r'\*(\w[\w\s]*?)\*'),
            (match) => match.group(1) ?? '',
          )
          .replaceAllMapped(
            RegExp(r'\*\*(.*?)\*\*'),
            (match) => "<b>${match.group(1)}</b>",
          )
          .replaceAll(RegExp(r'\n'), '\n');

      setState(() {
        chatMessages.add({"role": "ai", "text": aiResponse});
      });
    } catch (e) {
      setState(() {
        chatMessages.add({"role": "ai", "text": "Error: $e"});
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }

    _controller.clear();
  }

  Widget buildRichText(String text) {
    List<InlineSpan> spans = [];
    text.split(RegExp(r'(\n)')).forEach((line) {
      if (line.contains(RegExp(r'<b>(.*?)<\/b>'))) {
        spans.add(
          TextSpan(
            text: line.replaceAll(RegExp(r'<b>|<\/b>'), ''),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      } else {
        spans.add(TextSpan(text: line));
      }
      spans.add(TextSpan(text: '\n'));
    });
    return RichText(
      text: TextSpan(
        children: spans,
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Gemini AI Chat',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                final message = chatMessages[index];
                final isUser = message["role"] == "user";
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey[800],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft:
                            isUser ? Radius.circular(12) : Radius.circular(0),
                        bottomRight:
                            isUser ? Radius.circular(0) : Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child:
                        isUser
                            ? Text(
                              message["text"]!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                            : buildRichText(message["text"]!),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter your prompt...',
                      hintStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.blueAccent,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.lightBlue,
                          width: 2.0,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    onSubmitted: (value) {
                      if (!isLoading) generateResponse(value);
                    },
                  ),
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                  onPressed:
                      isLoading
                          ? null
                          : () {
                            if (_controller.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Please enter a message before sending.',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }
                            generateResponse(_controller.text);
                          },
                  child:
                      isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Icon(Icons.send),
                  backgroundColor: isLoading ? Colors.grey : Colors.blueAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
