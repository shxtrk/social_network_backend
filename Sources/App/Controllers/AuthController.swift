import Fluent
import Vapor

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.grouped("users").post(use: createUser)
        
        let passwordProtected = routes.grouped(User.authenticator())
        passwordProtected.post("auth", use: auth)
    }
}

extension AuthController {
    func createUser(req: Request) async throws -> User.PrivateRepresentation {
        try User.Create.validate(content: req)
        let create = try req.content.decode(User.Create.self)
        guard create.password == create.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        let user = try User(
            userName: create.userName,
            email: create.email,
            passwordHash: Bcrypt.hash(create.password)
        )
        try await user.save(on: req.db)
        return try user.privateRepresentation()
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
