import Vapor
import Fluent

final class PostLike: Model {
    static let schema = "post_likes"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Parent(key: "post_id")
    var userPost: UserPost

    init() { }

    init(id: UUID? = nil,
         user: User,
         userPost: UserPost) throws {
        self.id = id
        self.$user.id = try user.requireID()
        self.$userPost.id = try userPost.requireID()
    }
}


struct PostLikeRepresentation: Content {
    var postId: UUID
    var userId: UUID
}
