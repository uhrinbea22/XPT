import 'package:app/screens/home/transactions/create_transaction.dart';
import 'package:app/screens/home/menu.dart';
import 'package:app/screens/home/transactions/list_transactions_by_category.dart';
import 'package:app/screens/home/transactions/transactions_detailview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/auth_service.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(ListAllTrans());
}

class ListAllTrans extends StatelessWidget {
  const ListAllTrans();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme.of(context),
      title: 'List all transactions',
      home: MyAppHomePage(title: 'All transactions'),
    );
  }
}

class MyAppHomePage extends StatelessWidget {
  MyAppHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  final budget = 0;
  final String actualMonthStart =
      '${DateTime.now().year}-0${DateTime.now().month}-01';
  final String nextMonthStart =
      '${DateTime.now().year}-0${DateTime.now().month + 1}-01';

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    final numberFormat = new NumberFormat("#,###", "en_US");
    return Column(
      children: [
        ListTile(
          selectedColor: Colors.lightBlueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          tileColor: Colors.white24,
          hoverColor: Colors.blueGrey,
          leading: CircleAvatar(
            backgroundColor: Colors.tealAccent,
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
          title: Row(
            children: [
              Expanded(
                child: Text(document['title'],
                    style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
          subtitle: Text(numberFormat.format(document['amount']),
              style: TextStyle(color: Colors.black)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionDetailview(document['title']),
              ),
            );
          },
          onLongPress: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ListAllTransByCateg(title: document['category']),
                ));
          },
        )
      ],
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
            .collection('transactions')
            .where('uid', isEqualTo: user!.uid)
            .where('date', isGreaterThanOrEqualTo: actualMonthStart)
            .where('date', isLessThan: nextMonthStart)
            //.orderBy("dates")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Text(snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.green,
              size: 50,
            );
          }
          return ListView.builder(
            itemExtent: 80.0,
            itemCount: snapshot.data!.size,
            itemBuilder: ((context, index) =>
                _buildListItem(context, snapshot.data!.docs[index])),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          hoverColor: Colors.purple,
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateTransaction(),
                ));
          }),
  
    );
  }
}
