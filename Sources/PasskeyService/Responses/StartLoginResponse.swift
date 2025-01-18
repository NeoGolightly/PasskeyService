//
//  File.swift
//  PassKeyServer
//
//  Created by Neo Golightly on 16.01.25.
//

import Vapor
import WebAuthn

public struct StartLoginResponse: AsyncResponseEncodable, Encodable {
  let sessionID: String
  let credentialRequestOptions: PublicKeyCredentialRequestOptions
  public func encodeResponse(for request: Request) async throws -> Response {
    var headers = HTTPHeaders()
    headers.contentType = .json
    return try Response(status: .ok, headers: headers, body: .init(data: JSONEncoder().encode(self)))
  }
}
