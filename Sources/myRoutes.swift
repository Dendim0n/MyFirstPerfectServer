//
//  Routes.swift
//  Qiming's FirstServer
//
//  Created by 任岐鸣 on 2016/12/6.
//
//

import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

class myRoutes {
    func testRoutes() -> Routes {
        var routes = Routes()
        routes.add(method: .get, uri: "/test", handler: {
            _, response in
            try? response.setBody(json: ["name":"Qiming"])
            response.completed()
        })
        routes.add(method: .get, uri: "/", handler: {
            request, response in
            print("request")
            response.setHeader(.contentType, value: "text/html")
            response.appendBody(string: "<html><title>Hello, world!</title><body>Welcome to the ofo database!</body></html>")
            response.completed()
        })
        return routes
    }
    //
    //    func loginRoutes() -> Routes {
    //        var routes = Routes()
    //        routes.add(method: .get, uri: "/login", handler: {
    //            request, response in
    //            if let name = request.param(name: "username") {
    //                if let password = request.param(name: "password") {
    //                    try? response.setBody(json: ["username" : name, "password": password])
    //                    let result = (true,0)
    //                    var code = 0
    //                    if result.0 {
    //                        code = 0
    //                    } else {
    //                        code = 1
    //                    }
    //                    try? response.setBody(json: ["code" : code,"msg":result.1])
    //                } else {
    //                    try? response.setBody(json: ["code":"1","msg":"no password"])
    //                }
    //            } else {
    //                try? response.setBody(json: ["code":"1","msg":"no username"])
    //            }
    //            response.completed()
    //        })
    //        return routes
    //    }
    
    func save() -> Routes {
        var routes = Routes()
        routes.add(method: .post, uri: "/save", handler: {
            request, response in
            
            if let code = request.param(name: "code") {
                if let password = request.param(name: "password") {
                    
                    let queryResult = ofoDatabase.sharedInstance.savePassword(code: code, password: password)
                    
                    try? response.setBody(json: ["code":ReturnCode.systemError,"msg" : queryResult.1])
                    
                } else {
                    try? response.setBody(json: ["code":ReturnCode.inputError,"msg":"no password input"])
                }
            } else {
                try? response.setBody(json: ["code":ReturnCode.inputError,"msg":"no code input"])
            }
            response.completed()
        })
        return routes
    }
    
    func get() -> Routes {
        var routes = Routes()
        routes.add(method: .post, uri: "/get", handler: {
            request, response in
            
            if let code = request.param(name: "code") {
                
                let queryResult = ofoDatabase.sharedInstance.getPassword(code: code)
                var code = ReturnCode.noError
                if !queryResult.0 {
                    code = ReturnCode.systemError
                }
                try? response.setBody(json: ["code":code,"msg" :"" ,"password":queryResult.1])
                
            } else {
                try? response.setBody(json: ["code":ReturnCode.inputError,"msg":"no code input"])
            }
            response.completed()
        })
        return routes
        
    }
    
    func saveMultiple() -> Routes {
        var routes = Routes()
        routes.add(method: .post, uri: "/saveMultiple", handler: {
            request, response in
            for param in request.postParams {
                let decoded = try? param.0.jsonDecode() as? [String:String]
                if decoded != nil {
                    for (key,value) in decoded!! {
                        _ = ofoDatabase.sharedInstance.savePassword(code: key, password: value)
                    }
                }
                try? response.setBody(json: ["code":ReturnCode.noError,"msg":"Add Complete"])
                
                response.completed()
            }
        })
        return routes
    }
}
