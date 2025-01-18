//
//  File.swift
//  PassKeyServer
//
//  Created by Neo Golightly on 11.01.25.
//

import Vapor
@preconcurrency import WebAuthn

extension Application {
  struct WebAuthnKey: StorageKey {
    typealias Value = WebAuthnManager
  }
  
  public var webAuthn: WebAuthnManager {
    get {
      guard let webAuthn = storage[WebAuthnKey.self] else {
        fatalError("WebAuthn is not configured. Use app.webAuthn = ...")
      }
      return webAuthn
    }
    set {
      storage[WebAuthnKey.self] = newValue
    }
  }
}

extension Request {
  public var webAuthn: WebAuthnManager { application.webAuthn }
}


