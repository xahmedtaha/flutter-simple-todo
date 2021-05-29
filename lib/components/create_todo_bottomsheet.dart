import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:todo/db/todo_provider.dart';
import 'package:todo/db/todo_model.dart';

class CreateTodoBottomsheet extends StatefulWidget {
  final Todo? todo;
  final Function(Todo) onSave;

  CreateTodoBottomsheet(
      {this.todo, required this.onSave});

  @override
  _CreateTodoBottomsheetState createState() =>
      _CreateTodoBottomsheetState(todo);
}

class _CreateTodoBottomsheetState extends State<CreateTodoBottomsheet> {
  TodoProvider todoProvider = Get.find();
  late Todo todo;

  _CreateTodoBottomsheetState(initTodo) {
    todo = initTodo ?? Todo(title: '', notes: '', priority: 'Normal');
  }

  void saveTodo() async {
    if (!todo.title.isBlank!) {
      await todoProvider.insert(todo);
      widget.onSave(todo);
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
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 10,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: todo.title,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'New todo...',
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
              TextButton(
                onPressed: todo.title.isBlank! ? null : saveTodo,
                child: Text('SAVE'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            right: 18,
            left: 18,
            bottom: 10,
          ),
          child: Row(
            children: [],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).viewInsets.bottom,
        ),
      ],
    );
  }
}
