//
//  VolumeStream.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 17/01/2022.
//

import SwiftUI
import Twift

struct VolumeStream: View {
  @EnvironmentObject var twitterClient: Twift
  @State var tweets: [Tweet] = []
  @State var errors: [Error] = []
  
  var body: some View {
    Form {
      Section {
        AsyncButton(action: {
          do {
            let result = try await twitterClient.volumeStream(
              fields: [\.createdAt, \.publicMetrics, \.authorId],
              expansions: [.authorId(userFields: [\.profileImageUrl])]
            )
            
            for try await entry in result {
              tweets.append(entry.data)
            }
          } catch {
            if let error = error as? TwitterAPIError {
              withAnimation { errors = [error] }
            } else {
              withAnimation { errors = [error] }
            }
          }
        }) {
          Text("Start stream")
        }
      }
      
      Section("Tweets") {
        Text("\(tweets.count)")
      }
      
      if !errors.isEmpty {
        Section("Errors") {
          Text(String(describing: errors))
        }
      }
    }.navigationTitle("Volume Stream")
  }
}

struct VolumeStream_Previews: PreviewProvider {
    static var previews: some View {
        VolumeStream()
    }
}
