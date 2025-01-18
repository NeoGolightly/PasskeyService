//
//  FinishSignupRequest.swift
//  PasskeyService
//
//  Created by Neo Golightly on 18.01.25.
//

import WebAuthn

struct FinishSignupRequest: Decodable {
  let sessionID: String
  let registrationCredential: RegistrationCredential
}
