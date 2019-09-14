
import 'package:todo_app/data/AppDatabase.dart';
import 'package:todo_app/domain/entity/ToDo.dart';
import 'package:todo_app/domain/repository/ToDoRepository.dart';

class TodoRepositoryImpl implements ToDoRepository {
  final AppDatabase _db;

  const TodoRepositoryImpl(this._db);

  @override
  Future<List<ToDo>> getToDos(DateTime date) async {
    return await _db.loadToDos(date);
  }

  @override
  saveToDo(ToDo toDo) {
    _db.saveToDo(toDo);
  }

  @override
  removeToDo(ToDo toDo) {
    _db.removeToDo(toDo);
  }

}