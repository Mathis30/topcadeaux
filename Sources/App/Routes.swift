import Vapor
import Fluent
import FluentSQLite

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // "It works" page
    router.get { req -> Future<View> in
        return try AgeCategory.query(on: req).all().flatMap(to:View.self) { ageCategories in
            struct Context: Codable {
               let ageCategories: [AgeCategory]
            }
            if ageCategories.count == 9 {
                return try req.view().render("index", Context(ageCategories: ageCategories))
            } else {
                let category1 = AgeCategory(id:nil, name:"0 - 3").save(on: req)
                let category2 = AgeCategory(id:nil, name:"4 - 6").save(on: req)
                let category3 = AgeCategory(id:nil, name:"7 - 10").save(on: req)
                let category4 = AgeCategory(id:nil, name:"11 - 14").save(on: req)
                let category5 = AgeCategory(id:nil, name:"15 - 17").save(on: req)
                let category6 = AgeCategory(id:nil, name:"18 - 24").save(on: req)
                let category7 = AgeCategory(id:nil, name:"25 - 34").save(on: req)
                let category8 = AgeCategory(id:nil, name:"35 - 64").save(on: req)
                let category9 = AgeCategory(id:nil, name:"65 - 120").save(on: req)
                return try req.view().render("index", Context(ageCategories: ageCategories))
            }
        }
    }
    router.get("category", Int.parameter) { req -> Future<View> in
        let categoryID = try req.parameters.next(Int.self)
        return try AgeCategory.query(on: req).filter(\.id == categoryID).first().flatMap(to:View.self) { ageCategory in
            guard let ageCategory = ageCategory else {
                throw Abort(.notFound)
            }
            struct Context: Codable {
                var ageCategory: AgeCategory
                var gifts: [ProductCategory]
            }
            return try ProductCategory.query(on: req).filter(\.ageCategoryID == categoryID).all().flatMap(to: View.self) { gifts in
                return try req.view().render("category", Context(ageCategory: ageCategory, gifts: gifts))
            }
        }
    }
    router.post("add", "gift") { req -> Future<Response> in
        let giftName: String = try req.content.syncGet(at: "name")
        let giftPrice: String = try req.content.syncGet(at: "tarif")
        let giftAgeCategory: Int = try req.content.syncGet(at: "ageCategory")
        let gift = ProductCategory(id:nil, name:giftName, votes:1, price:giftPrice, ageCategoryID:giftAgeCategory)
        return gift.save(on: req).map(to: Response.self) { _ in
            return req.redirect(to: "/category/\(giftAgeCategory)")
        }
    }
}
