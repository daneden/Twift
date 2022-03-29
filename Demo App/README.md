#  Twift Demo App

This demo SwiftUI app and Xcode target provides a testing environment and example usage for the Twift library.

## Setup

You will need to provide your API credentials before you can build and run the app.

1. Create a `.env` file in the Demo App folder (or copy `.env.example` to `.env`)
2. Populate the `.env` file with `TWITTER_API_KEY`, `TWITTER_API_SECRET`, and `TWITTER_CALLBACK_URL` values (see `.env.example` for an example)
3. Build the Twift_SwiftUI target to create the `Secrets.swift` file which provides your client credentials for the app. You may need to clean the build folder to prevent errors about `Secrets.swift` being missing and then manually re-build.
4. Go to the “Info” tab in the Twift_SwiftUI target overview and update the URL Types pane to reflect the URL scheme for your API client.
