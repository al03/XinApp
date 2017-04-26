//
//  Connet.swift
//  Xin
//
//  Created by Albert on 21/04/2017.
//  Copyright © 2017 Albert Mao. All rights reserved.
//

import Foundation
import Starscream

class Connect: WebSocketDelegate {
    
    var _URL:String
    
    let socket:WebSocket
    
    init(_ aURL:String) {
        _URL = aURL
        
        socket = WebSocket(url: URL(string:aURL)!)
        
        socket.delegate = self
    }
    
    open func connet (){
        socket.connect()
    }
    
    open func disconnect() {
        if socket.isConnected {
            socket.disconnect()
        }
    }
    
    open func send(_ msg:String){
        socket.write(string: msg)
    }
    
    func websocketDidConnect(socket: WebSocket) {
        print("websocket is connected")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("websocket is Disconnect")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("DidReceiveMessage \(text)")
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("websocket ReceiveData")
    }
    
}
