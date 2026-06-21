# Xpendo Graduation Project Information

## 1. Project Overview

* Project name: Xpendo
* Short app description: Xpendo, bireysel kullanıcıların günlük harcamalarını kaydetmesini, kategorilere ayırmasını, bütçe limitleriyle karşılaştırmasını ve grafiklerle analiz etmesini sağlayan SwiftUI tabanlı bir iOS kişisel finans uygulamasıdır. Kanıt: `XPendo/XPendoApp.swift`, `XPendo/AppRootView.swift`, `XPendo/Features/Home/HomeView.swift`, `XPendo/Features/Expenses/ExpensesView.swift`, `XPendo/Features/Budget/BudgetView.swift`, `XPendo/Features/Analytics/AnalyticsView.swift`.
* Main problem the app solves: Kullanıcıların harcamalarını dağınık şekilde takip etmesi, kategori bazlı bütçe kontrolü yapamaması ve harcama alışkanlıklarını görsel olarak analiz edememesi problemini çözer. Kanıt: harcama kayıtları için `XPendo/Models/Expense.swift`, bütçe için `XPendo/Models/Budget.swift`, analiz için `XPendo/Features/Analytics/AnalyticsView.swift`.
* Target users: Kişisel gelir-gider takibi yapmak isteyen bireysel iOS kullanıcıları. Kodda kurumsal, aile, ekip veya çok kullanıcılı yapı bulunmamaktadır. Kanıt: login/signup veya user model bulunmaması; yerel SwiftData modelleri `Expense`, `Category`, `Budget`, `AppSettings`.
* Main objective: Harcama ekleme, listeleme, düzenleme, silme, bütçe yönetimi, bildirim, fiş OCR önerisi, lokalizasyon ve grafik destekli analiz özelliklerini tek bir modern iOS uygulamasında sunmak.
* Current development status: Partially implemented. Ana yerel harcama takibi, bütçe, analiz, ayarlar, lokalizasyon, bildirim ve OCR akışları uygulanmış görünmektedir; CloudKit/iCloud senkronizasyonu ise gerçek senkronizasyon olarak etkin değildir. Kanıt: `XPendo/Data/XPendoModelContainer.swift` içinde `cloudKitDatabase` değeri `.none` döndürmektedir; `XPendo/Features/Settings/SettingsView.swift` içinde iCloud bölümü bilgilendirme/planlı durumdadır.

## 2. Technologies Used

| Technology / Framework / Tool | Status | Where it is used | Related files |
|---|---|---|---|
| Swift | Implemented | Tüm uygulama kodu Swift ile yazılmıştır. | `XPendo/**/*.swift` |
| SwiftUI | Implemented | App entry, ekranlar, navigation, sheet, TabView ve custom UI component yapısı. | `XPendo/XPendoApp.swift`, `XPendo/AppRootView.swift`, feature view dosyaları |
| MVVM | Implemented | Ekranların önemli bir kısmında View ve ViewModel ayrımı vardır. | `XPendo/Features/*/ViewModels/*.swift`, ilgili View dosyaları |
| SwiftData | Implemented | Model persistence, `@Model`, `@Query`, `ModelContainer`, `ModelContext`. | `XPendo/Models/*.swift`, `XPendo/Data/XPendoModelContainer.swift` |
| CoreData | Not found in the current project | Kodda `import CoreData` veya CoreData stack bulunmadı. | Not found in the current project |
| UserDefaults / AppStorage | Implemented | Onboarding durumu, demo mode ve seçili dilin saklanması. | `XPendo/AppRootView.swift`, `XPendo/XPendoApp.swift`, `XPendo/Data/AppModeStore.swift`, `XPendo/Shared/AppLanguage.swift` |
| Swift Charts | Implemented | Kategori bazlı bar chart ve aylık trend chart. | `XPendo/Features/Analytics/AnalyticsView.swift` |
| UserNotifications | Implemented | Günlük hatırlatma ve bütçe aşımı bildirimi. | `XPendo/Notifications/LocalNotificationManager.swift`, `XPendo/Notifications/NotificationSyncService.swift` |
| CloudKit / iCloud | Partially implemented | Settings ekranında iCloud bilgilendirmesi ve SwiftData config içinde CloudKit hazırlık fonksiyonu var; gerçek CloudKit database `.none`. | `XPendo/Features/Settings/SettingsView.swift`, `XPendo/Data/XPendoModelContainer.swift` |
| Localization | Implemented | Türkçe/İngilizce `Localizable.strings`, uygulama içi dil seçimi ve özel `AppLocalization`. | `XPendo/en.lproj/Localizable.strings`, `XPendo/tr.lproj/Localizable.strings`, `XPendo/Shared/AppLanguage.swift` |
| OCR / Vision | Implemented | Fiş görselinden metin tanıma için `VNRecognizeTextRequest`. | `XPendo/Features/AddExpense/ReceiptOCRService.swift` |
| VisionKit | Not found in the current project | Kodda `import VisionKit` veya `DataScannerViewController` bulunmadı. | Not found in the current project |
| AVFoundation | Implemented | Kamera izni kontrolü. | `XPendo/Features/AddExpense/ReceiptScannerView.swift` |
| PhotosUI | Implemented | Fiş görselini galeriden seçme. | `XPendo/Features/AddExpense/ReceiptScannerView.swift` |
| UIKit | Implemented | Kamera picker, image handling ve adaptive UIColor desteği. | `XPendo/Features/AddExpense/ReceiptScannerView.swift`, `XPendo/Features/AddExpense/ReceiptOCRService.swift`, `XPendo/Shared/XPendoTheme.swift` |
| Observation framework | Implemented | `@Observable` ViewModel sınıfları. | `AddExpenseViewModel.swift`, `ExpensesViewModel.swift`, `BudgetViewModel.swift`, `SettingsViewModel.swift`, `NotificationSettingsViewModel.swift` |
| XCTest / XCUIAutomation | Partially implemented | `XPendoTests` içinde currency conversion, default category provider, receipt parser ve model initialization için küçük unit test suite eklendi. `XPendoUITests` dosyaları halen template-level düzeydedir. | `XPendoTests/CurrencyConverterTests.swift`, `XPendoTests/DefaultCategoryProviderTests.swift`, `XPendoTests/ReceiptParserServiceTests.swift`, `XPendoTests/ModelInitializationTests.swift`, `XPendoUITests/XPendoUITests.swift` |
| Third-party packages | Not found in the current project | `project.pbxproj` içinde Swift Package referansı bulunmadı. | `XPendo.xcodeproj/project.pbxproj` |

