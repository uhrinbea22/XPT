import 'dart:io';
import 'package:app/screens/home/theme_manager.dart';
import 'package:app/screens/home/transactions/fileupload.dart';
import 'package:app/screens/home/transactions/list_all_transactions.dart';
import 'package:app/screens/home/menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
  /* runApp(ChangeNotifierProvider<ThemeNotifier>(
    create: (_) => new ThemeNotifier(),
    child: CreateTransaction(),
  )); */
}

class CreateTransaction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Add new transaction';
    // return MyCustomForm();
    return MaterialApp(
      title: appTitle,
      theme: Theme.of(context),
      home: Scaffold(
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

  String dropdownvalue = 'Food';
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
  var showText = "";
  var categoryController = TextEditingController();
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  File? _photo;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

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
    final fileName = myController['title']!.text.toString();
    //basename(_photo!.path);
    String directory = _authService.getuser()!.uid;

    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref(directory)
          .child(fileName);
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
                      title: new Text('Gallery'),
                      onTap: () {
                        imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
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
                height: 32,
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
                            width: 100,
                            height: 100,
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
                controller: myController['amount'],
                decoration: const InputDecoration(
                  icon: Icon(Icons.money),
                  hintText: 'Enter the amount',
                  labelText: 'Amount',
                  iconColor: Colors.grey,
                ),
              ),
              //datepicker to make it easier for user to choose date
              TextFormField(
                  controller: myController['date'],
                  decoration: const InputDecoration(
                    icon: Icon(Icons.calendar_month),
                    hintText: 'Enter date',
                    labelText: 'Date',
                    iconColor: Colors.grey,
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101));
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
                            Future.delayed(const Duration(seconds: 5), () {
                              Navigator.of(context).pop(true);
                            });
                            return const AlertDialog(
                              title: Text('Date is not selected!'),
                            );
                          });
                    }
                  }),
              TextFormField(
                controller: myController['place'],
                decoration: const InputDecoration(
                    icon: Icon(Icons.place_outlined), labelText: "Place"),
              ),
              TextFormField(
                controller: myController['title'],
                decoration: const InputDecoration(
                    icon: Icon(Icons.abc), labelText: "Title"),
              ),
              TextFormField(
                controller: myController['notes'],
                decoration: const InputDecoration(
                    icon: Icon(Icons.note), labelText: "Notes"),
              ),
              CheckboxListTile(
                title: Text('Expense'),
                checkColor: Colors.grey,
                activeColor: Colors.blue,
                value: expense_value,
                onChanged: (bool? value) {
                  setState(() {
                    expense_value = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Persistent'),
                checkColor: Colors.grey,
                activeColor: Colors.blue,
                value: persistent_value,
                onChanged: (bool? value) {
                  setState(() {
                    persistent_value = value!;
                  });
                },
              ),
              CheckboxListTile(
                //controller : myController['persistent'],
                title: Text('Online'),
                checkColor: Colors.grey,
                activeColor: Colors.blue,
                value: online_value,
                onChanged: (bool? value) {
                  setState(() {
                    online_value = value!;
                  });
                },
              ),
              Row(
                children: [
                  Text(
                    'Category : ',
                    style: TextStyle(
                        color: showText == "" ? Colors.black : Colors.red),
                  ),
                  Text(dropdownvalue),
                  Column(
                    children: [
                      Text(
                        showText,
                        style: TextStyle(color: Colors.red),
                      )
                    ],
                  ),
                  Container(
                    child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("transactions")
                            .where("category", isNotEqualTo: '')
                            //.where("category", i)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData)
                            return const Text("Loading.....");
                          else {
                            List<DropdownMenuItem> currencyItems = [];

                            for (int i = 0;
                                i < snapshot.data!.docs.length;
                                i++) {
                              DocumentSnapshot snap = snapshot.data!.docs[i];
                              categoryList.add(snap['category']);

                              if (currencyItems.contains(DropdownMenuItem(
                                value: (snap['category']).toString(),
                                child: Text(snap['category']),
                              ))) {
                              } else {
                                currencyItems.add(
                                  DropdownMenuItem(
                                    value: (snap['category']).toString(),
                                    child: Text(
                                      snap['category'],
                                      style:
                                          TextStyle(color: Color(0xff11b719)),
                                    ),
                                  ),
                                );
                              }
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(width: 50.0),
                                DropdownButton<dynamic>(
                                  items: currencyItems,
                                  onChanged: (choosedCategory) {
                                    setState(() {
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
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.blueGrey,
                        hoverColor: Colors.purple,
                        child: Icon(Icons.add),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('New category'),
                                  content: TextField(
                                    controller: categoryController,
                                    decoration: const InputDecoration(
                                        hintText: 'Type new category'),
                                  ),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          dropdownvalue =
                                              categoryController.text;
                                        });
                                        dropdownvalue = categoryController.text;

                                        if (categoryList
                                            .contains(dropdownvalue)) {
                                          setState(() {
                                            showText =
                                                "This category is already exists! Create a new one or choose from the list!";
                                          });
                                        } else
                                          showText = "Submit";
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Submit"),
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
                    padding: const EdgeInsets.only(left: 150.0, top: 20.0),
                    child: ElevatedButton(
                        child: const Text('Submit'),
                        onPressed: () async {
                          //create a transaction
                          final tr = Transact(
                            DateTime.parse(myController['date']!.text),
                            int.parse(myController['amount']!.text),
                            persistent_value,
                            dropdownvalue,
                            online_value,
                            myController['notes']!.text,
                            myController['place']!.text,
                            expense_value,
                            myController['title']!.text,
                          );

                          //check if with that amount the category limit is overlapped
                          final citiesRef = await FirebaseFirestore.instance
                              .collection("category_limits")
                              .where("uid",
                                  isEqualTo: _authService.getuser()!.uid)
                              .where("category".toLowerCase(),
                                  isEqualTo: tr.category!.toLowerCase())
                              //.where("expense", isEqualTo: true)
                              .get();
                          if (citiesRef.docs.isNotEmpty) {
                            if (citiesRef.docs.first['limit'] + tr.amount >
                                citiesRef.docs.first['limit']) {
                              //TODO : hibauzenet pop up window
                              print("TULLÉPED A HATART");
                            }
                          } else if (tr.expense == true) {
                            FirebaseFirestore.instance
                                .collection('category_limits')
                                .doc()
                                .set({
                              'category': tr.category.toString(),
                              'limit': "0",
                              'uid': _authService.getuser()!.uid
                            });
                          }
                          //find the category with user uid, and check if it has limit

                          //if not, normally add the transaction
                          //if it has, check the amounts, and warn the user about possible over expense

                          //store it in database
                          FirebaseFirestore.instance
                              .collection('transactions')
                              .doc()
                              .set({
                            'date': tr.date,
                            'amount': tr.amount,
                            'title': tr.title,
                            'place': tr.place,
                            'online': tr.online,
                            'expense': tr.expense,
                            'note': tr.note,
                            'category': tr.category,
                            'persistent': tr.persistent,
                            'uid': _authService.getuser()!.uid
                          });
                          //put it in the calendar
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ListAllTrans()),
                          );
                        }),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 250.0, top: 20.0),
                    child: ElevatedButton(
                      child: const Text('Back'),
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
