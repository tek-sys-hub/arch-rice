pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property bool isConnected: socketLoader.item ? socketLoader.item.connected : false
    readonly property Socket clientSocket: socketLoader.item

    Loader {
        id: socketLoader
        active: true
        sourceComponent: Component {
            Socket {
                id: innerSocket
                connected: true
                path: "/tmp/cherry-shell.sock"

                parser: SplitParser {
                    onRead: message => {
                        try {
                            let data = JSON.parse(message);
                            root.messageReceived(data.type, data.payload);
                        } catch (e) {
                            console.warn("SocketService: JSON parse error:", e);
                        }
                    }
                }

                onError: (err) => {
                    console.warn("SocketService: Socket error:", err);
                    root.scheduleReconnect();
                }

                onConnectionStateChanged: {
                    if (!connected) {
                        console.log("SocketService: Lost connection to daemon, retrying...");
                        root.scheduleReconnect();
                    } else {
                        console.log("SocketService: Connected to Cherry Daemon");
                        reconnectTimer.stop();
                        root.connected();
                    }
                }
            }
        }
    }

    function scheduleReconnect() {
        if (!reconnectTimer.running) {
            reconnectTimer.start();
        }
    }

    // ── Reconnect logic ──────────────────────────────────────────
    Timer {
        id: reconnectTimer
        interval: 1000
        repeat: true
        running: false
        onTriggered: {
            if (!root.isConnected) {
                // Re-create the Socket QObject to clear any stuck QLocalSocket C++ state
                socketLoader.active = false;
                recreateTimer.restart();
            } else {
                stop();
            }
        }
    }

    Timer {
        id: recreateTimer
        interval: 80
        repeat: false
        onTriggered: {
            socketLoader.active = true;
        }
    }

    // ── Signals ──────────────────────────────────────────────────
    signal messageReceived(string type, var payload)
    signal connected

    // ── API ──────────────────────────────────────────────────────
    function sendCommand(module, action, payload) {
        if (!root.isConnected || !socketLoader.item) {
            console.warn("SocketService: Cannot send — not connected");
            return;
        }
        let msg = JSON.stringify({
            module: module,
            action: action,
            payload: payload ?? {}
        }) + "
";
        socketLoader.item.write(msg);
        socketLoader.item.flush();
    }
}
