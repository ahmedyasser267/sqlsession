import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}



class _HomeScreenState extends State<HomeScreen> {
  late Database database;
  List<Map<String, dynamic>>tasks=[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initalizeDatabse();
  }

  Future<void> initalizeDatabse() async {
    database=await createdatabse();
    refreshTasks();
  }

  Future<Database> createdatabse() async {
    return openDatabase(
        join(await getDatabasesPath(),'todolist.db'),
        onCreate: (db,version){
          return db.execute('CREATE TABLE tasks(id INTEGER PRIMARY KEY,title  TEXT,isDone INTEGER)',
          );


        },
        version: 1


    );

  }
  Future<void>insertTask(Database db,String title)async {
    await db.insert('tasks', {
      'title':title,
      'isDone':0},
      conflictAlgorithm: ConflictAlgorithm.replace,



    );


  }
  Future<List<Map<String, Object?>>>getTasks(Database db) async {
    return await db.query('tasks');

  }
  Future<void>updateTask(Database db, int id,int isDone)async {

    db.update('tasks', {'isDone':isDone},
      where: 'id=?',
      whereArgs: [id],
    );
  }
  Future<void>deleteTask(Database db,int id)async {
    await db.delete('tasks',
        where: 'id=?',
        whereArgs: [id]
    );
  }
  Future<void>refreshTasks()async {
    final data=await getTasks(database);
    setState(() {
      tasks=data;
    });

  }

  void addTask(String title) async {
    await insertTask(database,title);
    refreshTasks();

  }


  void upTasks(int id,int isDone) async {
    await updateTask(database, id, isDone);
    refreshTasks();


  }
     void removeTask(int id) async {
    await deleteTask(database, id);

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 30
        ),
        ),
        centerTitle: true,
        backgroundColor: Color(0XFF525B44),
      ),
      body: ListView.builder(

          itemCount:tasks.length, itemBuilder: (BuildContext context, int index) {
            final task=tasks[index];
            return ListTile(
              title: Text(task['title']),
              trailing: Checkbox(value: task['isDone']==1, onChanged:(value){
                upTasks(task['id'],value!?1:0);
              }

              ),
              onLongPress: ()=>removeTask(task['id']),
            );

      },


           ),
      floatingActionButton: FloatingActionButton(onPressed: ()=>
          showDialog(context: context, builder: (context)=>AlertDialog(
            title: Text('Add TASK'),
            content: TextField(
              onSubmitted: (value){
                addTask(value);
                Navigator.pop(context);
              }
            ),
          ),

          ),
          child: Icon(Icons.add),
      ),


    );
  }
}
