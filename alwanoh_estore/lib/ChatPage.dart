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
  List<String> adminIds = [];

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _fetchAdminNames();
  }

  // Fetch all admin IDs from the "admin" collection
  List<String> adminNames = [];

  Future<void> _fetchAdminNames() async {
    try {
      // Fetch the admin_credentials document
      final adminDoc = await _firestore.collection('admin').doc('admin_credentials').get();

      if (adminDoc.exists) {
        // Extract the admin name from the document
        setState(() {
          adminNames = [adminDoc['name'] as String]; // Use admin name from Firestore
        });
        print("Fetched Admin Name: $adminNames"); // Log the admin name
      } else {
        setState(() {
          adminNames = [];
        });
        print("Admin credentials document not found");
      }
    } catch (e) {
      print("Error fetching admin names: $e");
    }
  }






  // Function to send a message to all admins
  void _sendMessage() async {
    if (_controller.text.trim().isNotEmpty && adminNames.isNotEmpty) {
      for (String adminName in adminNames) {
        try {
          await _firestore.collection('chat').add({
            'text': _controller.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
            'senderId': user?.uid,
            'receiverId': adminName, // Send message to admin
            'userEmail': user?.email,
          });
          print('Message sent to $adminName'); // Debugging line
        } catch (e) {
          print('Error sending message: $e');
        }
      }
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
              color: Colors.black.withOpacity(0.9),
              image: DecorationImage(
                image: AssetImage('assets/back.png'),
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
                  color: Styles.customColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Chat',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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
          .where('receiverId', isEqualTo: adminNames.isNotEmpty ? adminNames.first : '')
          .where('senderId', isEqualTo: user?.uid) // Only messages sent by the current user
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
            chatDocs[index]['senderId'] == user?.uid,
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
  Widget _buildChatBubble(
      String message, String receiverName, bool isMe, dynamic timestamp) {
    String formattedTime = '';

    if (timestamp is Timestamp) {
      formattedTime = DateFormat('hh:mm a').format(timestamp.toDate());
    } else {
      formattedTime = 'Just now';
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
              isMe ? 'You' : receiverName, // Show admin name or "You"
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
            icon: Icon(Icons.send,color: Styles.customColor,),
            onPressed: _sendMessage,
            color: Styles.primaryColor,
          ),
        ],
      ),
    );
  }
}
