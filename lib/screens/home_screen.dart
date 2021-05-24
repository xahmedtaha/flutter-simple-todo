import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo/components/todo_card.dart';
import 'package:todo/db/todo_provider.dart';
import 'package:todo/db/todo_model.dart';
import 'package:todo/components/create_todo_bottomsheet.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, this.title = 'Simple Todo'}) : super(key: key);

  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TodoProvider todoProvider = Get.find();
  List<Todo>? todos;

  getTodos() async {
    List<Todo> providerTodos = await todoProvider.getAll();
    setState(() {
      todos = providerTodos;
    });
  }

  @override
  void initState() {
    super.initState();
    getTodos();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).primaryColor,
      ),
      child: Scaffold(
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
          toolbarHeight: 65.0,
          centerTitle: true,
          // leading: IconButton(
          //   icon: Icon(Icons.info_outline),
          //   tooltip: 'Show app info',
          //   onPressed: () {},
          // ),
          // actions: [
          //   IconButton(
          //     icon: Icon(Icons.share_outlined),
          //     tooltip: 'Share the app',
          //     onPressed: () {},
          //   ),
          // ],
        ),
        body: todos == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : todos!.isEmpty
                ? Center(
                    child: Text(
                      'No todos, yet.',
                      style: GoogleFonts.pacifico(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.only(
                        bottom: kFloatingActionButtonMargin +
                            kBottomNavigationBarHeight +
                            12),
                    itemCount: todos?.length,
                    itemBuilder: (context, index) {
                      final todo = todos![index];
                      return Dismissible(
                        key: Key(todo.toString()),
                        child: TodoCard(
                          todo: todo,
                          onEdit: getTodos,
                        ),
                        onDismissed: (direction) {
                          setState(() {
                            todos!.removeAt(index);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Todo removed.'),
                              action: SnackBarAction(
                                label: 'UNDO',
                                onPressed: () async {
                                  await todoProvider.insert(todo);
                                  setState(() {
                                    todos!.add(todo);
                                  });
                                },
                              ),
                            ),
                          );
                          todoProvider.delete(todo.id!);
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
                      );
                    },
                  ),
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          tooltip: 'Add a todo',
          backgroundColor: Colors.teal,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => CreateTodoBottomsheet(),
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ).whenComplete(getTodos); // refresh todos when the sheet closes.
          },
        ),
      ),
    );
  }
}
