//
//  TokenType.swift
//  PasskeyService
//
//  Created by Neo Golightly on 18.01.25.
//

import Vapor
import Fluent

public protocol TokenType: Model, Content {
  associatedtype User: UserType
  var id: UUID? { get }
  var value: String { get }
  var user: User { get }
}
