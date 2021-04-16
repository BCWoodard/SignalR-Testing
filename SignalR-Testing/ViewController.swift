//
//  ViewController.swift
//  SignalR-Testing
//
//  Created by Brad Woodard on 4/8/21.
//

import UIKit
import SwiftSignalRClient

class ViewController: UIViewController {

    @IBOutlet weak var msgTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiSGFsZXkgSGFsYWsiLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6ImQwMzIxYjYwLTgzMjItNGM0MC04NDNmLTYwMzI2NmQxMzU4YiIsImh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL2VtYWlsYWRkcmVzcyI6ImhhbGV5LmhhbGFrQGdtYWlsLmNvbS54eCIsImh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvcm9sZSI6WyJQZXRPd25lciIsIkZJR09fUEVUX09XTkVSIl0sImV4cCI6MTYxODU4ODQ0MCwiaXNzIjoiaHR0cHM6Ly9sb2NhbGhvc3QiLCJhdWQiOiJodHRwczovL2xvY2FsaG9zdCJ9.gHRHKFCmSf8x7pxB1I_AtYZnNlcDEsRtKpjsfDaTnvo"
    private let serverUrl = URL(string: "https://api-figo.ask.vet/FigoPetOwnerHub")
    private var chatHubConnection: HubConnection?
    private var chatHubConnectionDelegate: HubConnectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupChatHub()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.chatHubConnection!.stop()
    }
    
    private func setupChatHub() {
        self.chatHubConnectionDelegate = ChatHubConnectionDelegate(controller: self)
        self.chatHubConnection = HubConnectionBuilder(url: serverUrl!)
            .withLogging(minLogLevel: .debug)
            .withHubConnectionDelegate(delegate: self.chatHubConnectionDelegate!)
            .withHttpConnectionOptions(configureHttpOptions: { (options) in
                options.accessTokenProvider = { self.token }
                options.skipNegotiation = true
            })
            .build()
        
        
        self.chatHubConnection!.on(method: "OnSessionChange") { (response) in
            print("### OnSessionChange: \(response)")
        }
        self.chatHubConnection!.on(method: "OnPostAdded") { (response) in
            // Do something with the response object
            print("### OnPostAdded: \(response)")
        }
        self.chatHubConnection!.on(method: "OnTyping") { (response) in
            // Do something with the response object
            print("### OnTyping: \(response)")
        }
        
        self.chatHubConnection!.start()

    }


    // MARK: - ChatHubConnectionDelegate Functions
    fileprivate func connectionDidOpen() {
        let intakeObject = AskVetIntakeObject(figoPetId: "132013", question: "another string", neutered: false)
        
        chatHubConnection!.invoke(method: "JoinSession", intakeObject) { (err) in
            guard err == nil else {
                print("### JoinSession Error")
                return
            }
            print("### JoinSession SUCCESS")
        }
        
        // Need to invoke using this function. It takes one argument and returns one result
        // self.chatHubConnection?.invoke(method: "JoinSession", intakeObject, resultType: <#T##Decodable.Protocol#>, invocationDidComplete: <#T##(Decodable?, Error?) -> Void#>)
    }

    fileprivate func connectionDidFailToOpen(error: Error) {
        print("### Connection Failed to Open: \(error.localizedDescription)")
    }

    fileprivate func connectionDidClose(error: Error?) {
        print("### Connection Did Close: \(error?.localizedDescription ?? "Nil error description")")
    }

    fileprivate func connectionWillReconnect(error: Error?) {
        print("### Connection Attempting Reconnect: \(error?.localizedDescription ?? "Nil error description")")
    }

    fileprivate func connectionDidReconnect() {
        print("### Connection Did Reconnect")
    }
    
    
    // MARK: - IBAction
    @IBAction func btnSend(_ sender: UIButton) {
//        let FigoPetId = "132013"
//        let Question = "question"
//        let Neutered = false
        let intakeObject = AskVetIntakeObject(figoPetId: "132013", question: "another string", neutered: false)
        
        chatHubConnection!.invoke(method: "JoinSession", intakeObject) { (err) in
            print("### JoinSession: \(err?.localizedDescription ?? "Nil error description")")
        }
//        chatHubConnection!.invoke(method: "JoinSession", intakeObject, invocationDidComplete: { (response) in
//            print("\n### Invoke Session Call:\n \(String(describing: response))")
//        })
    }
}

class ChatHubConnectionDelegate: HubConnectionDelegate {

    weak var controller: ViewController?

    init(controller: ViewController) {
        self.controller = controller
    }

    func connectionDidOpen(hubConnection: HubConnection) {
        controller?.connectionDidOpen()
    }

    func connectionDidFailToOpen(error: Error) {
        controller?.connectionDidFailToOpen(error: error)
    }

    func connectionDidClose(error: Error?) {
        controller?.connectionDidClose(error: error)
    }

    func connectionWillReconnect(error: Error) {
        controller?.connectionWillReconnect(error: error)
    }

    func connectionDidReconnect() {
        controller?.connectionDidReconnect()
    }
}

// MARK: AskVet Objects
struct AskVetIntakeObject: Encodable {
    enum CodingKey: String {
        case figoPetId = "FigoPetId"
        case question = "Question"
        case neutered = "Neutered"
    }
    
    var figoPetId: String?
    var question: String?
    var neutered: Bool? = false
}

struct AskVetChatSessionWithPosts: Encodable {
    enum CodingKey: String {
        case posts = "Posts"
        case session = "Session"
    }
    
    var posts: [AskVetChatPost]?
    var session: AskVetChatSession?
}

struct AskVetChatPost: Encodable {
    
}

struct AskVetChatSession: Encodable {
    
}
