import GRDB
import SharedModels

extension Note: FetchableRecord, PersistableRecord {
    enum Columns: String, ColumnExpression {
        case id, caption, location, date
    }
}
