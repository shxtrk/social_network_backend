import Fluent

struct CreateUserFollower: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(UserFollower.schema)
            .id()
            .field("follower_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
            .field("following_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
            .unique(on: "follower_id", "following_id")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(UserFollower.schema).delete()
    }
}
