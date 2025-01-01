# Ilan Kıbrıs

//to run the application
```shell
flutter run
```

//To update iOS pods
```shell
cd ios
pod init
pod update
pod install
cd ..
```

//To make release build for iOS
```shell
flutter build ios --release
```

//To make release build for Android
```shell
flutter build apk --release
```

//To run the release build for iOS
```shell
open build/ios/Runner.xcworkspace
```

//To clean the pub cache
```shell
flutter clean
flutter pub cache clean
flutter pub get
```

//To repair the pub cache
```shell
flutter clean
flutter pub cache repair
flutter pub get
```

//to generate android application
```shell
flutter build apk --split-per-abi
open  build/app/outputs/flutter-apk/
```

// to solve most common iOS errors
```shell
flutter clean
rm -Rf ios/Pods
rm -Rf ios/.symlinks
rm -Rf ios/Flutter/Flutter.framework
rm -Rf Flutter/Flutter.podspec
rm ios/podfile.lock
cd ios 
pod deintegrate
sudo rm -rf ~/Library/Developer/Xcode/DerivedData
flutter pub cache repair
flutter pub get 
pod install 
pod update 
```

