import QtQml

QtObject {
  property var status: ({ installed: false, version: "", gatewayState: "unknown", activeModel: "", currentSessionId: "", currentSessionTitle: "", hermesNodeAvailable: false, nodesOnline: 0, nodesTotal: 0, nodes: {}, remote: false, remoteStale: false })
  property bool statusReady: false
  property string lastError: ""
  readonly property bool canLaunchLocally: statusReady && status.remote === false
  property bool outputReceived: false
  property bool processExited: false
  property int processExitCode: -1
  property var pendingStatus: null

  function begin() {
    statusReady = false
    outputReceived = false
    processExited = false
    processExitCode = -1
    pendingStatus = null
  }

  function receive(raw) {
    outputReceived = true
    try {
      var parsed = JSON.parse(String(raw || ""))
      if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)
          || typeof parsed.remote !== "boolean") throw new Error("invalid status")
      pendingStatus = parsed
    } catch (error) {
      pendingStatus = null
      lastError = "Status refresh failed"
    }
    apply()
  }

  function finish(exitCode) {
    processExited = true
    processExitCode = exitCode
    apply()
  }

  function apply() {
    if (!outputReceived || !processExited) return
    statusReady = false
    if (processExitCode !== 0) {
      lastError = "Status command exited " + processExitCode
    } else if (pendingStatus !== null) {
      status = pendingStatus
      statusReady = true
      lastError = ""
    }
  }
}
