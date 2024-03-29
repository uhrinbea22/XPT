import 'package:app/screens/home/menu.dart';
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
    return MaterialApp(
      title: 'Kategória limitek',
      theme: Theme.of(context),
      home: const CategoryLimitsScreen(title: 'Kategória limitek'),
    );
  }
}

class CategoryLimitsScreen extends StatelessWidget {
  const CategoryLimitsScreen({Key? key, required this.title}) : super(key: key);
  final String title;
  final int limitValue = 0;

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    final limitController = TextEditingController(text: document['limit']);
    return ListTile(
      title: Row(
        children: [
          Expanded(
              child: Text(
            document['category'].toString(),
          )),
          Expanded(
              child: Row(
            children: [
              const Icon(Icons.report_outlined),
              Text(document['limit']),
            ],
          ))
        ],
      ),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Max limit beállítása'),
                content: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: limitController,
                  decoration:
                      const InputDecoration(hintText: 'Add meg a limitet'),
                ),
                actions: <Widget>[
                  ///set max limit to category
                  ElevatedButton(
                    child: const Text('Rendben'),
                    onPressed: () {
                      ///update in db
                      FirebaseFirestore.instance
                          .collection('category_limits')
                          .doc(document.id)
                          .set({'limit': limitController.text},
                              SetOptions(merge: true)).then((value) {});
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
      resizeToAvoidBottomInset: false,
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text(title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('category_limits')
            .where("uid", isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Text('Hiba történt');
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.green,
              size: 50,
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Várakozás");
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
