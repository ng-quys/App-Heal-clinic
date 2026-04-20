class Users{
  DateTime createAt;
  String email;
  String fullName;
  String phone;
  String role;
  String uid;
  DateTime updateAt;

  Users({
   required this.createAt,
   required this.email,
   required this.fullName,
   required this.phone,
   required this.role,
   required this.uid,
   required this.updateAt,
});

  Map<String, dynamic> toMap(){
    return{
      'createAt': createAt,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'role': role,
      'uid': uid,
      'updateAt': updateAt,
    };
  }

  factory Users.fromMap(Map<String, dynamic> map){
    return Users(
        createAt: map['createAt'] as DateTime,
        fullName: map['fullName'],
        email: map['email'],
        phone: map['phone'],
        role: map['role'],
        uid: map['uid'],
        updateAt: map['updateAt'] as DateTime,
    );
  }
}