//
//  FinishLoginRequest.swift
//  PasskeyService
//
//  Created by Neo Golightly on 18.01.25.
//

import WebAuthn

struct FinishLoginRequest: Decodable {
  let sessionID: String
  let authenticationCredential: AuthenticationCredential
}
