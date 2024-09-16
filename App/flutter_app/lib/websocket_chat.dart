// lib/websocket_chat.dart
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WebSocketChat extends StatefulWidget {
  const WebSocketChat({super.key});

  @override
  _WebSocketChatState createState() => _WebSocketChatState();
}

class _WebSocketChatState extends State<WebSocketChat> {
  WebSocketChannel channel;
  final TextEditingController _controller = TextEditingController();
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() async {
    final token = await _getToken();
    channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8000/ws/chat/'),
    );
    channel.stream.listen((message) {
      setState(() {
        messages.add(message);
      });
    });
    channel.sink.add(json.encode({'token': token}));
  }

  Future<String> _getToken() async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/token/'),
      body: {'username': 'your_username', 'password': 'your_password'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['access'];
    } else {
      throw Exception('Failed to get token');
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      channel.sink.add(json.encode({'message': _controller.text}));
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WebSocket Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(messages[index]));
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(labelText: 'Send a message'),
                ),
              ),
              ElevatedButton(
                onPressed: _sendMessage,
                child: const Text('Send'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}