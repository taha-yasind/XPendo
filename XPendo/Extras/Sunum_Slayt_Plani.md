# Xpendo — Mezuniyet Projesi Sunum Planı (Revize)
**Süre:** 15–20 dakika | **Slayt Sayısı:** 14 | **Hedef Kitle:** 3 Yazılım Bölümü Hocası

---

> **Not:** Bu Markdown dosyası slayt oluşturmak için bir referans ve çalışma dokümanıdır; gerçek slayttan çok daha fazla metin içerir. Canva/PowerPoint'te her slayta yalnızca kısa maddeler ve görseller koy. Detaylı açıklamalar, karar gerekçeleri ve jüri cevapları bu dosyadan konuşma notu olarak kullanılır, slayta yazılmaz.

---

## GENEL YAPI

| # | Slayt Başlığı | Süre |
|---|--------------|------|
| 1 | Title | ~30 sn |
| 2 | Problem and Motivation | ~1.5 dk |
| 3 | Project Scope and Boundaries | ~1.5 dk |
| 4 | Application Overview | ~1.5 dk |
| 5 | Screens and User Journey | ~1.5 dk |
| 6 | Technology Stack and Decision Rationale | ~2 dk |
| 7 | System Architecture Overview | ~1.5 dk |
| 8 | MVVM Structure in Xpendo | ~1.5 dk |
| 9 | SwiftData Data Model | ~1 dk |
| 10 | Add Expense Flow | ~1 dk |
| 11 | OCR Receipt Suggestion Pipeline | ~1.5 dk |
| 12 | Preferences, Currency, Localization, and Notifications | ~1.5 dk |
| 13 | Testing, Limitations, and Quality | ~1 dk |
| 14 | Conclusion and Future Work | ~1 dk |
| **Toplam** | | **≈ 17–19 dk** |

---

## SLAYT DETAYLARI

---

### Slayt 1 — Title
**Süre:** ~30 sn

**İçerik:**
- Başlık: **Xpendo**
- Alt başlık: *"A Personal Expense Tracking Application for iOS"*
- Ad Soyad
- Bölüm, Üniversite
- Danışman
- Tarih

