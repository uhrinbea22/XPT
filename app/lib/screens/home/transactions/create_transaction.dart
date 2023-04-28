import 'dart:io';
import 'dart:ui';
import 'package:app/consts/styles.dart';
import 'package:app/screens/home/transactions/fileupload.dart';
import 'package:app/screens/home/transactions/list_all_transactions.dart';
import 'package:app/screens/home/menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import '../../../firebase_options.dart';
import '../../../models/transact.dart';
import '../../../services/auth_service.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(CreateTransaction());
}

class CreateTransaction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Tranzakció hozzáadása';
    return MaterialApp(
      title: appTitle,
      theme: Theme.of(context),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        drawer: NavDrawer(),
        appBar: AppBar(
          title: Text(appTitle),
        ),
        body: MyCustomForm(),
      ),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  var _streamCategoriesList;
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  ImageUploads imgUpload = new ImageUploads();

  String dropdownvalue = 'Kategória';
  final Map<String, TextEditingController> myController = {
    'amount': TextEditingController(),
    'category': TextEditingController(),
    'date': TextEditingController(),
    'persistent': TextEditingController(),
    'place': TextEditingController(),
    'title': TextEditingController(),
    'notes': TextEditingController(),
    'expense': TextEditingController(),
  };

  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  List categoryList = [];
  bool expense_value = false;
  bool persistent_value = false;
  bool online_value = false;
  bool titleInDbAlready = false;
  var showText = "";
  String categoryExists = "";
  bool absorbValue = false;
  var categoryController = TextEditingController();
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  File? _photo;
  final ImagePicker _picker = ImagePicker();
  String imgName = "";

  var _selectedOption = "Kiadás";

  @override
  void initState() {
    imgName = "";
    super.initState();
  }

  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  Future imgFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile();
      } else {
        //TODO : warn user that no image is selected
        print('No image selected.');
      }
    });
  }

  Future uploadFile() async {
    //TODO : create directory with user_id and insert pic as the transaction__id

    if (_photo == null) return;
    //final fileName = myController['title']!.text.toString();
    imgName = basename(_photo!.path);
    String directory = _authService.getuser()!.uid;

    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref("$directory/")
          .child("/$imgName");
      await ref.putFile(_photo!);
    } catch (e) {
      print('error occured');
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Galéria'),
                      onTap: () {
                        imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Kamera'),
                    onTap: () {
                      imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<bool> titleInDb(String title) async {
    var limitSnapshots = await FirebaseFirestore.instance
        .collection("transactions")
        .where("uid", isEqualTo: _authService.getuser()!.uid)
        .where('title', isEqualTo: title)
        .get();

    if (limitSnapshots.docs.isNotEmpty) {
      setState(() {
        titleInDbAlready = true;
      });
      return true;
    } else
      setState(() {
        titleInDbAlready = false;
      });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Center(
                  child: GestureDetector(
                onTap: () {
                  _showPicker(context);
                },
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Color(0xffFDCF09),
                  child: _photo != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.file(
                            _photo!,
                            width: 25,
                            height: 25,
                            fit: BoxFit.fitHeight,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(50)),
                          width: 100,
                          height: 100,
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.grey[800],
                          ),
                        ),
                ),
              )),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r"[0-9]"),
                  )
                ],
                validator: (value) {
                  if (value == null || value.isEmpty || int.parse(value) < 0) {
                    return 'Add meg az összeget';
                  }
                  return null;
                },
                controller: myController['amount'],
                decoration: const InputDecoration(
                  icon: Icon(Icons.money),
                  hintText: 'Add meg az összeget',
                  labelText: 'Összeg*',
                  iconColor: Colors.grey,
                ),
              ),
              //datepicker to make it easier for user to choose date
              TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: myController['date'],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Add meg a dátumot';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    icon: Icon(Icons.calendar_month),
                    hintText: 'Add meg a dátumot',
                    labelText: 'Dátum*',
                    iconColor: Colors.grey,
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2025));
                    if (pickedDate != null) {
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                      setState(() {
                        myController['date']!.text = formattedDate;
                      });
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) {
                            Future.delayed(const Duration(seconds: 3), () {
                              Navigator.of(context).pop(true);
                            });
                            return const AlertDialog(
                              title: Text('Dátum nincs kiválasztva!'),
                            );
                          });
                    }
                  }),
              TextFormField(
                controller: myController['place'],
                decoration: const InputDecoration(
                    icon: Icon(Icons.place_outlined), labelText: "Hely"),
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.runtimeType != String) {
                    return 'Add meg a megnevezést';
                  }
                  return null;
                },
                controller: myController['title'],
                decoration: const InputDecoration(
                    icon: Icon(Icons.abc), labelText: "Megnevezés*"),
              ),
              TextFormField(
                controller: myController['notes'],
                decoration: const InputDecoration(
                    icon: Icon(Icons.note), labelText: "Jegyzet"),
              ),

              Column(children: [
                RadioListTile(
                  title: Text('Kiadás'),
                  value: 'Kiadás',
                  groupValue: _selectedOption,
                  onChanged: (value) {
                    setState(() {
                      _selectedOption = (value as String?)!;
                    });
                  },
                ),
                RadioListTile(
                  title: Text('Bevétel'),
                  value: 'Bevétel',
                  groupValue: _selectedOption,
                  onChanged: (value) {
                    setState(() {
                      _selectedOption = (value as String?)!;
                    });
                  },
                )
              ]),
              CheckboxListTile(
                title: Text('Rendszeres'),
                subtitle: Text("Ha fizetés vagy számla, csekkold be"),
                checkColor: Colors.grey,
                activeColor: Colors.blue,
                value: persistent_value,
                //subtitle: Text("If it is bill or salary - check it"),
                onChanged: (bool? value) {
                  setState(() {
                    persistent_value = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Online'),
                checkColor: Colors.grey,
                activeColor: Colors.blue,
                value: online_value,
                //  subtitle: Text("If transaction was online - check it"),
                onChanged: (bool? value) {
                  setState(() {
                    online_value = value!;
                  });
                },
              ),
              Row(
                children: [
                  Container(
                    child: Column(
                      children: [
                        Text('Kategória* : '),
                        Text(dropdownvalue),
                        Column(
                          children: [
                            Text(
                              showText,
                              style: TextStyle(color: Colors.red, fontSize: 10),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("transactions")
                            //.where("category", isNotEqualTo: "")
                            .where("uid",
                                isEqualTo: _authService.getuser()!.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          // if not has data - loading
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting ||
                              !snapshot.hasData) {
                            return LoadingAnimationWidget.staggeredDotsWave(
                              color: Colors.green,
                              size: 50,
                            );
                          } else {
                            for (int i = 0;
                                i < snapshot.data!.docs.length;
                                i++) {
                              //add only when it is not alerady in it - check cases too
                              DocumentSnapshot snap = snapshot.data!.docs[i];
                              if (!categoryList
                                  .contains(snap['category'].toString())) {
                                categoryList.add(snap['category']);
                              }
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(width: 50.0),
                                DropdownButton<dynamic>(
                                  items: categoryList.map((location) {
                                    return DropdownMenuItem(
                                      child: new Text(location),
                                      value: location,
                                    );
                                  }).toList(),
                                  onChanged: (choosedCategory) {
                                    setState(() {
                                      showText = "";
                                      dropdownvalue =
                                          choosedCategory.toString();
                                    });
                                    dropdownvalue = choosedCategory.toString();
                                    categoryController.text =
                                        choosedCategory.toString();
                                  },
                                  isExpanded: false,
                                ),
                              ],
                            );
                          }
                        }),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 20.0, top: 0.0),
                    child: FloatingActionButton(
                        mini: true,
                        child: Icon(Icons.add_outlined),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Új kategória'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: categoryController,
                                        decoration: const InputDecoration(
                                            hintText:
                                                'Adj meg egy új kategóriát'),
                                      ),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      onPressed: () {
                                        if (categoryList.contains(
                                            categoryController.text)) {
                                          setState(() {
                                            showText =
                                                "Ez a kategória már létezik!";
                                          });
                                        } else
                                          setState(() {
                                            dropdownvalue =
                                                categoryController.text;
                                          });
                                        dropdownvalue = categoryController.text;
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'Hozzáad',
                                      ),
                                    )
                                  ],
                                );
                              });
                        }),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                      padding: const EdgeInsets.only(left: 100.0, top: 20.0),
                      child: AbsorbPointer(
                        absorbing: absorbValue,
                        child: ElevatedButton(
                            child: const Text('Hozzáad'),
                            onPressed: () async {
                              //check if datas are all valid
                              if (await titleInDb(
                                  myController["title"]!.text)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Adj meg egy másik elnevezést, már létezik ilyen.')),
                                );
                              } else {
                                if (_formKey.currentState!.validate()) {
                                  // make button disabled, to prevent double data sending
                                  setState(() {
                                    absorbValue = true;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Adat feldolgozása')),
                                  );

                                  //create a transaction
                                  final tr = Transact(
                                      DateTime.parse(
                                          myController['date']!.text),
                                      int.parse(myController['amount']!.text),
                                      persistent_value,
                                      dropdownvalue,
                                      online_value,
                                      myController['notes']!.text,
                                      myController['place']!.text,
                                      _selectedOption == "Bevétel"
                                          ? false
                                          : true,
                                      myController['title']!.text,
                                      imgName);

                                  //get the category limit document for the transactions category
                                  final citiesRef = await FirebaseFirestore
                                      .instance
                                      .collection("category_limits")
                                      .where("uid",
                                          isEqualTo:
                                              _authService.getuser()!.uid)
                                      .where("category",
                                          isEqualTo: tr.category!)
                                      .get();

                                  final allTransactionInCategory =
                                      await FirebaseFirestore.instance
                                          .collection("transactions")
                                          .where("uid",
                                              isEqualTo:
                                                  _authService.getuser()!.uid)
                                          .where("category",
                                              isEqualTo: tr.category!)
                                          //check the month too
                                          .get();

                                  List categoryAmount = allTransactionInCategory
                                      .docs
                                      .map((e) => (e.data()['amount']))
                                      .toList();
                                  num max = 0;
                                  for (int i = 0;
                                      i < categoryAmount.length;
                                      i++) {
                                    max = max + categoryAmount[i];
                                  }
                                  max = max + tr.amount;
                                  int limit = 0;
                                  if (citiesRef.docs.isNotEmpty) {
                                    limit = int.parse(
                                        citiesRef.docs.first['limit']);
                                  }
                                  num diff = max - limit;

                                  // check if it is overlapped - warn the user about it
                                  if (citiesRef.docs.isNotEmpty) {
                                    if (max + tr.amount >
                                        int.parse(
                                            citiesRef.docs.first['limit'])) {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Limit átlépése'),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    "Már többet költöttél, mint amennyit terveztél $diff $valuta -al.",
                                                  ),
                                                ],
                                              ),
                                            );
                                          });
                                    }
                                  } else if (citiesRef.docs.isEmpty &&
                                      tr.expense) {
                                    FirebaseFirestore.instance
                                        .collection('category_limits')
                                        .doc()
                                        .set({
                                      'category': tr.category.toString(),
                                      'limit': "0",
                                      'date':
                                          '${DateTime.now().year}-0${DateTime.now().month}-${DateTime.now().day}',
                                      'uid': _authService.getuser()!.uid
                                    });
                                  }
                                  //find the category with user uid, and check if it has limit

                                  //if not, normally add the transaction
                                  //if it has, check the amounts, and warn the user about possible over expense

                                  //store it in database
                                  int actualMonth = DateTime.now().month;
                                  var date;
                                  if (tr.persistent == true) {
                                    for (int i = actualMonth; i <= 12; i++) {
                                      if (i <= 2) {
                                        //februar honap lekezelese
                                        if (myController['date']!.text[8]
                                                    as int >=
                                                2 &&
                                            myController['date']!.text[9]
                                                    as int >
                                                8) {
                                          date =
                                              '${DateTime.now().year}-0${i}-${myController['date']!.text[8]}${28}';
                                        }
                                      }
                                      if (i < 10) {
                                        date =
                                            '${DateTime.now().year}-0${i}-${myController['date']!.text[8]}${myController['date']!.text[9]}';
                                      } else {
                                        date =
                                            '${DateTime.now().year}-${i}-${myController['date']!.text[8]}${myController['date']!.text[9]}';
                                      }

                                      FirebaseFirestore.instance
                                          .collection('transactions')
                                          .doc()
                                          .set({
                                        'date': date,
                                        'amount': tr.amount,
                                        'title': tr.title,
                                        'place': tr.place,
                                        'online': tr.online,
                                        'expense': tr.expense,
                                        'note': tr.note,
                                        'category': tr.category,
                                        'persistent': tr.persistent,
                                        'picture': tr.picture,
                                        'uid': _authService.getuser()!.uid
                                      });
                                    }
                                  } else {
                                    FirebaseFirestore.instance
                                        .collection('transactions')
                                        .doc()
                                        .set({
                                      'date': myController['date']!.text,
                                      'amount': tr.amount,
                                      'title': tr.title,
                                      'place': tr.place,
                                      'online': tr.online,
                                      'expense': tr.expense,
                                      'note': tr.note,
                                      'category': tr.category,
                                      'persistent': tr.persistent,
                                      'picture': tr.picture,
                                      'uid': _authService.getuser()!.uid
                                    });
                                  }
                                  //put it in the calendar
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ListAllTrans()),
                                  );
                                }
                              }
                            }),
                      )),
                  Container(
                    padding: const EdgeInsets.only(left: 50.0, top: 20.0),
                    child: ElevatedButton(
                      child: const Text('Vissza'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        ));
  }
}
