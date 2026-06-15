//
//
//
// class Employee {
//   final int id;
//   final String name;
//   final String jobTitle;
//   final String workEmail;
//   final String workPhone;
//   final String department;
//   final String manager;
//   final String company;
//   final String imageUrl; // this is a URL, not base64
//
//   Employee({
//     required this.id,
//     required this.name,
//     required this.jobTitle,
//     required this.workEmail,
//     required this.workPhone,
//     required this.department,
//     required this.manager,
//     required this.company,
//     required this.imageUrl,
//   });
//
//   // safe converter: null/false -> '', others -> toString()
//   static String _toString(dynamic value) {
//     if (value == null || value == false) return '';
//     return value.toString();
//   }
//
//   factory Employee.fromJson(Map<String, dynamic> json) {
//     return Employee(
//       id: (json['id'] as num?)?.toInt() ?? 0,
//       name: _toString(json['name']),
//       jobTitle: _toString(json['job_title']),
//       workEmail: _toString(json['work_email']),
//       workPhone: _toString(json['work_phone']),
//       department: _toString(json['department']),
//       manager: _toString(json['manager']),
//       company: _toString(json['company']),
//       // image_url from your API: "/web/image/hr.employee/1/image_1920"
//       imageUrl: _toString(json['image_url']),
//     );
//   }
// }
//
// class EmployeeResponse {
//   final int uid;
//   final String name;
//   final String email;
//   final Employee employee;
//
//   EmployeeResponse({
//     required this.uid,
//     required this.name,
//     required this.email,
//     required this.employee,
//   });
//
//   factory EmployeeResponse.fromJson(Map<String, dynamic> json) {
//     final result = json['result'] ?? {};
//     return EmployeeResponse(
//       uid: result['uid'] ?? 0,
//       name: result['name'] ?? '',
//       email: result['email'] ?? '',
//       employee: Employee.fromJson(result['employee'] ?? {}),
//     );
//   }
// }


class Employee {
  final int id;
  final String name;
  final String jobTitle;
  final String workEmail;
  final String workPhone;
  final String department;
  final String manager;
  final String company;
  final String imageUrl;

  Employee({
    required this.id,
    required this.name,
    required this.jobTitle,
    required this.workEmail,
    required this.workPhone,
    required this.department,
    required this.manager,
    required this.company,
    required this.imageUrl,
  });

  // safe converter: null / false -> '', anything else -> toString()
  static String _toString(dynamic value) {
    if (value == null || value == false) return '';
    return value.toString();
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: _toString(json['name']),
      jobTitle: _toString(json['job_title']),
      workEmail: _toString(json['work_email']),
      workPhone: _toString(json['work_phone']),
      department: _toString(json['department']),
      manager: _toString(json['manager']),
      company: _toString(json['company']),
      // image_url from API: "/web/image/hr.employee/1/image_1920"
      imageUrl: _toString(json['image_url']),
    );
  }
}

class EmployeeResponse {
  final int uid;
  final String name;
  final String email;
  final Employee employee;

  EmployeeResponse({
    required this.uid,
    required this.name,
    required this.email,
    required this.employee,
  });

  factory EmployeeResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>? ?? {};
    return EmployeeResponse(
      uid: (result['uid'] as num?)?.toInt() ?? 0,
      name: result['name'] as String? ?? '',
      email: result['email'] as String? ?? '',
      employee: Employee.fromJson(
        result['employee'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
