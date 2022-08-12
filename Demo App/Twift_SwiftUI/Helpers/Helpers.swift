//
//  Helpers.swift
//  Twift_SwiftUI
//
//  Created by Daniel Eden on 20/01/2022.
//

import Foundation
import struct Twift.List
import struct Twift.User

typealias TwitterList = Twift.List

let allUserFields: Set<Twift.User.Field> = [
  \.createdAt,
   \.description,
   \.entities,
   \.location,
   \.pinnedTweetId,
   \.profileImageUrl,
   \.protected,
   \.publicMetrics,
   \.url,
   \.verified,
   \.withheld
]
