//
//  File.swift
//  PassKeyServer
//
//  Created by Neo Golightly on 14.01.25.
//

import Foundation
import Vapor
import Fluent
import WebAuthn
import Redis
import RediStack



public struct PasskeyService<User: UserType, Token: TokenType>: Sendable {
  private let redisExpirationInSeconds: Int = 60
  
  public init() {}
  
  @Sendable
  public func startSignup(req: Request) async throws -> StartSignupResponse {
    print("startSignup")
    //
    let startSignupRequest = try req.query.decode(User.StartSignupRequest.self)
    // check if user already exists
    guard try await !User.userExistsFor(request: startSignupRequest, db: req.db)
    else { throw Abort(.conflict, reason: "User already taken.", identifier: "exists") }
    //
    let userID = UUID()
    let (options, challange) = createPublicKeyCredentialCreationOptions(req: req,
                                                                        userID: userID,
                                                                        name: startSignupRequest.name,
                                                                        displayName:  startSignupRequest.displayName)
    // create signup session
    let signupSession = startSignupRequest.makeSignupSession(challange: challange, userID: userID)
    //
    try await req.redis.setex(RedisKey(signupSession.id.uuidString), toJSON: signupSession, expirationInSeconds: redisExpirationInSeconds)
    //
    return StartSignupResponse(sessionID: signupSession.id.uuidString, credentialCreationOptions: options)
  }
    
  @Sendable
  public func finishSignup(req: Request) async throws -> User.SignupResponse {
    req.logger.trace("start finish signup")
    //
    let finishSignupRequest = try req.content.decode(FinishSignupRequest.self)
    //
    req.logger.trace("find session")
    guard let signupSession = try await req.redis.get(RedisKey(finishSignupRequest.sessionID), asJSON: User.StartSignupRequest.SignupSession.self)
    else { throw Abort(.badRequest, reason: "Session id not correct") }
    //
    req.logger.trace("get challenge")
    guard let challenge = Data(base64Encoded: signupSession.challange)
    else { throw Abort(.badRequest, reason: "Missing registration challenge") }
    //
    req.logger.trace("check credential")
    let credential = try await req.webAuthn.finishRegistration(challenge: [UInt8](challenge),
                                                               credentialCreationData: finishSignupRequest.registrationCredential,
                                                               confirmCredentialIDNotRegisteredYet: { credentialID in
      return try await Passkey<User>.query(on: req.db).filter(\.$id == credentialID).first() == nil
    })
    //
    req.logger.trace("create user")
    let user = User.create(from: signupSession, db: req.db)
    try await user.save(on: req.db)
    //
    req.logger.trace("create passkey")
    try await Passkey<User>(
        id: credential.id,
        publicKey: credential.publicKey.base64URLEncodedString().asString(),
        currentSignCount: Int32(credential.signCount),
        userID: user.requireID()
    ).save(on: req.db)
    //
    req.logger.trace("create token")
    let token = try user.generateToken()
    try await token.save(on: req.db)
    //
    req.logger.trace("create signup response")
    return user.createSignupResponse(accessToken: token.value)
  }
  
  @Sendable
  public func startLogin(req: Request) async throws -> StartLoginResponse {
    //
    guard let startLoginRequest = try? req.query.decode(User.StartLoginRequest.self)
    else { throw Abort(.badRequest, reason: "wrong parameters") }
    //
    guard let user = try await User.userFor(request: startLoginRequest, db: req.db)
    else {  throw Abort(.badRequest, reason: "user not found")}
    //
    let (options, challange) = try createPublicKeyCredentialRequestOptions(req: req)
    // create signup session
    let loginSession = startLoginRequest.makeLoginSession(challange: challange, userID: try user.requireID())
    //
    try await req.redis.setex(RedisKey(loginSession.id.uuidString), toJSON: loginSession, expirationInSeconds: redisExpirationInSeconds)
    return StartLoginResponse(sessionID: loginSession.id.uuidString, credentialRequestOptions: options)
  }
  
  @Sendable
  public func finishLogin(req: Request) async throws -> User.LoginResponse {
    //
    let finishLoginRequest = try req.content.decode(FinishLoginRequest.self)
    //
    guard let signupSession = try await req.redis.get(RedisKey(finishLoginRequest.sessionID), asJSON: User.StartLoginRequest.LoginSession.self)
    else { throw Abort(.badRequest, reason: "Session id not correct") }
    //
    guard let challenge = Data(base64Encoded: signupSession.challange) else {
        throw Abort(.badRequest, reason: "Missing registration challenge")
    }
    // find the credential the stranger claims to possess
    guard let credential = try await Passkey<User>.query(on: req.db)
      .filter(\.$id == finishLoginRequest.authenticationCredential.id.urlDecoded.asString())
      .with(\.$user)
      .first() else {
      throw Abort(.unauthorized)
    }
    //
    let verifiedAuthentication = try req.webAuthn.finishAuthentication(credential: finishLoginRequest.authenticationCredential,
                                                                       expectedChallenge: [UInt8](challenge),
                                                                       credentialPublicKey: [UInt8](URLEncodedBase64(credential.publicKey).urlDecoded.decoded!),
                                                                       credentialCurrentSignCount: UInt32(credential.currentSignCount))
    
    // if we successfully verified the user, update the sign count
    credential.currentSignCount = Int32(verifiedAuthentication.newSignCount)
    try await credential.save(on: req.db)
    //
    let token = try credential.user.generateToken()
    try await token.save(on: req.db)
    //
    return credential.user.createLoginResponse(accessToken: token.value)
  }
}

extension PasskeyService {
  private func createPublicKeyCredentialCreationOptions(req: Request, userID: UUID, name: String, displayName: String) -> (options: PublicKeyCredentialCreationOptions, challangeBase64encoded: String) {
    let userCredentials = PublicKeyCredentialUserEntity(id: [UInt8](userID.uuidString.utf8),
                                                        name: name,
                                                        displayName: displayName)
    let options = req.webAuthn.beginRegistration(user: userCredentials)
    let challange = Data(options.challenge).base64EncodedString()
    return (options, challange)
  }
  
  private func createPublicKeyCredentialRequestOptions(req: Request) throws -> (options: PublicKeyCredentialRequestOptions, challangeBase64encoded: String) {
    let options = try req.webAuthn.beginAuthentication()
    let challange = Data(options.challenge).base64EncodedString()
    return (options, challange)
  }
}
