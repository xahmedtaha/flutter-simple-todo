import 'package:flutter/material.dart';
import 'package:todo/components/create_todo_bottomsheet.dart';
import 'package:todo/db/todo_provider.dart';
import 'package:get/get.dart';
import 'package:todo/db/todo_model.dart';

class TodoCard extends StatefulWidget {
  final Todo todo;
  final Function(Todo) onEdit;

  TodoCard({Key? key, required this.todo, required this.onEdit})
      : super(key: key);

  @override
  _TodoCardState createState() => _TodoCardState(todo: todo);
}

class _TodoCardState extends State<TodoCard> {
  Todo todo;
  TodoProvider todoProvider = Get.find();

  _TodoCardState({required this.todo});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              onSave: widget.onEdit,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
          );
        },
        leading: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            onChanged: (bool? value) {
              setState(() {
                todo.done = value!;
                todoProvider.update(todo);
              });
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            activeColor: Colors.teal,
            value: todo.done,
          ),
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