## 3. Architecture and Project Structure

* App architecture: SwiftUI + MVVM + SwiftData persistence mimarisi kullanılmaktadır.
* MVVM usage: Implemented. `HomeViewModel`, `ExpensesViewModel`, `BudgetViewModel`, `AnalyticsViewModel`, `SettingsViewModel`, `NotificationSettingsViewModel` ve `AddExpenseViewModel` dosyaları vardır.
* App entry point: `XPendo/XPendoApp.swift`, `@main struct XPendoApp` ile başlar ve `AppRootView` içine `XPendoModelContainer.container(for:)` bağlanır.
* Main navigation structure: `XPendo/AppRootView.swift` içinde onboarding kontrolü, `TabView`, `NavigationStack` ve floating add button vardır.
* MainTabView: Not found in the current project. Tab yapısı ayrı bir `MainTabView` dosyasında değil, `AppRootView.swift` içinde tanımlıdır.
* Main tabs: Home, Expenses, Budget, Analytics. Settings ekranına Home ekranındaki gear icon üzerinden gidilir. Kanıt: `XPendo/AppRootView.swift`, `XPendo/Features/Home/HomeView.swift`.
* Models: `Expense`, `Category`, `Budget`, `AppSettings`. Kanıt: `XPendo/Models/*.swift`.
* Views: Feature klasörleri altında ekran bazlı SwiftUI view dosyaları vardır. Kanıt: `XPendo/Features/Home/HomeView.swift`, `XPendo/Features/Expenses/ExpensesView.swift`, `XPendo/Features/Budget/BudgetView.swift`, `XPendo/Features/Analytics/AnalyticsView.swift`, `XPendo/Features/Settings/SettingsView.swift`, `XPendo/Features/AddExpense/AddExpenseView.swift`, `XPendo/Features/Onboarding/OnboardingView.swift`.
* Services / Managers / Helpers: `AppDataSeeder`, `DemoDataSeeder`, `DefaultCategoryProvider`, `CurrencyConverter`, `AppLocalization`, `CategoryLocalization`, `LocalNotificationManager`, `NotificationSyncService`, `ReceiptOCRService`, `ReceiptParserService`.
* Custom UI components: `SurfaceCard`, `FloatingAddButton`, `BudgetStatusCard`, `ExpenseRowCard`, `PlaceholderCard`, `StateMessageContent`.

## 4. Implemented Features

