# Як виправити тип Target з Library на tvOS App

## ❌ Проблема
Випадково створено Library target замість tvOS App target.

## ✅ Рішення 1: Видалити та створити знову (ПРОСТІШЕ)

### Кроки:

1. **Видалити поточний target:**
   - Відкрити Xcode
   - Project Navigator → Виберіть проект (синя іконка)
   - Знайти HDRezkaTv в списку Targets
   - Вибрати HDRezkaTv → натиснути "-" (внизу)
   - Confirm Delete

2. **Створити новий tvOS App target:**
   - Натиснути "+" (внизу targets)
   - Виберіть **tvOS → App** (не Framework/Library!)
   - Product Name: **HDrezkaTV** (або HDRezkaTv)
   - Bundle ID: **com.hdrezka.tv**
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Finish

3. **Додати файли до нового target:**
   - Всі файли з `HDrezkaTV/` - Target Membership
   - Shared файли з Domain/Data - Target Membership
   - Все як в QUICK_START_TVOS.md

---

## ✅ Рішення 2: Змінити тип існуючого target (СКЛАДНІШЕ)

⚠️ **НЕ РЕКОМЕНДУЮ** - легше пересоздать

Але якщо хочете:

### Build Settings:

1. Виберіть HDRezkaTv target
2. Build Settings → All
3. Знайти та змінити:

```
Product Type: Application
Product Bundle Identifier: com.hdrezka.tv
Mach-O Type: mh_execute (не mh_dylib)
Wrapper Extension: app (не framework)
```

4. Info.plist:
   - Перевірте що використовується правильний Info.plist
   - `HDrezkaTV/Resources/Info.plist`

5. General Tab:
   - Deployment Info → tvOS
   - App Icon → Встановити

---

## 🎯 Що має бути після виправлення:

### Target Type:
```
Type: Application
Platform: tvOS
Product: HDrezkaTV.app
```

### Build Settings (важливі):
```
Product Name: HDrezkaTV
Product Bundle Identifier: com.hdrezka.tv
Product Type: com.apple.product-type.application
Wrapper Extension: app
Mach-O Type: mh_execute
```

---

## ✅ Перевірка

Після виправлення:

1. Clean Build Folder (Cmd + Shift + K)
2. Build (Cmd + B)
3. Має компілюватись як **Application**
4. Можна запустити на simulator (Cmd + R)

---

## 📝 Як перевірити тип target:

```
1. Виберіть target HDRezkaTv
2. General tab
3. Дивіться на "Supported Destinations"
   → Має бути: tvOS Device, tvOS Simulator
4. Build Settings → Product Type
   → Має бути: com.apple.product-type.application
```

---

## 🚀 Після виправлення:

```bash
# Має працювати:
xcodebuild -scheme HDRezkaTv -sdk appletvsimulator build

# Результат:
** BUILD SUCCEEDED **
```

І ви зможете запустити на simulator/device! 📺

