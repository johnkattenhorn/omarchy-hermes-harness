import QtQuick
import QtTest
import "../.." as Harness

TestCase {
  name: "StatusState"
  Harness.StatusState { id: state }

  Component { id: freshState; Harness.StatusState {} }

  function test_initialState() {
    var fresh = createTemporaryObject(freshState, this)
    verify(!fresh.statusReady)
    verify(!fresh.canLaunchLocally)
  }

  function init() { state.begin() }

  function test_delayedFirstRefresh() {
    verify(!state.canLaunchLocally)
    state.receive('{"remote":false}')
    verify(!state.canLaunchLocally)
    state.finish(0)
    verify(state.canLaunchLocally)
  }

  function test_failedCommandAfterValidOutput() {
    state.receive('{"remote":false}')
    state.finish(7)
    verify(!state.statusReady)
    verify(!state.canLaunchLocally)
  }

  function test_exitBeforeOutput() {
    state.finish(0)
    verify(!state.canLaunchLocally)
    state.receive('{"remote":false}')
    verify(state.canLaunchLocally)
  }

  function test_failedParse_data() {
    return [{tag:"garbage",raw:"broken"}, {tag:"array",raw:"[]"},
            {tag:"missing mode",raw:"{}"}, {tag:"string mode",raw:'{"remote":"false"}'}]
  }

  function test_failedParse(data) {
    state.receive(data.raw)
    state.finish(0)
    verify(!state.canLaunchLocally)
  }

  function test_failureAfterLocalSuccess_data() {
    return [{tag:"parse failure",raw:"broken",code:0},
            {tag:"command failure",raw:'{"remote":false}',code:7}]
  }

  function test_failureAfterLocalSuccess(data) {
    state.receive('{"remote":false}')
    state.finish(0)
    verify(state.canLaunchLocally)
    state.begin()
    state.finish(data.code)
    state.receive(data.raw)
    verify(!state.statusReady)
    verify(!state.canLaunchLocally)
  }

  function test_remoteAndRefresh() {
    state.receive('{"remote":true}')
    state.finish(0)
    verify(state.statusReady)
    verify(!state.canLaunchLocally)
    state.begin()
    state.receive('{"remote":false}')
    state.finish(0)
    verify(state.canLaunchLocally)
    state.begin()
    verify(!state.canLaunchLocally)
  }
}
