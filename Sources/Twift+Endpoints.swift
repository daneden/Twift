//
//  File.swift
//  
//
//  Created by Daniel Eden on 11/01/2022.
//

import Foundation

extension Twift {
  enum APIRoute: String {
    case users, tweets
    case usersBy = "users/by"
    case usersByUsername = "users/by/username"
    case me = "users/me"
  }
}
