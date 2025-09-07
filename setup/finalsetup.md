# Chatbot Setup Instructions

## 1. Add Dependencies
Add to `pubspec.yaml`:
```yaml
dependencies:
  dialog_flowtter: ^0.3.3
```

Run:
```bash
flutter pub get
```

## 2. Create Assets Structure
```
rental_webapp/
  ├── assets/
  │   └── credentials/
  │       └── dialogflow-credentials.json  # Add your key file here
```

## 3. Configure Service Account Key
1. Rename your downloaded JSON key to `dialogflow-credentials.json`
2. Place it in `assets/credentials/` folder
3. Add to `.gitignore`:
```
assets/credentials/
```

## 4. Update pubspec.yaml
Add assets path:
```yaml
flutter:
  assets:
    - assets/credentials/dialogflow-credentials.json
```

## 5. Initialize Service
The DialogflowService will automatically initialize when first used.

## 6. Add Chat Page to Navigation
Add to your router:
```dart
case '/chat':
  return MaterialPageRoute(builder: (_) => const ChatPage());
```

## 7. Testing
1. Run the app
2. Navigate to chat page
3. Try sending a message
4. Check debug console for any errors

## Common Issues
1. "File not found": Ensure key file is in correct location
2. "Invalid credentials": Check JSON file content
3. "Service not initialized": Verify Google Cloud API is enabled

## Security Note
Never commit the credentials file to version control.