import 'package:beta_kwest_app/todo_item.dart';
import 'package:beta_kwest_app/todo_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TodoItemAdapter());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final TodoService _todoService = TodoService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: _todoService.getAllTodos(), 
        builder: (BuildContext context, AsyncSnapshot<List<TodoItem>> snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            return TodoListPage(snapshot.data ?? []);
          }else {
            return const CircularProgressIndicator();
          }
        },
        ),
      
    );
  }
}

class TodoListPage extends StatefulWidget {
  // const TodoListPage({super.key});
  final List<TodoItem> todos;

  // ignore: prefer_const_constructors_in_immutables, use_key_in_widget_constructors
  TodoListPage(this.todos);

  @override
  // ignore: library_private_types_in_public_api
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TodoService _todoService = TodoService();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kwest beta"),
        backgroundColor: Colors.black,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<TodoItem>('todoBox').listenable(),
        builder: (context, Box<TodoItem> box, _){
          return ListView.builder(
            itemCount: box.values.length,
            itemBuilder: (context, index){
              var todo = box.getAt(index);
              return ListTile(
                title: Text(todo!.title),
                leading: Checkbox(
                  value: todo.isCompleted,
                  onChanged: (val){
                    _todoService.updateIsCompleted(index, todo);
                  },
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: (){
                    _todoService.deleteTodo(index);
                  }
                ),
              );
            }
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          showDialog(
            context: context, 
            builder: (context){
              return AlertDialog(
                title: const Text('Add To do'),
                content: TextField(
                  controller: _controller,
                ),
                actions: [
                  ElevatedButton(
                    child: const Text('Add'),
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          var todo = TodoItem(_controller.text, false);
                          _todoService.addItem(todo);
                          _controller.clear();
                          Navigator.pop(context);
                        }
                      },
                  )
                ],
              );
            }
            );
        },
         child: const Icon(Icons.add),
      ),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//   final String title;
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
