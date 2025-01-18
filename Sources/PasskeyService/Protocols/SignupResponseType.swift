//
//  SignupResponseType.swift
//  PasskeyService
//
//  Created by Neo Golightly on 18.01.25.
//

import Vapor

public protocol SignupResponseType: Content {
  var accessToken: String { get }
}
