import 'package:app/screens/home/menu.dart';
import 'package:app/screens/home/transactions/transactions_detailview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/auth_service.dart';

class ListAllTransByCateg extends StatelessWidget {
  String title;
  ListAllTransByCateg({Key? key, required this.title}) : super(key: key);

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return SingleChildScrollView(
        child: Column(
      children: [
        ListTile(
          selectedColor: Colors.lightBlueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          tileColor: Colors.white24,
          hoverColor: Colors.blueGrey,
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            child: document['expense'] == true
                ? Icon(
                    Icons.remove,
                    color: Colors.black,
                  )
                : Icon(
                    Icons.add,
                    color: Colors.black,
                  ),
          ),
          /* leading: document['expense'] == true
              ? Icon(Icons.add)
              : Icon(Icons.remove), */
          title: Row(
            children: [
              Expanded(
                child: Text(document['title'],
                    style: TextStyle(color: Colors.black)
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
        )
      ],
    ));
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
            .collection('transactions')
            .where('uid', isEqualTo: user!.uid)
            .where('category', isEqualTo: title)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Something went wrong');
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.green,
              size: 50,
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Waiting");
          }
          return ListView.builder(
            itemExtent: 100.0,
            itemCount: snapshot.data!.size,
            itemBuilder: ((context, index) =>
                _buildListItem(context, snapshot.data!.docs[index])),
          );
        },
      ),
    );
  }
}
