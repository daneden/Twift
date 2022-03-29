//
//  TweetRow.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 15/01/2022.
//

import Foundation
import SwiftUI
import Twift

struct TweetRow: View {
  var tweet: Tweet
  var user: User?
  
  var body: some View {
    HStack(alignment: .top) {
      if let pfp = user?.profileImageUrlLarger {
        UserProfileImage(url: pfp)
      }
      
      VStack(alignment: .leading, spacing: 4) {
        HStack(spacing: 4) {
          if let userName = user?.name,
             let userHandle = user?.username {
            Text(userName)
              .fontWeight(.bold)
              .foregroundStyle(.primary)
            
            Text("@\(userHandle)")
            
            Text("•")
          }
          
          if let createdAt = tweet.createdAt {
            Text(createdAt.formatted(.relative(presentation: .named)))
          }
        }
        .lineLimit(1)
        .font(.footnote)
        .foregroundStyle(.secondary)
        
        Text(tweet.text)
        
        if let metrics = tweet.publicMetrics {
          HStack {
            Label("\(metrics.replyCount)", systemImage: "bubble.left")
              .foregroundColor(.blue)
            
            Label("\(metrics.retweetCount)", systemImage: "repeat")
              .foregroundColor(.green)
            
            Label("\(metrics.likeCount)", systemImage: "heart")
              .foregroundColor(.pink)
          }
          .symbolVariant(.fill)
          .font(.caption)
        }
      }.contextMenu {
        Button(action: {
          UIPasteboard.general.string = tweet.id
        }) {
          Label("Copy Tweet ID", systemImage: "doc.on.doc")
        }
    }
    }
  }
}
