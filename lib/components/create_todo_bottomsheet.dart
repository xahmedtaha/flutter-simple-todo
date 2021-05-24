import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:todo/db/todo_provider.dart';
import 'package:todo/db/todo_model.dart';

class CreateTodoBottomsheet extends StatefulWidget {
  final Todo? todo;

  CreateTodoBottomsheet({this.todo});

  @override
  _CreateTodoBottomsheetState createState() =>
      _CreateTodoBottomsheetState(todo);
}

class _CreateTodoBottomsheetState extends State<CreateTodoBottomsheet> {
  TodoProvider todoProvider = Get.find();
  late Todo todo;

  _CreateTodoBottomsheetState(initTodo) {
    if (initTodo == null) {
      todo = Todo(title: '', notes: '', priority: 'Normal');
    } else {
      todo = initTodo;
    }
  }

  void saveTodo() async {
    if (!todo.title.isBlank!) {
      await todoProvider.insert(todo);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: TextFormField(
                  initialValue: todo.title,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Add todo...',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  style: TextStyle(fontSize: 18.0),
                  onChanged: (text) {
                    setState(() {
                      todo.title = text.trim();
                    });
                  },
                  onEditingComplete: saveTodo,
                ),
              ),
              IconButton(
                onPressed: todo.title.isBlank! ? null : saveTodo,
                icon: Icon(
                  Icons.check,
                ),
                tooltip: 'Add',
                color: Colors.teal,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            right: 12,
            left: 12,
            bottom: 10,
          ),
          child: ToggleButtons(
            borderRadius: BorderRadius.circular(6),
            children: <Widget>[
              Tooltip(
                message: 'Normal',
                child: Icon(
                  Icons.flag,
                  color: Colors.grey,
                ),
              ),
              Tooltip(
                message: 'Important',
                child: Icon(
                  Icons.flag,
                  color: Colors.green,
                ),
              ),
              Tooltip(
                message: 'Urgent',
                child: Icon(
                  Icons.flag,
                  color: Colors.red,
                ),
              ),
            ],
            onPressed: (index) {
              setState(() {
                switch (index) {
                  case 0:
                    todo.priority = 'Normal';
                    break;
                  case 1:
                    todo.priority = 'Important';
                    break;
                  case 2:
                    todo.priority = 'Urgent';
                    break;
                }
              });
            },
            isSelected: [
              todo.priority == 'Normal',
              todo.priority == 'Important',
              todo.priority == 'Urgent'
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).viewInsets.bottom,
        ),
      ],
    );
  }
}
