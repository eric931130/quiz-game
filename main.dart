import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '問答遊戲',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("問答遊戲")),
      body: Center(
        child: ElevatedButton(
          child: Text("開始遊戲"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QuestionScreen()),
            );
          },
        ),
      ),
    );
  }
}

class QuestionScreen extends StatefulWidget {
  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final TextEditingController _questionController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void _submitQuestion() {
    String question = _questionController.text.trim();
    if (question.isNotEmpty) {
      _db.collection('questions').add({
        'text': question,
        'timestamp': FieldValue.serverTimestamp()
      });
      _questionController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("發問 & 回答")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _questionController,
              decoration: InputDecoration(labelText: "輸入問題"),
            ),
          ),
          ElevatedButton(
            onPressed: _submitQuestion,
            child: Text("發問"),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.collection('questions').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    return ListTile(title: Text(doc['text']));
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
