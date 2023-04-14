import 'package:app/screens/home/menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/auth_service.dart';

void main() {
  runApp(const ListAllTrans());
}

class ListAllTrans extends StatelessWidget {
  const ListAllTrans();

  @override
  Widget build(BuildContext context) {
    //return MyAppHomePage(title: "Set limit");
    return MaterialApp(
      title: 'Set limit ',
      theme: Theme.of(context),
      home: MyAppHomePage(title: 'Set limit'),
    );
  }
}

class MyAppHomePage extends StatelessWidget {
  MyAppHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  final limitController = TextEditingController();
  String limitValue = "";

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: Colors.grey),
      title: Row(
        children: [
          Expanded(
            child:
                Text(document['category'], style: TextStyle(color: Colors.black)
                    //Theme.of(context).textTheme.displayMedium,
                    ),
          ),
        ],
      ),
      subtitle: Text(document['limit'].toString(),
          style: TextStyle(color: Colors.black)
          //Theme.of(context).textTheme.displaySmall,
          ),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Set max limit'),
                content: TextField(
                  controller: limitController,
                  decoration: const InputDecoration(hintText: 'Type limit'),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: const Text('Submit'),
                    onPressed: () {
                      limitValue = limitController.text;
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    User? user = _authService.getuser();
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text(title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('category_limits')
            .where("uid", isEqualTo: _authService.getuser()!.uid)
            .snapshots(),
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
