import 'dart:js';

import 'package:app/screens/home/menu.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';

void main() {
  runApp(const ListAllCat());
}

class ListAllCat extends StatelessWidget {
  const ListAllCat();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'list of categories',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const _ListAllCat(title: 'All expenses'),
    );
  }
}

class _ListAllCat extends StatelessWidget {
  const _ListAllCat({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text(title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .where("category", isNotEqualTo: '')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text("Waiting...");
          if (snapshot.hasError) return Text('Something went wrong');

          List<String> categories = [];
          for (var element in snapshot.data!.docs) {
            categories.add(element['category']);
          }
          print(categories);
          // if (snapshot.hasData) return Text('has data');

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Waiting");
          }
          return ListView.builder(
            itemExtent: 80.0,
            itemCount: snapshot.data!.size,
            itemBuilder: ((context, index) => Text(categories[index])),
          );
        },
      ),
    );
  }
}
