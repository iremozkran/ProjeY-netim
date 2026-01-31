String? onlyNumbersValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Bu alan boş bırakılamaz';
  }
  final numericRegex = RegExp(r'^[0-9]+$'); // Sadece sayılara izin verir
  if (!numericRegex.hasMatch(value)) {
    return 'Lütfen yalnızca sayı girin';
  }
  return null; // Geçerli bir giriş
}

String? nullOrEmptyValidator(String? v) {
  if (v == null || v == "") {
    return "Boş bırakılamaz!";
  }
  return null;
}

String? nameValidator(String? v) {
  if (v == null) {
    return "Lütfen bir isim girin";
  } else if (v.isEmpty) {
    return "Lütfen bir isim girin";
  } else if (v.contains(RegExp(r'[1-9]'))) {
    return "İsminiz rakam içeremez";
  } else {
    return null;
  }
}

String? userNameValidator(String? v) {
  if (v == null) {
    return "Kullanıcı adı seçin";
  } else if (v.isEmpty) {
    return "Kullanıcı adı seçin";
  } else if (v.contains(RegExp(r'[A-Z]'))) {
    return "Yalnızca küçük harf!";
  } else if (v.contains(RegExp(r'[^a-z1-9_]+'))) {
    return "Kullanıcı adı izin verilmeyen karakter içeriyor";
  } else if (v.length < 3) {
    return "Kullanıcı adı en az 3 harfli olmalı";
  } else if (v.length > 20) {
    return "Daha kısa bir isim seçmeyi dene";
  }
  return null;
}

String? passwordValidator(String? v) {
  if (v == null) {
    return "Lütfen bir şifte girin";
  } else if (v.split("").length < 6) {
    return "Şifreniz en az 6 haneli olmalı";
  }
  return null;
}
