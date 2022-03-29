//
//  TweetsMethodView.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 29/03/2022.
//

import SwiftUI
import Twift

struct PaginatedTweetsMethodView: View {
  var tweets: [Tweet]?
  var errors: [TwitterAPIError] = []
  
  var includes: Tweet.Includes?
  var meta: Meta?
  
  var getPage: (_: String?) async -> Void
  
  var body: some View {
    if !errors.isEmpty {
      Section("Errors") {
        ForEach(errors, id: \.self) { error in
          Text(String(describing: error))
        }
      }
    }
    
    if let meta = meta {
      Section {
        AsyncButton {
          await prevPage()
        } label: {
          Label("Previous Page", systemImage: "arrow.backward")
        }.disabled(meta.previousToken == nil)
        
        AsyncButton {
          await nextPage()
        } label: {
          Label("Next Page", systemImage: "arrow.forward")
        }.disabled(meta.nextToken == nil)
      }
    }
    
    if let tweets = tweets, !tweets.isEmpty {
      Section("Tweets") {
        ForEach(tweets) { tweet in
          TweetRow(tweet: tweet, user: userForTweet(tweet: tweet))
        }
      }
    }
    
    if let meta = meta {
      Section("Meta") {
        if let count = meta.resultCount {
          StackedLabel("resultCount") {
            Text("\(count)")
          }
        }
        
        if let nextToken = meta.nextToken {
          StackedLabel("nextToken") {
            Text(nextToken)
              .font(.body.monospaced())
          }
        }
        
        if let previousToken = meta.previousToken {
          StackedLabel("previousToken") {
            Text(previousToken)
              .font(.body.monospaced())
          }
        }
      }
    }
  }
  
  func userForTweet(tweet: Tweet) -> User? {
    guard let authorId = tweet.authorId else { return nil }
    
    return includes?.users?.first(where: { $0.id == authorId })
  }
  
  func nextPage() async {
    if let nextToken = meta?.nextToken {
      await getPage(nextToken)
    }
  }
  
  func prevPage() async {
    if let prevToken = meta?.previousToken {
      await getPage(prevToken)
    }
  }
}

struct TweetsMethodView_Previews: PreviewProvider {
    static var previews: some View {
      PaginatedTweetsMethodView { token in
        return
      }
    }
}
