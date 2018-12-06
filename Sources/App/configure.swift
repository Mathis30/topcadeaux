import Leaf
import Vapor
import Fluent
import FluentSQLite

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(LeafProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    /// Use Leaf for rendering views
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self)
    services.register(middlewares)
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
    
    /// Base de données
    let directoryConfig = DirectoryConfig.detect()
    services.register(directoryConfig)
    try services.register(FluentSQLiteProvider())
    let db = try SQLiteDatabase(storage: .file(path: "\(directoryConfig.workDir)topcadeaux.db"))
    var databases = DatabasesConfig()
    databases.add(database: db, as: .sqlite)
    services.register(databases)
    
    var migrationConfig = MigrationConfig()
    migrationConfig.add(model: AgeCategory.self, database: .sqlite)
    migrationConfig.add(model: ProductCategory.self, database: .sqlite)
    services.register(migrationConfig)
}
