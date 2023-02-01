import Fluent
import Vapor

struct UserPostController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userPosts = routes.grouped("users").grouped(":userID").grouped("posts")
        userPosts.get(use: getAll)
        
        let tokenProtectedUserPosts = userPosts.grouped(UserToken.authenticator())
        tokenProtectedUserPosts.post(use: create)
        tokenProtectedUserPosts.group(":postID") { userPost in
            userPost.grouped("upload_image").post(use: uploadImage)
            userPost.delete(use: delete)
        }
    }
}

extension UserPostController {
    func getAll(req: Request) async throws -> [UserPost.PublicRepresentation] {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return try await user.$posts.get(on: req.db).compactMap { $0.publicRepresentation }
    }
}

extension UserPostController {
    func create(req: Request) async throws -> UserPost.PublicRepresentation {
        let userId = try req.auth.require(User.self).requireID()
        guard userId == req.parameters.get("userID") else {
            throw Abort(.unauthorized)
        }
        let create = try req.content.decode(UserPost.Create.self)
        let userPost = UserPost(userID: userId, text: create.text)
        try await userPost.save(on: req.db)
        guard let response = userPost.publicRepresentation else {
            throw Abort(.notFound)
        }
        return response
    }
    
    func uploadImage(req: Request) async throws -> UserPost.PublicRepresentation {
        let userId = try req.auth.require(User.self).requireID()
        guard userId == req.parameters.get("userID") else {
            throw Abort(.unauthorized)
        }
        
        guard let userPost = try await UserPost.find(req.parameters.get("postID"), on: req.db),
              userPost.$user.id == userId else {
            throw Abort(.notFound)
        }
        
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
        
        guard let response = userPost.publicRepresentation else {
            throw Abort(.notFound)
        }
        return response
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        let userId = try req.auth.require(User.self).requireID()
        guard userId == req.parameters.get("userID") else {
            return .unauthorized
        }
        guard let userPost = try await UserPost.find(req.parameters.get("postID"), on: req.db),
              userPost.$user.id == userId else {
            throw Abort(.notFound)
        }
        if let currentImage = userPost.image {
            try FileManager.default.removeItem(atPath: req.application.directory.workingDirectory + currentImage)
        }
        try await userPost.delete(on: req.db)
        return .noContent
    }
}
