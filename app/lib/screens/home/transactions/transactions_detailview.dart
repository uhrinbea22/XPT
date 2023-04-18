import 'package:app/screens/home/menu.dart';
import 'package:app/screens/home/transactions/list_all_transactions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';

class DetailView extends StatelessWidget {
  DetailView(this.title, {Key? key}) : super(key: key);
  String title;
  @override
  Widget build(BuildContext context) {
    final appTitle = 'List by categories';
    // return MyCustomForm();
    return MaterialApp(
      title: appTitle,
      theme: Theme.of(context),
      home: Scaffold(
        drawer: NavDrawer(),
        appBar: AppBar(
          title: Text(appTitle),
        ),
        body: TransactionDetailview(title),
      ),
    );
  }
}

class TransactionDetailview extends StatelessWidget {
  //title, date, persistent, category, onlie, note, place, expense, ?picture?

  String title;
  TransactionDetailview(this.title, {Key? key}) : super(key: key);
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    final AuthService _authService = AuthService();
    User? user = _authService.getuser();
    Storage storage = Storage();

    return Scaffold(
      drawer: NavDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Offstage(
                      offstage: document['picture'] != "" ? false : true,
                      child: FutureBuilder(
                          future: storage.downloadUrl(
                              _authService.getuser()!.uid, document["picture"]),
                          builder: (BuildContext context,
                              AsyncSnapshot<String?> snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting ||
                                !snapshot.hasData) {
                              return LoadingAnimationWidget.staggeredDotsWave(
                                color: Colors.green,
                                size: 50,
                              );
                            }
                            if (snapshot.hasError)
                              return Text('Something went wrong');
                            return Container(
                              width: 150,
                              height: 175,
                              child: Image.network(snapshot.data!),
                            );
                          }),
                    ),
                    /*  Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 16, 20, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Text(
                              'Title',
                            ),
                          ),
                        ],
                      ),
                    ), */
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Text(
                              document['title'],
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    /*  Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 16, 20, 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Text(
                              'Amount',
                            ),
                          ),
                        ],
                      ),
                    ), */
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          /*   Icon(
                            document['expense'] == false
                                ? Icons.add
                                : Icons.remove,
                            color: Colors.black,
                            size: 20.0,
                          ), */
                          Text(
                            document['amount'].toString(),
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    /* Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 16, 20, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.place_rounded,
                            color: Colors.black,
                            size: 20.0,
                          ),
                          /*   Expanded(
                           
                            child: Text(
                              'Place',
                            ),
                          ), */
                        ],
                      ),
                    ), */
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          /*     Icon(
                            Icons.place_sharp,
                            color: Colors.black,
                            size: 20.0,
                          ), */
                          Expanded(
                            child: Text(document['place']),
                          ),
                        ],
                      ),
                    ),
                    /*   Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Text(
                              'Regularity',
                            ),
                          ),
                        ],
                      ),
                    ), */

                    //only show when it is regular
                    Offstage(
                      offstage: document['persistent'] == true ? false : true,
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Text(document['persistent']
                                  ? 'Regular '
                                  : 'Not regular '),
                            ),
                          ],
                        ),
                      ),
                    ),

                    /*    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 16, 20, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Text(
                              'Category',
                            ),
                          ),
                        ],
                      ),
                    ), */
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          /*  Icon(Icons.category), */
                          Expanded(
                            child: Text(document['category']),
                          ),
                        ],
                      ),
                    ),
                    /*     Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 16, 20, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Text(
                              'Date',
                            ),
                          ),
                        ],
                      ),
                    ), */
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text((document['date']).toString()),
                          /*  Icon(Icons.date_range), */
                          /* Text((document['date'] as Timestamp)
                              .toDate()
                              .toString()
                              .substring(0, 10)), */
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(4, 0, 0, 0),
                          ),
                        ],
                      ),
                    ),
                    /*   Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 16, 20, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Text(
                              'Online',
                            ),
                          ),
                        ],
                      ),
                    ), */
                    Offstage(
                      offstage: document['online'] == true ? false : true,
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Text(
                                  document['online'] ? 'Online' : 'Not online'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                              child: Text(
                                'Note',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 4, 20, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Text(document['note']),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 4, 20, 0),
                      child: FloatingActionButton(
                          hoverColor: Colors.purple,
                          child: Icon(Icons.delete_forever),
                          onPressed: () {
                            //warn user
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Are you sure?'),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        child: const Text(
                                            'Yes, I delete this transaction'),
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .runTransaction(
                                                  (transaction) async =>
                                                      await transaction.delete(
                                                          document.reference));
                                          /*   Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const ListAllTrans()
                                                    ),
                                          ); */
                                        },
                                      )
                                    ],
                                  );
                                });
                          }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Timestamp todayTimestamp = Timestamp.fromDate(DateTime.now());

    final AuthService _authService = AuthService();
    User? user = _authService.getuser();
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text('Details'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("transactions")
            .where("title", isEqualTo: title)
            .where("uid", isEqualTo: user!.uid)
            //.orderBy("date")
            .get()
            .asStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Something went wrong');
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.green,
              size: 50,
            );
          }

          return ListView.builder(
            itemExtent: 1000.0,
            itemCount: snapshot.data!.size,
            itemBuilder: ((context, index) =>
                _buildListItem(context, snapshot.data!.docs[index])),
          );
        },
      ),
    );
  }
}
