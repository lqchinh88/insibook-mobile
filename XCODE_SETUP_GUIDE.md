# Xcode Multi-Environment Setup Guide

This guide walks you through setting up iOS schemes for dev, staging, and production environments in Xcode.

## Prerequisites

- All configuration files have been created in `ios/Runner/Configs/`
- Info.plist has been updated to use `$(DISPLAY_NAME)`
- Build scripts are ready in `scripts/`

## Step-by-Step Xcode Setup

### 1. Open the Project

```bash
open ios/Runner.xcworkspace
```

**⚠️ Important**: Always open `.xcworkspace`, not `.xcodeproj`

### 2. Create Build Configurations

1. **Select the Runner Project**
   - Click on "Runner" at the very top of the left sidebar (blue icon)
   
2. **Go to the Info Tab**
   - In the main panel, click the "Info" tab (next to "General")
   
3. **Expand Configurations Section**
   - You should see "Debug" and "Release" configurations
   
4. **Duplicate Configurations**
   - Click the `+` button under Configurations
   - Select "Duplicate 'Debug' Configuration"
   - Rename to `Debug-Dev`
   - Repeat to create:
     - `Debug-Staging` 
     - `Debug-Production`
     - `Release-Dev` (duplicate Release)
     - `Release-Staging` (duplicate Release)
     - `Release-Production` (duplicate Release)

### 3. Assign Configuration Files

For each new configuration:

1. **Select Runner Target**
   - Under "Runner" project, select the "Runner" target
   
2. **Assign .xcconfig Files**
   - For each configuration, click the dropdown in the "Based on Configuration File" column
   - Select the corresponding file:
     - `Debug-Dev` → `Debug-Dev.xcconfig`
     - `Debug-Staging` → `Debug-Staging.xcconfig`
     - `Debug-Production` → `Debug-Production.xcconfig`
     - `Release-Dev` → `Release-Dev.xcconfig`
     - `Release-Staging` → `Release-Staging.xcconfig`
     - `Release-Production` → `Release-Production.xcconfig`

### 4. Create and Configure Schemes

#### Create New Schemes

1. **Go to Scheme Manager**
   - Top menu: **Product** → **Scheme** → **Manage Schemes**
   
2. **Duplicate the Runner Scheme**
   - Select "Runner" scheme
   - Click the gear icon → **Duplicate**
   - Rename to `Dev`
   - Repeat to create `Staging` and `Production` schemes

#### Configure Each Scheme

**For Dev Scheme:**
1. Select `Dev` scheme and click **Edit**
2. **Run** section:
   - Build Configuration: `Debug-Dev`
3. **Test** section:
   - Build Configuration: `Debug-Dev`
4. **Profile** section:
   - Build Configuration: `Release-Dev`
5. **Analyze** section:
   - Build Configuration: `Debug-Dev`
6. **Archive** section:
   - Build Configuration: `Release-Dev`

**For Staging Scheme:**
1. Select `Staging` scheme and click **Edit**
2. **Run** section:
   - Build Configuration: `Debug-Staging`
3. **Test** section:
   - Build Configuration: `Debug-Staging`
4. **Profile** section:
   - Build Configuration: `Release-Staging`
5. **Analyze** section:
   - Build Configuration: `Debug-Staging`
6. **Archive** section:
   - Build Configuration: `Release-Staging`

**For Production Scheme:**
1. Select `Production` scheme and click **Edit**
2. **Run** section:
   - Build Configuration: `Debug-Production`
3. **Test** section:
   - Build Configuration: `Debug-Production`
4. **Profile** section:
   - Build Configuration: `Release-Production`
5. **Analyze** section:
   - Build Configuration: `Debug-Production`
6. **Archive** section:
   - Build Configuration: `Release-Production`

### 5. Verify Setup

After completing the setup, verify each scheme:

1. **Select Dev Scheme** from the scheme dropdown (top left)
2. **Product** → **Build**
3. Check that the bundle identifier shows: `com.example.insibook_mobile.dev`
4. Repeat for Staging and Production schemes

## Using the Schemes

### For Development
- **Select**: `Dev` scheme
- **Run**: Cmd+R (installs as "InsiBook Dev")
- **Archive**: Product → Archive (for TestFlight internal testing)

### For Staging
- **Select**: `Staging` scheme  
- **Run**: Cmd+R (installs as "InsiBook Staging")
- **Archive**: Product → Archive (for TestFlight staging distribution)

### For Production
- **Select**: `Production` scheme
- **Run**: Cmd+R (installs as "InsiBook") 
- **Archive**: Product → Archive (for App Store submission)

## Build Scripts Integration

You can still use the Flutter build scripts:

```bash
# Build and then open Xcode for archiving
./scripts/build_ios_dev.sh
./scripts/build_ios_staging.sh  
./scripts/build_ios_production.sh
```

## Expected Results

After setup, you should have:

### Three Installable Apps
- **InsiBook Dev** (`com.example.insibook_mobile.dev`)
- **InsiBook Staging** (`com.example.insibook_mobile.staging`)
- **InsiBook** (`com.example.insibook_mobile`)

### Environment-Specific Behavior
- **Dev**: Shows green "DEVELOPMENT" banner, uses localhost API
- **Staging**: Shows orange "STAGING" banner, uses staging API  
- **Production**: No banner, uses production API

### App Store Distribution Strategy
- **Dev**: Internal testing only (never distribute)
- **Staging**: TestFlight internal testing (separate App Store Connect app)
- **Production**: App Store release

## Troubleshooting

### Configuration File Not Found
- Make sure files are in `ios/Runner/Configs/`
- Check the "Based on Configuration File" dropdown shows the files

### Bundle Identifier Issues
- Verify the .xcconfig files have correct `PRODUCT_BUNDLE_IDENTIFIER`
- Make sure you created the App IDs in Apple Developer Console

### Scheme Build Fails
- Clean build folder: **Product** → **Clean Build Folder**
- Run `flutter clean && flutter pub get`
- Try building again

### Environment Not Working
- Check that `DART_DEFINES = ENVIRONMENT=xxx` is in the .xcconfig file
- Verify the scheme is using the correct configuration

## Apple Developer Console Setup

Remember to create App IDs for:
- `com.example.insibook_mobile` (Production)
- `com.example.insibook_mobile.staging` (Staging)  
- `com.example.insibook_mobile.dev` (Development)

And create separate apps in App Store Connect for Production and Staging.

---

✅ **Setup Complete!** You now have a professional multi-environment iOS build system.