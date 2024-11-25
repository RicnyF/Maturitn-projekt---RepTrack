import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService{
  //collection
  final CollectionReference exercises =
  FirebaseFirestore.instance.collection('Exercises');
  
  
   //READ
  Stream<QuerySnapshot> getExercisesStream(){
        final exercisesStream = exercises.orderBy('name', ).snapshots();
    
    return exercisesStream;
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
}