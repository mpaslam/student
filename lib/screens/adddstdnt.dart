// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:finalapp/database/model.dart';
// import 'package:finalapp/screens/registor.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:flutter_xlider/flutter_xlider.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';


// FirebaseAuth auth = FirebaseAuth.instance;

// class StudentProvider extends ChangeNotifier {
//   FirebaseFirestore firestore = FirebaseFirestore.instance;
//   FirebaseAuth auth = FirebaseAuth.instance;

//   List<Student> _students = [];

//   List<Student> get students => _students;

//   set students(List<Student>? students) {
//     _students = students ?? [];

//     notifyListeners();
//   }

//   Future<void> saveStudentToFirestore(Student student) async {
//     User? currentUser = auth.currentUser;

//     if (currentUser != null) {
//       String documentName = currentUser.email!;

//       DocumentReference documentReference =
//           firestore.collection('students').doc(documentName);

//       await firestore.runTransaction((transaction) async {
//         DocumentSnapshot snapshot = await transaction.get(documentReference);

//         List<dynamic> studentsData =
//             snapshot.exists ? snapshot['students'] : [];

//         studentsData.add({
//           'name': student.name,
//           'age': student.age,
//           'profilePicturePath': student.profilePicture?.path,
//         });

//         transaction.update(documentReference, {'students': studentsData});
//       });

//       notifyListeners();
//     }
//   }

//   Future<void> deleteStudent(Student student) async {
//     User? currentUser = auth.currentUser;

//     if (currentUser != null) {
//       String documentName = currentUser.email!;

//       DocumentReference documentReference =
//           firestore.collection('students').doc(documentName);

//       await firestore.runTransaction((transaction) async {
//         DocumentSnapshot snapshot = await transaction.get(documentReference);

//         List<dynamic> studentsData =
//             snapshot.exists ? snapshot['students'] : [];

//         studentsData.removeWhere((data) =>
//             data['name'] == student.name && data['age'] == student.age);

//         transaction.update(documentReference, {'students': studentsData});
//       });

//       notifyListeners();
//     }
//   }

//   Stream<List<Student>> getStudentsStreamForCurrentUser() {
//     User? currentUser = auth.currentUser;

//     if (currentUser != null) {
//       String documentName = currentUser.email!;

//       return firestore
//           .collection('students')
//           .doc(documentName)
//           .snapshots()
//           .map((snapshot) {
//         List<dynamic> studentsData =
//             snapshot.exists ? snapshot['students'] : [];

//         return studentsData.map((data) {
//           return Student(
//             name: data['name'],
//             age: data['age'],
//             profilePicture: data['profilePicturePath'] != null
//                 ? File(data['profilePicturePath'])
//                 : null,
//           );
//         }).toList();
//       });
//     }

//     return Stream.value([]);
//   }

//   List<Student> searchStudents(String query) {
//     return _students
//         .where((student) =>
//             student.name.toLowerCase().contains(query.toLowerCase()))
//         .toList();
//   }
// }

// class FilterProvider extends ChangeNotifier {
//   RangeValues _ageRange = const RangeValues(0, 100);

//   RangeValues get ageRange => _ageRange;

//   setAgeRange(RangeValues values) {
//     _ageRange = values;
//     notifyListeners();
//   }

//   bool isStudentInRange(Student student) {
//     return student.age >= _ageRange.start && student.age <= _ageRange.end;
//   }
// }

// class SearchProvider extends ChangeNotifier {
//   bool _isSearchVisible = false;

//   bool get isSearchVisible => _isSearchVisible;

//   set isSearchVisible(bool value) {
//     _isSearchVisible = value;
//     notifyListeners();
//   }
// }

// class StudentListScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => StudentProvider()),
//         ChangeNotifierProvider(create: (_) => SearchProvider()),
//         ChangeNotifierProvider(create: (_) => FilterProvider()),
//       ],
//       child: _StudentListScreen(),
//     );
//   }
// }

