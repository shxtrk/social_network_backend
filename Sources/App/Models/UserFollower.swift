import Vapor
import Fluent

final class UserFollower: Model {
    static let schema = "user_followers"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "follower_id")
    var follower: User

    @Parent(key: "following_id")
    var following: User

    init() { }

    init(id: UUID? = nil,
         follower: User,
         following: User) throws {
        self.id = id
        self.$follower.id = try follower.requireID()
        self.$following.id = try following.requireID()
    }
}
