import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService{
  //collection
  final CollectionReference exercises =
  FirebaseFirestore.instance.collection('Exercises');
  final CollectionReference routines = FirebaseFirestore.instance.collection('Routines');
  
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
}