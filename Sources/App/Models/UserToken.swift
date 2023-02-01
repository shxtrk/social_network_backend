import Fluent
import Vapor

final class UserToken: Model, Content {
    static let schema = "user_tokens"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "value")
    var value: String

    @Parent(key: "user_id")
    var user: User

    init() { }

    init(id: UUID? = nil,
         value: String,
         userID: User.IDValue) {
        self.id = id
        self.value = value
        self.$user.id = userID
    }
}

extension User {
    func generateToken() throws -> UserToken {
        try .init(
            value: [UInt8].random(count: 16).base64,
            userID: self.requireID()
        )
    }
}

// MARK: - DTO

extension UserToken {
    struct PrivateRepresentation: Content {
        let userId: UUID
        let token: String
    }
    
    var privateRepresentation: PrivateRepresentation {
        PrivateRepresentation(userId: self.$user.id, token: self.value)
    }
}
