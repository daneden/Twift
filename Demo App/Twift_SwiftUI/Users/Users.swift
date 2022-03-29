//
//  Users.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 14/01/2022.
//

import SwiftUI
import Twift

struct Users: View {
  @EnvironmentObject var twitterClient: Twift
  
  var body: some View {
    Form {
      Section("Get Users") {
        NavigationLink(destination: GetMe()) { MethodRow(label: "`getMe()`", method: .GET) }
        NavigationLink(destination: GetUser()) { MethodRow(label: "`getUser(_ userId)`", method: .GET) }
        NavigationLink(destination: GetUserByUsername()) { MethodRow(label: "`getUserBy(username)`", method: .GET) }
        NavigationLink(destination: GetUsersByUsernames()) { MethodRow(label: "`getUsersBy(usernames)`", method: .GET) }
      }
      
      Section("Follows") {
        NavigationLink(destination: GetFollowing()) { MethodRow(label: "`getFollowing(_ userId)`", method: .GET) }
        NavigationLink(destination: GetFollowers()) { MethodRow(label: "`getFollowers(_ userId)`", method: .GET) }
        NavigationLink(destination: FollowUser()) { MethodRow(label: "`followUser(sourceUserId:targetUserId)`", method: .POST) }
        NavigationLink(destination: UnfollowUser()) { MethodRow(label: "`unfollowUser(sourceUserId:targetUserId)`", method: .DELETE) }
      }
      
      Section("Blocks") {
        NavigationLink(destination: GetBlockedUsers()) { MethodRow(label: "`getBlockedUsers(for)`", method: .GET) }
        NavigationLink(destination: BlockUser()) { MethodRow(label: "`blockUser(sourceUserId:targetUserId)`", method: .POST) }
        NavigationLink(destination: UnblockUser()) { MethodRow(label: "`unblockUser(sourceUserId:targetUserId)`", method: .DELETE) }
      }
      
      Section("Mutes") {
        NavigationLink(destination: GetMutedUsers()) { MethodRow(label: "`getMutedUsers(for)`", method: .GET) }
        NavigationLink(destination: MuteUser()) { MethodRow(label: "`muteUser(sourceUserId:targetUserId)`", method: .POST) }
        NavigationLink(destination: UnmuteUser()) { MethodRow(label: "`unmuteUser(sourceUserId:targetUserId)`", method: .DELETE) }
      }
    }
    .navigationTitle("Users")
  }
}

struct Users_Previews: PreviewProvider {
  static var previews: some View {
    Users()
  }
}