| Feature | Status | Explanation | Related Files |
|---|---|---|---|
| Add expense | Implemented | Yeni harcama başlık, tutar, tarih, kategori ve not ile kaydediliyor. | `XPendo/Features/AddExpense/AddExpenseView.swift`, `AddExpenseViewModel.swift` |
| Edit expense | Implemented | Expense list üzerinden edit sheet açılıyor ve mevcut `Expense` güncelleniyor. | `XPendo/Features/Expenses/ExpensesView.swift`, `XPendo/Features/AddExpense/AddExpenseView.swift` |
| Delete expense | Implemented | Silme onay sheet'i ve `modelContext.delete` kullanılıyor. | `XPendo/Features/Expenses/ExpensesView.swift`, `ExpensesViewModel.swift` |
| Expense list | Implemented | Harcamalar tarih ve oluşturulma zamanına göre listeleniyor, filtreleniyor. | `XPendo/Features/Expenses/ExpensesView.swift` |
| Expense categories | Implemented | Varsayılan kategoriler seed ediliyor ve harcama/bütçe ile ilişkilendiriliyor. | `XPendo/Data/DefaultCategoryProvider.swift`, `XPendo/Data/AppDataSeeder.swift`, `XPendo/Models/Category.swift` |
| Budget management | Implemented | Aylık bütçe oluşturma/güncelleme ve harcama karşılaştırması var. | `XPendo/Features/Budget/BudgetView.swift`, `BudgetViewModel.swift` |
| Category-based budget | Implemented | Bütçeler kategori ilişkisi ile tutuluyor. | `XPendo/Models/Budget.swift`, `BudgetStatusCard.swift` |
| Budget reset | Implemented | Kategori-ay bütçesi reset confirmation sheet ile silinebiliyor. | `XPendo/Features/Budget/BudgetView.swift`, `BudgetViewModel.swift` |
| Analytics screen | Implemented | Toplam harcama, top kategori, en yüksek ay ve grafikler gösteriliyor. | `XPendo/Features/Analytics/AnalyticsView.swift`, `AnalyticsViewModel.swift` |
| Charts / donut chart / bar chart | Partially implemented | Swift Charts ile bar chart ve line/area chart var; donut chart bulunmadı. | `XPendo/Features/Analytics/AnalyticsView.swift` |
| Settings screen | Implemented | Bildirim, tema, dil, para birimi, demo data, onboarding ve iCloud bilgi bölümleri var. | `XPendo/Features/Settings/SettingsView.swift` |
| Theme selection | Implemented | Light, dark, system tema seçenekleri var. | `XPendo/Shared/XPendoTheme.swift`, `XPendo/Features/Settings/ViewModels/SettingsViewModel.swift` |
| Dark mode / Light mode | Implemented | `preferredColorScheme` ve adaptive renk paleti kullanılıyor. | `XPendo/AppRootView.swift`, `XPendo/Shared/XPendoTheme.swift` |
| Language selection | Implemented | Uygulama içinde English/Türkçe seçimi ve locale güncellemesi var. | `XPendo/Shared/AppLanguage.swift`, `XPendo/Features/Settings/SettingsView.swift` |
| Turkish / English localization | Implemented | `en.lproj` ve `tr.lproj` içinde `Localizable.strings` dosyaları var. | `XPendo/en.lproj/Localizable.strings`, `XPendo/tr.lproj/Localizable.strings` |
| Currency selection | Implemented | TRY, USD, EUR seçenekleri var. | `XPendo/Shared/CurrencyConverter.swift`, `SettingsViewModel.swift` |
| Local currency conversion | Implemented | TRY base currency olarak kullanılıyor; USD ve EUR için sabit local rate var. | `XPendo/Shared/CurrencyConverter.swift` |
| Data persistence after app restart | Implemented | SwiftData persistent `ModelContainer` kullanılıyor. | `XPendo/Data/XPendoModelContainer.swift` |
| Preloaded sample expenses | Partially implemented | Demo data manuel olarak settings üzerinden yüklenebiliyor; her launch otomatik sample expense ekleme yok. | `XPendo/Data/DemoDataSeeder.swift`, `XPendo/Features/Settings/ViewModels/SettingsViewModel.swift` |
| Onboarding screen | Implemented | İlk açılışta `hasSeenOnboarding` false ise onboarding gösteriliyor. | `XPendo/AppRootView.swift`, `XPendo/Features/Onboarding/OnboardingView.swift` |
| Ability to reopen onboarding from settings | Implemented | Settings içinde onboarding tekrar açılıyor. | `XPendo/Features/Settings/SettingsView.swift` |
| Notifications | Implemented | Günlük 20:00 hatırlatma ve 18:00 bütçe uyarısı schedule ediliyor. | `XPendo/Notifications/LocalNotificationManager.swift` |
| OCR / receipt scanning | Implemented | Kamera/galeri ile görsel alınabiliyor, Vision OCR ve parser öneri üretiyor. | `ReceiptScannerView.swift`, `ReceiptOCRService.swift`, `ReceiptParserService.swift` |
| Login / signup | Not implemented | Auth ekranı, user modeli veya backend auth entegrasyonu bulunmadı. | Not found in the current project |
| Cloud sync / iCloud / CloudKit | Partially implemented | UI bilgilendirme ve SwiftData CloudKit hazırlık metodu var; gerçek CloudKit database `.none`. | `XPendo/Features/Settings/SettingsView.swift`, `XPendo/Data/XPendoModelContainer.swift` |
| Multi-user support | Not implemented | Kullanıcı hesabı, role, shared database veya multi-user veri modeli bulunmadı. | Not found in the current project |

