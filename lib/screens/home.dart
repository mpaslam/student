// import 'package:finalapp/database/filter_provider.dart';
// import 'package:finalapp/database/model.dart';
// import 'package:finalapp/database/search_provider.dart';
// import 'package:finalapp/database/student_provider.dart';
// import 'package:finalapp/screens/student_detials.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class YourWidget extends StatelessWidget {
//   final List<Student> students;
//   // final StudentProvider studentProvider;
//   // final SearchProvider searchProvider;
//   // final FilterProvider filterProvider;
//   final TextEditingController searchController;

//   YourWidget({
//     required this.students,
//     // required this.studentProvider,
//     // required this.searchProvider,
//     // required this.filterProvider,
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
//     var studentProvider = Provider.of<StudentProvider>(context, listen: false);
//     var searchProvider = Provider.of<SearchProvider>(context, listen: false);
//     var filterProvider = Provider.of<FilterProvider>(context, listen: false);

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
