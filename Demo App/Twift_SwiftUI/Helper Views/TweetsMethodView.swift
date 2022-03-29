//
//  TweetsMethodView.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 29/03/2022.
//

import SwiftUI
import Twift

struct TweetsMethodView: View {
  var tweets: [Tweet]?
  var errors: [TwitterAPIError] = []
  
  var includes: Tweet.Includes?
  
  var body: some View {
    if let tweets = tweets {
      Section("Tweets") {
        ForEach(tweets) { tweet in
          TweetRow(tweet: tweet, user: userForTweet(tweet: tweet))
        }
      }
    }
    
    if let includes = includes {
      Section("Expansions") {
        Text(String(reflecting: includes))
          .font(.caption.monospaced())
          .foregroundStyle(.secondary)
          .padding(.vertical, 4)
      }
    }
    
    if !errors.isEmpty {
      Section("Errors") {
        ForEach(errors, id: \.self) { error in
          Text(String(describing: error))
        }
      }
    }
  }
  
  func userForTweet(tweet: Tweet) -> User? {
    guard let authorId = tweet.authorId else { return nil }
    
    return includes?.users?.first(where: { $0.id == authorId })
  }
}

struct TweetsMethodView_Previews: PreviewProvider {
    static var previews: some View {
        TweetsMethodView()
    }
}
