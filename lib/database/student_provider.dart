import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalapp/database/model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentProvider extends ChangeNotifier {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  List<Student> _students = [];

  List<Student> get students => _students;

  set students(List<Student>? students) {
    _students = students ?? [];
    notifyListeners();
  }

  Future<void> saveStudentToFirestore(Student student) async {
    User? currentUser = auth.currentUser;

    if (currentUser != null) {
      String documentName = currentUser.email!;

      DocumentReference documentReference =
          firestore.collection('students').doc(documentName);

      await firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(documentReference);

        List<dynamic> studentsData = snapshot.exists ? snapshot['students'] : [];

        // Log the existing data
        print('Existing students data: $studentsData');

        Map<String, dynamic> newStudentData = {
          'name': student.name,
          'age': student.age,
          'profilePicturePath': student.profilePicture?.path,
        };

        // Log the new student data
        print('New student data: $newStudentData');

        // Validate new student data
        newStudentData.forEach((key, value) {
          if (key is! String || (value is! String && value is! int && value != null)) {
            throw ArgumentError('Invalid field or value in new student data: $key: $value');
          }
        });

        studentsData.add(newStudentData);

        // Log the updated data
        print('Updated students data: $studentsData');

        if (snapshot.exists) {
          transaction.update(documentReference, {'students': studentsData});
        } else {
          transaction.set(documentReference, {'students': studentsData});
        }
      }).catchError((error) {
        print('Transaction failed: $error');
      });

      notifyListeners();
    }
  }

  Future<void> deleteStudent(Student student) async {
    User? currentUser = auth.currentUser;

    if (currentUser != null) {
      String documentName = currentUser.email!;

      DocumentReference documentReference =
          firestore.collection('students').doc(documentName);

      await firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(documentReference);

        List<dynamic> studentsData = snapshot.exists ? snapshot['students'] : [];

        // Log the existing data
        print('Existing students data: $studentsData');

        studentsData.removeWhere((data) =>
            data['name'] == student.name && data['age'] == student.age);

        // Log the updated data
        print('Updated students data: $studentsData');

        transaction.update(documentReference, {'students': studentsData});
      }).catchError((error) {
        print('Transaction failed: $error');
      });

      notifyListeners();
    }
  }

  Stream<List<Student>> getStudentsStreamForCurrentUser() {
    User? currentUser = auth.currentUser;

    if (currentUser != null) {
      String documentName = currentUser.email!;

      return firestore
          .collection('students')
          .doc(documentName)
          .snapshots()
          .map((snapshot) {
        List<dynamic> studentsData =
            snapshot.exists ? snapshot['students'] : [];

        // Log the students data from the snapshot
        print('Snapshot students data: $studentsData');

        return studentsData.map((data) {
          return Student(
            name: data['name'],
            age: data['age'],
            profilePicture: data['profilePicturePath'] != null
                ? File(data['profilePicturePath'])
                : null,
          );
        }).toList();
      });
    }

    return Stream.value([]);
  }

  List<Student> searchStudents(String query) {
    return _students
        .where((student) =>
            student.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
