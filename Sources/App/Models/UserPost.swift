import Fluent
import Vapor

final class UserPost: Model, Content {
    static let schema = "user_posts"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "text")
    var text: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @OptionalField(key: "image")
    var image: String?
    
    @Siblings(through: PostLike.self, from: \.$userPost, to: \.$user)
    public var likes: [User]
    
    init() { }

    init(id: UUID? = nil,
         userID: User.IDValue,
         text: String,
         createdAt: Date? = nil,
         updatedAt: Date? = nil,
         image: String? = nil) {
        self.id = id
        self.$user.id = userID
        self.text = text
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.image = image
    }
}

// MARK: - DTO

extension UserPost {
    struct Create: Content {
        var text: String
    }
}

extension UserPost {
    struct PublicRepresentation: Content {
        var id: UUID
        var userId: UUID
        var text: String
        var createdAt: Date
        var updatedAt: Date
        var image: String?
        var likes: [PostLikeRepresentation]
    }
    
    func publicRepresentation(likes: [User]) throws -> PublicRepresentation {
        guard let id = self.id,
              let createdAt = self.createdAt,
              let updatedAt = self.updatedAt else {
            throw Abort(.internalServerError)
        }
        
        let likes: [PostLikeRepresentation] = likes.compactMap {
            guard let userId = $0.id else { return nil }
            return PostLikeRepresentation(postId: id, userId: userId)
        }
        
        return PublicRepresentation(id: id,
                                    userId: self.$user.id,
                                    text: self.text,
                                    createdAt: createdAt,
                                    updatedAt: updatedAt,
                                    image: image,
                                    likes: likes)
    }
}
