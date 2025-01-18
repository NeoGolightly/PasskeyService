//
//  LoginSessionType.swift
//  PasskeyService
//
//  Created by Neo Golightly on 18.01.25.
//

import Foundation

public protocol LoginSessionType: Codable {
  var id: UUID { get }
  var challange: String { get }
}
