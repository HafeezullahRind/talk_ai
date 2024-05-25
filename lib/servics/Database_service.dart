// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:talk_ai/Models/user_model.dart';

// const String TODO_COLLECTON_REF = "newuser";

// class DatabaseService {
//   final _firestore = FirebaseFirestore.instance;

//   late final CollectionReference _todosRef;

//   DatabaseService() {
//     _todosRef = _firestore.collection(TODO_COLLECTON_REF).withConverter<UserModel>(
//         fromFirestore: (snapshots, _) => UserModel.fromJson(
//               snapshots.data()!,
//             ),
//         toFirestore: (todo, _) => todo.toJson());
//   }

//   Stream<List<UserModel>> getTodos() {
//   return _todosRef.snapshots().map((querySnapshot) =>
//       querySnapshot.docs.map((doc) => doc.data() as UserModel).toList());
// }

//   void addTodo(UserModel todo) async {
//     _todosRef.add(todo);
//   }

//   void updateTodo(String todoId, UserModel todo) {
//     _todosRef.doc(todoId).update(todo.toJson());
//   }

//   void deleteTodo(String todoId) {
//     _todosRef.doc(todoId).delete();
//   }
// }
