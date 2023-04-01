import 'package:app/screens/home/menu.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';

class ListAllCat extends StatelessWidget {
  ListAllCat();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'list of categories',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: _ListAllCat(title: 'All expenses'),
    );
  }
}

class _ListAllCat extends StatelessWidget {
  final AuthService _authService = AuthService();
  _ListAllCat({
    Key? key,
    required this.title,
  }) : super(key: key);
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
            .collection('categories')
            .where("uid", isEqualTo: _authService.getuser()!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text("Waiting...");
          if (snapshot.hasError) return Text('Something went wrong');
          List<String> categories = [];
          List<int> amounts = [];
          List<int> limits = [];
          for (var element in snapshot.data!.docs) {
            categories.add(element['category']);
            limits.add(element['limit']);
            amounts.add(element['amount']);
          }
          //print(categories);

          // if (snapshot.hasData) return Text('has data');

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Waiting");
          }

          //getAllCategories();
          return ListView.builder(
            itemExtent: 80.0,
            itemCount: snapshot.data!.size,
            itemBuilder: ((context, index) =>
                Text(categories[index].toString())),
          );
        },
      ),
    );
  }
}
