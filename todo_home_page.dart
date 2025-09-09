import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TodoHomePage(),
    );
  }
}

class TodoHomePage extends StatefulWidget {
  @override
  _TodoHomePageState createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final List<Task> _tasks = [];
  final TextEditingController _controller = TextEditingController();
  String _selectedPriority = 'Low';
  String _selectedCategory = 'Work';
  String _filterStatus =
      'All'; // To filter tasks by 'All', 'Pending', or 'Completed'

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskStrings = _tasks
        .map((task) =>
            '${task.name}|${task.priority}|${task.category}|${task.isComplete}')
        .toList();
    await prefs.setStringList('tasks', taskStrings);
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskData = prefs.getStringList('tasks') ?? [];
    setState(() {
      _tasks.clear();
      for (String taskStr in taskData) {
        final taskParts = taskStr.split('|');
        if (taskParts.length == 4) {
          _tasks.add(Task(
            name: taskParts[0],
            priority: taskParts[1],
            category: taskParts[2],
            isComplete: taskParts[3] == 'true',
          ));
        }
      }
    });
  }

  void _addTask() {
    final String newTaskName = _controller.text;
    if (newTaskName.isNotEmpty) {
      setState(() {
        _tasks.add(Task(
          name: newTaskName,
          priority: _selectedPriority,
          category: _selectedCategory,
        ));
        _controller.clear();
        _saveTasks();
      });
    }
  }

  void _editTask(int index) {
    final Task task = _tasks[index];
    final TextEditingController editController =
        TextEditingController(text: task.name);
    String newPriority = task.priority;
    String newCategory = task.category;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editController,
                decoration: InputDecoration(hintText: 'Edit your task'),
              ),
              DropdownButton<String>(
                value: newPriority,
                items: ['Low', 'Medium', 'High'].map((String priority) {
                  return DropdownMenuItem<String>(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    newPriority = newValue!;
                  });
                },
              ),
              DropdownButton<String>(
                value: newCategory,
                items: ['Work', 'Personal', 'Urgent'].map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    newCategory = newValue!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _tasks[index].name = editController.text;
                  _tasks[index].priority = newPriority;
                  _tasks[index].category = newCategory;
                  _saveTasks();
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
      _saveTasks();
    });
  }

  void _toggleComplete(int index) {
    setState(() {
      _tasks[index].isComplete = !_tasks[index].isComplete;
      _saveTasks();
    });
  }

  // Filter tasks by their completion status
  List<Task> _filteredTasks() {
    if (_filterStatus == 'Pending') {
      return _tasks.where((task) => !task.isComplete).toList();
    } else if (_filterStatus == 'Completed') {
      return _tasks.where((task) => task.isComplete).toList();
    } else {
      return _tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: () => _clearCompletedTasks(),
            tooltip: 'Clear Completed Tasks',
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                _filterStatus = value;
              });
            },
            itemBuilder: (BuildContext context) {
              return ['All', 'Pending', 'Completed'].map((String status) {
                return PopupMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'Enter a new task',
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedPriority,
                    items: ['Low', 'Medium', 'High'].map((String priority) {
                      return DropdownMenuItem<String>(
                        value: priority,
                        child: Text(priority),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPriority = newValue!;
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    items:
                        ['Work', 'Personal', 'Urgent'].map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _addTask,
                    icon: Icon(Icons.add),
                    label: Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredTasks().length,
                itemBuilder: (context, index) {
                  final task = _filteredTasks()[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Checkbox(
                        value: task.isComplete,
                        onChanged: (bool? value) {
                          _toggleComplete(index);
                        },
                      ),
                      title: Text(
                        task.name,
                        style: TextStyle(
                          decoration: task.isComplete
                              ? TextDecoration.lineThrough
                              : null,
                          color: _getPriorityColor(task.priority),
                        ),
                      ),
                      subtitle: Text(
                          'Priority: ${task.priority}\nCategory: ${task.category}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editTask(index),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _removeTask(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearCompletedTasks() {
    setState(() {
      _tasks.removeWhere((task) => task.isComplete);
      _saveTasks();
    });
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.black;
    }
  }
}

class Task {
  String name;
  String priority;
  String category;
  bool isComplete;

  Task({
    required this.name,
    this.priority = 'Low', // Default priority
    this.category = 'Work', // Default category
    this.isComplete = false,
  });
}