## 5. Data Models

### Expense

* Purpose: Kullanıcının tekil harcama kaydını temsil eder.
* Properties/fields: `id: UUID`, `title: String`, `amount: Double`, `date: Date`, `category: Category?`, `note: String?`, `createdAt: Date`.
* Relationships: `category` alanı ile `Category` modeline optional ilişki.
* Persistence method: SwiftData `@Model`.
* Related file: `XPendo/Models/Expense.swift`.

### Category

* Purpose: Harcamaları ve bütçeleri sınıflandırmak için kategori.
* Properties/fields: `id: UUID`, `name: String`, `icon: String`, `color: String`, `isDefault: Bool`.
* Relationships: `Expense` ve `Budget` modelleri kategoriye referans verir.
* Persistence method: SwiftData `@Model`.
* Related file: `XPendo/Models/Category.swift`.

### Budget

* Purpose: Belirli ay/yıl için kategori bazlı bütçe limiti.
* Properties/fields: `id: UUID`, `category: Category?`, `limitAmount: Double`, `month: Int`, `year: Int`.
* Relationships: `category` alanı ile `Category` modeline optional ilişki.
* Persistence method: SwiftData `@Model`.
* Related file: `XPendo/Models/Budget.swift`.

### AppSettings

* Purpose: Uygulama tercihlerini saklar.
* Properties/fields: `id: UUID`, `currencyCode: String`, `preferredThemeCode: String?`, `preferredLanguageCode: String?`, `notificationsEnabled: Bool`, `dailyReminderEnabled: Bool`, `budgetWarningEnabled: Bool`.
* Relationships: Yok.
* Persistence method: SwiftData `@Model`.
* Related file: `XPendo/Models/AppSettings.swift`.

### Currency model / enum

* Purpose: Desteklenen para birimlerini ve local conversion rate değerlerini tutar.
* Values: `TRY`, `USD`, `EUR`.
* Rates: TRY = `1.00`, USD = `45.02`, EUR = `52.76`.
* Persistence method: Seçili currency code `AppSettings.currencyCode` içinde SwiftData ile saklanır.
* Related file: `XPendo/Shared/CurrencyConverter.swift`.

### Sample/default data logic

* Default categories: `Food`, `Transport`, `Shopping`, `Bills`, `Entertainment`, `Health`, `Education`, `Other`; sadece eksikse seed edilir.
* Default settings: App settings yoksa oluşturulur; duplicate settings silinir.
* Demo data: Manuel olarak yüklenen demo expense ve budget kayıtları oluşturur.
* Related files: `XPendo/Data/DefaultCategoryProvider.swift`, `XPendo/Data/AppDataSeeder.swift`, `XPendo/Data/DemoDataSeeder.swift`.

## 6. Data Storage and Persistence

* Primary storage: SwiftData persistent `ModelContainer`.
* Stored models: `Expense`, `Category`, `Budget`, `AppSettings`. Kanıt: `XPendo/Data/XPendoModelContainer.swift`.
* App data survives app restart: Implemented. `makePersistentContainer` içinde `isStoredInMemoryOnly: false` ile persistent container oluşturuluyor.
* UserDefaults usage: Demo mode için `xpendo.demoModeEnabled`, onboarding için `hasSeenOnboarding`, preferred language için `xpendo.preferredLanguageCode` kullanılıyor. Kanıt: `AppModeStore.swift`, `AppRootView.swift`, `AppLanguage.swift`.
* CoreData usage: Not found in the current project.
* JSON storage: Not found in the current project.
* Sample/default data insertion: Default categories ve settings `AppDataSeeder.seedIfNeeded` ile eksikse ekleniyor. Her launch duplicate şekilde tekrar ekleme hedeflenmemiştir. Demo sample expense/budget ise manuel yükleme ile eklenir ve mevcut expense/budget varsa yükleme hata verir.
* Risks/issues:
  * `XPendoModelContainer` persistent container oluşturamazsa in-memory store'a düşüyor; bu durumda app açılır ancak veriler kalıcı olmaz. Kanıt: `XPendo/Data/XPendoModelContainer.swift`.
  * CloudKit config fonksiyonu mevcut olsa da `.none` döndürdüğü için iCloud sync kalıcılığı yoktur. Kanıt: `XPendo/Data/XPendoModelContainer.swift`.
  * Para birimi dönüşümü local sabit kurla yapılır; gerçek zamanlı exchange rate yoktur. Kanıt: `XPendo/Shared/CurrencyConverter.swift`.

