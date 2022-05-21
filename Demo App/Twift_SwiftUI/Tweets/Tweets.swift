//
//  Tweets.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 15/01/2022.
//

import SwiftUI
import Twift

struct Tweets: View {
  @EnvironmentObject var twitterClient: Twift
  
    var body: some View {
      Form {
        Section("Manage Tweets") {
          NavigationLink(destination: PostTweet()) { MethodRow(label: "`postTweet(_ tweet)`", method: .POST) }
        }
        
        Section("Get Tweets") {
          NavigationLink(destination: GetTweet()) { MethodRow(label: "`getTweet(_ tweetId)`", method: .GET) }
        }
        
        Section("Timelines") {
          NavigationLink(destination: UserTimeline()) { MethodRow(label: "`userTimeline(_ userId)`", method: .GET) }
          NavigationLink(destination: UserMentions()) { MethodRow(label: "`userMentions(_ userId)`", method: .GET) }
          NavigationLink(destination: ReverseChronologicalTimeline()) { MethodRow(label: "`reverseChronologicalTimeline(_ userId)`", method: .GET) }
        }
        
        Section("Likes") {
          NavigationLink(destination: LikeTweet()) { MethodRow(label: "`likeTweet(_ tweetId, userId)`", method: .POST) }
          NavigationLink(destination: UserLikes()) { MethodRow(label: "`getUserLikes(for userId)`", method: .GET) }
        }
        
        Section("Bookmarks") {
          NavigationLink(destination: GetBookmarks()) { MethodRow(label: "`getBookmarks(for userId)`", method: .GET) }
          NavigationLink(destination: AddBookmark()) { MethodRow(label: "`addBookmark(_ tweetId, userId)`", method: .POST) }
          NavigationLink(destination: DeleteBookmark()) { MethodRow(label: "`deleteBookmark(_ tweetId, userId)`", method: .DELETE) }
        }
        
        Section {
          NavigationLink(destination: VolumeStream()) { MethodRow(label: "`volumeStream()`", method: .GET) }
        } header: {
          Text("Volume Stream")
        } footer: {
          Text("Volume Stream requires OAuth 2.0 App-Only authentication (bearer token)")
        }.disabled(!isEnabled)
        
      }.navigationTitle("Tweets")
    }
  
  var isEnabled: Bool {
    switch twitterClient.authenticationType {
    case .appOnly(_): return true
    default: return false
    }
  }
}

struct Tweets_Previews: PreviewProvider {
    static var previews: some View {
        Tweets()
    }
}
