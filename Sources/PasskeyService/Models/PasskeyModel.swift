//
//  File.swift
//  PassKeyServer
//
//  Created by Neo Golightly on 13.01.25.
//

import Fluent
import Vapor
import WebAuthn

protocol PasskeyModelType: Model {
  associatedtype User: UserType
//  static var schema: String { get }
  var id: String? { get }
  
  var publicKey: String { get }
  
  var currentSignCount: Int32  { get }
  
  var user: User { get }
}


public final class PasskeyModel<U: UserType>: Model, @unchecked Sendable, PasskeyModelType  {
  typealias User = U
  
  public static var schema: String { "passkeys" }
  
  @ID(custom: "id", generatedBy: .user)
  public var id: String?
  
  @Field(key: "public_key")
  var publicKey: String
  
  @Field(key: "current_sign_count")
  var currentSignCount: Int32
  
  @Parent(key: "user_id")
  var user: User
  
  public init() {}
  
  init(id: String, publicKey: String, currentSignCount: Int32, userID: User.IDValue) {
    self.id = id
    self.publicKey = publicKey
    self.currentSignCount = currentSignCount
    self.$user.id = userID
  }
  
  convenience init(from credential: Credential, userID: UUID) {
    self.init(
      id: credential.id,
      publicKey: credential.publicKey.base64URLEncodedString().asString(),
      currentSignCount: Int32(credential.signCount),
      userID: userID
    )
  }
}
