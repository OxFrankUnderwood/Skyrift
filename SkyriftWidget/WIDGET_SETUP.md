# Skyrift Widget Kurulum Rehberi

## ✅ Tamamlanan Değişiklikler

### 1. Widget Tasarımı Güncellendi
- **Small Widget**: Kompakt görünüm, şehir adı, ikon, sıcaklık ve min/max gösterimi
- **Medium Widget**: Geniş görünüm, detaylı bilgiler, dikey ayırıcı ile ayrılmış bölümler
- **Large Widget**: Tam görünüm, büyük ikon ve kartlar halinde min/max bilgileri
- Tüm widget'lar uygulamayla aynı gradient renkleri ve tipografiyi kullanıyor

### 2. Veri Paylaşımı Yapılandırıldı
- `WidgetDataManager` kullanılarak App Group üzerinden veri paylaşımı
- Timeline her 15 dakikada bir güncelleniyor
- Gerçek hava durumu verisi widget'a aktarılıyor

### 3. Hata Düzeltildi
- `@main` attribute hatası düzeltildi (sadece Bundle'da kaldı)
- Widget'lar bundle içinde düzgün yapılandırıldı

## 🔧 Yapılması Gerekenler

### Xcode Proje Ayarları

#### 1. App Group Oluşturma (ÖNEMLİ!)

**Ana Uygulama İçin (Skyrift target):**
1. Xcode'da projenizi seçin
2. **Skyrift** target'ını seçin
3. **Signing & Capabilities** sekmesine gidin
4. **+ Capability** butonuna tıklayın
5. **App Groups** seçin
6. **+** butonuna tıklayın ve şunu ekleyin: `group.com.skyrift.weather`
7. Checkbox'ı işaretleyin

**Widget Extension İçin (SkyriftWidget target):**
1. Aynı projede **SkyriftWidget** target'ını seçin
2. **Signing & Capabilities** sekmesine gidin
3. **+ Capability** butonuna tıklayın
4. **App Groups** seçin
5. **AYNI** group ID'sini ekleyin: `group.com.skyrift.weather`
6. Checkbox'ı işaretleyin

#### 2. WidgetDataManager'ın Her İki Target'te Olduğundan Emin Olun

1. Xcode'da `WidgetDataManager.swift` dosyasını seçin
2. Sağ panelde **Target Membership** bölümünü kontrol edin
3. Şu iki checkbox'ın işaretli olduğundan emin olun:
   - ☑️ Skyrift
   - ☑️ SkyriftWidget

## 📱 Test Etme

### Widget'ı Ekleme
1. Uygulamayı çalıştırın ve bir konum için hava durumunu yükleyin
2. Ana ekrana gidin (Home Screen)
3. Boş bir alana uzun basın
4. Sağ üstteki **+** butonuna tıklayın
5. "Skyrift" widget'ını bulun
6. Small, Medium veya Large boyut seçin
7. **Add Widget** butonuna tıklayın

### Veri Güncellemesini Test Etme
1. Uygulamayı açın
2. Farklı bir konum seçin
3. Ana ekrana dönün
4. Widget'ın otomatik olarak güncellenmesini bekleyin (15 dakika içinde)
5. Veya widget'a uzun basıp "Reload Timeline" seçebilirsiniz (Debug için)

## 🎨 Tasarım Özellikleri

### Renkler
Widget'lar hava durumu koduna göre dinamik gradient kullanır:
- ☀️ **Açık Hava**: Turuncu-sarı gradient (gündüz), koyu mavi (gece)
- ☁️ **Bulutlu**: Gri-mavi tonları
- 🌫️ **Sisli**: Açık gri tonları
- 🌧️ **Yağmurlu**: Koyu mavi tonları
- ❄️ **Karlı**: Açık mavi-beyaz tonları
- ⛈️ **Fırtınalı**: Mor-koyu mavi tonları

### Tipografi
- **Sıcaklık**: Thin weight, rounded design
- **Şehir Adı**: Semibold weight
- **Detaylar**: Medium weight
- Tüm metinler beyaz renkte, opacity ile vurgulama

## 🐛 Olası Sorunlar ve Çözümler

### Widget Veri Göstermiyor
**Çözüm**: 
- App Group ID'lerinin her iki target'te de aynı olduğundan emin olun
- `WidgetDataManager.swift` dosyasının her iki target'te de olduğunu kontrol edin
- Uygulamayı tekrar derleyin ve çalıştırın

### Widget Güncellemiyor
**Çözüm**:
- Widget'a uzun basın ve "Remove Widget" → "Add Widget" yapın
- Simulatörde: Device → Trigger iCloud Sync

### "No suitable app records were found"
**Çözüm**:
- Developer hesabınızın aktif olduğundan emin olun
- Bundle ID'lerin doğru olduğunu kontrol edin
- Signing ayarlarını kontrol edin

## 📝 Notlar

- Widget'lar 15 dakikada bir otomatik güncellenir
- iOS, pil tasarrufu için widget güncellemelerini kısıtlayabilir
- Widget verisi uygulamadaki son seçili konumdan gelir
- App Group üzerinden veri paylaşımı gerçekleşir

## 🔄 Gelecek Geliştirmeler

Potansiyel özellikler:
- [ ] Saatlik tahmin grafikleri (Large widget'ta)
- [ ] Çoklu konum desteği (Kullanıcı widget'tan konum seçebilir)
- [ ] Dil desteği (Widget metinleri için localization)
- [ ] Dark/Light mode desteği
- [ ] Interaktif widget butonları (iOS 17+)

---

**Son Güncelleme**: 26 Şubat 2026
**Versiyon**: 1.0
