import Fluent

struct CreateUserPost: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(UserPost.schema)
            .id()
            .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
            .field("text", .string, .required)
            .field("created_at", .date)
            .field("updated_at", .date)
            .field("image", .string)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(UserPost.schema).delete()
    }
}
