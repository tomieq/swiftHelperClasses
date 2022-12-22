//
//  Created by Tomasz on 22/12/2022.
//

import Foundation

enum WebsocketConnectionStatus {
    case connected
    case disconnected
}

class WebsocketClient: NSObject {
    private let logTag = "🦞 WebsocketClient"
    private var webSocket: URLSessionWebSocketTask?
    private var serverUrl: String?
    private var connectionId = -1
    private var pingTimer: Timer?

    var connectionStatus = WebsocketConnectionStatus.disconnected {
        didSet {
            self.connectionUpdate?(self.connectionStatus)
        }
    }

    var connectionUpdate: ((WebsocketConnectionStatus) -> Void)?
    var incomingData: ((String) -> Void)?

    override init() {
        super.init()
        self.setupPingPong()
    }

    func connect(url: String) {
        self.closeSocket()
        self.serverUrl = url
        self.openWebSocket()
    }

    private func setupPingPong() {
        self.pingTimer = Timer(timeInterval: 60, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            guard self.connectionStatus == .connected else {
                return
            }
            AppLogger.log(self.logTag, "Sending ping")
            self.webSocket?.sendPing { error in
                if let error = error {
                    AppLogger.log(self.logTag, "Server responded with error instead of pong: \(error)")
                } else {
                    AppLogger.log(self.logTag, "Received pong")
                }
            }
        }
        RunLoop.main.add(self.pingTimer!, forMode: .default)
    }

    func send(_ text: String) {
        AppLogger.log(self.logTag, "Sending: \(text)")
        self.webSocket?.send(.string(text)) { [weak self] error in
            if let error = error {
                AppLogger.log(self?.logTag, "Error sending command: \(error)")
                self?.connectionStatus = .disconnected
            }
        }
    }

    private func openWebSocket() {
        if let serverUrl = serverUrl, let url = URL(string: serverUrl) {
            AppLogger.log(self.logTag, "Opening websocket connection to \(serverUrl)")
            let request = URLRequest(url: url, timeoutInterval: 8)
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            let webSocket = session.webSocketTask(with: request)
            self.webSocket = webSocket
            self.setupReceiver()
            self.webSocket?.resume()
        } else {
            self.webSocket = nil
            self.connectionStatus = .disconnected
        }
    }

    private func setupReceiver() {
        self.webSocket?.receive(completionHandler: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                AppLogger.log(self.logTag, "Websocket error \(error)")
                self.connectionStatus = .disconnected
            case let .success(webSocketTaskMessage):
                switch webSocketTaskMessage {
                case let .string(text):
                    AppLogger.log(self.logTag, "Received string \(text)")
                    self.incomingData?(text)
                    self.setupReceiver()
                case let .data(data):
                    AppLogger.log(self.logTag, "Received data: \(data)")
                    self.setupReceiver()
                default:
                    AppLogger.log(self.logTag, "Failed. Received unknown data format. Expected String")
                }
            }
        })
    }

    private func closeSocket() {
        self.webSocket?.cancel(with: .goingAway, reason: nil)
        if self.connectionStatus != .disconnected {
            self.connectionStatus = .disconnected
        }
        self.webSocket = nil
    }
}

extension WebsocketClient: URLSessionWebSocketDelegate {
    func urlSession(_: URLSession, webSocketTask _: URLSessionWebSocketTask, didOpenWithProtocol _: String?) {
        AppLogger.log(self.logTag, "Websocket connected.")
        self.connectionStatus = .connected
    }

    func urlSession(_: URLSession, webSocketTask _: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason _: Data?) {
        AppLogger.log(self.logTag, "Websocket closed with code: \(closeCode)")
        self.webSocket = nil
        self.connectionStatus = .disconnected
    }

    func urlSession(_: URLSession, didBecomeInvalidWithError error: Error?) {
        AppLogger.log(self.logTag, "Received error \(error.debugDescription)")
        self.webSocket = nil
        self.connectionStatus = .disconnected
    }
}
