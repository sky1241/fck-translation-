## Icon Update (SVG → PNG 1024 → Launcher Icons → Release)

1) Rasterize SVG to PNG 1024 (Inkscape)
```powershell
$proj="C:\Users\ludov\OneDrive\Bureau\fck trans\fck-translation-\qwen_chat_openai"
$svg="$proj\assets\icons\app_logo.svg"
$png="$proj\assets\icons\app_logo_1024.png"
$ink=(Get-Command inkscape -ErrorAction SilentlyContinue).Source; if(-not $ink){$ink="C:\Program Files\Inkscape\bin\inkscape.com"}
& "$ink" "$svg" -o "$png" -w 1024 -h 1024
```

2) Generate launcher icons
```powershell
cd $proj
dart run flutter_launcher_icons -f "$proj\flutter_launcher_icons.yaml"
```

3) Clean, build release no-shrink, install
```powershell
Get-Process java,gradle,adb,flutter_tester -ErrorAction SilentlyContinue | Stop-Process -Force
flutter clean; Remove-Item -Recurse -Force .\build,.dart_tool -ErrorAction SilentlyContinue
cd "$proj\android"; .\gradlew.bat --stop; .\gradlew.bat clean; cd $proj
flutter pub get
flutter build apk --release --no-shrink `
  --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1/chat/completions `
  --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY `
  --dart-define=OPENAI_PROJECT=$env:OPENAI_PROJECT `
  --dart-define=OPENAI_MODEL=gpt-4o-mini `
  --dart-define=RELAY_WS_URL=wss://fck-relay-ws.onrender.com `
  --dart-define=RELAY_ROOM=test123
$dev="FMMFSOOBXO8T5D75"
adb -s $dev uninstall com.example.qwen_chat_openai 2>$null
adb -s $dev install -r -g "$proj\build\app\outputs\flutter-apk\app-release.apk"
adb -s $dev shell am start -n com.example.qwen_chat_openai/.MainActivity
```

Tip: if icon doesn’t refresh immediately, restart the launcher/phone and relaunch the app.