// class _StudentListScreen extends StatelessWidget {
//   TextEditingController _searchController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     var studentProvider = Provider.of<StudentProvider>(context);
//     var searchProvider = Provider.of<SearchProvider>(context);
//     var filterProvider = Provider.of<FilterProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: searchProvider.isSearchVisible
//             ? _buildSearchField(context)
//             : Text('Student List'),
//         actions: [
//           IconButton(
//             onPressed: () {
//               searchProvider.isSearchVisible = !searchProvider.isSearchVisible;
//               if (!searchProvider.isSearchVisible) {
//                 _searchController.clear();
//               }
//             },
//             icon: Icon(
//               searchProvider.isSearchVisible ? Icons.cancel : Icons.search,
//             ),
//           ),
//           IconButton(
//             onPressed: () {
//               _showFilterScreen(context, filterProvider);
//             },
//             icon: Icon(Icons.filter_list),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder(
//               stream: studentProvider.getStudentsStreamForCurrentUser(),
//               builder: (context, AsyncSnapshot<List<Student>> snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return SpinKitWave(
//                     color: Colors.black,
//                     size: 50.0,
//                   );
//                 }

//                 if (snapshot.hasError) {
//                   return Text('Error: ${snapshot.error}');
//                 }

//                 List<Student> students = snapshot.data ?? [];

