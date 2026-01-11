# Проблеми збірки tvOS

## Проблема з swift-atomics

**Статус:** ❌ Не вирішено

**Опис:**
- `swift-atomics` має проблему з компіляцією на tvOS: `Unable to find module dependency: '_Builtin_stdbool'`
- `swift-atomics` не використовується безпосередньо в RezkaTV - це транзитивна залежність через `SwiftSoup` → `LRUCache` → `Atomics`

**Вплив:**
- Через проблему з `swift-atomics` не збираються інші залежності (Alamofire, Defaults, FactoryKit, SwiftSoup, OrderedCollections, Kingfisher)

**Рішення:**
1. Оновити Xcode до останньої версії
2. Спробувати зібрати проект через Xcode GUI (Product → Build)
3. Очистити DerivedData через Xcode (Product → Clean Build Folder)
4. Оновити версії пакетів, якщо доступні новіші версії

**Примітка:**
Ця проблема не пов'язана з кодом RezkaTV, а з пакетом `swift-atomics` та його сумісністю з tvOS SDK.

