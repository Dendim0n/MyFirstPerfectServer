//
//  Database.swift
//  Qiming's FirstServer
//
//  Created by 任岐鸣 on 2016/12/6.
//
//

import Foundation
import SQLite

class ofoDatabase {
    
    static let sharedInstance = ofoDatabase()
    
    var dbPath = "ofoDatabase"
    
    var sqlite:SQLite?
    
    init() {
        do {
            sqlite = try SQLite(dbPath)
            createTables()
        } catch {
            print(error)
            closeDB()
        }
    }
    
    func savePassword(code:String,password:String) -> (Bool,String) {
        do {
//            if code.characters.count != 6 || password.characters.count != 4 {
//                return (false,"Invalid Info")
//            }
            
            let insertStatement = "INSERT INTO account VALUES (\(code),\(password))"
            
            let result = getPassword(code: code)
            
            if result.0 && result.1 == password {
                return (false,"Already had")
            } else if result.0 && result.1 != password {
                let updateStatement = "UPDATE account SET password = '\(password)' WHERE code = \(code)"
                try sqlite?.execute(statement: updateStatement)
                return (true,"Password Updated")
            } else {
                try? sqlite?.execute(statement: insertStatement)
                return (true,"Password Saved")
            }
            
        } catch {
            print(error)
            return (false,"System Error")
        }
    }
    
    func getPassword(code:String) -> (Bool,String,Int) {
        do {
            let queryStatement = "SELECT * FROM account"
            
            var passwordFound = false
            var password = "Code Not Found"
            var returnIndex = -1
            
            
            try sqlite?.forEachRow(statement: queryStatement, handleRow: { (stmt, index) in
                if stmt.columnText(position: 0) == code {
                    passwordFound = true
                    password = stmt.columnText(position: 1)
                    returnIndex = index
                }
            })
            return (passwordFound,password,returnIndex)
        } catch {
            print(error)
            return (false,"System Error",-1)
        }
    }
    
    func createTables() {
        do {
            try sqlite?.execute(statement: "CREATE TABLE if not exists account (code TEXT PRIMARY KEY NOT NULL, password TEXT NOT NULL)")
        } catch {
            print(error)
        }
        
    }
    
    func closeDB() {
        sqlite?.close()
    }
}
