//
//  CreatePasskey.swift
//  PassKeyServer
//
//  Created by Neo Golightly on 13.01.25.
//

import Fluent

extension PasskeyModel {
  
  public struct Create: AsyncMigration {
    public init() {
      
    }
    public var name: String {
      "passkeyModel_create"
    }
    public func prepare(on database: Database) async throws {
      try await database.schema("passkeys")
        .field("id", .string)
        .field("public_key", .string, .required)
        .field("current_sign_count", .int32, .required)
        .field("user_id", .uuid, .required, .references(User.schema, "id"))
        .create()
    }
    
    public func revert(on database: Database) async throws {
      try await database.schema("passkeys").delete()
    }
  }
  
}
