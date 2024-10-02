import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../Thems/styles.dart'; // Assuming Styles is in this path

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
  }

  // Function to send a message
  void _sendMessage() async {
    if (_controller.text.trim().isNotEmpty) {
      await _firestore.collection('chat').add({
        'text': _controller.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'userId': user?.uid,
        'userEmail': user?.email,
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9), // Set color with 90% opacity
              image: DecorationImage(
                image: AssetImage('assets/back.png'), // Background image
                fit: BoxFit.cover,
              ),
            ),
          ),

          Column(
            children: [
              // Custom AppBar Replacement with Row
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                  color: Styles.customColor, // Using customColor for the top bar
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Add some space between icon and text
                      Text(
                        'Chat',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Change text color to white
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: _firestore
                      .collection('chat')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
                    if (chatSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final chatDocs = chatSnapshot.data?.docs ?? [];
                    return ListView.builder(
                      reverse: true,
                      itemCount: chatDocs.length,
                      itemBuilder: (ctx, index) => _buildChatBubble(
                        chatDocs[index]['text'],
                        chatDocs[index]['userEmail'],
                        chatDocs[index]['userId'] == user?.uid,
                        chatDocs[index]['createdAt'],
                      ),
                    );
                  },
                ),
              ),
              _buildMessageInput(),
            ],
          ),
        ],
      ),
    );

  }

  // Widget to build the chat bubble
// Widget to build the chat bubble
  Widget _buildChatBubble(
      String message, String userEmail, bool isMe, dynamic timestamp) {
    String formattedTime = '';

    // Check if timestamp is null before formatting
    if (timestamp is Timestamp) {
      formattedTime = DateFormat('hh:mm a').format(timestamp.toDate());
    } else {
      formattedTime = 'Just now'; // Default text if timestamp is null
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Styles.primaryColor : Styles.seconderyColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Styles.customColor,
          ),
        ),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              userEmail,
              style: TextStyle(
                fontSize: 12,
                color: isMe ? Colors.white70 : Colors.black54,
              ),
            ),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            Text(
              formattedTime,
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Widget to build the message input area
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: TextStyle(color: Styles.customColor),
              controller: _controller,
              cursorColor: Styles.customColor,
              decoration: InputDecoration(
                filled: true,
                fillColor: Styles.seconderyColor.withOpacity(0.1),
                labelText: 'Send a message...',
                labelStyle: TextStyle(color: Styles.customColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Styles.customColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Styles.customColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Styles.customColor),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessage,
            color: Styles.primaryColor, // Send button using primaryColor
          ),
        ],
      ),
    );
  }
}
