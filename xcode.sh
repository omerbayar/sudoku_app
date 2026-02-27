set -e

echo "flutter clean 1"
flutter clean

echo "flutter pub get 2"
flutter pub get

echo "cd ios 3"
cd ios

echo "pod install 4"
pod install

echo "cd .. 5"
cd ..