# Assets Directory

Cấu trúc thư mục assets cho FA Ops app.

## Cấu trúc

```
assets/
├── images/     # PNG, JPG, WebP images
├── icons/       # Icon files (PNG, ICO)
└── svg/        # SVG vector graphics
```

## Sử dụng

### SVG
Sử dụng package `flutter_svg` để hiển thị SVG:

```dart
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture.asset(
  'assets/svg/logo.svg',
  width: 100,
  height: 100,
)
```

### Images
Sử dụng `Image.asset()` hoặc `AssetImage()`:

```dart
Image.asset('assets/images/background.png')
```

### Icons
Tương tự như images:

```dart
Image.asset('assets/icons/app_icon.png')
```





