import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let tokenProtected = routes.grouped(UserToken.authenticator())
        
        let users = tokenProtected.grouped("users")
        users.get(use: getAllUsers)
        
        let user = users.grouped(":userID")
        user.get(use: getUser)
        user.put(use: updateUser)
        user.delete(use: deleteUser)
    }
}

extension UserController {
    func getAllUsers(req: Request) async throws -> [User.PublicRepresentation] {
        try req.auth.require(User.self)
        return try await User.query(on: req.db).all().map { try $0.publicRepresentation() }
    }
    
    func getUser(req: Request) async throws -> User.RichPublicRepresentation {
        try req.auth.require(User.self)
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }

        let following = try await user.$following.get(on: req.db)
        let followers = try await user.$followers.get(on: req.db)
        
        return try user.richPublicRepresentation(following: following, followers: followers)
    }
    
    func updateUser(req: Request) async throws -> User.PrivateRepresentation {
        let user = try req.auth.require(User.self)
        try user.requireID().authorize(to: req.parameters.get("userID"))
        
        try User.Update.validate(content: req)
        let update = try req.content.decode(User.Update.self)
        
        if let userName = update.userName {
            user.userName = userName
        }
        if let email = update.email {
            user.email = email
        }
        if user.hasChanges {
            try await user.save(on: req.db)
        }
        
        return try user.privateRepresentation()
    }
    
    func deleteUser(req: Request) async throws -> HTTPStatus {
        let userId = try req.auth.require(User.self).requireID()
        try userId.authorize(to: req.parameters.get("userID"))
        
        guard let user = try await User.find(userId, on: req.db) else {
            throw Abort(.notFound)
        }
        try await user.delete(on: req.db)
        return .noContent
    }
}
