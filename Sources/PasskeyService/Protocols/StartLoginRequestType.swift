//
//  StartLoginRequestType.swift
//  PasskeyService
//
//  Created by Neo Golightly on 18.01.25.
//

import Foundation
import Vapor
public protocol StartLoginRequestType: Content {
  associatedtype LoginSession: LoginSessionType
  func makeLoginSession(challange: String, userID: UUID) -> LoginSession
}
