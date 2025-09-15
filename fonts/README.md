# Plus Jakarta Sans Font Files

This directory contains Plus Jakarta Sans font files for the InsiBook mobile app.

## Required Files:
- PlusJakartaSans-Regular.ttf (400)
- PlusJakartaSans-Medium.ttf (500)
- PlusJakartaSans-SemiBold.ttf (600)
- PlusJakartaSans-Bold.ttf (700)
- PlusJakartaSans-Italic.ttf (400 italic)
- PlusJakartaSans-MediumItalic.ttf (500 italic)
- PlusJakartaSans-SemiBoldItalic.ttf (600 italic)
- PlusJakartaSans-BoldItalic.ttf (700 italic)

## Download Instructions:

### Option 1: Download from Google Fonts
1. Visit: https://fonts.google.com/specimen/Plus+Jakarta+Sans
2. Click "Download family"
3. Extract the ZIP file
4. Copy the required font files to this directory

### Option 2: Download from GitHub
```bash
cd fonts
curl -o PlusJakartaSans-Regular.ttf https://github.com/google/fonts/raw/main/ofl/plusjakartasans/PlusJakartaSans-Regular.ttf
curl -o PlusJakartaSans-Medium.ttf https://github.com/google/fonts/raw/main/ofl/plusjakartasans/PlusJakartaSans-Medium.ttf
curl -o PlusJakartaSans-SemiBold.ttf https://github.com/google/fonts/raw/main/ofl/plusjakartasans/PlusJakartaSans-SemiBold.ttf
curl -o PlusJakartaSans-Bold.ttf https://github.com/google/fonts/raw/main/ofl/plusjakartasans/PlusJakartaSans-Bold.ttf
curl -o PlusJakartaSans-Italic.ttf https://github.com/google/fonts/raw/main/ofl/plusjakartasans/PlusJakartaSans-Italic.ttf
curl -o PlusJakartaSans-MediumItalic.ttf https://github.com/google/fonts/raw/main/ofl/plusjakartasans/PlusJakartaSans-MediumItalic.ttf
curl -o PlusJakartaSans-SemiBoldItalic.ttf https://github.com/google/fonts/raw/main/ofl/plusjakartasans/PlusJakartaSans-SemiBoldItalic.ttf
curl -o PlusJakartaSans-BoldItalic.ttf https://github.com/google/fonts/raw/main/ofl/plusjakartasans/PlusJakartaSans-BoldItalic.ttf
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
  style: GoogleFonts.plusJakartaSans(),
)
```

## Note:
The font files need to be manually added to this directory for the app to build correctly with the current configuration.

## Why Plus Jakarta Sans?
Plus Jakarta Sans is an excellent choice for the InsiBook app with:
- Modern, clean design perfect for a book summary app
- Good support for Vietnamese characters and diacritical marks
- Excellent readability at various sizes
- Versatile weights for different UI elements
- Professional appearance that pairs well with the brand color (#D45555)
- Optimized for digital interfaces