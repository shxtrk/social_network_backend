import Fluent
import Vapor

struct UserPostController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let tokenProtected = routes.grouped(UserToken.authenticator())
        
        let userPosts = tokenProtected.grouped("users")
            .grouped(":userID")
            .grouped("posts")
        userPosts.post(use: create)
        userPosts.get(use: getAll)
        
        let userPost = userPosts.grouped(":postID")
        userPost.get(use: getUserPost)
        userPost.grouped("upload_image").post(use: uploadImage)
        userPost.delete(use: delete)
    }
}

extension UserPostController {
    func getAll(req: Request) async throws -> [UserPost.PublicRepresentation] {
        try req.auth.require(User.self)
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        let userId = try user.requireID()
        let posts = try await UserPost.query(on: req.db).with(\.$likes).filter(\.$user.$id == userId).all()
        return try posts.map { try $0.publicRepresentation(likes: $0.likes) }
    }
    
    func getUserPost(req: Request) async throws -> UserPost.PublicRepresentation {
        try req.auth.require(User.self)
        guard let userPost = try await UserPost.find(req.parameters.get("postID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return try userPost.publicRepresentation(likes: userPost.likes)
    }
    
    func create(req: Request) async throws -> UserPost.PublicRepresentation {
        let userId = try req.auth.require(User.self).requireID()
        try userId.authorize(to: req.parameters.get("userID"))
        
        let create = try req.content.decode(UserPost.Create.self)
        let userPost = UserPost(userID: userId, text: create.text)
        try await userPost.save(on: req.db)
        return try userPost.publicRepresentation(likes: [])
    }
    
    func uploadImage(req: Request) async throws -> UserPost.PublicRepresentation {
        let userId = try req.auth.require(User.self).requireID()
        try userId.authorize(to: req.parameters.get("userID"))
        
        guard let userPost = try await UserPost.find(req.parameters.get("postID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try userPost.$user.id.authorize(to: userId)
        
        let file = try req.content.decode(File.self)
        guard file.filename == req.parameters.get("postID") else {
            throw Abort(.notAcceptable)
        }
        
        let filename = String(UUID()) + "-" + file.filename
        let path = req.application.directory.workingDirectory + filename
        try await req.fileio.writeFile(file.data, at: path)
        
        if let currentImage = userPost.image {
            try FileManager.default.removeItem(atPath: req.application.directory.workingDirectory + currentImage)
        }
        userPost.image = filename
        
        try await userPost.save(on: req.db)
        return try userPost.publicRepresentation(likes: userPost.likes)
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        let userId = try req.auth.require(User.self).requireID()
        try userId.authorize(to: req.parameters.get("userID"))
        
        guard let userPost = try await UserPost.find(req.parameters.get("postID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try userPost.$user.id.authorize(to: userId)
        
        if let currentImage = userPost.image {
            try FileManager.default.removeItem(atPath: req.application.directory.workingDirectory + currentImage)
        }
        try await userPost.delete(on: req.db)
        return .noContent
    }
}
