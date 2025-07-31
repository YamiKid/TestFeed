//
//  Post.swift
//  TestFeed
//
//  Created by Maksim Kazushchik on 30.07.25.
//

import Foundation

struct Post: Codable {
    let id: Int
    let title: String
    let body: String
    var isLiked: Bool
    var avatarURL: URL? {
        return URL(string: "https://picsum.photos/seed/avatar/100/100")
    }
} 
