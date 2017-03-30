//
//  Server.swift
//  Xin
//
//  Created by Albert on 29/03/2017.
//  Copyright © 2017 Albert Mao. All rights reserved.
//

import UIKit
import PocketSocket

class Server:NSObject, PSWebSocketServerDelegate {


    static let shared = Server()
    private var socket: PSWebSocketServer
    
    override init() {
        socket = PSWebSocketServer(host: nil, port: 9001)
        super.init()
        socket.delegate = self
    }
    
    func start() {
        socket.start();
    }
    
    func send(_ msg:String)
    {
        socket.send
    }
    
    func serverDidStart(_ server: PSWebSocketServer!) {
        print("start")
    }
    
    func server(_ server: PSWebSocketServer!, webSocket: PSWebSocket!, didFailWithError error: Error!) {
        print("fail:\(error)")
    }
    
    func serverDidStop(_ server: PSWebSocketServer!) {
        print("Stop")
    }
    
    func server(_ server: PSWebSocketServer!, webSocketDidOpen webSocket: PSWebSocket!) {
        
    }
    
    func server(_ server: PSWebSocketServer!, acceptWebSocketWith request: URLRequest!) -> Bool {
        print("request:\(request)")
        
        return true
    }
    
    func server(_ server: PSWebSocketServer!, webSocket: PSWebSocket!, didReceiveMessage message: Any!) {
        print("msg:\(message)")
    }
    
    func server(_ server: PSWebSocketServer!, didFailWithError error: Error!) {
        
    }
    
    func server(_ server: PSWebSocketServer!, webSocket: PSWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        
    }
    
}
