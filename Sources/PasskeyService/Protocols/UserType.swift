//
//  UserType.swift
//  PasskeyService
//
//  Created by Neo Golightly on 18.01.25.
//

import Foundation
import Fluent

public protocol UserType: Model where Self.IDValue == UUID {
  associatedtype StartSignupRequest: StartSignupRequestType
  associatedtype StartLoginRequest: StartLoginRequestType
  associatedtype SignupResponse: SignupResponseType
  associatedtype LoginResponse: LoginResponseType
  associatedtype Token: TokenType
  static func userExistsFor(request: StartSignupRequest, db: Database) async throws -> Bool
  static func userFor(request: StartSignupRequest, db: Database) async throws -> Self?
  static func userFor(request: StartLoginRequest, db: Database) async throws -> Self?
  static func create(from session: StartSignupRequest.SignupSession, db: Database) -> Self
  
  func generateToken() throws -> Token
  func createSignupResponse(accessToken: String) -> SignupResponse
  func createLoginResponse(accessToken: String) -> LoginResponse
}
