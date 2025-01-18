//
//  StartLoginRequestType.swift
//  PasskeyService
//
//  Created by Neo Golightly on 18.01.25.
//

import Foundation

public protocol StartLoginRequestType: Codable {
  associatedtype LoginSession: LoginSessionType
  func makeLoginSession(challange: String, userID: UUID) -> LoginSession
}
