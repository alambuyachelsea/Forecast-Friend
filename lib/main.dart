import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Forecast Friend',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const ShoppingPage(),
    const WorkPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forecast Friend'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Shopping',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cases),
            label: 'Work',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<TaskItem> _items = [];
  final TextEditingController _controller = TextEditingController();

  void _addItem() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Home Task'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: "Enter task name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                _controller.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                setState(() {
                  _items.add(TaskItem(name: _controller.text));
                });
                _controller.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _removeItemAfterDelay(int index) {
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _items.removeAt(index);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                return CheckboxListTile(
                  title: Text(
                    item.name,
                    style: TextStyle(
                      decoration:
                          item.isChecked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  value: item.isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      item.isChecked = value ?? false;
                      if (item.isChecked) {
                        _removeItemAfterDelay(index);
                      }
                    });
                  },
                );
              }),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _addItem,
          child: const Text('Add Home Task'),
        ),
      ],
    );
  }
}

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  @override
  _ShoppingPageState createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  final List<TaskItem> _items = [];
  final TextEditingController _controller = TextEditingController();

  void _addItem() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Shopping Task'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: "Enter task name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                _controller.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                setState(() {
                  _items.add(TaskItem(name: _controller.text));
                });
                _controller.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _removeItemAfterDelay(int index) {
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _items.removeAt(index);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                return CheckboxListTile(
                  title: Text(
                    item.name,
                    style: TextStyle(
                      decoration:
                          item.isChecked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  value: item.isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      item.isChecked = value ?? false;
                      if (item.isChecked) {
                        _removeItemAfterDelay(index);
                      }
                    });
                  },
                );
              }),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _addItem,
          child: const Text('Add Shopping Task'),
        ),
      ],
    );
  }
}

class WorkPage extends StatefulWidget {
  const WorkPage({super.key});

  @override
  _WorkPageState createState() => _WorkPageState();
}

class _WorkPageState extends State<WorkPage> {
  final List<TaskItem> _items = [];
  final TextEditingController _controller = TextEditingController();

  void _addItem() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Work Task'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: "Enter task name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                _controller.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                setState(() {
                  _items.add(TaskItem(name: _controller.text));
                });
                _controller.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _removeItemAfterDelay(int index) {
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _items.removeAt(index);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                return CheckboxListTile(
                  title: Text(
                    item.name,
                    style: TextStyle(
                      decoration:
                          item.isChecked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  value: item.isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      item.isChecked = value ?? false;
                      if (item.isChecked) {
                        _removeItemAfterDelay(index);
                      }
                    });
                  },
                );
              }),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _addItem,
          child: const Text('Add Work Task'),
        ),
      ],
    );
  }
}

class TaskItem {
  String name;
  bool isChecked;

  TaskItem({required this.name, this.isChecked = false});
}
