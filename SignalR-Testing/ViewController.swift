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
    
    private let serverUrl = URL(string: "https://figo-api.ask.vet/FigoPetOwnerHub/")
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
            .withAutoReconnect()
            .withHubConnectionDelegate(delegate: self.chatHubConnectionDelegate!)
            .withHttpConnectionOptions(configureHttpOptions: { (options) in
                options.accessTokenProvider = { "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJGSUdPIiwiZXhwIjoyNTM0MDIzMDA4MDAsImlzcyI6Imh0dHBzOi8vbG9jYWxob3N0IiwiYXVkIjoiaHR0cHM6Ly9sb2NhbGhvc3QifQ.SysvET6OPaYF12rTYp252r4C0E7ZYcCSsJ51auLEL80" }
                options.skipNegotiation = true
            })
            .build()
        
        self.chatHubConnection!.on(method: "JoinSession") { (responseObject) in
            print("### JoinSession: \(responseObject)")
        }
        self.chatHubConnection!.start()
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
        let intakeObject = AskVetIntakeObject(figoPetId: "some string", question: "another string", neutered: false)
        
        chatHubConnection!.invoke(method: "JoinSession", intakeObject, invocationDidComplete: { (response) in
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
