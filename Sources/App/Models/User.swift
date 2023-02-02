import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "user_name")
    var userName: String
    
    @Field(key: "email")
    var email: String

    @Field(key: "password_hash")
    var passwordHash: String
    
    @Children(for: \.$user)
    var posts: [UserPost]

    init() { }

    init(id: UUID? = nil,
         userName: String,
         email: String,
         passwordHash: String) {
        self.id = id
        self.userName = userName
        self.email = email
        self.passwordHash = passwordHash
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$email
    static let passwordHashKey = \User.$passwordHash

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}

// MARK: - DTO

extension User {
    struct Create: Content, Validatable {
        var userName: String
        var email: String
        var password: String
        var confirmPassword: String
        
        static func validations(_ validations: inout Validations) {
            validations.add("userName", as: String.self, is: !.empty)
            validations.add("email", as: String.self, is: .email)
            validations.add("password", as: String.self, is: .count(8...))
        }
    }
}

extension User {
    struct Update: Content, Validatable {
        var userName: String?
        var email: String?
        
        static func validations(_ validations: inout Validations) {
            validations.add("userName", as: String?.self, is: .nil || !.empty, required: false)
            validations.add("email", as: String?.self, is: .nil || .email)
        }
    }
}

extension User {
    struct PrivateRepresentation: Content {
        var id: UUID
        var userName: String
        var email: String
    }
    
    func privateRepresentation() throws -> PrivateRepresentation {
        guard let id = self.id else {
            throw Abort(.internalServerError)
        }
        return PrivateRepresentation(id: id, userName: self.userName, email: self.email)
    }
}

extension User {
    struct PublicRepresentation: Content {
        var id: UUID
        var userName: String
    }
    
    func publicRepresentation() throws -> PublicRepresentation {
        guard let id = self.id else {
            throw Abort(.internalServerError)
        }
        return PublicRepresentation(id: id, userName: self.userName)
    }
}