**Görsel öneri:** Xpendo uygulama ikonu ortada büyük, koyu arka plan (#0d0d1a), teal vurgu rengi (#00BFA5).

**Konuşma notu:** Sadece kendini ve projenin ne olduğunu bir cümleyle tanıt. Uzatma.

---

### Slayt 2 — Problem and Motivation
**Süre:** ~1.5 dk

**İçerik:**

**Problem (sol sütun):**
- Günlük harcamaları takip etmek zahmetli
- Mevcut uygulamalar ya çok karmaşık ya da tam lokalize değil
- Harcama farkındalığı düşük → bütçe aşımları fark edilmiyor
- Faturalardaki bilgileri manüel girmek zaman alıyor

**Çözüm — Xpendo (sağ sütun):**
- Hızlı harcama girişi
- Kategori bazlı bütçe takibi
- Görsel analitik (kategori dağılımı, aylık trend)
- Fiş üzerinden form doldurma önerisi (OCR)
- Türkçe / İngilizce, TRY / USD / EUR desteği

**Görsel öneri:** 2 sütun — sol kırmızı ikon + madde listesi, sağ yeşil ikon + madde listesi.

**Konuşma notu:** "Bu projeyi neden yaptım?" sorusunu burada cevapla. Kısa ve ikna edici ol.

**Olası jüri sorusu:** *"Piyasada benzer uygulamalar varken neden yeni bir tane yaptınız?"*

**Önerilen cevap:** Mevcut uygulamalar genellikle İngilizce ve fazla karmaşık. Bu proje, iOS ekosisteminin native teknolojileriyle (SwiftUI, SwiftData, Vision Framework) yerel kullanıcıya odaklı, sade ama teknik açıdan modern bir çözüm sunmayı amaçlıyor.

---

### Slayt 3 — Project Scope and Boundaries
**Süre:** ~1.5 dk

**İçerik:**

**Uygulamada Gerçeklenen Özellikler (✅):**
- Yerel harcama takibi (ekleme, düzenleme, silme)
- Kategori bazlı bütçe yönetimi (aylık, her kategori için ayrı limit)
- Analytics: kategori dağılım grafiği ve 6 aylık trend grafiği
- SwiftData ile local persistence
- Tema, dil ve para birimi tercihleri
- OCR tabanlı fiş öneri sistemi (kullanıcı onayı gerekli, otomatik kayıt yok)
- Local notification desteği (günlük hatırlatıcı, bütçe uyarısı)
- Onboarding ekranı ve ayarlar
- Demo mode (ayrı veri deposu)

**Kapsam Dışı Bırakılan Özellikler — Bilinçli Karar (🚫):**
- Kullanıcı girişi / kayıt (login / signup)
- Çok kullanıcı desteği
- Banka entegrasyonu
- Aktif CloudKit / iCloud senkronizasyonu
- Gerçek zamanlı döviz kuru API'si
- Tam bankacılık / finans platformu özellikleri

**Gizlilik ve Local-First Notu:** Mevcut versiyonda login, backend veya banka entegrasyonu olmadığından kullanıcı verisi tamamen cihazda kalıyor. Bu, daha sade ve gizlilik dostu bir tasarım yaklaşımını destekliyor.

**Görsel öneri:** 2 sütun — sol "✅ Gerçeklendi", sağ "🚫 Kapsam Dışı (Bilinçli)".

**Konuşma notu:** Bu slayt jüriyi yönlendirir. Kapsam dışı özellikler başarısızlık değil, bilinçli tasarım kararıdır. Bunu net söyle. "Kullanıcı verisi cihazı terk etmiyor" cümlesini ekle.

**Olası jüri sorusu:** *"Neden login sistemi eklemedíniz?"*

**Önerilen cevap:** Projenin amacı kişisel harcama takibi. Login, kullanıcı yönetimi ve backend altyapısı gerektiriyor. Bu projeyi local-first, gizlilik odaklı ve backend bağımsız tutmak hem scope açısından uygun hem de bilinçli bir mimari karar. Kullanıcı verisi cihazda kalıyor.

---

### Slayt 4 — Application Overview
**Süre:** ~1.5 dk

**İçerik:**

| Modül | Açıklama |
|-------|----------|
| 🏠 Home | Günlük ve aylık özet, son harcamalar, bütçe önizlemesi |
| 📋 Expenses | Tüm harcamalar — arama, filtre, düzenleme, silme |
| 💰 Budget | Kategori + ay bazında limit belirleme ve takip |
| 📊 Analytics | Kategori dağılım grafiği ve 6 aylık trend grafiği |
| 📷 Add Expense + OCR | Form ile harcama ekleme; opsiyonel fiş öneri sistemi |
| ⚙️ Settings | Para birimi, tema, dil, bildirim tercihleri, demo mode |

**Görsel öneri:** 6 kart grid — her birinde ikon + başlık + 1 satır açıklama.

**Konuşma notu:** Hızlıca geç. Detaylar sonraki slaytlarda gelecek.

---

### Slayt 5 — Screens and User Journey
**Süre:** ~1.5 dk

**İçerik:** 5 ekran görüntüsü yan yana, iPhone mockup frame içinde.

Kullanılacak görseller (`ScreenShots/` klasöründen):
- `Onboarding-1.png` — ilk açılış akışı
- `HomeScreen.png` veya `HomeScreen-Dark.png` — dashboard
- `Add-Expense.png` — harcama ekleme formu
- `Budget.png` — bütçe ekranı
- `Analytics.png` — analitik ekranı

**Görsel öneri:** iPhone mockup frame içinde 5 ekran, her birinin altında kısa başlık.

**Konuşma notu:** Her ekranı 15–20 saniyede geç. "Kullanıcı bu ekranda ne yapıyor?" diye kısaca anlat.

**Olası jüri sorusu:** *"Kullanıcı deneyimi (UX) tasarımını nasıl ele aldınız?"*

**Önerilen cevap:** Ekranlar sade tutuldu — her ekran tek bir sorumluluğa sahip. Tab navigation ile kullanıcı her zaman nerede olduğunu biliyor. Dark/Light mode ve Türkçe/İngilizce desteği kullanıcı tercihine göre çalışıyor. Onboarding ile kullanıcı uygulamayı ilk kez açtığında yönlendiriliyor.

---

### Slayt 6 — Technology Stack and Decision Rationale
**Süre:** ~2 dk

**İçerik:**

| Teknoloji | Kullanım | Alternatifler | Neden Seçildi | Ödünleşim |
|-----------|----------|--------------|--------------|-----------|
| **Swift** | Ana programlama dili | Objective-C | Modern, type-safe, Apple'ın aktif geliştirdiği dil | — |
| **SwiftUI** | UI katmanı | UIKit | Declarative, daha az kod, live preview, @Observable uyumu | Bazı ileri düzey UIKit özellikleri kısıtlı |
| **SwiftData** | Persistence | CoreData, SQLite, Firebase | Native Swift entegrasyonu, az boilerplate, @Model basitliği | iOS 17+ gerektirir; olgunlaşmakta olan framework |
| **Vision Framework** | OCR | Google Cloud Vision, AWS Textract | Cihaz üzerinde çalışır, offline, gizlilik, API maliyeti yok | Doğruluk ağ tabanlı servislere kıyasla düşük olabilir |
| **UserNotifications** | Bildirimler | APNs + backend push | Local-first tasarıma uygun, backend gerektirmez | Sunucu tetiklemeli bildirimler yapılamaz |
| **XCTest** | Test | Sadece manuel test | Temel logic UI'dan bağımsız dosyalarda incelenebilir hale getirildi | Tam otomatik kapsam sağlanmadı; UI test yok |

**Görsel öneri:** Her satır için ikon + kısa tablo. Alternatifler grileştirilmiş, seçilen vurgulanmış.

> **Slayt yoğunluk notu:** Gerçek slayta tam tablo sığmayabilir. Slayta yalnızca "Teknoloji + Neden seçildi" sütunlarını koy. Alternatifler ve ödünleşim sütunları bu Markdown dosyasında konuşma notu olarak kalsın.

**Konuşma notu:** Her teknolojiyi neden seçtiğini tek cümleyle açıkla. Bu slayt "Neden X değil Y?" sorularına toplu cevap veriyor.

**Olası jüri sorusu:** *"SwiftData neden kullandınız, CoreData daha olgun değil mi?"*

**Önerilen cevap:** SwiftData, iOS 17 ile gelen ve CoreData'nın üzerine inşa edilmiş modern bir abstraction. Swift modelleriyle doğal çalışıyor — `@Model`, `@Query`, `ModelContext` gibi native yapılar kullanıyor. CoreData'ya kıyasla çok daha az boilerplate. Bu projenin kapsamı ve iOS 17+ hedefi için doğru seçim.

---

### Slayt 7 — System Architecture Overview
**Süre:** ~1.5 dk

**İçerik:**

Bu slayta proje genel mimari diyagramı konur.

**Katmanlar (yukarıdan aşağıya):**

```
[ XPendoApp — @main Entry Point ]
        ↓ .modelContainer(for: activeMode)
[ XPendoModelContainer — Standard / Demo Store ]
        ↓
[ AppRootView — Onboarding / TabView / FloatingAddButton ]
        ↓
[ SwiftUI Presentation Layer ]
  HomeView | ExpensesView | BudgetView | AnalyticsView | SettingsView
        ↓
[ MVVM ViewModel Layer ]
  HomeViewModel | ExpensesViewModel | BudgetViewModel | AnalyticsViewModel
        ↓
[ SwiftData Data Layer — ModelContext ]
  Expense | Category | Budget | AppSettings
        ↓
[ Services & Helpers ]
  ReceiptOCRService | ReceiptParserService
  CurrencyConverter | LocalNotificationManager
  NotificationSyncService | AppLocalization | XPendoTheme
```

**Kullanılan Apple Framework'leri:** Vision · SwiftData · UserNotifications · SwiftUI

**Görsel öneri:** Katmanlı kutu diyagramı. Önceki oturumda oluşturulan mimari diyagram baz alınabilir.

**Konuşma notu:** Diyagramı üstten aşağı takip et. "Veri nasıl akıyor?" perspektifinden anlat.

**Olası jüri sorusu:** *"Neden bu katmanlı yapıyı seçtiniz?"*

**Önerilen cevap:** Her katman kendi sorumluluğuna sahip. UI görüntüleme yapar, ViewModel hesaplama ve doğrulama yapar, Data katmanı saklama ve sorgulama yapar. Bu ayrım kodu okunabilir, değiştirilebilir ve test edilebilir kılıyor.

---

### Slayt 8 — MVVM Structure in Xpendo
**Süre:** ~1.5 dk

**İçerik:**

**Kavramsal şema:**
```
View                ViewModel                 Model (@Model)
─────               ─────────                 ──────────────
Render only         Business logic            SwiftData entity
@Query              Validation                Expense
@State              Calculations              Category
@Binding            Data preparation          Budget
                    ─────────────             AppSettings
                    @Observable (class)
                    or struct (pure logic)
```

**Xpendo'da iki farklı ViewModel tipi:**

| Tip | Örnekler | Neden |
|-----|----------|-------|
| `struct` (pure) | HomeViewModel, AnalyticsViewModel | Sadece hesaplama yapıyor, UI state tutmuyor |
| `@Observable class` | BudgetViewModel, AddExpenseViewModel | UI state + CRUD akışları yönetiyor |

**MVVM vs Alternatifler:**

| Yaklaşım | Avantaj | Dezavantaj |
|----------|---------|-----------|
| **MVVM (seçilen)** | Test edilebilir, ayrışık, açıklanabilir | Daha fazla dosya ve yapı |
| MVC | Daha az dosya | View şişer, logic View içinde kalır |
| Logic View içinde | Hızlı prototip | Sürdürülemez, test edilemez |

**Konuşma notu:** Somut örnek ver. "HomeView ekranı çiziyor; HomeViewModel ise hangi harcamanın bugüne ait olduğunu hesaplıyor. View bu hesaplamadan haberdar değil."

**Olası jüri sorusu:** *"MVVM'yi neden seçtiniz, MVC yeterli olmaz mıydı?"*

**Önerilen cevap:** MVVM, UI kodu ile business logic'i ayırıyor. ViewModel logic'i View'dan ayrı olarak incelenebilir veya test edilebilir. MVC'de logic genellikle View'a sızıyor ve proje büyüdükçe yönetmek zorlaşıyor. SwiftUI'nin @Observable macro'su ile MVVM native olarak çok iyi entegre oluyor.

---

### Slayt 9 — SwiftData Data Model
**Süre:** ~1 dk

**İçerik:**

**4 @Model Sınıfı:**

```
Expense                      Category
───────                      ────────
id: UUID                     id: UUID
title: String                name: String
amount: Double  ← TRY        icon: String (SF Symbol)
date: Date                   color: String (hex)
category: Category?          isDefault: Bool
note: String?
createdAt: Date

Budget                       AppSettings
──────                       ───────────
id: UUID                     id: UUID
category: Category?          currencyCode: String
limitAmount: Double ← TRY    preferredThemeCode: String?
month: Int                   preferredLanguageCode: String?
year: Int                    notificationsEnabled: Bool
                             dailyReminderEnabled: Bool
                             budgetWarningEnabled: Bool
```

**Tasarım Kararı — TRY Base Storage:**

| Seçenek | Artı | Eksi |
|---------|------|------|
| **TRY base (seçilen)** | Geçmiş veriler tutarlı kalır; currency değişince veri güncellenmez | Kur oranları statik |
| Her expense'de currency saklamak | Bireysel kayıt bazında farklı currency | Toplam hesapları karmaşık, veri tutarsızlığı riski |

**Görsel öneri:** UML benzeri kutu diyagramı, ilişki oklarıyla.

**Olası jüri sorusu:** *"Neden her şeyi TRY cinsinden saklıyorsunuz?"*

**Önerilen cevap:** Tek referans para birimi kullanmak geçmiş kayıtların tutarlı kalmasını sağlıyor. Kullanıcı currency değiştirdiğinde tüm eski kayıtları güncellemek yerine sadece gösterim katmanında dönüşüm yapıyorum. Hem doğruluk hem de basitlik açısından avantajlı.

---

### Slayt 10 — Add Expense Flow
**Süre:** ~1 dk

**İçerik:**

**Normal Harcama Ekleme Akışı:**

```
FloatingAddButton  (her tabdan erişilebilir)
        ↓
AddExpenseView  (Sheet modal)
  Başlık · tutar · tarih · kategori · not
        ↓
AddExpenseViewModel
  Validation (boş alan, sıfır/negatif tutar)
  convertToTRY() → amount TRY'ye çevrilir
        ↓
ModelContext.insert(expense) + save()
        ↓
NotificationSyncService.refresh()
  → bütçe aşımı yeniden kontrol edilir
  → bildirim planı güncellenir
        ↓
Sheet kapanır, listeler güncellenir (@Query)
```

**Edit Mode:**
Aynı form ve ViewModel yapısı düzenleme modunu da destekliyor. Mevcut bir Expense sağlandığında ViewModel yeni kayıt oluşturmak yerine o kaydı günceller. Kullanıcı Expenses listesinden bir harcamaya dokunduğunda aynı `AddExpenseView` edit modunda açılır.

**Görsel öneri:** Solda `Add-Expense.png` ekran görüntüsü, sağda akış adımları.

**Konuşma notu:** "Harcama eklendiğinde sadece form kaydedilmiyor; bildirim planı da otomatik güncelleniyor" noktasını vurgula. Edit modunun da aynı yapıyı kullandığını kısaca belirt.

---

### Slayt 11 — OCR Receipt Suggestion Pipeline
**Süre:** ~1.5 dk

> ⚠️ **Kritik Çerçeveleme:** OCR otomatik kayıt yapmaz. Kullanıcıya öneri sunar. Kullanıcı formu gözden geçirir ve kayıt kararını kendisi verir.

**İçerik — Pipeline Akışı:**

```
[Kullanıcı — Kamera Butonu]
        ↓
[ReceiptScannerView]
  Kamera veya fotoğraf kütüphanesi
        ↓ UIImage
[ReceiptOCRService]
  VNRecognizeTextRequest  (Vision Framework)
  TR + EN dil modeli
  Async background task (priority: .userInitiated)
        ↓ Ham metin (String)
[ReceiptParserService]
  Merchant adı  → ilk anlamlı satır tespiti
  Tutar         → "TOPLAM" / "TOTAL" keyword + regex
  Tarih         → dd.MM.yyyy / dd/MM/yyyy / yyyy-MM-dd
  Kategori      → keyword eşleştirme (Food, Transport, Health…)
        ↓ ReceiptScanResult (title? · amount? · date? · categoryName? · note?)
[AddExpenseViewModel.applyReceiptScanResult()]
  Form alanlarına öneri olarak doldurur
        ↓
[Kullanıcı gözden geçirir, düzeltebilir]
        ↓
[Kullanıcı Save'e basar → normal save akışı]
```

**Decision Rationale — Vision Framework vs Cloud OCR:**

| | Vision Framework (seçilen) | Cloud OCR (Google / AWS) |
|-|---------------------------|--------------------------|
| Çalışma ortamı | Cihaz üzerinde, offline | İnternet + API key gerekli |
| Gizlilik | Görüntü cihazı terk etmez | Görüntü sunucuya gönderilir |
| Maliyet | Ücretsiz | API kullanım ücreti |
| Doğruluk | Fiş kalitesine bağlı | Genellikle daha yüksek |
| **Karar** | ✅ Local-first, gizlilik odaklı | ❌ Bu projenin kapsamı dışında |

**Görsel öneri:** Solda `OCR-Screen.png`, sağda pipeline diyagramı.

**Konuşma notu:** "OCR fiş bilgilerini öneri olarak forma doldurur. Kullanıcı bunları gözden geçirip kaydetmek zorunda. Sistem hiçbir zaman otomatik kayıt yapmıyor." — Bu cümleyi net söyle.

**Olası jüri sorusu:** *"OCR'ın doğruluğu nedir, ne kadar güvenilir?"*

**Önerilen cevap:** Vision Framework'ün doğruluğu fişin baskı kalitesine ve aydınlatmaya bağlı. Bu nedenle tasarım öneri tabanlı — sistem yanlış bir değer okusa bile kullanıcı formu düzeltip kayıt kararını kendisi veriyor. Otomatik kayıt olsaydı hatalı veri riski çok daha yüksek olurdu. Bu bilinçli bir güvenlik kararı.

---

### Slayt 12 — Preferences, Currency, Localization, and Notifications
**Süre:** ~1.5 dk

**İçerik:**

**Para Birimi Mimarisi:**
- `AppCurrency` enum: TRY, USD, EUR
- Sabit kur oranları (offline, API bağımlılığı yok)
- `CurrencyConverter.convertToTRY()` → kayıt anında
- `CurrencyConverter.formatFromTRY()` → gösterim anında

**Decision Rationale — Sabit Kur vs Live API:**

| | Sabit Kur (seçilen) | Live Kur API |
|-|--------------------|-------------|
| Bağımlılık | Yok | İnternet + API key |
| Çalışma | Offline | Online gerekli |
| Güncellik | Statik | Gerçek zamanlı |
| **Karar** | ✅ Local-first uyumlu | ❌ Kapsam dışı, gelecek çalışma |

**Lokalizasyon:**
- `Localizable.strings` — TR ve EN için ayrı dosyalar
- `CategoryLocalization` — kategori adları da lokalize edilir
- Dil değişince `AppRootView` View ID'sini sıfırlayarak tüm UI yenilenir

**Bildirimler:**
- `LocalNotificationManager` → günlük 20:00 hatırlatıcı, 18:00 bütçe uyarısı
- Bütçe uyarısı yalnızca aşım tespit edildiğinde planlanır
- `NotificationSyncService` → expense/budget değişince schedule yenilenir
- ⚠️ *Gerçek cihazda notification teslimatını sunum öncesi doğrula.*

**Decision Rationale — Local vs Remote Notifications:**

| | Local Notifications (seçilen) | Remote Push (APNs + backend) |
|-|------------------------------|------------------------------|
| Backend | Gerekmez | Sunucu gerekli |
| Kullanım | Hatırlatıcı, bütçe uyarısı | Sunucu tetiklemeli |
| **Karar** | ✅ Local-first uyumlu | ❌ Bu proje kapsamında gereksiz |

**Olası jüri sorusu:** *"Neden live döviz kuru kullanmadınız?"*

**Önerilen cevap:** Live kur API'si internet bağlantısı, API anahtarı ve hata yönetimi gerektiriyor. Bu projenin local-first tasarımıyla uyumsuz. Sabit oranlar offline çalışmayı garanti ediyor. Gelecekte eklenebilir bir özellik olarak bırakıldı.

---

### Slayt 13 — Testing, Limitations, and Quality
**Süre:** ~1 dk

**İçerik:**

**Unit Test Dosyaları (XCTest):**

| Dosya | Test Edilen |
|-------|------------|
| `ReceiptParserServiceTests` | OCR parser: tutar, tarih, kategori tespiti |
| `CurrencyConverterTests` | TRY ↔ USD ↔ EUR dönüşümleri |
| `DefaultCategoryProviderTests` | 8 kategorinin doğru seed edilmesi |
| `ModelInitializationTests` | @Model default değerleri ve başlangıç koşulları |

**Test Yaklaşımı:**
- Ana doğrulama yöntemi: manuel test
- Unit test dosyaları temel logic için hazırlandı; kritik logic UI'dan ayrı olarak incelenebilir
- ⚠️ *Tam otomatik test çalıştırmanın yerel Xcode ortamına göre kısıtlı olabileceğini göz önünde bulundur.*
- UI test: kapsam dışında

**Bildirim Doğrulama Notu:**
Notification planlama logic'i (`LocalNotificationManager`, `NotificationSyncService`) kodda mevcut. Ancak gerçek cihazda bildirim teslimatının doğrulanması bir validation adımı olarak kalmaktadır. Bu bir başarısızlık değil, sunum öncesi tamamlanması gereken bir kontrol noktasıdır.

**Demo Mode:**
- Ayrı SwiftData store → gerçek kullanıcı verisine dokunmaz
- Sunum sırasında güvenle gösterilebilir

**Bilinen Sınırlılıklar:**
- OCR doğruluğu fiş kalitesine ve aydınlatmaya bağlı
- Kur oranları statik (real-time değil)
- Çoklu cihaz sync yok (CloudKit aktif değil)

**Görsel öneri:** Test dosyaları listesi + Demo Mode açıklaması + Sınırlılıklar yan yana.

**Olası jüri sorusu:** *"Neden UI testi yazmadınız?"*

**Önerilen cevap:** Proje kapsamında kritik business logic testleri önceliklendirildi — OCR parser doğruluğu ve currency dönüşümleri gibi. SwiftUI UI testleri daha karmaşık setup gerektiriyor ve bu projenin zaman kapsamında önceliklendirilmedi. Manuel test ile UI davranışı doğrulandı.

---

### Slayt 14 — Conclusion and Future Work
**Süre:** ~1 dk

**İçerik:**

**Proje Özeti — Gerçeklenenler:**
- ✅ Native SwiftUI tabanlı iOS uygulaması
- ✅ MVVM mimarisi ile ayrışık, test edilebilir yapı
- ✅ SwiftData ile local-first persistence
- ✅ Cihaz üzerinde OCR tabanlı fiş öneri sistemi (Vision Framework)
- ✅ Dinamik local bildirim sistemi
- ✅ TRY base currency mimarisi
- ✅ TR/EN lokalizasyon desteği
- ✅ Dark/Light mode adaptive tasarım, Demo mode

**Gelecek Çalışmalar:**
- CloudKit/iCloud senkronizasyonu (aktif sync mevcut versiyonda etkin değil; gelecek geliştirme olarak planlanıyor)
- Gerçek zamanlı döviz kuru API entegrasyonu
- iOS Home Screen Widget
- Makbuz görsel arşivleme
- Ek dil ve para birimi desteği

**Görsel öneri:** Sol "✅ Tamamlandı", sağ "→ Gelecek". Alt orta: teşekkür + "Sorularınız?" bölümü.

**Konuşma notu:** Güçlü bitir. Öğrendiklerini değil, ne yaptığını özetle.

---

## ZAMANLAMA ÖZETİ

| Bölüm | Slaytlar | Süre |
|-------|----------|------|
| Açılış ve motivasyon | 1–2 | ~2 dk |
| Kapsam | 3 | ~1.5 dk |
| Uygulama tanıtımı | 4–5 | ~3 dk |
| Teknik mimari ve kararlar | 6–11 | ~8.5 dk |
| Kalite ve sınırlılıklar | 12–13 | ~2.5 dk |
| Kapanış | 14 | ~1 dk |
| **Toplam** | **14 slayt** | **≈ 17–19 dk** |

---

## CANVA TASARIM ÖNERİLERİ

- **Renk:** `#0d0d1a` arka plan · `#00BFA5` teal vurgu · `#ffffff` ana metin
- **Font:** Inter, SF Pro veya Helvetica Neue — temiz sans-serif
- **Slayt başına max 5–6 madde** — slayt not değil yönlendirici olmalı
- **Ekran görüntüleri:** iPhone mockup frame içine koy (Canva'da mevcut)
- **Tablolar:** Alternatifler grileştirilmiş, seçilen satır vurgulanmış
- **Teknik bloklar:** Koyu arka planlı monospace metin kutusu ile göster

---

## SUNUM ÖNCESİ KONTROL LİSTESİ

Slaytları oluşturmadan önce aşağıdakileri doğrula:

- [ ] Xcode'da projenin minimum iOS deployment target'ını kontrol et — slayttaki iOS versiyon ifadesini buna göre düzelt
- [ ] `ScreenShots/` klasöründeki görsellerin güncel ve temiz olduğunu kontrol et
- [ ] Analytics ekranındaki grafik tipini doğrula (bar chart / trend grafiği — pasta/donut grafik yoksa kullanma)
- [ ] Gerçek cihazda notification teslimatını test et (schedule logic koda yazıldı; gerçek teslimat ayrıca doğrulanmalı)
- [ ] Demo mode'un çalıştığını ve gerçek veriyi etkilemediğini doğrula
- [ ] OCR slaytında "öneri" ifadesinin kullanıldığını kontrol et — "otomatik kayıt" kesinlikle kullanma
- [ ] CloudKit'in "gelecek çalışma, aktif değil" olarak konumlandırıldığını kontrol et — "altyapı hazır" gibi ifadeler kullanma
- [ ] Unit test dosyalarının Xcode'da derlenip derlenmediğini kontrol et; "test edildi" yerine "test dosyaları hazırlandı" de
- [ ] Tüm teknik terimlerin tutarlı kullanıldığını gözden geçir (ViewModel, ModelContext, @Observable vb.)
- [ ] Gerçek slayta geçmeden önce her slayttaki metin miktarını azalt — bu Markdown çok daha ayrıntılı; slayta yalnızca kısa maddeler ve görseller gir
- [ ] Sunum sırasında gösterilecek demo akışını en az bir kez prova et
- [ ] Her slayttaki "Olası jüri sorusu" ve "Önerilen cevap" bölümlerini çalış

---

*Bu plan Xpendo projesinin kaynak kodu analiz edilerek hazırlanmıştır. "⚠️ Sunum öncesi doğrula" notları eklenen yerlerde implementation'ı canlı ortamda kontrol et.*
