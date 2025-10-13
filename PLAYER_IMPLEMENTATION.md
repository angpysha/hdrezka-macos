# 🎬 Реалізація плеєра для tvOS

## ✅ Що реалізовано

### 1. TVPlayerViewModel
**Файл:** `RezkaTV/Presentation/Player/TVPlayerViewController.swift`

**Функціонал:**
- ✅ Автоматичний вибір озвучки (перша доступна)
- ✅ Підтримка фільмів
- ✅ Підтримка серіалів (сезони + епізоди)
- ✅ Перевірка premium контенту
- ✅ Вибір якості відео (default quality з налаштувань)
- ✅ Створення AVPlayer з HLS потоком
- ✅ Підтримка субтитрів

### 2. TVPlayerViewController
**UIViewControllerRepresentable** для AVPlayerViewController

**Особливості:**
- ✅ Picture-in-Picture підтримка
- ✅ External playback (AirPlay)
- ✅ Native tvOS контроли
- ✅ Автоматичний dismiss callback

### 3. TVPlayerView
**SwiftUI View** з станами:

- ✅ Loading (ProgressView)
- ✅ Playing (AVPlayerViewController)
- ✅ Error (помилка + кнопка закрити)

---

## 🎮 Як це працює

### Процес відтворення:

```
1. Користувач натискає "Дивитись"
   ↓
2. TVDetailsView.playMovie()
   ↓
3. Відкривається fullScreenCover з TVPlayerView
   ↓
4. TVPlayerViewModel.loadVideo()
   ↓
5. Вибирається озвучка
   ↓
6. Для серіалів: завантаження сезонів
   ↓
7. GetMovieVideoUseCase отримує HLS потік
   ↓
8. Перевірка premium
   ↓
9. Створення AVPlayer з URL
   ↓
10. Автоматичний play()
```

---

## 📝 Використання в TVDetailsView

```swift
struct TVDetailsView: View {
    @State private var isPlayerPresented = false
    
    var body: some View {
        ScrollView {
            // ... контент ...
            
            Button {
                playMovie()  // ← Відкрити плеєр
            } label: {
                Text("Дивитись")
            }
        }
        .fullScreenCover(isPresented: $isPlayerPresented) {
            if let details = viewModel.state.data {
                TVPlayerView(details: details)  // ← Плеєр
            }
        }
    }
    
    private func playMovie() {
        isPlayerPresented = true
    }
}
```

---

## 🎯 Основні функції

### 1. Автоматичний вибір озвучки

```swift
guard let voiceActing = details.voiceActing?.first else {
    error = "No voice acting available"
    return
}
```

### 2. Підтримка серіалів

```swift
if details.series != nil {
    loadSeriesAndPlay(voiceActing: voiceActing)
} else {
    loadVideoStream(voiceActing: voiceActing, season: nil, episode: nil)
}
```

### 3. Вибір якості

```swift
let defaultQuality = Defaults[.defaultQuality]

if defaultQuality == .ask {
    videoURL = movieVideo.getMaxQuality()  // Найкраща
} else {
    videoURL = movieVideo.getClosestTo(quality: defaultQuality.rawValue)
}
```

### 4. Налаштування AVPlayer

```swift
let player = AVPlayer(url: videoURL)
player.allowsExternalPlayback = true  // AirPlay
player.usesExternalPlaybackWhileExternalScreenIsActive = true
```

---

## 🚀 Додаткові можливості

### TODO список покращень:

#### 1. Збереження позиції відтворення ⏱️

```swift
// При закритті плеєра
.onDisappear {
    player.pause()
    
    // Зберегти позицію
    let currentTime = player.currentTime().seconds
    savePosition(movieId: details.movieId, position: currentTime)
}

// При відкритті плеєра
Task {
    if let savedPosition = loadPosition(for: details.movieId) {
        let time = CMTime(seconds: savedPosition, preferredTimescale: 1)
        await player.seek(to: time)
    }
}
```

#### 2. Вибір озвучки 🎭

Додати menu для вибору озвучки перед відтворенням:

```swift
Menu("Вибрати озвучку") {
    ForEach(details.voiceActing ?? []) { acting in
        Button(acting.name) {
            selectedActing = acting
            loadVideo()
        }
    }
}
```

