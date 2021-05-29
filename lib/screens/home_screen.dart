import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo/components/todo_card.dart';
import 'package:todo/db/todo_provider.dart';
import 'package:todo/db/todo_model.dart';
import 'package:todo/components/create_todo_bottomsheet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:launch_review/launch_review.dart';
import 'package:package_info/package_info.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, this.title = 'Simple Todo'}) : super(key: key);

  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TodoProvider todoProvider = Get.find();
  List<Todo> todos = [];
  final animatedListKey = GlobalKey<AnimatedListState>();
  late Future<List<Todo>> dataFuture;

  @override
  void initState() {
    super.initState();
    dataFuture = todoProvider.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).cardColor,
        systemNavigationBarIconBrightness:
            Theme.of(context).brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backwardsCompatibility: false,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Theme.of(context).primaryColor,
            statusBarIconBrightness: Brightness.light,
          ),
          title: Text(
            widget.title,
            style: GoogleFonts.pacifico(),
          ),
          centerTitle: true,
        ),
        body: FutureBuilder<List<Todo>>(
          future: dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'An error happened while retrieving todos, please restart the app. \nIf the problem persists, try deleting the app\'s storage.',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              } else if (snapshot.hasData) {
                todos = snapshot.data!;
                if (snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Add some todos !',
                      style: GoogleFonts.pacifico(
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return AnimatedList(
                  key: animatedListKey,
                  initialItemCount: todos.length,
                  itemBuilder: (context, index, animation) {
                    final todo = todos[index];
                    return SizeTransition(
                      sizeFactor: animation,
                      child: Dismissible(
                        key: Key(todo.id.toString()),
                        child: TodoCard(
                          todo: todo,
                          onEdit: (Todo editedTodo) {
                            setState(() {
                              todos[index] = editedTodo;
                            });
                          },
                        ),
                        onDismissed: (direction) {
                          todos.removeAt(index);
                          animatedListKey.currentState?.removeItem(
                            index,
                            (context, animation) =>
                                Container(), // Show nothing while animating out.. the Dismissible widget will handle the animation.
                          );
                          todoProvider.delete(todo.id);
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text('Todo removed.'),
                              action: SnackBarAction(
                                label: 'UNDO',
                                onPressed: () async {
                                  await todoProvider.insert(todo);
                                  todos.insert(index, todo);
                                  animatedListKey.currentState
                                      ?.insertItem(index);
                                },
                              ),
                            ),
                          );
                        },
                        background: Container(
                          color: Colors.red,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ListTile(
                                title: Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.white),
                                ),
                                leading: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        direction: DismissDirection.startToEnd,
                      ),
                    );
                  },
                );
              }
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          elevation: 3,
          tooltip: 'Add a todo',
          backgroundColor: Colors.teal,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => CreateTodoBottomsheet(
                onSave: (Todo newTodo) {
                  todos.insert(0, newTodo);
                  animatedListKey.currentState?.insertItem(0);
                },
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ); // refresh todos when the sheet closes.
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    context: context,
                    builder: (context) => StatefulBuilder(
                      builder: (context, updateModalState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              decoration: new BoxDecoration(
                                border: new Border(
                                  bottom: new BorderSide(
                                    color: Colors.grey,
                                    width: .2,
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Center(
                                    child: Text(
                                      'More',
                                      style: GoogleFonts.pacifico(
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ListTile(
                              title: Text('About the app'),
                              leading: Icon(Icons.info),
                              onTap: () {
                                PackageInfo.fromPlatform().then((info) {
                                  showAboutDialog(
                                    context: context,
                                    applicationVersion: info.version,
                                    applicationLegalese:
                                        "Designed and developed by Ahmed Taha (GitHub: xahmedtaha).\nOpen sourced on GitHub.",
                                    applicationIcon: Image(
                                      image: AssetImage('assets/icon/icon.png'),
                                      width: 45,
                                    ),
                                  );
                                });
                              },
                            ),
                            ListTile(
                              title: Text('Share with your friends'),
                              leading: Icon(Icons.share),
                              onTap: () {
                                PackageInfo.fromPlatform().then((info) {
                                  Share.share(
                                      "Check out Simple Todo app! https://play.google.com/store/apps/details?id=${info.packageName}");
                                });
                              },
                            ),
                            ListTile(
                              title: Text('Rate us on the app store'),
                              leading: Icon(Icons.reviews),
                              onTap: () {
                                LaunchReview.launch();
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
                icon: Icon(Icons.menu),
                tooltip: 'More options',
              ),
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    context: context,
                    builder: (context) => StatefulBuilder(
                      builder: (context, updateModalState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              decoration: new BoxDecoration(
                                border: new Border(
                                  bottom: new BorderSide(
                                    color: Colors.grey,
                                    width: .2,
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Center(
                                    child: Text(
                                      'Settings',
                                      style: GoogleFonts.pacifico(
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 20.0,
                                bottom: 30.0,
                              ),
                              child: Text(
                                'More options coming soon!',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
                icon: Icon(Icons.settings),
                tooltip: 'Settings',
              ),
            ],
          ),
          shape: CircularNotchedRectangle(),
          notchMargin: 6,
        ),
      ),
    );
  }
}
