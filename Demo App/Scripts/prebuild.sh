if [ ! -f ".env" ];
then
  echo "error: No .env file was found for environment variables. Check the README for setup instructions for this demo app.";
  exit 1;
fi

set -o allexport; source .env; set +o allexport;

content="import Foundation
/// This file is automatically populated by a pre-action build script in the Twift_SwiftUI scheme
/// **Do not** check in the \`.env\` file or this generated \`Secrets.swift\` file to version control.

let TWITTER_API_KEY=\"$TWITTER_API_KEY\"
let TWITTER_API_SECRET=\"$TWITTER_API_SECRET\"
let TWITTER_CALLBACK_URL=\"$TWITTER_CALLBACK_URL\"
let CLIENT_ID=\"$CLIENT_ID\"
";

echo "$content" > Twift_SwiftUI/Secrets.swift;
exit 0;
