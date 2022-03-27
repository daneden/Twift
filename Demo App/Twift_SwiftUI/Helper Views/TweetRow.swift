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
  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      if let createdAt = tweet.createdAt {
        Text(createdAt.formatted(.relative(presentation: .named)))
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      
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
