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
    
    private let serverUrl = URL(string: "https://figo-api.ask.vet/FigoPetOwnerHub")
    private var chatHubConnection: HubConnection?
    private var chatHubConnectionDelegate: HubConnectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupChatHub()
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
//
//          ### Partner Token
//                options.accessTokenProvider = { "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJGSUdPIiwiZXhwIjoyNTM0MDIzMDA4MDAsImlzcyI6Imh0dHBzOi8vbG9jYWxob3N0IiwiYXVkIjoiaHR0cHM6Ly9sb2NhbGhvc3QifQ.SysvET6OPaYF12rTYp252r4C0E7ZYcCSsJ51auLEL80" }
//
//          ### User token from getLiveVetConfiguration
                
//                options.headers = ["Authorization" : "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiSGFsZXkgSGFsYWsiLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6ImQwMzIxYjYwLTgzMjItNGM0MC04NDNmLTYwMzI2NmQxMzU4YiIsImh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL2VtYWlsYWRkcmVzcyI6ImhhbGV5LmhhbGFrQGdtYWlsLmNvbS54eCIsImh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvcm9sZSI6WyJQZXRPd25lciIsIkZJR09fUEVUX09XTkVSIl0sImV4cCI6MTYxNzkxNTIyNCwiaXNzIjoiaHR0cHM6Ly9sb2NhbGhvc3QiLCJhdWQiOiJodHRwczovL2xvY2FsaG9zdCJ9.GwiPj7fls_0rAUcEdNAvj0s7aOVJUax491y1jmS1-5s"]
                options.accessTokenProvider = { "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiSGFsZXkgSGFsYWsiLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6ImQwMzIxYjYwLTgzMjItNGM0MC04NDNmLTYwMzI2NmQxMzU4YiIsImh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL2VtYWlsYWRkcmVzcyI6ImhhbGV5LmhhbGFrQGdtYWlsLmNvbS54eCIsImh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvcm9sZSI6WyJQZXRPd25lciIsIkZJR09fUEVUX09XTkVSIl0sImV4cCI6MTYxNzkxNTIyNCwiaXNzIjoiaHR0cHM6Ly9sb2NhbGhvc3QiLCJhdWQiOiJodHRwczovL2xvY2FsaG9zdCJ9.GwiPj7fls_0rAUcEdNAvj0s7aOVJUax491y1jmS1-5s" }
                options.skipNegotiation = true
            })
            .build()
        self.chatHubConnection!.start()
        
        let intakeObject = AskVetIntakeObject(figoPetId: "19490370", question: "another string", neutered: false)
        self.chatHubConnection!.on(method: "OnSessionChange") { (response) in
            print("### JoinSession: \(response)")
        }
        self.chatHubConnection!.invoke(method: "JoinSession", intakeObject) { (err) in
            print("### Err: \(err?.localizedDescription)")
        }
        

    }


    // MARK: - ChatHubConnectionDelegate Functions
    fileprivate func connectionDidOpen() {
        print("### SUCCESS: Connection Did Open")
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
        let intakeObject = AskVetIntakeObject(figoPetId: "19490370", question: "another string", neutered: false)
        
        chatHubConnection!.invoke(method: "Post", intakeObject, invocationDidComplete: { (response) in
            print("\n### Invoke Session Call:\n \(String(describing: response))")
        })
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

struct ChatSessionWithPosts: Encodable {
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
