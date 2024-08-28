import 'dart:convert';
import 'dart:io';

Future<Map<String, dynamic>> readStudents() async {
  final file = File('Student.json');
  if (await file.exists()) {
    final contents = await file.readAsString();
    return jsonDecode(contents);
  }
  return {"students": []};
}

Future<void> writeStudents(Map<String, dynamic> data) async {
  final file = File('Student.json');
  
  // Kiểm tra sự tồn tại của file trước khi ghi
  if (!(await file.exists())) {
    print('File không tồn tại. Tạo file mới.');
  }

  final contents = jsonEncode(data);
  await file.writeAsString(contents, mode: FileMode.write); // Đảm bảo ghi vào file hiện tại
}

Future<void> displayAllStudents() async {
  final data = await readStudents();
  final students = data['students'] as List<dynamic>;

  if (students.isEmpty) {
    print('Không có sinh viên nào trong hệ thống.');
    return;
  }

  for (var student in students) {
    print('ID: ${student['id']} - Name: ${student['name']}');
    for (var subject in student['subjects']) {
      print('  Môn: ${subject['name']} - Điểm: ${subject['scores']}');
    }
  }
}

Future<void> addStudent() async {
  print('Nhập ID sinh viên:');
  int id = int.parse(stdin.readLineSync()!);

  print('Nhập tên sinh viên:');
  String name = stdin.readLineSync()!;

  List<Map<String, dynamic>> subjects = [];
  while (true) {
    print('Nhập tên môn học (hoặc nhập "done" để kết thúc):');
    String subjectName = stdin.readLineSync()!;
    if (subjectName == 'done') break;

    print('Nhập điểm số, phân cách bằng dấu phẩy (e.g., 8,9,10):');
    List<int> scores = stdin.readLineSync()!.split(',').map(int.parse).toList();

    subjects.add({"name": subjectName, "scores": scores});
  }

  final data = await readStudents();
  final students = data['students'] as List<dynamic>;

  final newStudent = {
    "id": id,
    "name": name,
    "subjects": subjects,
  };

  students.add(newStudent);
  data['students'] = students; // Đảm bảo rằng dữ liệu đã được cập nhật

  await writeStudents(data);
  print('Thêm sinh viên thành công!');
}

Future<void> editStudent() async {
  print('Nhập ID sinh viên cần chỉnh sửa:');
  int id = int.parse(stdin.readLineSync()!);

  final data = await readStudents();
  final students = data['students'] as List<dynamic>;

  var studentToEdit = students.firstWhere((student) => student['id'] == id, orElse: () => null);
  if (studentToEdit == null) {
    print('Sinh viên không tồn tại.');
    return;
  }

  // Chỉnh sửa tên sinh viên
  print('Nhập tên mới (hoặc để trống nếu không thay đổi):');
  String newName = stdin.readLineSync()!;
  if (newName.isNotEmpty) {
    studentToEdit['name'] = newName;
  }

  while (true) {
    print('Chọn hành động cho môn học:');
    print('1. Thêm môn học');
    print('2. Sửa môn học');
    print('3. Xóa môn học');
    print('4. Hoàn tất chỉnh sửa môn học');
    String action = stdin.readLineSync()!;

    switch (action) {
      case '1':
        // Thêm môn học mới
        print('Nhập tên môn học mới:');
        String subjectName = stdin.readLineSync()!;

        print('Nhập điểm số, phân cách bằng dấu phẩy (e.g., 8,9,10):');
        List<int> scores = stdin.readLineSync()!.split(',').map(int.parse).toList();

        studentToEdit['subjects'].add({"name": subjectName, "scores": scores});
        print('Môn học đã được thêm.');
        break;

      case '2':
        // Sửa môn học
        print('Danh sách môn học hiện tại:');
        for (int i = 0; i < studentToEdit['subjects'].length; i++) {
          print('$i. Môn: ${studentToEdit['subjects'][i]['name']} - Điểm: ${studentToEdit['subjects'][i]['scores']}');
        }

        print('Nhập chỉ số môn học cần sửa:');
        int index = int.parse(stdin.readLineSync()!);

        if (index >= 0 && index < studentToEdit['subjects'].length) {
          print('Nhập tên môn học mới (hoặc để trống nếu không thay đổi):');
          String updatedSubjectName = stdin.readLineSync()!;
          
          if (updatedSubjectName.isNotEmpty) {
            studentToEdit['subjects'][index]['name'] = updatedSubjectName;
          }

          print('Nhập điểm số mới, phân cách bằng dấu phẩy (e.g., 8,9,10):');
          List<int> updatedScores = stdin.readLineSync()!.split(',').map(int.parse).toList();

          studentToEdit['subjects'][index]['scores'] = updatedScores;
          print('Môn học đã được sửa.');
        } else {
          print('Chỉ số môn học không hợp lệ.');
        }
        break;

      case '3':
        // Xóa môn học
        print('Danh sách môn học hiện tại:');
        for (int i = 0; i < studentToEdit['subjects'].length; i++) {
          print('$i. Môn: ${studentToEdit['subjects'][i]['name']} - Điểm: ${studentToEdit['subjects'][i]['scores']}');
        }

        print('Nhập chỉ số môn học cần xóa:');
        int index = int.parse(stdin.readLineSync()!);

        if (index >= 0 && index < studentToEdit['subjects'].length) {
          studentToEdit['subjects'].removeAt(index);
          print('Môn học đã được xóa.');
        } else {
          print('Chỉ số môn học không hợp lệ.');
        }
        break;

      case '4':
        // Hoàn tất chỉnh sửa
        print('Hoàn tất chỉnh sửa môn học.');
        await writeStudents(data); // Ghi dữ liệu vào file JSON hiện tại
        return;

      default:
        print('Lựa chọn không hợp lệ. Vui lòng thử lại.');
    }
  }
}


Future<void> searchStudent() async {
  print('Nhập tên hoặc ID sinh viên cần tìm kiếm:');
  String keyword = stdin.readLineSync()!;

  final data = await readStudents();
  final students = data['students'] as List<dynamic>;

  bool found = false;
  for (var student in students) {
    if (student['id'].toString().contains(keyword) || student['name'].contains(keyword)) {
      print('ID: ${student['id']} - Name: ${student['name']}');
      for (var subject in student['subjects']) {
        print('  Môn: ${subject['name']} - Điểm: ${subject['scores']}');
      }
      found = true;
    }
  }

  if (!found) {
    print('Không tìm thấy sinh viên nào.');
  }
}
