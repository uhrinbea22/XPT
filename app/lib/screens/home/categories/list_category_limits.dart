import 'package:app/screens/home/transactions/create_transaction.dart';
import 'package:app/screens/home/menu.dart';
import 'package:app/screens/home/transactions/transactions_detailview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../services/auth_service.dart';

void main() {
  runApp(const CategoryLimits());
}

class CategoryLimits extends StatelessWidget {
  const CategoryLimits();

  @override
  Widget build(BuildContext context) {
    // return MyAppHomePage(title: "Category limits");
    return MaterialApp(
      title: 'Kategória limitek',
      theme: Theme.of(context),
      home: MyAppHomePage(title: 'Kategória limitek'),
    );
  }
}

class MyAppHomePage extends StatelessWidget {
  MyAppHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  int limitValue = 0;

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    final limitController = TextEditingController(text: document['limit']);

    return ListTile(
      leading: CircleAvatar(backgroundColor: Colors.grey),
      title: Row(
        children: [
          Expanded(
            child: Text(document['category'].toString(),
                style: TextStyle(color: Colors.black)
                //Theme.of(context).textTheme.displayMedium,
                ),
          ),
          Expanded(
            child: Text(document['limit'], style: TextStyle(color: Colors.black)
                //Theme.of(context).textTheme.displayMedium,
                ),
          ),
        ],
      ),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Max limit beállítása'),
                content: TextFormField(
                  //initialValue: document['limit'].toString(),
                  keyboardType: TextInputType.number,
                  controller: limitController,
                  decoration:
                      const InputDecoration(hintText: 'Add meg a limitet'),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: const Text('Rendben'),
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('category_limits')
                          .doc(document.id)
                          .set({'limit': limitController.text},
                              SetOptions(merge: true)).then((value) {});
                      // categoryRef.update({"limit": 100});
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
          if (snapshot.hasError) return Text('Hiba történt');
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.green,
              size: 50,
            );
          }
          // if (snapshot.hasData) return Text('has data');

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Várakozás");
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
