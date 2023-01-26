import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        let users = routes.grouped("users")
        users.post(use: create)
        
        let tokenProtected = users.grouped(UserToken.authenticator())
        tokenProtected.group(":userID") { user in
            user.get(use: info)
            user.delete(use: delete)
        }
    }
}

extension UserController {
    func create(req: Request) async throws -> User.Info {
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
        guard let userInfo = user.info else {
            throw Abort(.notFound)
        }
        return userInfo
    }
}

extension UserController {
    func info(req: Request) async throws -> User.Info {
        let userId = try req.auth.require(User.self).requireID()
        guard userId == req.parameters.get("userID") else {
            throw Abort(.unauthorized)
        }
        guard let userInfo = try await User.find(userId, on: req.db)?.info else {
            throw Abort(.notFound)
        }
        return userInfo
    }
    
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
