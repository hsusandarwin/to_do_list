import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseMethod {
  addToDoList(Map<String,dynamic> listinfo,String id)async{
    try{
        await FirebaseFirestore.instance.collection("List").doc(id).set(listinfo);
        print('List Added Successfully');
    }catch (e){
        print('Error : $e');
    }
  }

 getLists()async{
  String uid = FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance.collection("List").where("UserId",isEqualTo: uid).snapshots();
  }

  updateCheckedTask(String taskId,bool isChecked)async{
    return await FirebaseFirestore.instance.collection("List").doc(taskId).update({"isChecked" : isChecked});
  }
}

// class DatabaseMethod {
//   Future<void> addToDoList() async {
//     print("List added");
//     final id = '123456';
//     final toJson = {'id': id, 'title': 'title'};
    // final _collection = FirebaseFirestore.instance.collection("list");
    // final querySnapshot = await _collection
    //     .where('id', isEqualTo: 'pct9RlmRcrEFE05LqMqu')
    //     .get();
    // if (querySnapshot.docs.isNotEmpty) {
    //   final existingTodo = querySnapshot.docs.first.data();
    //   print('existingTodo $');
    // }
    
//     try {
//       await FirebaseFirestore.instance.collection("list").doc(id).set(toJson);
//       print("List added successfully");
//     } catch (e) {
//       print("Error adding list: $e");
//     }
//   }
// }