## 7. UI/UX Design

* Main screens: Home, Expenses, Budget, Analytics, Settings, Add Expense, Onboarding.
* Tab structure: `AppRootView.swift` içinde `TabView` ile Home, Expenses, Budget ve Analytics sekmeleri tanımlıdır.
* Sheet usage: Add Expense sheet, edit expense sheet, delete confirmation sheet, receipt scanner sheet, reset budget sheet, settings reset/demo sheets kullanılıyor. Kanıt: `AddExpenseView.swift`, `ExpensesView.swift`, `BudgetView.swift`, `SettingsView.swift`.
* Navigation structure: Her ana tab `NavigationStack` ile sarılmıştır; Settings ekranı Home içinden `NavigationLink` ile açılır.
* Color palette: `XPendoTheme` içinde accent teal, coral, text renkleri, background, surface, placeholder, tab bar ve adaptive dark/light renkleri tanımlıdır. Kanıt: `XPendo/Shared/XPendoTheme.swift`.
* Dark mode/light mode support: Implemented. `PreferredTheme` ve `preferredColorScheme` kullanılıyor. Kanıt: `XPendo/AppRootView.swift`, `XPendo/Shared/XPendoTheme.swift`.
* Custom components: `SurfaceCard`, `FloatingAddButton`, `ExpenseRowCard`, `BudgetStatusCard`, `StateMessageContent`, `PlaceholderCard`.
* App icon/assets: App icon asset set içinde normal ve dark 1024 px PNG dosyaları vardır. Kanıt: `XPendo/Assets.xcassets/AppIcon.appiconset/Contents.json`.
* Modern iOS/fintech style: Kart tabanlı yüzeyler, SF Symbols icon kullanımı, adaptive renkler, grafikler, bütçe progress bar ve floating add button ile modern iOS/fintech görünümüne uygundur. Kanıt: `XPendo/Shared/XPendoTheme.swift`, `XPendo/Shared/SurfaceCard.swift`, `XPendo/Features/Budget/Components/BudgetStatusCard.swift`, `XPendo/Features/Analytics/AnalyticsView.swift`.

## 8. Localization and Currency

### Localization

* Turkish/English localization: Implemented.
* Localization files: `XPendo/en.lproj/Localizable.strings` ve `XPendo/tr.lproj/Localizable.strings`.
* Localizable.strings or string catalogs: `Localizable.strings` kullanılmıştır; string catalog bulunmadı.
* In-app language switching: Implemented. Settings ekranında language menu var; `AppLocalization.updateLanguage` UserDefaults ve locale değerini güncelliyor. Kanıt: `XPendo/Shared/AppLanguage.swift`, `XPendo/Features/Settings/SettingsView.swift`.
* Raw language keys issue: Partially implemented. Birçok string key lokalize edilmiştir; ancak bazı yerlerde İngilizce raw string veya key kullanımı görülebilir. Örnek: `XPendo/Features/Budget/BudgetView.swift` içinde `"Budget"`, `"Categories"`, `"Monthly budget tracking"` gibi stringler; `XPendo/Features/Settings/SettingsView.swift` içinde `"iCloud Sync"`, `"CloudKit Ready"`, `"Apply"` gibi raw stringler. Bunların bir kısmı `Localizable.strings` içinde exact-key yöntemiyle çevrilmiş olsa da key-based localization ile karışık kullanım vardır.

### Currency

* Currency selection: Implemented. Settings ekranında currency menu vardır.
* Currency conversion: Implemented as local fixed conversion. Tutarlar TRY base currency olarak saklanır; seçili currency ile gösterilir.
* Local exchange rates:
  * TRY: `1.00`
  * USD: `45.02`
  * EUR: `52.76`
* Real-time exchange rates: Not found in the current project.
* Related files: `XPendo/Shared/CurrencyConverter.swift`, `XPendo/Features/Settings/ViewModels/SettingsViewModel.swift`, `XPendo/Models/AppSettings.swift`.

## 9. Notifications, OCR, Cloud, Login

### Notifications

* Status: Implemented
* Evidence from files: `XPendo/Notifications/LocalNotificationManager.swift`, `XPendo/Notifications/NotificationSyncService.swift`, `XPendo/Features/Settings/ViewModels/NotificationSettingsViewModel.swift`, `XPendo/Models/AppSettings.swift`.
* Explanation: App notification permission ister, günlük harcama hatırlatması için 20:00 tekrarlı local notification planlar ve mevcut ayda bütçe aşımı varsa 18:00 bütçe uyarısı planlar.