#### 3. Вибір якості 📺

Додати menu для вибору якості:

```swift
Menu("Якість") {
    ForEach(movieVideo.getAvailableQualities(), id: \.self) { quality in
        Button(quality) {
            selectedQuality = quality
            updateVideoQuality()
        }
    }
}
```

#### 4. Субтитри 📝

```swift
// AVPlayer автоматично підхопить субтитри з HLS
// Або додати вручну:
if !movieVideo.subtitles.isEmpty {
    for subtitle in movieVideo.subtitles {
        // Додати subtitle track
        let asset = AVURLAsset(url: subtitle.url)
        // ... налаштування
    }
}
```

#### 5. Picture-in-Picture 🖼️

```swift
// Вже підтримується!
controller.allowsPictureInPicturePlayback = true
```

#### 6. Прогрес перегляду 📊

```swift
// Відстежування прогресу
player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { time in
    let progress = time.seconds / player.currentItem?.duration.seconds ?? 1
    // Оновити прогрес
}
```

---

## 🎮 tvOS Контроли

### Native контроли AVPlayerViewController:

- **Click center** - Play/Pause
- **Swipe left/right** - Перемотка (10 сек)
- **Swipe up** - Інформація про відео
- **Swipe down** - Показати прогрес
- **Menu button** - Закрити плеєр

### Додаткові жести:

- **Довге натискання** - Швидка перемотка
- **Подвійне натискання** - Пропустити вперед/назад

---

## 🔧 Налаштування

### Defaults (користувацькі налаштування):

```swift
@Default(.defaultQuality) private var defaultQuality  // Якість
@Default(.rate) private var rate                      // Швидкість
@Default(.volume) private var volume                  // Гучність
@Default(.isMuted) private var isMuted               // Без звуку
@Default(.spatialAudio) private var spatialAudio     // Просторовий звук
```

---

## 📱 Інтеграція

### В TVDetailsView:

```swift
// 1. State для modal
@State private var isPlayerPresented = false

// 2. Кнопка відтворення
Button {
    playMovie()
} label: {
    HStack {
        Image(systemName: "play.fill")
        Text("Дивитись")
    }
}

// 3. fullScreenCover
.fullScreenCover(isPresented: $isPlayerPresented) {
    if let details = viewModel.state.data {
        TVPlayerView(details: details)
    }
}

// 4. Функція відкриття
private func playMovie() {
    isPlayerPresented = true
}
```

---

## 🎯 Приклад використання

```swift
// Просто відкрити плеєр з MovieDetailed
let details: MovieDetailed = ...
let playerView = TVPlayerView(details: details)

// Плеєр автоматично:
// 1. Завантажить відео потік
// 2. Вибере озвучку
// 3. Для серіалів завантажить сезони
// 4. Створить AVPlayer
// 5. Почне відтворення
```

---

## ⚠️ Обмеження та примітки

### tvOS обмеження:

1. **Файли не зберігаються** - тільки streaming
2. **Обмежена файлова система** - кеш HLS автоматичний
3. **Немає background playback** - тільки активний режим

### Переваги native AVPlayerViewController:

- ✅ Автоматичні контроли (Play/Pause/Scrubbing)
- ✅ Siri Remote integration
- ✅ Picture-in-Picture
- ✅ Субтитри з HLS
- ✅ AirPlay підтримка
- ✅ Адаптивний streaming (HLS)

---

## 🚀 Тестування

1. Запустити RezkaTV на simulator
2. Відкрити деталі фільму
3. Натиснути "Дивитись"
4. Плеєр має завантажитись та почати відтворення

### Контроли в simulator:

```
Space - Play/Pause
Arrow Left/Right - Перемотка
Escape - Закрити
```

---

## 📚 Документація Apple

- [AVPlayerViewController](https://developer.apple.com/documentation/avkit/avplayerviewcontroller)
- [AVPlayer](https://developer.apple.com/documentation/avfoundation/avplayer)
- [HLS Best Practices](https://developer.apple.com/documentation/http_live_streaming)
- [tvOS Player Guidelines](https://developer.apple.com/design/human-interface-guidelines/playing-video)

---

**Плеєр готовий до використання! 🎬**

