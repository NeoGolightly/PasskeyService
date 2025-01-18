//
//  LoginResponseType.swift
//  PasskeyService
//
//  Created by Neo Golightly on 18.01.25.
//

import Vapor

public protocol LoginResponseType: Content {
  var accessToken: String { get }
}
