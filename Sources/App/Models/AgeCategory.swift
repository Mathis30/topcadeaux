import Vapor
import Foundation
import FluentSQLite

struct AgeCategory: Content, SQLiteModel, Migration {
    var id: Int?
    var name: String
}
