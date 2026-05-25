class User {
  final int? id;
  final String fullName;
  final String email;
  final String phone;
  final String passwordHash;
  final String role; // 'shopkeeper' or 'customer'
  final String securityQuestion;
  final String securityAnswer;

  User({
    this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.passwordHash,
    required this.role,
    required this.securityQuestion,
    required this.securityAnswer,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'password_hash': passwordHash,
      'role': role,
      'security_question': securityQuestion,
      'security_answer': securityAnswer,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      fullName: map['full_name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      passwordHash: map['password_hash'] ?? '',
      role: map['role'] ?? 'shopkeeper',
      securityQuestion: map['security_question'] ?? 'What is your place of birth?',
      securityAnswer: map['security_answer'] ?? '',
    );
  }

  // Helper to map from MongoDB document (which uses _id instead of id)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : null,
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      passwordHash: json['password_hash'] ?? '',
      role: json['role'] ?? 'shopkeeper',
      securityQuestion: json['security_question'] ?? '',
      securityAnswer: json['security_answer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}
