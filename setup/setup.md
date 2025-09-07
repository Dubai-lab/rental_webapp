Here are the step-by-step instructions to set up Dialogflow ES for your chatbot:

1. Access Google Cloud Console
    Go to console.cloud.google.com
    Sign in with your Google account
    Create a new project or select existing project

2. Enable Dialogflow API
 1. In Google Cloud Console:
      Go to "APIs & Services" > "Dashboard"
      Click "+ ENABLE APIS AND SERVICES"
      Search for "Dialogflow API"
      Click "Enable"

3. Create Service Account
     Go to "IAM & Admin" > "Service Accounts"
     Click "CREATE SERVICE ACCOUNT"
     Fill in:
       Name: rental-chatbot
       Description: Service account for rental app chatbot
     Click "CREATE AND CONTINUE"
     For Role, select:
       "Dialogflow > Dialogflow API Client"
     Click "DONE"

4. Generate Key File
      Find your service account in the list
      Click the three dots (actions menu)
      Select "Manage keys"
      Click "ADD KEY" > "Create new key"
      Choose "JSON"
      Click "CREATE"
      Save the downloaded JSON file as dialogflow-credentials.jsony
      
5. Create Dialogflow Agent
      Go to dialogflow.cloud.google.com
      Click "Create Agent"
      Enter:
        Agent name: RentalSupport
        Default language: English
        Project: Select your Google Cloud project
      Click "CREATE"

6. Add to Your Project
    Create an assets folder in your Flutter project root
    Create a credentials subfolder
    Copy the downloaded JSON key file there
    Update pubspec.yaml: 
# ...existing code...
flutter:
  assets:
    - assets/credentials/dialogflow-credentials.json
# ...existing code...

7. Security Note
     Add assets/credentials/ to .gitignore:
     # ...existing code...
     assets/credentials/
     # ...existing code...