### OCR / Receipt Scanning

* Status: Implemented
* Evidence from files: `XPendo/Features/AddExpense/ReceiptScannerView.swift`, `XPendo/Features/AddExpense/ReceiptOCRService.swift`, `XPendo/Features/AddExpense/ReceiptParserService.swift`, `XPendo/Features/AddExpense/ReceiptScanResult.swift`.
* Explanation: Kullanıcı kamera veya galeri ile fiş görseli seçebilir. Vision OCR metni okur, parser title/amount/date/category/note önerisi üretir. Son kayıt kullanıcı onayıyla yapılır.

### CloudKit / iCloud Sync

* Status: Partially implemented
* Evidence from files: `XPendo/Features/Settings/SettingsView.swift`, `XPendo/Data/XPendoModelContainer.swift`.
* Explanation: Settings ekranında iCloud/CloudKit için bilgi bölümü vardır ve SwiftData config içinde CloudKit database fonksiyonu bulunur. Ancak fonksiyon `.none` döndürür; gerçek CloudKit container/sync aktif değildir.

### Login / Signup

* Status: Not implemented
* Evidence from files: Not found in the current project
* Explanation: Auth screen, user account model, signup/login formu veya Firebase/Supabase/custom backend entegrasyonu bulunmadı.

### Multi-user Support

* Status: Not implemented
* Evidence from files: Not found in the current project
* Explanation: Kullanıcı kimliği, multi-user relationship, paylaşım, role veya ortak veri yapısı bulunmadı. Uygulama tek cihaz/tek kullanıcı yerel kişisel finans kullanımına odaklanmıştır.

## 10. Testable User Scenarios

| Test Case | Steps | Expected Result | Current Status |
|---|---|---|---|
| Add a new expense | Floating add button'a dokun, title/amount/category/date gir, save et. | Harcama kaydedilir; Home, Expenses ve Analytics ekranlarında görünür. | Implemented |
| Delete an expense | Expenses ekranında expense menu > Delete, confirmation sheet'te Delete. | Harcama SwiftData'dan silinir ve listeden kaybolur. | Implemented |
| Restart app and check persistence | Harcama ekle, app'i kapat/aç. | Persistent SwiftData store çalışıyorsa kayıt korunur. | Implemented |
| Change theme | Settings > Preferred Theme seç, Apply. | AppRootView `preferredColorScheme` ile görünüm değişir. | Implemented |
| Change language | Settings > Language seç, Apply. | Locale güncellenir ve desteklenen lokalize metinler değişir. | Implemented |
| Change currency | Settings > Currency seç, Apply. | Tutarlar seçili currency formatında gösterilir. | Implemented |
| Set/update/reset budget | Budget ekranında kategori tutarı gir, Save/Update; Reset ile sil. | İlgili ay/kategori bütçesi oluşturulur, güncellenir veya silinir. | Implemented |
| View analytics | Birkaç expense ekle, Analytics tab'ına git. | Quick insights, category bar chart ve monthly trend chart görünür. | Implemented |
| Open onboarding again from settings | Settings > Show Onboarding Again. | Onboarding full screen tekrar açılır. | Implemented |
| Test notification behavior | Settings'te notifications aç, daily reminder/budget warning aktif et. | İzin verilirse local notification request'leri planlanır; gerçek notification delivery testi henüz tamamlanmadı. | Partially implemented |
| Test OCR behavior | Gerçek iPhone 13 üzerinde camera ile receipt scanning akışını dene. | OCR sonucundan expense formuna öneriler uygulanır; kullanıcı değerleri kaydetmeden önce kontrol etmelidir. | Implemented |
| Test CloudKit sync | Aynı Apple ID ile farklı cihazda data sync bekle. | Gerçek sync aktif olmadığı için beklenen sonuç alınmaz. | Partially implemented |
| Login/signup | Login veya signup ekranı arama. | Böyle bir akış yoktur. | Not implemented |

## 11. Known Issues or Risks

