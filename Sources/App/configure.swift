import Fluent
import FluentSQLiteDriver
import Vapor

public func configure(_ app: Application) throws {
    
    app.routes.defaultMaxBodySize = "10mb"
    
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.workingDirectory))
    
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    app.migrations.add(CreateUser())
    app.migrations.add(CreateUserToken())
    app.migrations.add(CreateUserFollower())
    app.migrations.add(CreateUserPost())
    app.migrations.add(CreatePostLike())
    
    // TODO: replace with manual migration
    try app.autoMigrate().wait()
    
    try routes(app)
}
