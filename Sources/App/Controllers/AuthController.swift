import Fluent
import Vapor

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let passwordProtected = routes.grouped(User.authenticator())
        passwordProtected.post("auth", use: auth)
    }
}

extension AuthController {
    func auth(req: Request) async throws -> UserToken.PrivateRepresentation {
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()
        try await token.save(on: req.db)
        return token.privateRepresentation
    }
}
