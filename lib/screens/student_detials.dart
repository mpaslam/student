import 'package:finalapp/database/model.dart';
import 'package:finalapp/database/student_provider.dart';
// import 'package:finalapp/screens/addstudents.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentDetailsScreen extends StatelessWidget {
  final Student student;

  const StudentDetailsScreen({required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmation(context, student);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (student.profilePicture != null)
              CircleAvatar(
                backgroundImage: FileImage(student.profilePicture!),
                radius: 50,
              ),
            SizedBox(height: 20),
            Text('Name: ${student.name}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Age: ${student.age}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, Student student) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Student'),
          content: Text('Are you sure you want to delete ${student.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await Provider.of<StudentProvider>(context, listen: false)
                    .deleteStudent(student);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
