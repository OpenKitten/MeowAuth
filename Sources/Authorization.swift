import Routing
import HTTP

public typealias PermissionChecker = ((Request) throws -> ())

public class PermissionCheckerMiddleware : Middleware {
    let permissionChecker: PermissionChecker
    
    public init(_ permissionChecker: @escaping PermissionChecker) {
        self.permissionChecker = permissionChecker
    }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        try permissionChecker(request)
        
        return try next.respond(to: request)
    }
}

extension RouteBuilder {
    public func group(_ permissionChecker: @escaping PermissionChecker, handler: (RouteBuilder) -> ()) {
        let builder = grouped(PermissionCheckerMiddleware(permissionChecker))
        handler(builder)
    }
}
