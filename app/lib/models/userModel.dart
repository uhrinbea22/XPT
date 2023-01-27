class UserModel {
  final String uid;
  // String? referenceId;
  UserModel({required this.uid});
}

class UserData {
  final String uid;
  final int expense;
  final int income;

  UserData({required this.uid, required this.expense, required this.income});
}

class Totals {
  final double grandBalance, grandIncome, grandExpense;

  Totals(
      {required this.grandBalance,
      required this.grandIncome,
      required this.grandExpense});
}
