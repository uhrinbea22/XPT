import 'dart:html';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'expense db test',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const MyAppHomePage(title: 'Possible tests'),
    );
  }
}

class MyAppHomePage extends StatelessWidget {
  const MyAppHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(
              document['name'],
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xffddddff),
            ),
            padding: const EdgeInsets.all(5.0),
            child: Text(
              document['number'].toString(),
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
        ],
      ),
      onTap: () {
        FirebaseFirestore.instance.collection('test').doc().set({
          'name': 'NEW NAME',
          'number': '2',
        });
        document.reference.update({'number': document['number'] + 1});
        //document.data().add({'name': 'vamal', 'number': 2});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('test').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text("Waiting...");
          if (snapshot.hasError) return Text('Something went wrong');
          // if (snapshot.hasData) return Text('has data');

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Waiting");
          }
          return ListView.builder(
            itemExtent: 80.0,
            itemCount: snapshot.data!.size,
            itemBuilder: ((context, index) =>
                _buildListItem(context, snapshot.data!.docs[index])),
          );
        },
      ),
    );
  }
}
