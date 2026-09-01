class AdminLabels {
  static const fields = <String, String>{
    'id': 'ID',
    'fullName': 'Ad Soyad',
    'email': 'E-posta',
    'phone': 'Telefon',
    'role': 'Rol',
    'isActive': 'Durum',
    'isDeleted': 'Silinmiş',
    'isPublished': 'Yayın Durumu',
    'createdAt': 'Kayıt Tarihi',
    'updatedAt': 'Güncellenme Tarihi',
    'name': 'Ad',
    'address': 'Adres',
    'business': 'İşletme',
    'businessId': 'İşletme ID',
    'owner': 'Sahip',
    'ownerUserId': 'Sahip ID',
    'employee': 'Çalışan',
    'employeeId': 'Çalışan ID',
    'service': 'Hizmet',
    'serviceId': 'Hizmet ID',
    'services': 'Hizmetler',
    'employees': 'Çalışanlar',
    'price': 'Fiyat',
    'durationMinutes': 'Süre',
    'bufferMinutes': 'Ara Süre',
    'status': 'Durum',
    'paymentStatus': 'Ödeme Durumu',
    'date': 'Tarih',
    'startTime': 'Başlangıç',
    'endTime': 'Bitiş',
    'totalPrice': 'Toplam Tutar',
    'depositAmount': 'Depozito',
    'remainingAmount': 'Kalan Tutar',
    'rating': 'Puan',
    'comment': 'Yorum',
    'customer': 'Müşteri',
    'customerName': 'Müşteri',
    'customerPhone': 'Müşteri Telefonu',
    'appointmentId': 'Randevu ID',
    'customerId': 'Müşteri ID',
    'key': 'Anahtar',
    'title': 'Başlık',
    'value': 'Değer',
    'contentType': 'İçerik Türü',
    'group': 'Grup',
    'imageUrl': 'Görsel URL',
    'body': 'İçerik',
    'startAt': 'Başlangıç',
    'endAt': 'Bitiş',
    'question': 'Soru',
    'answer': 'Cevap',
    'sortOrder': 'Sıra',
    'fileName': 'Dosya Adı',
    'originalFileName': 'Orijinal Dosya',
    'url': 'URL',
    'mimeType': 'Dosya Türü',
    'sizeBytes': 'Boyut',
    'dataType': 'Veri Türü',
    'description': 'Açıklama',
    'isPublic': 'Herkese Açık',
    'action': 'İşlem',
    'entityType': 'Kayıt Türü',
    'entityId': 'Kayıt ID',
    'adminUserId': 'Admin ID',
    'checkedAtUtc': 'Kontrol Zamanı',
    'database': 'Veritabanı',
    'responseMilliseconds': 'Yanıt Süresi',
    'appointments': 'Randevular',
    'completed': 'Tamamlanan',
    'cancelled': 'İptal',
    'revenue': 'Gelir',
    'from': 'Başlangıç',
    'to': 'Bitiş',
  };
  static String field(String key) => fields[key] ?? key;
  static String role(String? value) =>
      const {
        'Customer': 'Müşteri',
        'BusinessOwner': 'İşletme Sahibi',
        'Admin': 'Admin',
        'SuperAdmin': 'Süper Admin',
      }[value] ??
      value ??
      '-';
  static String status(String? value) =>
      const {
        'Pending': 'Bekliyor',
        'PendingPayment': 'Ödeme Bekliyor',
        'Confirmed': 'Onaylandı',
        'Completed': 'Tamamlandı',
        'Cancelled': 'İptal Edildi',
        'CancelledRefunded': 'İptal Edildi (İadeli)',
        'CancelledLate': 'Geç İptal',
        'NoShow': 'Gelmedi',
        'DepositPaid': 'Depozito Ödendi',
        'DepositRefunded': 'Depozito İade Edildi',
        'DepositKept': 'Depozito Tutuldu',
        'Healthy': 'Sağlıklı',
        'Unhealthy': 'Sorunlu',
        'Connected': 'Bağlı',
        'Disconnected': 'Bağlantı Yok',
      }[value] ??
      value ??
      '-';
}

class AdminFormatters {
  static String value(String key, dynamic value) {
    if (value == null) return '-';
    if (key == 'role') return AdminLabels.role('$value');
    if (key.toLowerCase().contains('status') || key == 'database') {
      return AdminLabels.status('$value');
    }
    if (value is bool) return value ? 'Aktif' : 'Pasif';
    if (_dateKeys.contains(key)) {
      final date = DateTime.tryParse('$value');
      if (date != null) {
        final d = date.toLocal();
        return '${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}';
      }
    }
    if (key == 'price' ||
        key == 'totalPrice' ||
        key == 'depositAmount' ||
        key == 'remainingAmount' ||
        key == 'revenue') {
      return '${value.toString()} ₺';
    }
    if (key == 'durationMinutes' || key == 'bufferMinutes') return '$value dk';
    return '$value';
  }

  static const _dateKeys = {
    'createdAt',
    'updatedAt',
    'date',
    'startTime',
    'endTime',
    'startAt',
    'endAt',
    'checkedAtUtc',
    'from',
    'to',
  };
  static String two(int value) => value.toString().padLeft(2, '0');
}
