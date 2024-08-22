import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_project/common/color_extension.dart';
import 'package:flutter_application_project/expense_home.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'main.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  _CalendarState createState() => _CalendarState();
}

final _categoryController = TextEditingController();
final _amountController = TextEditingController();

class _CalendarState extends State<Calendar> {
  late Map<DateTime, double> _expensesByDay;
  DateTime _focusedDay = DateTime.now();
  late ValueNotifier<DateTime> _selectedDay;
  List<Expense> _selectedDayExpenses = [];
  late double _totalMonthlyExpense = 0.0;

  @override
  void initState() {
    super.initState();
    _expensesByDay = {};
    _selectedDay = ValueNotifier(_focusedDay);
    _fetchAllExpenses();
    _totalMonthlyExpense = 0.0;
  }

  Future<void> _fetchAllExpenses() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('expenses')
            .where('userId', isEqualTo: user.uid)
            .get();

        Map<DateTime, double> expensesByDay = {};
        double totalMonthlyExpense = 0.0;

        for (var doc in querySnapshot.docs) {
          final createdAt = doc['createdAt'] as Timestamp;
          final date = DateTime(createdAt.toDate().year,
              createdAt.toDate().month, createdAt.toDate().day);
          final amount = doc['amount'] as double;

          if (date.month == _focusedDay.month) {
            totalMonthlyExpense += amount;
          }

          if (expensesByDay.containsKey(date)) {
            expensesByDay[date] = expensesByDay[date]! + amount;
          } else {
            expensesByDay[date] = amount;
          }
        }

        setState(() {
          _expensesByDay = expensesByDay;
          _totalMonthlyExpense = totalMonthlyExpense;
          if (kDebugMode) {
            print("Expenses by day: $_expensesByDay");
          }
        });
      } catch (error) {
        if (kDebugMode) {
          print("Error fetching expenses: $error");
        }
      }
    }
  }

  Future<List<Expense>> _fetchExpenses(DateTime day) async {
    List<Expense> expenses = [];

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('expenses')
            .where('userId', isEqualTo: user.uid)
            .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(day))
            .where('createdAt',
                isLessThan: Timestamp.fromDate(day.add(Duration(days: 1))))
            .orderBy('createdAt', descending: true)
            .get();

        for (var doc in querySnapshot.docs) {
          expenses.add(Expense(doc.id, doc['category'], doc['amount']));
        }
      } catch (error) {
        if (kDebugMode) {
          print("Error fetching expenses: $error");
        }
      }
    }

    return expenses;
  }

  void _updateExpense(BuildContext context, Expense expense) async {
    final category = _categoryController.text;
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('expenses')
            .doc(expense.id)
            .update({
          'category': category,
          'amount': amount,
        });
        _showEditSuccessDialog();

        _categoryController.clear();
        _amountController.clear();

        _selectedDayExpenses = await _fetchExpenses(_selectedDay.value);
        setState(() {});
      } catch (error) {
        if (kDebugMode) {
          print("Error updating expense: $error");
        }
      }
    }
  }

  void _showEditSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Success',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Edited an entry successfully!',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditModal(BuildContext context, Expense expense) {
    _categoryController.text = expense.category;
    _amountController.text = expense.amount.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            color: darkCard,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _updateExpense(context, expense);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  child: const Text(
                    'Update',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteExpense(Expense expense) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('expenses')
            .where('userId', isEqualTo: user.uid)
            .where('category', isEqualTo: expense.category)
            .where('amount', isEqualTo: expense.amount)
            .limit(1)
            .get();

        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }

        _showDeleteSuccessDialog();

        _selectedDayExpenses = await _fetchExpenses(_selectedDay.value);
        setState(() {});
      } catch (error) {
        if (kDebugMode) {
          print("Error deleting expense: $error");
        }
      }
    }
  }

  void _showDeleteSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Success',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Deleted an entry successfully!',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteExpenseConfirmation(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirm Deletion',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete this expense?',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'No',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteExpense(expense);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.calendar_today),
          title: const Text('Calendar'),
          backgroundColor: Colors.grey[1000],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  key: ValueKey(_expensesByDay),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) =>
                      isSameDay(day, _selectedDay.value),
                  firstDay: DateTime.utc(2000, 1, 30),
                  lastDay: DateTime.utc(2030, 12, 30),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return _buildDayCell(day);
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return _buildDayCell(day, isToday: true);
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      return _buildDayCell(day, isSelected: true);
                    },
                  ),
                  onDaySelected: (selectedDay, focusedDay) async {
                    setState(() {
                      _selectedDay.value = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _selectedDayExpenses = await _fetchExpenses(selectedDay);
                    setState(() {});
                  },
                ),
              ),
              Column(
                children: _selectedDayExpenses.map((expense) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 5, right: 40, left: 40),
                    child: SizedBox(
                      width: 370,
                      child: SizedBox(
                        height: 50,
                        child: Slidable(
                          actionPane: const SlidableDrawerActionPane(),
                          secondaryActions: <Widget>[
                            IconSlideAction(
                              caption: 'Edit',
                              color: darkBackground,
                              icon: Icons.edit,
                              onTap: () => _showEditModal(context, expense),
                            ),
                            IconSlideAction(
                              caption: 'Delete',
                              color: darkBackground,
                              icon: Icons.delete,
                              onTap: () =>
                                  _deleteExpenseConfirmation(context, expense),
                            ),
                          ],
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: TColor.gray70),
                              borderRadius: BorderRadius.circular(50),
                              color: TColor.gray80,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    expense.category,
                                    style: TextStyle(
                                      color: TColor.white,
                                    ),
                                  ),
                                  Text(
                                    '₱${expense.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Total Monthly Expense: ₱${_totalMonthlyExpense.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Comforta',
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.grey[800],
          shape: const CircularNotchedRectangle(),
          notchMargin: 10.0,
          child: SizedBox(
            height: 60.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                MaterialButton(
                  minWidth: 40,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ExpenseHome()),
                    );
                  },
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.home,
                        color: Colors.white,
                      ),
                      Text(
                        'Home',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                MaterialButton(
                  minWidth: 40,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Calendar()),
                    );
                  },
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.date_range,
                        color: Colors.white,
                      ),
                      Text(
                        'Date',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayCell(DateTime day,
      {bool isToday = false, bool isSelected = false}) {
    double totalExpense =
        _expensesByDay[DateTime(day.year, day.month, day.day)] ?? 0.0;
    return Container(
      decoration: BoxDecoration(
        color: isToday
            ? Colors.grey[1000]
            : isSelected
                ? Colors.grey[850]
                : Colors.grey[1000],
        borderRadius: BorderRadius.circular(100.0),
      ),
      margin: const EdgeInsets.all(4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day.day.toString(),
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: isToday || isSelected ? Colors.white : Colors.white,
            ),
          ),
          if (totalExpense > 0.0)
            Text(
              '₱${totalExpense.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 12.0,
                color: isToday || isSelected ? Colors.white : Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

class Expense {
  final String id;
  final String category;
  final double amount;

  Expense(this.id, this.category, this.amount);
}
