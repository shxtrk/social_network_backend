import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        let users = routes.grouped("users")
        users.post(use: create)
        
        let user = users.grouped(":userID")
        user.get(use: get)
        
        let tokenProtectedUser = user.grouped(UserToken.authenticator())
        tokenProtectedUser.delete(use: delete)
    }
}

extension UserController {
    func create(req: Request) async throws -> User.PrivateRepresentation {
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
        guard let userInfo = user.privateRepresentation else {
            throw Abort(.notFound)
        }
        return userInfo
    }
    
    func get(req: Request) async throws -> User.PublicRepresentation {
        guard let publicUser = try await User.find(req.parameters.get("userID"),
                                                   on: req.db)?.publicRepresentation else {
            throw Abort(.notFound)
        }
        return publicUser
    }
}

extension UserController {
    func delete(req: Request) async throws -> HTTPStatus {
        let userId = try req.auth.require(User.self).requireID()
        guard userId == req.parameters.get("userID") else {
            return .unauthorized
        }
        guard let user = try await User.find(userId, on: req.db) else {
            throw Abort(.notFound)
        }
        try await user.delete(on: req.db)
        return .noContent
    }
}
