class Student {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String classeId;
  final String userId;

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.classeId,
    required this.userId,
  });

  Map<String, dynamic> toMap() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'classeId': classeId,
    'userId': userId,
    'createdAt': DateTime.now().toUtc(),
  };

  factory Student.fromMap(String id, Map<String, dynamic> map) {
    return Student(
      id: id,
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      phone: map['phone'],
      classeId: map['classeId'],
      userId: map['userId'],
    );
  }
}
