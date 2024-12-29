import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService{
  //collection
  final CollectionReference exercises =
  FirebaseFirestore.instance.collection('Exercises');
  final CollectionReference routines = FirebaseFirestore.instance.collection('Routines');
  
  Future<DocumentSnapshot<Map<String,dynamic>>> getUserDetails(currentUser) async{
    return await FirebaseFirestore.instance.collection("Users").doc(currentUser!.uid).get();
  }
   //READ
  Stream<QuerySnapshot> getExercisesStream(){
        final exercisesStream = exercises.orderBy('name', ).snapshots();
    
    return exercisesStream;
   }
  Stream<QuerySnapshot> getStream(String collectionName){
    final stream = FirebaseFirestore.instance.collection(collectionName).orderBy('name', ).snapshots();
    
    return stream;
  }
  Future<DocumentSnapshot> getDocumentById(String collection, String id) {
  return FirebaseFirestore.instance.collection(collection).doc(id).get();
}
   //update
  /* Future<void> updateNote(String docID, String newNote){
    return notes.doc(docID).update({
      'note':newNote,
      'timestamp':Timestamp.now(),
    });
   }*/

    Future<void> deleteNote(String docID){
    return exercises.doc(docID).delete();
   }
   Future<void> deleteRoutine(String docID){
    return routines.doc(docID).delete();
   } 
   Future<List<DocumentSnapshot>> getExercisesByIds(List<String> ids) async {
    List<DocumentSnapshot> exercisesList = [];
    for (String id in ids) {
      DocumentSnapshot snapshot = await exercises.doc(id).get();
      if (snapshot.exists) {
        exercisesList.add(snapshot);
      }
    }
    return exercisesList;
  }

}