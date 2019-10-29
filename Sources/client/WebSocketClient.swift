import Foundation

// BEGIN: From Starscream library
//WebSocketClient is setup to be dependency injection for testing
public enum CloseCode : UInt16 {
    case normal                 = 1000
    case goingAway              = 1001
    case protocolError          = 1002
    case protocolUnhandledType  = 1003
    // 1004 reserved.
    case noStatusReceived       = 1005
    //1006 reserved.
    case encoding               = 1007
    case policyViolated         = 1008
    case messageTooBig          = 1009
}

public struct WSError: Error {
    public let type: ErrorType
    public let message: String
    public let code: Int
}

public protocol WebSocketClient: class {
    var delegate: WebSocketDelegate? {get set}
    var pongDelegate: WebSocketPongDelegate? {get set}
    var disableSSLCertValidation: Bool {get set}
    var overrideTrustHostname: Bool {get set}
    var desiredTrustHostname: String? {get set}
    var sslClientCertificate: SSLClientCertificate? {get set}
    #if os(Linux)
    #else
    var security: SSLTrustValidator? {get set}
    var enabledSSLCipherSuites: [SSLCipherSuite]? {get set}
    #endif
    var isConnected: Bool {get}

    func connect()
    func disconnect(forceTimeout: TimeInterval?, closeCode: UInt16)
    func write(string: String, completion: (() -> ())?)
    func write(data: Data, completion: (() -> ())?)
    func write(ping: Data, completion: (() -> ())?)
    func write(pong: Data, completion: (() -> ())?)
}

//implements some of the base behaviors
extension WebSocketClient {
    public func write(string: String) {
        write(string: string, completion: nil)
    }

    public func write(data: Data) {
        write(data: data, completion: nil)
    }

    public func write(ping: Data) {
        write(ping: ping, completion: nil)
    }

    public func write(pong: Data) {
        write(pong: pong, completion: nil)
    }

    public func disconnect() {
        disconnect(forceTimeout: nil, closeCode: CloseCode.normal.rawValue)
    }
}

//standard delegate you should use
public protocol WebSocketDelegate: class {
    func websocketDidConnect(socket: WebSocketClient)
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?)
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String)
    func websocketDidReceiveData(socket: WebSocketClient, data: Data)
}

//got pongs
public protocol WebSocketPongDelegate: class {
    func websocketDidReceivePong(socket: WebSocketClient, data: Data?)
}

// END

class WebSocketClientVapor: WebSocketClient {
    var delegate: WebSocketDelegate?
    var pongDelegate: WebSocketPongDelegate?
    var disableSSLCertValidation: Bool {
        get { return underlyingDisableSSLCertValidation }
        set(value) { underlyingDisableSSLCertValidation = value }
    }
    var underlyingDisableSSLCertValidation: Bool!
    var overrideTrustHostname: Bool {
        get { return underlyingOverrideTrustHostname }
        set(value) { underlyingOverrideTrustHostname = value }
    }
    var underlyingOverrideTrustHostname: Bool!
    var desiredTrustHostname: String?
    var sslClientCertificate: SSLClientCertificate?
    var security: SSLTrustValidator?
    var enabledSSLCipherSuites: [SSLCipherSuite]?
    var isConnected: Bool {
        get { return underlyingIsConnected }
        set(value) { underlyingIsConnected = value }
    }
    var underlyingIsConnected: Bool!

    //MARK: - connect

    var connectCallsCount = 0
    var connectCalled: Bool {
        return connectCallsCount > 0
    }
    var connectClosure: (() -> Void)?

    func connect() {
        connectCallsCount += 1
        connectClosure?()
    }

    //MARK: - disconnect

    var disconnectForceTimeoutCloseCodeCallsCount = 0
    var disconnectForceTimeoutCloseCodeCalled: Bool {
        return disconnectForceTimeoutCloseCodeCallsCount > 0
    }
    var disconnectForceTimeoutCloseCodeReceivedArguments: (forceTimeout: TimeInterval?, closeCode: UInt16)?
    var disconnectForceTimeoutCloseCodeClosure: ((TimeInterval?, UInt16) -> Void)?

    func disconnect(forceTimeout: TimeInterval?, closeCode: UInt16) {
        disconnectForceTimeoutCloseCodeCallsCount += 1
        disconnectForceTimeoutCloseCodeReceivedArguments = (forceTimeout: forceTimeout, closeCode: closeCode)
        disconnectForceTimeoutCloseCodeClosure?(forceTimeout, closeCode)
    }

    //MARK: - write

    var writeStringCompletionCallsCount = 0
    var writeStringCompletionCalled: Bool {
        return writeStringCompletionCallsCount > 0
    }
    var writeStringCompletionReceivedArguments: (string: String, completion: (() -> ())?)?
    var writeStringCompletionClosure: ((String, (() -> ())?) -> Void)?

    func write(string: String, completion: (() -> ())?) {
        writeStringCompletionCallsCount += 1
        writeStringCompletionReceivedArguments = (string: string, completion: completion)
        writeStringCompletionClosure?(string, completion)
    }

    //MARK: - write

    var writeDataCompletionCallsCount = 0
    var writeDataCompletionCalled: Bool {
        return writeDataCompletionCallsCount > 0
    }
    var writeDataCompletionReceivedArguments: (data: Data, completion: (() -> ())?)?
    var writeDataCompletionClosure: ((Data, (() -> ())?) -> Void)?

    func write(data: Data, completion: (() -> ())?) {
        writeDataCompletionCallsCount += 1
        writeDataCompletionReceivedArguments = (data: data, completion: completion)
        writeDataCompletionClosure?(data, completion)
    }

    //MARK: - write

    var writePingCompletionCallsCount = 0
    var writePingCompletionCalled: Bool {
        return writePingCompletionCallsCount > 0
    }
    var writePingCompletionReceivedArguments: (ping: Data, completion: (() -> ())?)?
    var writePingCompletionClosure: ((Data, (() -> ())?) -> Void)?

    func write(ping: Data, completion: (() -> ())?) {
        writePingCompletionCallsCount += 1
        writePingCompletionReceivedArguments = (ping: ping, completion: completion)
        writePingCompletionClosure?(ping, completion)
    }

    //MARK: - write

    var writePongCompletionCallsCount = 0
    var writePongCompletionCalled: Bool {
        return writePongCompletionCallsCount > 0
    }
    var writePongCompletionReceivedArguments: (pong: Data, completion: (() -> ())?)?
    var writePongCompletionClosure: ((Data, (() -> ())?) -> Void)?

    func write(pong: Data, completion: (() -> ())?) {
        writePongCompletionCallsCount += 1
        writePongCompletionReceivedArguments = (pong: pong, completion: completion)
        writePongCompletionClosure?(pong, completion)
    }

}
