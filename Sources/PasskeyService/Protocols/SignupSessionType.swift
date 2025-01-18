//
//  SignupSessionType.swift
//  PasskeyService
//
//  Created by Neo Golightly on 18.01.25.
//

import Foundation

public protocol SignupSessionType: Codable {
  var id: UUID { get }
  var challange: String { get }
  var userID: UUID { get }
}
