//
//  SqliteController.swift
//  PlurkGit
//
//  Created by Jiawei on 2019/3/15.
//  Copyright © 2019 BrickGit. All rights reserved.
//

import Foundation

open class SqliteController {
    
    private let dbName: String
    private let dbPath: String

    private let dbQueue: DispatchQueue

    public var database: OpaquePointer? = nil

    public init(name: String, appGroup: String? = nil) {
        dbName = name + ".db"
        dbQueue = DispatchQueue(label: "com.plurk.database_\(dbName)")

        let localPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/\(dbName)"

        if let appGroup = appGroup, let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) {
            dbPath = directory.appendingPathComponent(dbName).path

            if !FileManager.default.fileExists(atPath: dbPath, isDirectory: nil) && FileManager.default.fileExists(atPath: localPath, isDirectory: nil) {
                try? FileManager.default.copyItem(atPath: localPath, toPath: dbPath)
                print("try copy item from \(localPath) to \(dbPath)")
            }
        } else {
            dbPath = localPath
        }

        openDatabase()
    }
    
    public var isDatabaseOpen: Bool {
        return database != nil
    }

    private func openDatabase() {
        dbQueue.sync {
            if sqlite3_open_v2(dbPath, &database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX, nil) != SQLITE_OK {
                database = nil
            }
        }
    }

    private func closeDatabase() {
        dbQueue.sync {
            if database != nil {
                sqlite3_close(database)
                database = nil
            }
        }
    }

    public func ensureSchema(executes: [String], version: Int) {
        let oldSchemaVersion = Int(query("PRAGMA user_version")?[0]["user_version"] as? Int64 ?? 0)
        #if DEBUG
        print("🗄 [PDSqliteController] Check Version (database:\(oldSchemaVersion)  now:\(version))")
        #endif
        if oldSchemaVersion != version {
            for e in executes {
                execute(e)
            }
            execute("PRAGMA user_version = \(version)")
        }
    }

    public func resetDatabase() {
        closeDatabase()
        try? FileManager.default.removeItem(atPath: dbPath)
        openDatabase()
    }

    deinit {
        closeDatabase()
    }

    open func query(_ sql: String) -> [[String:Any]]? {
        guard database != nil else { return nil }
        var result = [[String:Any]]()
        dbQueue.sync {
            var statement: OpaquePointer? = nil
            if sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let columns = sqlite3_column_count(statement)
                    var row = [String:Any]()
                    for idx in 0..<columns {
                        if let chars = UnsafePointer<CChar>(sqlite3_column_name(statement, idx)) {
                            let name =  String(cString: chars, encoding: .utf8)!

                            let type = sqlite3_column_type(statement, idx)
                            switch type {
                            case SQLITE_INTEGER:
                                row[name] = sqlite3_column_int64(statement, idx)
                            case SQLITE_FLOAT:
                                row[name] = sqlite3_column_double(statement, idx)
                            case SQLITE_TEXT:
                                if let chars = UnsafePointer<CUnsignedChar>(sqlite3_column_text(statement, idx)) {
                                    row[name] = String(cString: chars)
                                }
                            case SQLITE_BLOB:
                                if let data = sqlite3_column_blob(statement, idx) {
                                    row[name] = Data(bytes: data, count: Int(sqlite3_column_bytes(statement, idx)))
                                }
                            default: break
                            }
                        }
                    }
                    result.append(row)
                }
            }
            sqlite3_finalize(statement)
            statement = nil
        }
        #if DEBUG
        print("🗄 [PDSqliteController] query: \(sql)\n                           result count: \(result.count)")
        #endif
        return result.isEmpty ? nil : result
    }
    
    public struct ExecuteResult {
        public let code: Int32
        public let changes: Int32
        public var ok: Bool {
            return code == SQLITE_DONE
        }
        
        static let unknow = ExecuteResult(code: -1, changes: 0)
    }

    @discardableResult open func execute(_ sql: String, bindValues:[Any?]? = nil) -> ExecuteResult {
        guard database != nil else { return .unknow }
        var code: Int32 = -1
        var changes: Int32 = 0
        dbQueue.sync {
            var statement: OpaquePointer? = nil
            code = sqlite3_prepare_v2(database, sql, -1, &statement, nil)
            if code == SQLITE_OK {
                if let bindValues = bindValues, !bindValues.isEmpty {
                    for (idx, value) in bindValues.enumerated() {
                        switch(value) {
                        case is Int:
                            sqlite3_bind_int64(statement, CInt(idx + 1), Int64(value as! Int))
                        case is Int32:
                            sqlite3_bind_int64(statement, CInt(idx + 1), Int64(value as! Int32))
                        case is Int64:
                            sqlite3_bind_int64(statement, CInt(idx + 1), value as! Int64)
                        case is Bool:
                            sqlite3_bind_int(statement, CInt(idx + 1), value as! Bool ? 1 : 0)
                        case is Float:
                            sqlite3_bind_double(statement, CInt(idx + 1), Double(value as! Float))
                        case is Double:
                            sqlite3_bind_double(statement, CInt(idx + 1), value as! Double)
                        case is String:
                            sqlite3_bind_text(statement, CInt(idx + 1), (value as! NSString).utf8String, -1, nil)
                        case is Date:
                            sqlite3_bind_int64(statement, CInt(idx + 1), Int64((value as! Date).timeIntervalSince1970 * 1000))
                        case is Data:
                            let data = value as! NSData
                            sqlite3_bind_blob(statement, CInt(idx + 1), data.bytes, CInt(data.length), nil)
                        default:
                            sqlite3_bind_null(statement, CInt(idx + 1))
                            break
                        }
                    }
                }
                code = sqlite3_step(statement)
                if code == SQLITE_DONE {
                    if sql.hasPrefix("DELETE") || sql.hasPrefix("UPDATE") {
                        changes = sqlite3_changes(database)
                    }
                }
            }
            sqlite3_finalize(statement)
            statement = nil
        }
        
        let result = ExecuteResult(code: code, changes: changes)
        #if DEBUG
        print("🗄 [PDSqliteController] execute: \(sql)\n                           values: \(bindValues ?? [])  ok: \(result.ok ? "✔️" : "❌") \(result.code)")
        #endif
        return result
    }

    @discardableResult open func insert(_ value: [String: Any?], to table:String) -> ExecuteResult {
        guard database != nil else { return .unknow }
        guard !value.isEmpty else { return .unknow }

        var columns = [String]()
        var values = [String]()
        var bindValues = [Any?]()

        value.forEach { (key, value) in
            columns.append(key)
            values.append("?")
            bindValues.append(value)
        }

        let sql = "INSERT INTO \(table) (\(columns.joined(separator: ", "))) VALUES (\(values.joined(separator: ", ")))"
        return execute(sql, bindValues: bindValues)
    }

    @discardableResult open func update(_ value: [String: Any?], to table:String, where condition: [String: Any]? = nil) -> ExecuteResult {
        guard database != nil else { return .unknow }
        guard !value.isEmpty else { return .unknow }

        var sets = [String]()
        var bindValues = [Any?]()

        value.forEach { (key, value) in
            sets.append("\(key) = ?")
            bindValues.append(value)
        }

        var sql = "UPDATE \(table) SET \(sets.joined(separator: ", "))"

        if let condition = condition, !condition.isEmpty {
            var wheres = [String]()
            condition.forEach { (key, value) in
                wheres.append("\(key) = ?")
                bindValues.append(value)
            }
            sql += " WHERE \(wheres.joined(separator: " and "))"
        }

        return execute(sql, bindValues: bindValues)
    }

    @discardableResult open func upsert(_ value: [String: Any?], to table:String, where condition: [String: Any]) -> ExecuteResult {
        let updateResult = update(value, to: table, where: condition)
        if updateResult.ok && updateResult.changes > 0 {
            return updateResult
        } else {
            return insert(value.merging(condition, uniquingKeysWith: {$1}), to: table)
        }
    }

    @discardableResult open func delete(from table:String, where condition: [String: Any]? = nil) -> ExecuteResult {
        guard database != nil else { return .unknow }

        var bindValues = [Any]()

        var sql = "DELETE FROM \(table)"
        if let condition = condition, !condition.isEmpty {
            var wheres = [String]()
            condition.forEach { (key, value) in
                wheres.append("\(key) = ?")
                bindValues.append(value)
            }
            sql += " WHERE \(wheres.joined(separator: " and "))"
        }

        return execute(sql, bindValues: bindValues)
    }
}

extension SqliteController {
    private static var schemaVersion: Int { return 1 }
    private static var schemaExecutes: [String] {
        return [
            "CREATE TABLE diaries (date DateTime PRIMARY KEY, diary BLOB)",
//            "CREATE INDEX IF NOT EXISTS diary_date ON diary(date)"
            
//            "CREATE TABLE matters (name VARCHAR PRIMARY KEY, type VARCHAR, default VARCHAR)"
        ]
    }

    public static let main: SqliteController = {
        let db = SqliteController(name: "main")
        db.ensureSchema(executes: schemaExecutes, version: schemaVersion)
        return db
    }()
}
