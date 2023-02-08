import Fluent

struct CreatePostLike: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(PostLike.schema)
            .id()
            .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
            .field("post_id", .uuid, .required, .references(UserPost.schema, "id", onDelete: .cascade))
            .unique(on: "user_id", "post_id")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(PostLike.schema).delete()
    }
}
