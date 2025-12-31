class UserModel {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final int? employeeId; // 👈 optional

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.employeeId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      employeeId: json['employee_id'], // 👈 may be null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'employee_id': employeeId,
    };
  }
}
