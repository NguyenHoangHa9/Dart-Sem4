import 'package:dart_exam/dart_exam.dart';
import 'dart:io';

void main() async {
  while (true) {
    print('Chọn một chức năng:');
    print('1. Hiển thị toàn bộ sinh viên');
    print('2. Thêm sinh viên mới');
    print('3. Sửa thông tin sinh viên');
    print('4. Tìm kiếm sinh viên');
    print('5. Thoát chương trình');

    String? choice = stdin.readLineSync();
    if (choice == null) {
      print('Lựa chọn không hợp lệ. Vui lòng thử lại.');
      continue;
    }

    switch (choice) {
      case '1':
        try {
          await displayAllStudents();
        } catch (e) {
          print('Đã xảy ra lỗi khi hiển thị sinh viên: $e');
        }
        break;
      case '2':
        try {
          await addStudent();
        } catch (e) {
          print('Đã xảy ra lỗi khi thêm sinh viên: $e');
        }
        break;
      case '3':
        try {
          await editStudent();
        } catch (e) {
          print('Đã xảy ra lỗi khi sửa thông tin sinh viên: $e');
        }
        break;
      case '4':
        try {
          await searchStudent();
        } catch (e) {
          print('Đã xảy ra lỗi khi tìm kiếm sinh viên: $e');
        }
        break;
      case '5':
        print('Thoát chương trình...');
        exit(0);
      default:
        print('Lựa chọn không hợp lệ. Vui lòng thử lại.');
    }
  }
}
