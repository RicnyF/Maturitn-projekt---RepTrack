import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService{
  //collection
  final CollectionReference notes =
  FirebaseFirestore.instance.collection('notes');
  
  
  // ADD
  Future<void> addNote(String note){
    return notes.add({
      'note':note,
      'timestamp':Timestamp.now(),
    });
  }
   //READ
  Stream<QuerySnapshot> getNoteStream(){
        final notesStream = notes.orderBy('timestamp', descending:true).snapshots();
    
    return notesStream;
   }
    
   //update
   Future<void> updateNote(String docID, String newNote){
    return notes.doc(docID).update({
      'note':newNote,
      'timestamp':Timestamp.now(),
    });
   }
    Future<void> deleteNote(String docID){
    return notes.doc(docID).delete();
   }
}