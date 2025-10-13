# ✅ Виправлення помилок компіляції tvOS

## Проблеми та рішення

### 1. ❌ IOKit APIs в Const.swift

**Помилка:**
```
Cannot find 'IOServiceGetMatchingService' in scope
Cannot find 'kIOMainPortDefault' in scope
Cannot find 'IOServiceMatching' in scope
```

**Причина:** IOKit доступний тільки на macOS

**Рішення:** ✅ Додано conditional compilation
```swift
#if os(macOS)
let service = IOServiceGetMatchingService(...)
// UUID logic
#endif
```

**Файл:** `HDrezka/Core/Const.swift`

---

### 2. ❌ Theme, DefaultQuality, SpatialAudio не знайдені

**Помилка:**
```
Cannot find type 'Theme' in scope
Cannot find type 'DefaultQuality' in scope
Cannot find type 'SpatialAudio' in scope
```

**Причина:** Ці енуми визначені в `SettingsView.swift` (macOS View), який не доданий до tvOS target

**Рішення:** ✅ Додано визначення в `TVExtensions.swift`
```swift
enum Theme: Int, CaseIterable, Identifiable, Defaults.Serializable {
    case system, light, dark
}

enum DefaultQuality: String, CaseIterable, Identifiable, Defaults.Serializable {
    case ask, q360 = "360p", q480 = "480p", ...
}

enum SpatialAudio: Int, CaseIterable, Identifiable, Defaults.Serializable {
    case off, on, auto
}
```

**Файл:** `HDrezkaTV/Presentation/Utils/TVExtensions.swift`

---

### 3. ❌ NSFont в Utils.swift

**Помилка:**
```
Cannot find type 'NSFont' in scope
```

**Причина:** `NSFont`, `NSColor`, `NSFontManager` - macOS APIs, на tvOS це UIFont/UIColor

**Рішення:** ✅ Обернуто macOS-specific код
```swift
#if os(macOS)
import AppKit

class AttributedTextStyle {
    // macOS implementation using NSFont, NSColor
}

extension NSMutableAttributedString {
    // macOS extension
}
#endif
```

**Файл:** `HDrezka/Data/Utils/Utils.swift`

---

### 4. ✅ Додаткові виправлення

**osName в Const.swift:**
```swift
#if os(macOS)
let osName = "macOS"
#elseif os(tvOS)
let osName = "tvOS"
#elseif os(iOS)
let osName = "iOS"
#endif
```

---

## 📊 Підсумок виправлень

| Файл | Проблема | Рішення | Статус |
|------|----------|---------|--------|
| `Const.swift` | IOKit APIs | Conditional compilation | ✅ |
| `Const.swift` | osName hardcoded | Platform detection | ✅ |
| `TVExtensions.swift` | Missing enums | Added definitions | ✅ |
| `Utils.swift` | NSFont/NSColor | Conditional compilation | ✅ |

---

## 🚀 Наступні кроки

### Тепер ви можете:

1. **Build tvOS target** (Cmd + B)
   - Має компілюватись без помилок ✅

2. **Run на simulator** (Cmd + R)
   - Apple TV simulator

3. **Тестувати на пристрої**
   - Підключити Apple TV через USB-C

---

## 🐛 Якщо все ще є помилки

### Перевірте:

1. **Target Membership**
   - Всі файли Domain/Data додані до HDrezkaTV? ✅
   - ViewModels додані? ✅
   - macOS Views НЕ додані? ❌

2. **Dependencies**
   - Alamofire ✅
   - Kingfisher ✅
   - Factory ✅
   - Defaults ✅
   - SwiftSoup ✅

3. **Build Settings**
   - Deployment Target: tvOS 17.0+ ✅
   - Swift Language Version: 5 ✅

---

## 📝 Типові помилки після цього

### "Cannot find 'Downloader' in scope"
**Рішення:** НЕ додавайте `HDrezka/Core/Downloader.swift` до target
- Використовується `TVDownloaderStub`

### "Cannot find 'NSWindow' in scope"
**Рішення:** Видаліть macOS View файли з target
- Перевірте що НЕ додані `*View.swift` з HDrezka/Presentation/

### "Duplicate symbol"
**Рішення:** Перевірте що не додані обидві версії
- Не можна мати і `AppState.swift` і `TVAppState.swift` в target

---

## ✅ Фінальна перевірка

```bash
# Build має пройти успішно
xcodebuild -scheme HDrezkaTV -sdk appletvos build

# Або в Xcode
Scheme: HDrezkaTV
Device: Apple TV Simulator
Cmd + B
```

**Результат:** BUILD SUCCEEDED ✅

---

**Всі виправлення зроблені!** 🎉

Тепер ваш tvOS застосунок має компілюватись без помилок.

