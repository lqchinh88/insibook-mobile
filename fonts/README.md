# Be Vietnam Pro Font Files

This directory contains Be Vietnam Pro font files for the InsiBook mobile app.

## Required Files:
- BeVietnamPro-Regular.ttf (400)
- BeVietnamPro-Medium.ttf (500)
- BeVietnamPro-SemiBold.ttf (600)
- BeVietnamPro-Bold.ttf (700)
- BeVietnamPro-Italic.ttf (400 italic)
- BeVietnamPro-MediumItalic.ttf (500 italic)
- BeVietnamPro-SemiBoldItalic.ttf (600 italic)
- BeVietnamPro-BoldItalic.ttf (700 italic)

## Download Instructions:

### Option 1: Download from Google Fonts
1. Visit: https://fonts.google.com/specimen/Be+Vietnam+Pro
2. Click "Download family"
3. Extract the ZIP file
4. Copy the required font files to this directory

### Option 2: Download from GitHub
```bash
cd fonts
curl -o BeVietnamPro-Regular.ttf https://github.com/google/fonts/raw/main/ofl/bevietnampro/BeVietnamPro-Regular.ttf
curl -o BeVietnamPro-Medium.ttf https://github.com/google/fonts/raw/main/ofl/bevietnampro/BeVietnamPro-Medium.ttf
curl -o BeVietnamPro-SemiBold.ttf https://github.com/google/fonts/raw/main/ofl/bevietnampro/BeVietnamPro-SemiBold.ttf
curl -o BeVietnamPro-Bold.ttf https://github.com/google/fonts/raw/main/ofl/bevietnampro/BeVietnamPro-Bold.ttf
curl -o BeVietnamPro-Italic.ttf https://github.com/google/fonts/raw/main/ofl/bevietnampro/BeVietnamPro-Italic.ttf
curl -o BeVietnamPro-MediumItalic.ttf https://github.com/google/fonts/raw/main/ofl/bevietnampro/BeVietnamPro-MediumItalic.ttf
curl -o BeVietnamPro-SemiBoldItalic.ttf https://github.com/google/fonts/raw/main/ofl/bevietnampro/BeVietnamPro-SemiBoldItalic.ttf
curl -o BeVietnamPro-BoldItalic.ttf https://github.com/google/fonts/raw/main/ofl/bevietnampro/BeVietnamPro-BoldItalic.ttf
```

### Option 3: Use pubspec.yaml dependency
Alternatively, you can add the google_fonts package to pubspec.yaml:

```yaml
dependencies:
  google_fonts: ^6.1.0
```

Then use it in your code:
```dart
import 'package:google_fonts/google_fonts.dart';

Text(
  'Xin chào thế giới',
  style: GoogleFonts.beVietnamPro(),
)
```

## Note:
The font files need to be manually added to this directory for the app to build correctly with the current configuration.

## Why Be Vietnam Pro?
Be Vietnam Pro is specifically designed for Vietnamese typography with:
- Complete Vietnamese character set support
- Excellent readability for Vietnamese text
- Modern, clean design that pairs well with the app's brand colors
- Proper diacritical mark rendering
- Optimized spacing for Vietnamese characters