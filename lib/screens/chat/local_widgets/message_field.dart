import 'package:flutter/material.dart';
import 'package:gangbook/state_managment/chat_state.dart';
import 'package:gangbook/state_managment/user_state.dart';
import 'package:provider/provider.dart';

class MessageField extends StatefulWidget {
  @override
  _MessageFieldState createState() => _MessageFieldState();
}

class _MessageFieldState extends State<MessageField> {
  final _messageController = TextEditingController();
  bool isEmpty = true;
  bool isLoading = false;

  void _sendMessage() async {
    final chatState = Provider.of<ChatState>(context, listen: false);
    final userState = Provider.of<UserState>(context, listen: false);

    setState(() {
      isLoading = true;
    });
    await chatState.sendMessage(_messageController.text, userState.user);
    setState(() {
      isEmpty = true;
      isLoading = true;
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 10,
        left: 10,
        bottom: 5,
      ),
      width: double.infinity,
      constraints:
          BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.07),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: 'Your message here',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  if (value.trim().isNotEmpty && isEmpty) {
                    setState(() {
                      isEmpty = false;
                    });
                  }
                  if (value.trim().isEmpty && !isEmpty) {
                    setState(() {
                      isEmpty = true;
                    });
                  }
                },
                onEditingComplete: () {
                  if (_messageController.text.trim().isNotEmpty) {
                    _sendMessage();
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: InkWell(
              onTap: isEmpty ? null : _sendMessage,
              child: Container(
                decoration: BoxDecoration(
                  color: isEmpty ? Colors.grey : Colors.teal,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.06,
                  minWidth: MediaQuery.of(context).size.height * 0.06,
                ),
                child: Icon(
                  Icons.send,
                  color: isEmpty ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
