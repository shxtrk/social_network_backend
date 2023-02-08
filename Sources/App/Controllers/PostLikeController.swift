import Fluent
import Vapor

struct PostLikeController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let tokenProtected = routes.grouped(UserToken.authenticator())
        
        let likes = tokenProtected.grouped("posts")
            .grouped(":postID")
            .grouped("likes")
        likes.post(use: add)
        likes.delete(use: delete)
    }
}

extension PostLikeController {
    func add(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        
        guard let userPost = try await UserPost.find(req.parameters.get("postID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await user.$likes.attach(userPost, method: .ifNotExists, on: req.db)
        return .created
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)

        guard let userPost = try await UserPost.find(req.parameters.get("postID"), on: req.db) else {
            throw Abort(.notFound)
        }

        guard try await user.$likes.isAttached(to: userPost, on: req.db) else {
            return .notFound
        }

        try await user.$likes.detach(userPost, on: req.db)
        return .noContent
    }
}
