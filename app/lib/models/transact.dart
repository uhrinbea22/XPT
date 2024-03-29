import 'package:cloud_firestore/cloud_firestore.dart';

class Transact {
  DateTime? date;
  int amount;
  bool? persistent;
  String? category;
  bool? online;
  String? note;
  String? place;
  bool expense;
  String? picture;
  String? title;

  Transact(this.date, this.amount, this.persistent, this.category, this.online,
      this.note, this.place, this.expense, this.title, this.picture);

  Map<String, dynamic> toJson() => _transactToJson(this);

  @override
  String toString() =>
      'Transaction title: <$title>, amount:<$amount> , place<$place> , date<$date> , expense<$expense>, persistent<$persistent> , category<$category>, online<$online>';

  Transact _transactFromJson(Map<String, dynamic> json) {
    return Transact(
        (json['date'] as Timestamp).toDate(),
        json['amount'] as int,
        json['persistent'] as bool,
        json['category'] as String,
        json['online'] as bool,
        json['note'] as String,
        json['place'] as String,
        json['expense'] as bool,
        json['title'] as String,
        json['picture'] as String);
  }

  Transact.fromMap(Map<String, dynamic> data)
      : assert(data['amount'] != null),
        assert(data['category'] != null),
        assert(data['title'] != null),
        assert(data['date'] != null),
        assert(data['online'] != null),
        assert(data['note'] != null),
        assert(data['place'] != null),
        assert(data['expense'] != null),
        assert(data['persistent'] != null),
        assert(data['picture'] != null),
        title = data['title'],
        amount = data['amount'],
        date = data['date'],
        persistent = data['persistent'],
        category = data['category'],
        online = data['online'],
        note = data['note'],
        place = data['place'],
        expense = data['expense'],
        picture = data['picture'];

  Map<String, dynamic> _transactToJson(Transact tr) => <String, dynamic>{
        'amount': tr.amount,
        'date': tr.date,
        'expense': tr.expense,
      };
}
