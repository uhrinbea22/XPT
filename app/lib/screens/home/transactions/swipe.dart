import 'package:app/screens/home/menu.dart';
import 'package:app/screens/home/transactions/transactions_detailview.dart';
import 'package:app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../consts/styles.dart';

class HorizontalSwipeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: Theme.of(context),
        home: MainScreen());
  }
}

/// This is the stateless widget that the main application instantiates.
class MainScreen extends StatelessWidget {
  final String actualMonthStart =
      '${DateTime.now().year}-0${DateTime.now().month}-01';
  final String nextMonthStart =
      '${DateTime.now().year}-0${DateTime.now().month + 1}-01';
  final AuthService authService = AuthService();

  final controller = PageController(initialPage: 0);
  var currentPageValue = 0.0;

  @override
  Widget build(BuildContext context) {
    User? user = authService.getuser();
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(title: Text("Tranzakciók")),
      body: Center(
          child: PageView(
        physics: BouncingScrollPhysics(),
        pageSnapping: true,
        controller: controller,
        children: <Widget>[
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('transactions')
                  .where('uid', isEqualTo: user!.uid)
                  .where('date', isGreaterThanOrEqualTo: actualMonthStart)
                  .where('date', isLessThan: nextMonthStart)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
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
          ),
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('transactions')
                  .where('uid', isEqualTo: user!.uid)
                  .where('date', isGreaterThanOrEqualTo: actualMonthStart)
                  .where('date', isLessThan: nextMonthStart)
                  .where('expense', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
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
          ),
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('transactions')
                  .where('uid', isEqualTo: user!.uid)
                  .where('date', isGreaterThanOrEqualTo: actualMonthStart)
                  .where('date', isLessThan: nextMonthStart)
                  .where("expense", isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
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
          ),
        ],
      )),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    final numberFormat = new NumberFormat("#,###", "en_US");
    var title = controller.page;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(title.toString()),
        ListTile(
          selectedColor: Colors.lightBlueAccent,
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          tileColor: Colors.white30,
          leading: Icon(
            Icons.double_arrow_rounded,
            color: Colors.black,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(document['title'],
                    style: const TextStyle(color: Colors.black)),
              ),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: document['expense'] == true
                        ? Icon(
                            Icons.remove_outlined,
                            color: Colors.black,
                          )
                        : Icon(
                            Icons.add_outlined,
                            color: Colors.black,
                          ),
                  ),
                  Text('${document['amount']}$valuta',
                      style: const TextStyle(color: Colors.black, fontSize: 18))
                ],
              ))
            ],
          ),
          subtitle: Text(
            document['date'],
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
    );
  }
}