* CloudKit/iCloud sync gerçek olarak etkin değildir; Settings'te bilgi olarak vardır. Kanıt: `XPendo/Data/XPendoModelContainer.swift` içinde CloudKit `.none`.
* Persistent SwiftData container oluşturulamazsa in-memory fallback kullanılır; bu durumda app çalışır ancak data restart sonrası kalıcı olmaz. Kanıt: `XPendo/Data/XPendoModelContainer.swift`.
* Localization yaklaşımı karışık olabilir: bazı metinler key-based, bazıları raw English string olarak yazılmıştır. Kanıt: `XPendo/Features/Budget/BudgetView.swift`, `XPendo/Features/Settings/SettingsView.swift`.
* Currency conversion sabit local rate ile yapılır; gerçek zamanlı kur bilgisi yoktur. Kanıt: `XPendo/Shared/CurrencyConverter.swift`.
* OCR sonucu öneri niteliğindedir ve hatalı parse edilebilir; kullanıcı kaydetmeden önce kontrol etmelidir. Kanıt: `ReceiptParserService.swift`, `AddExpenseViewModel.applyReceiptScanResult`.
* OCR gerçek cihaz kamerası ile test edilmiştir ve çalışmaktadır; ancak mükemmel değildir, bazı durumlarda yanlış değer önerebilir. Final raporda tam otomatik veya tamamen güvenilir fiş okuma sistemi olarak anlatılmamalıdır.
* Notification implementation vardır; ancak gerçek cihazda notification delivery sonucu henüz doğrulanmamıştır. Final raporda "implemented but not fully validated on a real device" şeklinde dikkatli ifade edilmelidir.
* Unit test coverage artık temel business logic alanları için eklenmiştir; ancak UI testleri halen template-level düzeydedir ve tüm uygulama akışlarını kapsamaz. Kanıt: `XPendoTests/CurrencyConverterTests.swift`, `XPendoTests/DefaultCategoryProviderTests.swift`, `XPendoTests/ReceiptParserServiceTests.swift`, `XPendoTests/ModelInitializationTests.swift`, `XPendoUITests/XPendoUITests.swift`.

## 12. Limitations

* Real bank integration: Not implemented.
* Real-time exchange rates: Not implemented.
* Cloud synchronization: Partially implemented; gerçek iCloud/CloudKit sync aktif değil.
* User accounts: Not implemented.
* Login/signup: Not implemented.
* Multi-user collaboration/support: Not implemented.
* Advanced AI analytics: Not implemented.
* Donut chart: Not found in the current project.
* Receipt OCR: Implemented; ancak otomatik kesin kayıt değil, öneri tabanlıdır.
* CoreData stack: Not found in the current project.
* Third-party analytics/backend services: Not found in the current project.

## 13. Future Work Suggestions

* CloudKit/iCloud sync'i gerçek container ve capability ile etkinleştirmek.
* Currency conversion için güncel exchange rate API veya manuel güncelleme ekranı eklemek.
* Test coverage artırmak: ViewModel unit testleri, persistence testleri, UI flow testleri.
* Analytics tarafına donut chart, date range filter ve kategori trendleri eklemek.
* OCR parser doğruluğunu artırmak ve farklı fiş formatları için test seti oluşturmak.
* Localization kullanımını standartlaştırmak; raw string ve key-based yaklaşımı temizlemek.
* Budget notification ayarlarını daha ayrıntılı hale getirmek.
* Export özelliği eklemek: CSV/PDF expense report.
* Accessibility iyileştirmeleri yapmak: VoiceOver label, Dynamic Type ve contrast kontrolleri.

## 14. Report-Writing Summary

Xpendo, SwiftUI ile geliştirilen, SwiftData kullanarak harcama, kategori, bütçe ve uygulama ayarlarını yerel olarak saklayan bir iOS kişisel finans uygulamasıdır. Uygulama kullanıcıların harcama eklemesine, düzenlemesine, silmesine, harcamaları kategori ve zamana göre filtrelemesine, kategori bazlı aylık bütçe belirlemesine, harcama verilerini Swift Charts ile analiz etmesine, Türkçe/İngilizce dil seçmesine, açık/koyu/sistem tema kullanmasına ve TRY/USD/EUR para birimleri arasında sabit kurla görüntüleme yapmasına olanak sağlar. Mimari olarak SwiftUI + MVVM + SwiftData yapısı kullanılmıştır; `AppRootView` ana `TabView` navigasyonunu yönetir ve ekranlar ViewModel katmanlarıyla desteklenir. Persistence SwiftData persistent `ModelContainer` ile sağlanır; default kategoriler ve settings eksikse seed edilir, demo data ise settings üzerinden manuel yüklenebilir. UI/UX modern iOS/fintech stiline uygun kartlar, adaptive renk paleti, SF Symbols, floating add button ve grafiklerle tasarlanmıştır. Test tarafında XCTest/XCUIAutomation target'ları vardır fakat mevcut testler template düzeyindedir. Sınırlamalar arasında gerçek CloudKit sync'in aktif olmaması, login/signup ve multi-user desteğinin bulunmaması, gerçek zamanlı exchange rate olmaması ve gelişmiş AI analytics bulunmaması yer alır. Gelecekte CloudKit senkronizasyonu, daha güçlü test coverage, gerçek exchange rate, gelişmiş analytics, export ve accessibility iyileştirmeleri önerilir.

