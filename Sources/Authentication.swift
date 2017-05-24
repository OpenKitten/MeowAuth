import MeowVapor
import Foundation
import BCrypt
import Meow
import Vapor
import HTTP

public protocol Authenticatable {
    associatedtype Credentials
    
    func verify(_: Credentials) throws -> Self
}

public protocol AuthenticationMechanism {
    associatedtype User : Authenticatable
    
    static func getUser(for request: Request) throws -> User?
}

public struct Token {
    public let token: String
    
    public init(_ token: String) {
        self.token = token
    }
}

public struct SimpleBCryptCredentials {
    public let login: String
    public let password: String
    
    public init(login: String, password: String) {
        self.login = login
        self.password = password
    }
}

public protocol BCryptAuthenticatable : Authenticatable {
    typealias Credentials = SimpleBCryptCredentials
    
    var password: String { get }
    
    static func findOne(by loginName: String) throws -> Self?
}

public struct BCryptMechanism<A: BCryptAuthenticatable> : AuthenticationMechanism {
    public typealias Authenticatable = A
    
    public static func getUser(for request: Request) throws -> A? {
        guard let session = request.session else {
            return nil
        }
        
        guard let loginName = String(session.document["meow"]["auth"]["bcrypt-login-name"]), let authenticatable = try A.findOne(by: loginName) else {
            return nil
        }
        
        return authenticatable
    }
}

public class AuthenticationMiddleware<Mechanism : AuthenticationMechanism> : Middleware {
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        if let user = try Mechanism.getUser(for: request) {
            Meow.setCurrentUser(to: user)
        }
        
        return try next.respond(to: request)
    }
}

extension Meow {
    public static func getCurrentUser<A: Authenticatable>() -> A? {
        return Thread.current.threadDictionary.value(forKey: "_meowAuthenticatable") as? A
    }
    
    public static func setCurrentUser<A: Authenticatable>(to user: A) {
        Thread.current.threadDictionary.setValue(user, forKey: "_meowAuthenticatable")
    }
}
