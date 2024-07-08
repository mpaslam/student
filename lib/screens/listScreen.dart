import 'dart:io';

import 'package:finalapp/database/filter_provider.dart';
import 'package:finalapp/database/model.dart';
import 'package:finalapp/database/search_provider.dart';
import 'package:finalapp/database/student_provider.dart';
import 'package:finalapp/screens/registor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var studentProvider = Provider.of<StudentProvider>(context);
    var searchProvider = Provider.of<SearchProvider>(context);
    var filterProvider = Provider.of<FilterProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: searchProvider.isSearchVisible
            ? _buildSearchField(context)
            : Text('Student List'),
        actions: [
          IconButton(
            onPressed: () {
              searchProvider.isSearchVisible = !searchProvider.isSearchVisible;
              if (!searchProvider.isSearchVisible) {
                _searchController.clear();
                searchProvider.searchQuery = '';
              }
            },
            icon: Icon(
              searchProvider.isSearchVisible ? Icons.cancel : Icons.search,
            ),
          ),
          IconButton(
            onPressed: () {
              _showFilterScreen(context, filterProvider);
            },
            icon: Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Student>>(
              stream: studentProvider.getStudentsStreamForCurrentUser(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No students found.'));
                }

                List<Student> students = snapshot.data!
                    .where((student) =>
                        student.name.toLowerCase().contains(
                            searchProvider.searchQuery.toLowerCase()) &&
                        student.age >= filterProvider.ageRange.start &&
                        student.age <= filterProvider.ageRange.end)
                    .toList();

                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    Student student = students[index];
                    return ListTile(
                      leading: student.profilePicture != null
                          ? Image.file(student.profilePicture!)
                          : Icon(Icons.person),
                      title: Text(student.name),
                      subtitle: Text('Age: ${student.age}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _confirmDeleteStudent(context, student);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              _addStudent(context);
            },
            child: Icon(Icons.add),
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            onPressed: () async {
              await _signOut(context);
            },
            child: Icon(Icons.logout),
          )
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        onChanged: (query) {
          Provider.of<SearchProvider>(context, listen: false).searchQuery =
              query;
        },
        decoration: InputDecoration(
          labelText: 'Search Students',
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              Provider.of<SearchProvider>(context, listen: false).searchQuery =
                  '';
            },
          ),
        ),
      ),
    );
  }

  Future<void> _addStudent(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController ageController = TextEditingController();

    File? imageFile;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Student'),
        content: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: ageController,
              decoration: InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    imageFile = await _pickImage(ImageSource.gallery);
                  },
                  child: Text('Pick from Gallery'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    imageFile = await _pickImage(ImageSource.camera);
                  },
                  child: Icon(Icons.camera),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  ageController.text.isNotEmpty) {
                Student student = Student(
                  name: nameController.text,
                  age: int.parse(ageController.text),
                  profilePicture: imageFile,
                );

                await Provider.of<StudentProvider>(context, listen: false)
                    .saveStudentToFirestore(student);

                Navigator.of(context).pop();
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RegistrationPage(),
          ));
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<File?> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      return File(pickedFile.path);
    }

    return null;
  }

  Future<void> _showFilterScreen(
      BuildContext context, FilterProvider filterProvider) async {
    RangeValues ageRange = filterProvider.ageRange;

    await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Age Filter',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            FlutterSlider(
              values: [ageRange.start, ageRange.end],
              rangeSlider: true,
              max: 100,
              min: 0,
              onDragging: (handlerIndex, lowerValue, upperValue) {
                filterProvider.setAgeRange(
                  RangeValues(lowerValue, upperValue),
                );
              },
              tooltip: FlutterSliderTooltip(
                alwaysShowTooltip: true,
                positionOffset: FlutterSliderTooltipPositionOffset(
                  top: 0,
                ),
              ),
            ),
            Text('Min Age: ${ageRange.start.round()}'),
            Text('Max Age: ${ageRange.end.round()}'),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteStudent(
      BuildContext context, Student student) async {
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student.name}?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await Provider.of<StudentProvider>(context, listen: false)
          .deleteStudent(student);
    }
  }
}
