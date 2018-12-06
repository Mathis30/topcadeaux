import Vapor
import Foundation
import FluentSQLite

struct ProductCategory: Content, SQLiteUUIDModel, Migration {
    var id: UUID?
    var name: String
    var votes: Int
    var price: String
    var ageCategoryID: Int
}
