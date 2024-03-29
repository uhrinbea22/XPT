import 'package:app/screens/home/menu.dart';
import 'package:app/screens/home/transactions/transactions_detailview.dart';
import 'package:app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../consts/styles.dart';
import 'create_transaction.dart';

class ListAllTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: Theme.of(context),
        home: ListTransactions());
  }
}

class ListTransactions extends StatelessWidget {
  final String actualMonthStart = DateTime.now().month < 10
      ? '${DateTime.now().year}-0${DateTime.now().month}-01'
      : '${DateTime.now().year}-${DateTime.now().month}-01';
  final String nextMonthStart = DateTime.now().month < 10
      ? '${DateTime.now().year}-0${DateTime.now().month + 1}-01'
      : '${DateTime.now().year}-${DateTime.now().month + 1}-01';
  final AuthService authService = AuthService();
  final controller = PageController(initialPage: 0);
  var currentPageValue = 0.0;

  @override
  Widget build(BuildContext context) {
    User? user = authService.getuser();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: NavDrawer(),
      appBar: AppBar(
        title: const Text("Tranzakciók"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.arrow_right_alt,
            ),
            onPressed: () {
              controller.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeIn);
            },
          )
        ],
      ),
      body: Center(
          child: PageView(
        physics: const BouncingScrollPhysics(),
        pageSnapping: true,
        controller: controller,
        children: <Widget>[
          Container(
            ///list only the actual month's transactions
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
                  .where('uid', isEqualTo: user.uid)
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
                  .where('uid', isEqualTo: user.uid)
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
      floatingActionButton: FloatingActionButton(
          hoverColor: Colors.purple,
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateTransactionPage(),
                ));
          }),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          selectedColor: Colors.lightBlueAccent,
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          tileColor: Colors.white30,
          leading: const Icon(
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
                        ? const Icon(
                            Icons.remove_outlined,
                            color: Colors.black,
                          )
                        : const Icon(
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