//                 return YourWidget(
//                   students: students,
//                   studentProvider: studentProvider,
//                   searchProvider: searchProvider,
//                   filterProvider: filterProvider,
//                   searchController: _searchController,
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             onPressed: () {
//               _addStudent(context);
//             },
//             child: Icon(Icons.add),
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           FloatingActionButton(
//             onPressed: () async {
//               await _signOut(context);
//             },
//             child: Icon(Icons.logout),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchField(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: TextField(
//         controller: _searchController,
//         onChanged: (query) {
//           Provider.of<SearchProvider>(context, listen: false).isSearchVisible =
//               true;
//         },
//         decoration: InputDecoration(
//           labelText: 'Search Students',
//           suffixIcon: IconButton(
//             icon: Icon(Icons.clear),
//             onPressed: () {
//               _searchController.clear();
//               Provider.of<SearchProvider>(context, listen: false)
//                   .isSearchVisible = false;
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _addStudent(BuildContext context) async {
//     TextEditingController nameController = TextEditingController();
//     TextEditingController ageController = TextEditingController();

//     File? imageFile;

//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Add Student'),
//         content: Column(
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: InputDecoration(labelText: 'Name'),
//             ),
//             TextField(
//               controller: ageController,
//               decoration: InputDecoration(labelText: 'Age'),
//               keyboardType: TextInputType.number,
//             ),
//             Row(
//               children: [
//                 ElevatedButton(
//                   onPressed: () async {
//                     imageFile = await _pickImage(ImageSource.gallery);
//                   },
//                   child: Text('Pick from Gallery'),
//                 ),
//                 SizedBox(width: 10),
//                 ElevatedButton(
//                   onPressed: () async {
//                     imageFile = await _pickImage(ImageSource.camera);
//                   },
//                   child: Icon(Icons.camera),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               if (nameController.text.isNotEmpty &&
//                   ageController.text.isNotEmpty) {
//                 Student student = Student(
//                   name: nameController.text,
//                   age: int.parse(ageController.text),
//                   profilePicture: imageFile,
//                 );

//                 await Provider.of<StudentProvider>(context, listen: false)
//                     .saveStudentToFirestore(student);

//                 Navigator.of(context).pop();
//               }
//             },
//             child: Text('Add'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _signOut(BuildContext context) async {
//     try {
//       await FirebaseAuth.instance.signOut();
//       Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => RegistrationPage(),
//           ));
//     } catch (e) {
//       print('Error signing out: $e');
//     }
//   }

//   Future<File?> _pickImage(ImageSource source) async {
//     final pickedFile = await ImagePicker().pickImage(source: source);

//     if (pickedFile != null) {
//       return File(pickedFile.path);
//     }

//     return null;
//   }

//   Future<void> _showFilterScreen(
//       BuildContext context, FilterProvider filterProvider) async {
//     RangeValues ageRange = filterProvider.ageRange;

//     await showModalBottomSheet(
//       context: context,
//       builder: (context) => Container(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'Age Filter',
//               style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 16.0),
//             FlutterSlider(
//               values: [ageRange.start, ageRange.end],
//               rangeSlider: true,
//               max: 100,
//               min: 0,
//               onDragging: (handlerIndex, lowerValue, upperValue) {
//                 filterProvider.setAgeRange(
//                   RangeValues(lowerValue, upperValue),
//                 );
//               },
//               tooltip: FlutterSliderTooltip(
//                 alwaysShowTooltip: true,
//                 positionOffset: FlutterSliderTooltipPositionOffset(
//                   top: 0,
//                 ),
//               ),
//             ),
//             Text('Min Age: ${ageRange.start.round()}'),
//             Text('Max Age: ${ageRange.end.round()}'),
//             SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Apply'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




// class StudentDetailsScreen extends StatelessWidget {
//   final Student student;

//   const StudentDetailsScreen({required this.student});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Student Details'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.delete),
//             onPressed: () {
//               _showDeleteConfirmation(context, student);
//             },
//           ),
//         ],
//       ),
//       body: StreamBuilder<List<Student>>(
//         stream: getStudentsStreamForCurrentUser(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           } else if (snapshot.hasError) {
//             return Center(
//               child: Text('Error: ${snapshot.error}'),
//             );
//           } else {
//             List<Student> students = snapshot.data ?? [];
//             return ListView.builder(
//               itemCount: students.length,
//               itemBuilder: (context, index) {
//                 Student updatedStudent = students[index];
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       if (updatedStudent.profilePicture != null)
//                         CircleAvatar(
//                           backgroundImage: FileImage(updatedStudent.profilePicture!),
//                           radius: 50,
//                         ),
//                       SizedBox(height: 20),
//                       Text('Name: ${updatedStudent.name}', style: TextStyle(fontSize: 18)),
//                       SizedBox(height: 10),
//                       Text('Age: ${updatedStudent.age}', style: TextStyle(fontSize: 18)),
//                     ],
//                   ),
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }

//   Stream<List<Student>> getStudentsStreamForCurrentUser() {
//   User? currentUser = auth.currentUser;
//   FirebaseFirestore firestore = FirebaseFirestore.instance; // Define firestore instance here

//   if (currentUser != null) {
//     String documentName = currentUser.email!;

//     return firestore
//         .collection('students')
//         .doc(documentName)
//         .snapshots()
//         .map((snapshot) {
//       List<dynamic> studentsData =
//           snapshot.exists ? snapshot['students'] : [];

//       return studentsData.map((data) {
//         return Student(
//           name: data['name'],
//           age: data['age'],
//           profilePicture: data['profilePicturePath'] != null
//               ? File(data['profilePicturePath'])
//               : null,
//         );
//       }).toList();
//     });
//   }

//   return Stream.value([]);
// }


//   Future<void> _showDeleteConfirmation(BuildContext context, Student student) async {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Delete Student'),
//           content: Text('Are you sure you want to delete ${student.name}?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 await Provider.of<StudentProvider>(context, listen: false)
//                     .deleteStudent(student);
//                 Navigator.of(context).pop();
//               },
//               child: Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }


// class YourWidget extends StatelessWidget {
//   final List<Student> students;
//   final StudentProvider studentProvider;
//   final SearchProvider searchProvider;
//   final FilterProvider filterProvider;
//   final TextEditingController searchController;

//   YourWidget({
//     required this.students,
//     required this.studentProvider,
//     required this.searchProvider,
//     required this.filterProvider,
//     required this.searchController,
//   });

//   Future<void> _showStudentDetails(
//       BuildContext context, Student student) async {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => StudentDetailsScreen(student: student),
//       ),
//     );
//   }

//   Future<void> _showDeleteConfirmation(
//       BuildContext context, Student student) async {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Delete Student'),
//           content: Text('Are you sure you want to delete ${student.name}?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 await Provider.of<StudentProvider>(context, listen: false)
//                     .deleteStudent(student);
//                 Navigator.of(context).pop();
//               },
//               child: Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     studentProvider.students = students;

//     List<Student> displayedStudents = searchProvider.isSearchVisible
//         ? studentProvider.searchStudents(searchController.text)
//         : studentProvider.students;

//     displayedStudents = displayedStudents
//         .where((student) => filterProvider.isStudentInRange(student))
//         .toList();

//     return ListView.builder(
//       itemCount: displayedStudents.length,
//       itemBuilder: (context, index) {
//         return ListTile(
//           onTap: () {
//             _showStudentDetails(context, displayedStudents[index]);
//           },
//           onLongPress: () {
//             _showDeleteConfirmation(context, displayedStudents[index]);
//           },
//           leading: CircleAvatar(
//             backgroundImage: displayedStudents[index].profilePicture != null
//                 ? FileImage(displayedStudents[index].profilePicture!)
//                 : null,
//           ),
//           title: Text(displayedStudents[index].name),
//           subtitle: Text('Age: ${displayedStudents[index].age}'),
//         );
//       },
//     );
//   }
// }
