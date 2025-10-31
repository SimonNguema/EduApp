class AppUser {
  final String uid;
  final String? name;
  final String? email;
  final String role;
  final String? phone;

  AppUser({
    required this.uid,
    this.name,
    this.email,
    this.role = 'student',
    this.phone,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'role': role,
        'phone': phone,
        'createdAt': DateTime.now().toUtc(),
      };

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      role: map['role'] ?? 'student',
      phone: map['phone'],
    );
  }
}