## 14.1 Unit Test Suite Added for Graduation Report

| Test file | Purpose | Status |
|---|---|---|
| `XPendoTests/CurrencyConverterTests.swift` | TRY base currency, supported currency codes, fixed local TRY/USD/EUR rates, TRY conversion and display conversion logic. | Added |
| `XPendoTests/DefaultCategoryProviderTests.swift` | Default category list, required category names, unique category names and `Other` fallback category. | Added |
| `XPendoTests/ReceiptParserServiceTests.swift` | Receipt parser behavior with sample OCR text, suggested amount/date/category, empty input handling and suggestion-only parser output. | Added |
| `XPendoTests/ModelInitializationTests.swift` | Basic initialization of `Category`, `Expense`, `Budget` and `AppSettings`. | Added |

Validation note: Xcode test discovery found the new unit tests in the `XPendoTests` target and Xcode live diagnostics reported no issues in the new test files. Full automated test execution could not be completed in the current environment because the local CoreSimulator service/runtime was unavailable and the Mac destination was blocked by provisioning. This should be written in the final report as a small unit test suite added for core logic, supported mainly by manual functional testing.

## 15. Confirmed Final Report Information

| Item | Confirmed value |
|---|---|
| Final report title | `XPENDO: AN IOS-BASED PERSONAL EXPENSE TRACKING APPLICATION` |
| App name | `Xpendo` |
| Student name | `Taha Yasin Demirci` |
| Student number | `20212905022` |
| Advisor name/title | `Öğr. Üyesi Berc Deruni` |
| Jury members | Not determined yet |
| Report language | English |
| Writing style | Simple, clear, student-friendly academic English. Avoid overly complex language. |

## 16. Test Environment Information

| Item | Confirmed value |
|---|---|
| Real device | iPhone 13 |
| Real device iOS version | iOS 26.4 |
| Simulator testing | Tested on Xcode Simulator |
| Simulator devices | iPhone 16, iPhone 17, iPhone 17 Pro |
| Xcode version | 26.5 |
| Minimum iOS Deployment Target | Exists in Xcode project settings, but it is not necessary to include it in the final report unless specifically required. |
| Final report testing wording | The report should mention that the app was tested on simulator and real iPhone 13, but should avoid unnecessary internal Xcode setting details. |

## 17. Feature Testing Status Notes

* Notifications: Implementation exists in the project. Real notification delivery has not been tested yet. In the final report, this should be written carefully as implemented but not fully validated on a real device.
* OCR / Receipt scanning: OCR was tested on a real device using the camera. It works, but it is not perfect and sometimes makes mistakes. It should be described as an OCR-based receipt suggestion feature, not a fully automatic or fully reliable receipt reading system. The user must review the suggested values before saving the expense.
* Screenshots: Screenshots are not ready yet. They will be collected later.
* Automated tests: A small unit test suite now exists for currency conversion, default categories, receipt parsing and model initialization. Xcode discovered the new tests and live diagnostics reported no issues. Full test execution was blocked in the current environment by CoreSimulator/provisioning limitations, so the report should still mainly rely on manual functional testing results and describe the automated tests as limited but useful core-logic coverage.

## 18. Important Report-Writing Decisions

* Do not describe CloudKit/iCloud sync as an active implemented feature.
* CloudKit/iCloud sync should be written as a limitation or future work.
* Do not describe login/signup or multi-user support as implemented.
* Login/signup and multi-user support are out of scope.
* Do not describe real-time exchange rates as implemented.
* Currency conversion/display uses local fixed rates only.
* Do not overclaim OCR accuracy.
* Do not overclaim notification testing.
* Keep the final report honest, simple, and suitable for a graduation project.

## 19. Suggested Screenshot Checklist

* [ ] Home / Dashboard screen
* [ ] Add Expense sheet
* [ ] Expenses list screen
* [ ] Edit Expense flow if possible
* [ ] Budget screen
* [ ] Analytics screen
* [ ] Settings screen
* [ ] Theme selection or dark mode screen
* [ ] Language/currency settings if useful
* [ ] OCR / receipt scanning screen if possible
* [ ] Onboarding screen if useful

## 20. Suggested Diagram Checklist

* [ ] Use Case Diagram
* [ ] MVVM Architecture Diagram
* [ ] Data Model / Class Diagram
* [ ] Add Expense Flow Diagram or Sequence Diagram, optional

## 21. Remaining Missing Information

* Jury member names
* Approval date
* Final submission date
* Screenshots
* Final manual test notes
* Notification real-device delivery test result, if tested later
* Bibliography/reference sources
* Acknowledgements text
* Any final known bugs observed before submission
