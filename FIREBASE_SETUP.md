# Firebase Setup for Praystreak App

## Security Rules Setup

The Praystreak app requires proper Firebase security rules to function correctly. Follow these steps to set up your Firebase project:

### 1. Firestore Security Rules

1. Go to your [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Firestore Database** in the left sidebar
4. Click the **Rules** tab
5. Replace the default rules with the following:

```
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read and write their own data
    match /users/{userId} {
      allow create: if request.auth != null;
      allow read, update, delete: if request.auth != null && request.auth.uid == userId;
    }
    
    // Prayer data - allow users to manage their own prayers
    match /prayers/{prayerId} {
      allow read, write: if request.auth != null && 
                          (resource == null || resource.data.userId == request.auth.uid);
    }
    
    // Daily prayers collection
    match /dailyPrayers/{documentId} {
      allow read, write: if request.auth != null && 
                          (resource == null || resource.data.userId == request.auth.uid);
    }
    
    // Default deny
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

6. Click **Publish** to save the rules

### 2. Authentication Setup

1. In the Firebase Console, navigate to **Authentication** in the left sidebar
2. Click on the **Sign-in method** tab
3. Enable **Email/Password** as a sign-in provider
4. Save your changes

### 3. Database Structure

The app expects the following Firestore collections:

- `users`: Stores user profile information
- `dailyPrayers`: Stores daily prayer records for users

### Important Notes

- If you're experiencing permission issues, make sure your user is properly authenticated before accessing data.
- The security rules above restrict users to only access their own data.
- For testing purposes, you can temporarily make the rules more permissive, but don't forget to restore them for production.

## Troubleshooting

### Permission Denied Errors

If you see "Missing or insufficient permissions" errors:

1. Check that the user is properly authenticated
2. Verify the security rules match the data structure
3. Make sure you're trying to access data that belongs to the authenticated user

For example, to access a user document, the authenticated user's UID must match the document ID. 