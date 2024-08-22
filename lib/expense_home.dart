import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_project/calendar.dart';
import 'package:flutter_application_project/common/color_extension.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_page.dart';

class Expense {
  final String id; // Add this field
  final String category;
  final double amount;

  Expense(this.id, this.category, this.amount); // Update the constructor
}

class ExpenseHome extends StatefulWidget {
  const ExpenseHome({super.key});

  @override
  State<ExpenseHome> createState() => _ExpenseHomeState();
}

const purple = Color(0xff602e9e);
const babypowder = Color(0xfffefefa);

final _categoryController = TextEditingController();
final _amountController = TextEditingController();
User? user = FirebaseAuth.instance.currentUser;
String? username = user?.displayName;

Future<double> _fetchTotalMonthlyExpenses() async {
  double totalMonthlyExpense = 0.0;

  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      // Get the first day of the current month
      DateTime now = DateTime.now();
      DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
      DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

      // Query expenses collection based on the user ID and date range
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('expenses')
          .where('userId', isEqualTo: user.uid)
          .where('createdAt', isGreaterThanOrEqualTo: firstDayOfMonth)
          .where('createdAt', isLessThanOrEqualTo: lastDayOfMonth)
          .get();

      for (var doc in querySnapshot.docs) {
        totalMonthlyExpense += doc['amount'];
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error fetching monthly expenses: $error");
      }
    }
  }
  return totalMonthlyExpense;
}

