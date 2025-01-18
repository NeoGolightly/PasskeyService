//
//  StartSignupRequestType.swift
//  PasskeyService
//
//  Created by Neo Golightly on 18.01.25.
//

import Foundation

public protocol StartSignupRequestType: Codable {
  associatedtype SignupSession: SignupSessionType
  var name: String { get }
  var displayName: String { get }
  func makeSignupSession(challange: String, userID: UUID) -> SignupSession
}
