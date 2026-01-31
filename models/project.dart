class Project {
  int id;
  String name;
  String startDate;
  String targetEndDate;
  String? completionDate;

  Project({
    required this.id,
    required this.name,
    required this.startDate,
    required this.targetEndDate,
    this.completionDate,
  });

  // SQL'den alınan verileri model objesine dönüştürmek için bir constructor
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      startDate: map['startDate'], // Düzenlendi
      targetEndDate: map['targetEndDate'],
      completionDate: map['completionDate'],
    );
  }

  // Model objesini SQL'e yazmak için bir map fonksiyonu
  Map<String, dynamic> toMap() {
    return {
      'completionDate': completionDate,
      'id': id,
      'name': name,
      'startDate': startDate, // Düzenlendi
      'targetEndDate': targetEndDate, // Düzenlendi
    };
  }
}
