import 'package:flutter/material.dart';
import 'package:todo/components/create_todo_bottomsheet.dart';
import 'package:todo/db/todo_provider.dart';
import 'package:get/get.dart';
import 'package:todo/db/todo_model.dart';

class TodoCard extends StatefulWidget {
  final Todo todo;
  final VoidCallback onEdit;

  TodoCard({Key? key, required this.todo, required this.onEdit}) : super(key: key);

  @override
  _TodoCardState createState() => _TodoCardState(todo: todo);
}

class _TodoCardState extends State<TodoCard> {
  Todo todo;
  TodoProvider todoProvider = Get.find();

  _TodoCardState({required this.todo});

  @override
  Widget build(BuildContext context) {
    Color flagColor;
    switch (todo.priority) {
      case 'Urgent':
        flagColor = Colors.red;
        break;
      case 'Important':
        flagColor = Colors.green;
        break;
      default:
        flagColor = Colors.grey;
    }
    return Container(
      decoration: new BoxDecoration(
        border: new Border(
          bottom: new BorderSide(
            color: Colors.grey,
            width: .2,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.only(
          right: 15,
          left: 5,
        ),
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => CreateTodoBottomsheet(
              todo: todo,
            ),
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ).whenComplete(widget.onEdit);
        },
        leading: Checkbox(
          onChanged: (bool? value) {
            setState(() {
              todo.done = value!;
              todoProvider.update(todo);
            });
          },
          activeColor: Colors.teal,
          value: todo.done,
        ),
        trailing: Icon(
          Icons.flag,
          color: flagColor,
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration:
                todo.done ? TextDecoration.lineThrough : TextDecoration.none,
            color: todo.done ? Colors.grey : null,
          ),
        ),
      ),
    );
  }
}
