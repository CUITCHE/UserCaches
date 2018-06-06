//
//  UserModel.swift
//  UserCachesTests
//
//  Created by He,Junqiu on 2018/6/5.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import Foundation

struct User: Codable, Equatable {
    let name: String
    let age: Int
    let score: Double

    static var demo: User { return User(name: "demo", age: 362, score: 60.546) }
}

struct App: Codable, Equatable {
    let users: [User]
    let attribute: [String: String]

    static var demo: App { return App(users: [.demo, .demo, .demo], attribute: ["Haaaahaa": "Yooooy"]) }
}
