# Widget Extension Lokalizasyon Kurulumu

## ❌ Sorun
Widget Extension ayrı bir target olduğu için ana uygulamanın `L10n` enum'ına ve lokalizasyon dosyalarına erişemiyor.

## ✅ Çözüm

### Adım 1: Widget Klasörüne Localizable.strings Dosyaları Ekleyin

Xcode'da:

1. **SkyriftWidget** klasörüne sağ tıklayın
2. **New File...** seçin
3. **Strings File** seçin
4. Adı: `Localizable.strings`
5. **Create** tıklayın

### Adım 2: Dosyayı Lokalize Edin

1. Oluşturulan `Localizable.strings` dosyasını seçin
2. Sağ panelde (File Inspector) **Localize...** butonuna tıklayın
3. **Turkish** ve **English** seçin
4. Her dil için ayrı dosya oluşturulacak:
   - `tr.lproj/Localizable.strings`
   - `en.lproj/Localizable.strings`

### Adım 3: İçerikleri Kopyalayın

**Türkçe dosyaya** (`tr.lproj/Localizable.strings`):
```
Projedeki "SkyriftWidget-Localizable-tr.strings" içeriğini kopyalayın
```

**İngilizce dosyaya** (`en.lproj/Localizable.strings`):
```
Projedeki "SkyriftWidget-Localizable-en.strings" içeriğini kopyalayın
```

### Adım 4: Target Membership Kontrol Edin

1. Her iki `Localizable.strings` dosyasını seçin
2. Sağ panelde (File Inspector) **Target Membership** bölümünde:
   - ✅ **SkyriftWidget** işaretli olmalı
   - ✅ **SkyriftWidgetExtension** işaretli olmalı
   - ❌ **Skyrift** (ana app) işaretli OLMAMALI

---

## 🎯 Alternatif Çözüm: Shared Framework

Eğer daha temiz bir çözüm isterseniz:

### Opsiyon A: LocalizationKeys.swift'i Shared Yapın

1. `LocalizationKeys.swift` dosyasını seçin
2. Sağ panelde **Target Membership**:
   - ✅ Skyrift
   - ✅ SkyriftWidget
   - ✅ SkyriftWidgetExtension

3. `String+Localization.swift` dosyasını seçin
4. Aynı şekilde tüm target'lara ekleyin

### Opsiyon B: Widget Helper Oluşturun

```swift
// SkyriftWidget klasöründe yeni dosya: WidgetLocalization.swift

import Foundation

enum WidgetL10n {
    static func weatherDescription(for code: Int) -> String {
        let key: String
        switch code {
        case 0, 1: key = "weather_clear"
        case 2: key = "weather_partly_cloudy"
        case 3: key = "weather_overcast"
        // ... diğerleri
        default: key = "weather_cloudy"
        }
        return NSLocalizedString(key, comment: "")
    }
}
```

---

## 🧪 Test

### 1. Build Hatalarını Kontrol Edin
```bash
Cmd + Shift + K  # Clean Build Folder
Cmd + B          # Build
```

### 2. Widget'ı Test Edin
1. Uygulamayı çalıştırın
2. Ana ekrana widget ekleyin
3. Live Activity başlatın
4. Dili değiştirin:
   - Settings → Dil → Türkçe
   - Widget'taki metin değişmeli

### 3. Simulator'da Test
- İngilizce: Settings → General → Language & Region → English
- Türkçe: Settings → General → Language & Region → Türkçe

---

## 📋 Kontrol Listesi

- [ ] Widget klasöründe `Localizable.strings` oluşturuldu
- [ ] Türkçe ve İngilizce lokalizasyonlar eklendi
- [ ] İçerikler kopyalandı
- [ ] Target membership doğru
- [ ] Build başarılı (hata yok)
- [ ] Widget Türkçe'de doğru çalışıyor
- [ ] Widget İngilizce'de doğru çalışıyor
- [ ] Live Activity lokalize gösteriliyor

---

## 📁 Dosya Yapısı

```
Skyrift/
├── Skyrift/
│   ├── Resources/
│   │   ├── tr.lproj/
│   │   │   └── Localizable.strings  (Ana uygulama)
│   │   └── en.lproj/
│   │       └── Localizable.strings  (Ana uygulama)
│   └── LocalizationKeys.swift
│
└── SkyriftWidget/
    ├── SkyriftWidgetLiveActivity.swift
    ├── tr.lproj/
    │   └── Localizable.strings  (Widget - YENİ)
    └── en.lproj/
        └── Localizable.strings  (Widget - YENİ)
```

---

## 🚀 Hızlı Çözüm (Şu Anda Çalışıyor)

✅ `SkyriftWidgetLiveActivity.swift` dosyasını zaten güncelledim:
- `L10n` enum yerine doğrudan `NSLocalizedString()` kullanıyor
- Widget'ın kendi `Localizable.strings` dosyasını arayacak

**Tek yapmanız gereken:** Yukarıdaki adımları izleyerek Widget target'ına Localizable.strings dosyalarını ekleyin!

---

## 💡 Önemli Notlar

1. **Widget ve Ana Uygulama Ayrı Target'lar**
   - Ayrı bundle'ları var
   - Ayrı lokalizasyon dosyaları gerekir

2. **NSLocalizedString Otomatik Çalışır**
   - Widget'ın kendi bundle'ından okur
   - Sistem dilini otomatik alır

3. **Shared Code İçin**
   - Ortak kod paylaşmak isterseniz framework kullanın
   - Ya da dosyaları her iki target'a ekleyin

---

## ✅ Özet

**Durum:** ✅ Kod güncellemesi tamamlandı
**Gereken:** Widget Extension için Localizable.strings dosyaları eklenecek
**Sonuç:** Tüm Widget metinleri lokalize olacak

Adımları takip edin ve bildirin! 🚀
