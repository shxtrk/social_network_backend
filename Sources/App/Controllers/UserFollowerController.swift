import Fluent
import Vapor

struct UserFollowerController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let tokenProtected = routes.grouped(UserToken.authenticator())
        
        let follower = tokenProtected.grouped("users")
            .grouped(":userID")
            .grouped("followers")
            .grouped(":followingID")
        follower.post(use: add)
        follower.delete(use: delete)
    }
}

extension UserFollowerController {
    func add(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        try user.requireID().authorize(to: req.parameters.get("userID"))
        
        guard let following = try await User.find(req.parameters.get("followingID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await user.$following.attach(following, method: .ifNotExists, on: req.db)
        return .created
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        try user.requireID().authorize(to: req.parameters.get("userID"))
        
        guard let following = try await User.find(req.parameters.get("followingID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        guard try await user.$following.isAttached(to: following, on: req.db) else {
            return .notFound
        }
        
        try await user.$following.detach(following, on: req.db)
        return .noContent
    }
}
