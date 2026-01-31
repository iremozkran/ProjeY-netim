class Employee {
  int id;
  String name;
  String password;

  Employee({
    required this.id,
    required this.name,
    required this.password,
  });

  // SQL'den alınan verileri model objesine dönüştürmek için bir constructor
  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      password: map['password'],
    );
  }

  // Model objesini SQL'e yazmak için bir map fonksiyonu
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'password': password,
    };
  }

  @override
  String toString() {
    return id.toString();
  }
}
