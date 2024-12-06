import 'dart:convert';

const String notUserPhoto =
    'https://firebasestorage.googleapis.com/v0/b/eva-project-91804.appspot.com/o/user_photos%2Fnot_user.jpg?alt=media&token=c00c3440-595c-4b5a-857f-dea381fad831';

class MyUser {
  final String fullName;
  final String email;
  final String role;
  final String photoUrl;
  final String password;
  final String? signature;
  final String cc;
  final String eps;
  final String arl;
  final String afp;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String relationship;
  final String address;

  MyUser({
    required this.fullName,
    required this.email,
    required this.role,
    this.photoUrl = notUserPhoto,
    required this.password,
    this.signature,
    this.cc = '',
    this.eps = '',
    this.arl = '',
    this.afp = '',
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
    this.relationship = '',
    this.address = '',
  });

  MyUser copyWith({
    String? fullName,
    String? email,
    String? role,
    String? photoUrl,
    String? password,
    String? signature,
    String? cc,
    String? eps,
    String? arl,
    String? afp,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? relationship,
    String? address,
  }) {
    return MyUser(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      password: password ?? this.password,
      signature: signature ?? this.signature,
      cc: cc ?? this.cc,
      eps: eps ?? this.eps,
      arl: arl ?? this.arl,
      afp: afp ?? this.afp,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      relationship: relationship ?? this.relationship,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'role': role,
      'photoUrl': photoUrl,
      'signature': signature,
      'cc': cc,
      'eps': eps,
      'arl': arl,
      'afp': afp,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'relationship': relationship,
      'address': address,
    };
  }

  factory MyUser.fromMap(Map<String, dynamic> map) {
    return MyUser(
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      photoUrl: map['photoUrl'] ?? notUserPhoto,
      password: '',
      signature: map['signature'],
      cc: map['cc'] ?? '',
      eps: map['eps'] ?? '',
      arl: map['arl'] ?? '',
      afp: map['afp'] ?? '',
      emergencyContactName: map['emergencyContactName'] ?? '',
      emergencyContactPhone: map['emergencyContactPhone'] ?? '',
      relationship: map['relationship'] ?? '',
      address: map['address'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory MyUser.fromJson(String source) => MyUser.fromMap(json.decode(source));

  @override
  String toString() {
    return 'User(fullName: $fullName, email: $email, role: $role, photoUrl: $photoUrl, password: $password, signature: $signature, cc: $cc, eps: $eps, arl: $arl, afp: $afp, emergencyContactName: $emergencyContactName, emergencyContactPhone: $emergencyContactPhone, relationship: $relationship, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MyUser &&
        other.fullName == fullName &&
        other.email == email &&
        other.role == role &&
        other.photoUrl == photoUrl &&
        other.password == password &&
        other.signature == signature &&
        other.cc == cc &&
        other.eps == eps &&
        other.arl == arl &&
        other.afp == afp &&
        other.emergencyContactName == emergencyContactName &&
        other.emergencyContactPhone == emergencyContactPhone &&
        other.relationship == relationship &&
        other.address == address;
  }

  @override
  int get hashCode {
    return fullName.hashCode ^
        email.hashCode ^
        role.hashCode ^
        photoUrl.hashCode ^
        password.hashCode ^
        signature.hashCode ^
        cc.hashCode ^
        eps.hashCode ^
        arl.hashCode ^
        afp.hashCode ^
        emergencyContactName.hashCode ^
        emergencyContactPhone.hashCode ^
        relationship.hashCode ^
        address.hashCode;
  }
}
