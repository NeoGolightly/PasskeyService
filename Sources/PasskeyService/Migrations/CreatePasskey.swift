//
//  CreatePasskey.swift
//  PassKeyServer
//
//  Created by Neo Golightly on 13.01.25.
//

import Fluent


public struct CreatePasskey: AsyncMigration {
  public init(name: String) {
    
  }
  public func prepare(on database: Database) async throws {
    try await database.schema("passkeys")
      .field("id", .string)
      .field("public_key", .string, .required)
      .field("current_sign_count", .int32, .required)
      .field("user_id", .uuid, .required, .references("user", "id"))
      .create()
  }
  
  public func revert(on database: Database) async throws {
    try await database.schema("passkeys").delete()
  }
}

