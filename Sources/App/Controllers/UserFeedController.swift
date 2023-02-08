import Fluent
import Vapor

struct UserFeedController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let tokenProtected = routes.grouped(UserToken.authenticator())
        
        let userFeed = tokenProtected.grouped("users")
            .grouped(":userID")
            .grouped("feed")
        userFeed.get(use: feed)
    }
}

extension UserFeedController {
    func feed(req: Request) async throws -> [UserPost.PublicRepresentation] {
        let userId = try req.auth.require(User.self).requireID()
        try userId.authorize(to: req.parameters.get("userID"))
        
        guard let user = try await User.query(on: req.db).with(\.$following).filter(\.$id == userId).first() else {
            throw Abort(.notFound)
        }
        
        let followingIds = user.following.compactMap { $0.id }
        let posts = try await UserPost.query(on: req.db).with(\.$likes).filter(\.$user.$id ~~ followingIds).all()
        return try posts.map { try $0.publicRepresentation(likes: $0.likes) }
    }
}
