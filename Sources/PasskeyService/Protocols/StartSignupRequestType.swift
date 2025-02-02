//
//  StartSignupRequestType.swift
//  PasskeyService
//
//  Created by Neo Golightly on 18.01.25.
//

import Foundation
import Vapor
public protocol StartSignupRequestType: Content {
  associatedtype SignupSession: SignupSessionType
  var name: String { get }
  var displayName: String { get }
  func makeSignupSession(challange: String, userID: UUID) -> SignupSession
}