class _ExpenseHomeState extends State<ExpenseHome> {
  Future<List<Expense>> _fetchExpenses() async {
    List<Expense> expenses = [];

    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Query expenses collection based on the user ID
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('expenses')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .get();

        // Print fetched documents
        for (var doc in querySnapshot.docs) {
          if (kDebugMode) {
            print('Expense: ${doc['category']}, ${doc['amount']}');
          }
        }

        // Process each document in the query result
        for (var doc in querySnapshot.docs) {
          // Convert Timestamp to DateTime
          final createdAt = doc['createdAt'] as Timestamp;
          final createdAtDateTime = createdAt.toDate();

          // Check if the expense was created today
          if (DateFormat.yMd().format(createdAtDateTime) ==
              DateFormat.yMd().format(DateTime.now())) {
            // Create Expense object from document data
            expenses.add(Expense(doc.id, doc['category'], doc['amount']));
          }
        }
      } catch (error) {
        if (kDebugMode) {
          print("Error fetching expenses: $error");
        }
      }
    }
    return expenses;
  }

  bool isShowingDailyTotal =
      true; // Track if we are showing daily or monthly total

  void _toggleTotalView() {
    setState(() {
      isShowingDailyTotal = !isShowingDailyTotal;
    });
  }

  // Function to get the start of the current day
  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Function to get the end of the current day
  DateTime _endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999, 999);
  }

  void _showAddModal(BuildContext context) {
    showModalBottomSheet(
      isDismissible: false,
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
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: const TextStyle(
                        color:
                            Colors.white, // Change this to your desired color
                      ),
                      hintStyle: TextStyle(
                        color:
                            TColor.gray10, // Change this to your desired color
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.white, // Change this to your desired color
                    ),
                  ),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      labelStyle: const TextStyle(
                        color:
                            Colors.white, // Change this to your desired color
                      ),
                      hintStyle: TextStyle(
                        color:
                            TColor.gray10, // Change this to your desired color
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: Colors.white, // Change this to your desired color
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _addExpense(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ));
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
                    color: Colors.white, // Change this to your desired color
                  ),
                ),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: Colors.white, // Change this to your desired color
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

  void _showAddSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Success',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Added an entry successfully!',
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

  void _updateExpense(BuildContext context, Expense expense) async {
    final category = _categoryController.text;
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Update expense data in Firestore
        await FirebaseFirestore.instance
            .collection('expenses')
            .doc(expense.id) // Assuming you have an id field in Expense class
            .update({
          'category': category,
          'amount': amount,
        });
        _showEditSuccessDialog();

        // Clear text field controllers
        _categoryController.clear();
        _amountController.clear();

        // Fetch expenses again to update the UI
        setState(() {});
      } catch (error) {
        if (kDebugMode) {
          print("Error updating expense: $error");
        }
      }
    }
  }

  void _addExpense(BuildContext context) async {
    final category = _categoryController.text.trim();
    final amountText = _amountController.text.trim();

    // Validate category and amount input
    if (category.isEmpty || amountText.isEmpty) {
      _showErrorSnackbar(
          context, "Error: Both category and amount must be provided.");
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null) {
      _showErrorSnackbar(context, "Error: Amount must be a valid number.");
      return;
    }

    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Add expense data to Firestore
        await FirebaseFirestore.instance.collection('expenses').add({
          'userId': user.uid,
          'category': category,
          'amount': amount,
          'createdAt': DateTime.now(),
        });

        _showAddSuccessDialog();

        // Clear text field controllers
        _categoryController.clear();
        _amountController.clear();

        // Fetch expenses again to update the UI
        setState(() {});
      } catch (error) {
        if (kDebugMode) {
          print("Error adding expense: $error");
        }
        _showErrorSnackbar(context, "Error adding expense. Please try again.");
      }
    } else {
      _showErrorSnackbar(
          context, "User not logged in. Please log in and try again.");
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Input Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteExpense(Expense expense) async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Find the expense document in Firestore
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('expenses')
            .where('userId', isEqualTo: user.uid)
            .where('category', isEqualTo: expense.category)
            .where('amount', isEqualTo: expense.amount)
            .limit(1)
            .get();

        // Delete the expense document
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }

        _showDeleteSuccessDialog();

        // Fetch expenses again to update the UI
        setState(() {});
      } catch (error) {
        if (kDebugMode) {
          print(
            "Error deleting expense: $error",
          );
        }
      }
    }
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
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'No',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteExpense(expense); // Delete the expense
                Navigator.of(context).pop(); // Close the dialog
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

  Future<String?> _fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        return userDoc.get('username');
      } catch (error) {
        if (kDebugMode) {
          print("Error fetching username: $error");
        }
      }
    }
    return null;
  }

  DateTime selectDate = DateTime.now();
  var isLogoutLoading = false;

  Future<void> logOut() async {
    setState(() {
      isLogoutLoading = true;
    });
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      // Check if the widget is still in the tree
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login_page()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Expense>>(
      future: _fetchExpenses(),
      builder: (context, snapshot) {
        // Show loading indicator
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Show error message
        } else {
          List<Expense> expenses =
              snapshot.data ?? []; // Extract expense data from snapshot

          // Calculate total expense for the day
          double totalExpense =
              expenses.fold(0, (prev, curr) => prev + curr.amount);

          String formattedDate = DateFormat.yMMMMd().format(DateTime.now());
          return Scaffold(
            body: ListView(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, right: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          IconButton(
                            onPressed: logOut,
                            icon: isLogoutLoading
                                ? const CircularProgressIndicator()
                                : const Icon(Icons.exit_to_app_rounded),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Row(
                        children: <Widget>[
                          MouseRegion(
                            child: GestureDetector(
                              child: Icon(
                                Icons.home,
                                color: TColor.white,
                                size: 20,
                              ),
                            ),
                          ),
                          Text(
                            'HOME',
                            style: TextStyle(
                                color: TColor.white,
                                fontSize: 20,
                                fontFamily: 'Comforta',
                                fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 25, left: 20, right: 20),
                      child: FutureBuilder<String?>(
                        future: _fetchUserName(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            String userName = snapshot.data ?? 'user';
                            return Text(
                              'Hello $userName! Welcome Back!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Comforta',
                                fontWeight: FontWeight.w500,
                                color: TColor.white,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    Center(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 10, right: 20, left: 20),
                            child: Container(
                              margin: const EdgeInsets.only(top: 20),
                              height: 125,
                              width: 350,
                              decoration: BoxDecoration(
                                  border: Border.all(color: TColor.gray10),
                                  borderRadius: BorderRadius.circular(50),
                                  color: TColor.gray70),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      'Total Expense: ',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 15, // Adjusted font size
                                          fontFamily: 'Comforta',
                                          fontWeight: FontWeight.w500,
                                          color: TColor.white),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      '₱ ${totalExpense.toStringAsFixed(2)}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 40, // Adjusted font size
                                          fontFamily: 'Comforta',
                                          fontWeight: FontWeight.w900,
                                          color: TColor.white),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontFamily: 'Comforta',
                                        fontWeight: FontWeight.w100,
                                        color: TColor.gray10),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40, top: 15),
                  child: Text(
                    'All Expenses',
                    style: TextStyle(
                      color: TColor.white,
                      fontSize: 15, // Adjusted font size
                      fontFamily: 'Comforta',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40, top: 8),
                  child: Text(
                    'Today',
                    style: TextStyle(
                        fontSize: 10, // Adjusted font size
                        fontFamily: 'Comforta',
                        fontWeight: FontWeight.w100,
                        color: TColor.gray10),
                  ),
                ),
                // Show expenses for today
                Column(
                  children: expenses.map((expense) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(top: 5, right: 40, left: 40),
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
                                onTap: () => _deleteExpenseConfirmation(
                                    context, expense),
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
                                          color: TColor
                                              .white, // Change this to your desired color
                                        ),
                                      ),
                                      Text(
                                        '₱${expense.amount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors
                                              .white, // Change this to your desired color
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            bottomNavigationBar: BottomAppBar(
              color: Colors.grey[800],
              shape: const CircularNotchedRectangle(),
              notchMargin: 10.0,
              child: SizedBox(
                height: 20.0,
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.home,
                            color: TColor.white,
                          ),
                          Text(
                            'Home',
                            style: TextStyle(color: TColor.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20), // To create space for the FAB
                    MaterialButton(
                      minWidth: 40,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Calendar()),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.date_range,
                            color: TColor.white,
                          ),
                          Text(
                            'Date',
                            style: TextStyle(color: TColor.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.purple,
              onPressed: () => _showAddModal(context),
              shape: const CircleBorder(),
              child: Icon(
                CupertinoIcons.add,
                color: TColor.white,
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
          );
        }
      },
    );
  }
}
