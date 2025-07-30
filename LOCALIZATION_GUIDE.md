# Hướng dẫn Localization cho TremoSave

## Tổng quan

Ứng dụng TremoSave đã được thiết lập để hỗ trợ đa ngôn ngữ với các tính năng sau:

- **Tiếng Việt** (mặc định)
- **Tiếng Anh**

## Cấu trúc thư mục

```
l10n/
├── app_en.arb          # File localization tiếng Anh
└── app_vi.arb          # File localization tiếng Việt

lib/l10n/               # Generated files (tự động tạo)
├── app_localizations.dart
├── app_localizations_en.dart
└── app_localizations_vi.dart
```

## Cách thêm ngôn ngữ mới

### 1. Tạo file ARB mới

Tạo file `l10n/app_[locale].arb` với locale code (ví dụ: `fr` cho tiếng Pháp):

```json
{
  "@@locale": "fr",
  "appTitle": "Tremo Save",
  "@appTitle": {
    "description": "The title of the application"
  }
  // ... thêm các string khác
}
```

### 2. Cập nhật main.dart

Thêm locale mới vào `supportedLocales`:

```dart
supportedLocales: const [
  Locale('en'), // English
  Locale('vi'), // Vietnamese
  Locale('fr'), // French (mới)
],
```

### 3. Cập nhật LanguageService

Thêm method cho ngôn ngữ mới:

```dart
Future<void> setFrench() async {
  await setLanguage('fr');
}

bool get isFrench => _currentLocale.languageCode == 'fr';
```

### 4. Cập nhật LanguageSelector

Thêm option cho ngôn ngữ mới:

```dart
PopupMenuItem<String>(
  value: 'fr',
  child: Row(
    children: [
      Text('🇫🇷', style: TextStyle(fontSize: 20)),
      const SizedBox(width: 8),
      Text('Français'),
      if (languageService.isFrench)
        const Icon(Icons.check, size: 16, color: Colors.green),
    ],
  ),
),
```

### 5. Generate localization files

```bash
flutter gen-l10n --arb-dir=l10n --output-dir=lib/l10n
```

## Cách sử dụng trong code

### 1. Import localization

```dart
import 'package:tremo_save/l10n/app_localizations.dart';
```

### 2. Sử dụng trong widget

```dart
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  
  return Text(l10n.appTitle);
}
```

### 3. Sử dụng với parameters

```dart
Text(l10n.minutes(state.interval))
```

## Best Practices

### 1. Tổ chức strings

- Nhóm các string theo chức năng
- Sử dụng prefix để phân loại (ví dụ: `welcome_`, `settings_`)
- Thêm description cho mỗi string

### 2. Placeholders

Sử dụng placeholders cho dynamic content:

```json
{
  "totalSaves": "Tổng cộng {count} lần lưu",
  "@totalSaves": {
    "description": "Total saves count",
    "placeholders": {
      "count": {
        "type": "int",
        "example": "10"
      }
    }
  }
}
```

### 3. Pluralization

Flutter hỗ trợ pluralization tự động:

```json
{
  "saveCount": "{count, plural, =0{No saves} =1{1 save} other{{count} saves}}"
}
```

### 4. Date và Number formatting

Sử dụng `intl` package cho formatting:

```dart
import 'package:intl/intl.dart';

final formatter = DateFormat.yMMMd(l10n.localeName);
final formattedDate = formatter.format(DateTime.now());
```

## Testing

### 1. Test với ngôn ngữ khác nhau

```dart
testWidgets('should display correct language', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('vi'),
      home: const MyWidget(),
    ),
  );
  
  expect(find.text('Tremo Save'), findsOneWidget);
});
```

### 2. Test language switching

```dart
testWidgets('should switch language', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  
  // Tap language selector
  await tester.tap(find.byIcon(Icons.language));
  await tester.pumpAndSettle();
  
  // Select English
  await tester.tap(find.text('English'));
  await tester.pumpAndSettle();
  
  expect(find.text('Tremo Save'), findsOneWidget);
});
```

## Troubleshooting

### 1. Lỗi "Target of URI doesn't exist"

Chạy lại lệnh generate:

```bash
flutter clean
flutter pub get
flutter gen-l10n --arb-dir=l10n --output-dir=lib/l10n
```

### 2. Lỗi "AppLocalizations.of(context) returns null"

Đảm bảo đã thêm `localizationsDelegates` và `supportedLocales` trong MaterialApp.

### 3. Lỗi "Missing translation"

Kiểm tra file ARB có đầy đủ các string không.

## Cập nhật strings

Khi cần thêm/sửa strings:

1. Cập nhật tất cả file ARB
2. Chạy `flutter gen-l10n`
3. Cập nhật code sử dụng string mới
4. Test với tất cả ngôn ngữ

## Lưu ý quan trọng

- **Luôn cập nhật tất cả file ARB** khi thêm string mới
- **Test với tất cả ngôn ngữ** trước khi release
- **Sử dụng placeholders** thay vì concatenation
- **Thêm description** cho mỗi string để dễ maintain 