import Foundation


/// Represents order stats over a specific period.
///
public struct OrderStats: Decodable {
    public let date: String
    public let granularity: OrderStatGranularity
    public let quantity: String
    public let fields: [String]
    public let totalGrossSales: Float
    public let totalNetSales: Float
    public let totalOrders: Int
    public let totalProducts: Int
    public let averageGrossSales: Float
    public let averageNetSales: Float
    public let averageOrders: Float
    public let averageProducts: Float
    public let items: [OrderStatsItem]?


    /// The public initializer for order stats.
    ///
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let date = try container.decode(String.self, forKey: .date)
        let granularity = try container.decode(OrderStatGranularity.self, forKey: .unit)
        let quantity = try container.decode(String.self, forKey: .quantity)

        let fields = try container.decode([String].self, forKey: .fields)
        let rawData: [[AnyCodable]] = try container.decode([[AnyCodable]].self, forKey: .data)

        let totalGrossSales = try container.decode(Float.self, forKey: .totalGrossSales)
        let totalNetSales = try container.decode(Float.self, forKey: .totalNetSales)
        let totalOrders = try container.decode(Int.self, forKey: .totalOrders)
        let totalProducts = try container.decode(Int.self, forKey: .totalProducts)

        let averageGrossSales = try container.decode(Float.self, forKey: .averageGrossSales)
        let averageNetSales = try container.decode(Float.self, forKey: .averageNetSales)
        let averageOrders = try container.decode(Float.self, forKey: .averageOrders)
        let averageProducts = try container.decode(Float.self, forKey: .averageProducts)

        let items = rawData.map({ OrderStatsItem(fieldNames: fields, rawData: $0) })

        self.init(date: date, granularity: granularity, quantity: quantity, fields: fields, items: items, totalGrossSales: totalGrossSales, totalNetSales: totalNetSales, totalOrders: totalOrders, totalProducts: totalProducts, averageGrossSales: averageGrossSales, averageNetSales: averageNetSales, averageOrders: averageOrders, averageProducts: averageProducts)
    }


    /// OrderStats struct initializer.
    ///
    public init(date: String, granularity: OrderStatGranularity, quantity: String, fields: [String], items: [OrderStatsItem]?, totalGrossSales: Float, totalNetSales: Float, totalOrders: Int, totalProducts: Int, averageGrossSales: Float, averageNetSales: Float, averageOrders: Float, averageProducts: Float) {
        self.date = date
        self.granularity = granularity
        self.quantity = quantity
        self.fields = fields
        self.totalGrossSales = totalGrossSales
        self.totalNetSales = totalNetSales
        self.totalOrders = totalOrders
        self.totalProducts = totalProducts
        self.averageGrossSales = averageGrossSales
        self.averageNetSales = averageNetSales
        self.averageOrders = averageOrders
        self.averageProducts = averageProducts
        self.items = items
    }
}


/// Defines all of the OrderStats CodingKeys.
///
private extension OrderStats {

    enum CodingKeys: String, CodingKey {
        case date = "date"
        case unit = "unit"
        case quantity = "quantity"
        case fields = "fields"
        case data = "data"
        case totalGrossSales = "total_gross_sales"
        case totalNetSales = "total_net_sales"
        case totalOrders = "total_orders"
        case totalProducts = "total_products"
        case averageGrossSales = "avg_gross_sales"
        case averageNetSales = "avg_net_sales"
        case averageOrders = "avg_orders"
        case averageProducts = "avg_products"
    }
}


// MARK: - Comparable Conformance
//
extension OrderStats: Comparable {
    public static func == (lhs: OrderStats, rhs: OrderStats) -> Bool {
        return lhs.date == rhs.date &&
            lhs.granularity == rhs.granularity &&
            lhs.quantity == rhs.quantity &&
            lhs.fields == rhs.fields &&
            lhs.totalGrossSales == rhs.totalGrossSales &&
            lhs.totalNetSales == rhs.totalNetSales &&
            lhs.totalOrders == rhs.totalOrders &&
            lhs.totalProducts == rhs.totalProducts &&
            lhs.averageGrossSales == rhs.averageGrossSales &&
            lhs.averageNetSales == rhs.averageNetSales &&
            lhs.averageOrders == rhs.averageOrders &&
            lhs.averageProducts == rhs.averageProducts &&
            lhs.items == rhs.items
    }

    public static func < (lhs: OrderStats, rhs: OrderStats) -> Bool {
        return lhs.date < rhs.date ||
            (lhs.date == rhs.date && lhs.quantity < rhs.quantity)
    }
}