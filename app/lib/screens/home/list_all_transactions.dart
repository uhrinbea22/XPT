import 'dart:html';

import 'package:app/screens/home/menu.dart';
import 'package:app/screens/home/transactions_detailview.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';

void main() {
  runApp(const ListAllTrans());
}

class ListAllTrans extends StatelessWidget {
  const ListAllTrans();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'expense db test',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const MyAppHomePage(title: 'All expenses'),
    );
  }
}

class MyAppHomePage extends StatelessWidget {
  const MyAppHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: Colors.grey),
      title: Row(
        children: [
          Expanded(
            child: Text(document['title'], style: TextStyle(color: Colors.black)
                //Theme.of(context).textTheme.displayMedium,
                ),
          ),
        ],
      ),
      subtitle: Text(document['amount'].toString(),
          style: TextStyle(color: Colors.black)
          //Theme.of(context).textTheme.displaySmall,
          ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailview(document['title']),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text(title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('transactions').snapshots(),
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
