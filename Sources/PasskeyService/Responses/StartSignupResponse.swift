//
//  StartSignupResponse.swift
//  PasskeyService
//
//  Created by Neo Golightly on 18.01.25.
//

import Vapor
import WebAuthn

public struct StartSignupResponse: AsyncResponseEncodable, Encodable {
  let sessionID: String
  let credentialCreationOptions: PublicKeyCredentialCreationOptions
  public func encodeResponse(for request: Request) async throws -> Response {
    var headers = HTTPHeaders()
    headers.contentType = .json
    return try Response(status: .ok, headers: headers, body: .init(data: JSONEncoder().encode(self)))
  }
}
