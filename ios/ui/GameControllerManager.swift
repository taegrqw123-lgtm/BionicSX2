// PORTED FROM: PCSX2 macOS SDL input — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 8.3
// STATUS: NEW — GCController discovery and PS2 pad mapping

// Audit Sec 8.3: GameController.framework replaces SDL3/IOKit HID input
// Audit Sec 8.3: GCExtendedGamepad provides standard controls
// Audit Sec 8.3: Supports up to 4 simultaneous controllers

import GameController
import Foundation

class GameControllerManager {
    static let shared = GameControllerManager()

    private var connectedControllers: [GCController] = []
    private let maxControllers = 4  // Audit Sec 8.3: Matches PS2 hardware

    private init() {}

    func startMonitoring() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerConnected),
            name: .GCControllerDidConnect,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerDisconnected),
            name: .GCControllerDidDisconnect,
            object: nil)

        // Start discovery
        GCController.startWirelessControllerDiscovery {}

        // Register already-connected controllers
        for controller in GCController.controllers() {
            registerController(controller)
        }
    }

    func stopMonitoring() {
        NotificationCenter.default.removeObserver(self)
        GCController.stopWirelessControllerDiscovery()
    }

    @objc func controllerConnected(_ notification: Notification) {
        guard let controller = notification.object as? GCController else { return }
        if connectedControllers.count < maxControllers {
            registerController(controller)
        }
    }

    @objc func controllerDisconnected(_ notification: Notification) {
        guard let controller = notification.object as? GCController else { return }
        unregisterController(controller)
    }

    private func registerController(_ controller: GCController) {
        guard let gamepad = controller.extendedGamepad else { return }
        connectedControllers.append(controller)

        let playerIndex = connectedControllers.count - 1
        controller.playerIndex = GCControllerPlayerIndex(rawValue: playerIndex) ?? .index1

        // Audit Sec 2.7: Map GCController buttons → PS2 pad layout
        // Pad::StartPoll/Poll/EndPoll interface

        // Face buttons
        gamepad.buttonA.valueChangedHandler = { _, _, pressed in
            self.setPadButton(playerIndex, button: 0, pressed: pressed) // Cross
        }
        gamepad.buttonB.valueChangedHandler = { _, _, pressed in
            self.setPadButton(playerIndex, button: 1, pressed: pressed) // Circle
        }
        gamepad.buttonX.valueChangedHandler = { _, _, pressed in
            self.setPadButton(playerIndex, button: 2, pressed: pressed) // Square
        }
        gamepad.buttonY.valueChangedHandler = { _, _, pressed in
            self.setPadButton(playerIndex, button: 3, pressed: pressed) // Triangle
        }

        // Shoulder buttons
        gamepad.leftShoulder.valueChangedHandler = { _, _, pressed in
            self.setPadButton(playerIndex, button: 4, pressed: pressed) // L1
        }
        gamepad.rightShoulder.valueChangedHandler = { _, _, pressed in
            self.setPadButton(playerIndex, button: 5, pressed: pressed) // R1
        }
        gamepad.leftTrigger.valueChangedHandler = { _, _, pressed in
            self.setPadButton(playerIndex, button: 6, pressed: pressed) // L2
        }
        gamepad.rightTrigger.valueChangedHandler = { _, _, pressed in
            self.setPadButton(playerIndex, button: 7, pressed: pressed) // R2
        }

        // D-pad
        gamepad.dpad.valueChangedHandler = { _, xValue, yValue in
            self.setPadAxis(playerIndex, axis: 0, x: xValue, y: yValue) // D-pad
        }

        // Analog sticks
        gamepad.leftThumbstick.valueChangedHandler = { _, xValue, yValue in
            self.setPadAxis(playerIndex, axis: 1, x: xValue, y: yValue) // Left stick
        }
        gamepad.rightThumbstick.valueChangedHandler = { _, xValue, yValue in
            self.setPadAxis(playerIndex, axis: 2, x: xValue, y: yValue) // Right stick
        }

        // Menu buttons
        gamepad.buttonOptions?.valueChangedHandler = { _, _, pressed in
            self.setPadButton(playerIndex, button: 8, pressed: pressed) // Select
        }
        gamepad.buttonMenu.valueChangedHandler = { _, _, pressed in
            self.setPadButton(playerIndex, button: 9, pressed: pressed) // Start
        }

        print("[BionicSX2] Controller connected: \(controller.vendorName ?? "Unknown") at player \(playerIndex)")
    }

    private func unregisterController(_ controller: GCController) {
        if let index = connectedControllers.firstIndex(of: controller) {
            self.clearPadState(index)
            connectedControllers.remove(at: index)
        }
    }

    // Bridge to C++ pad emulation
    private func setPadButton(_ pad: Int, button: Int, pressed: Bool) {
        bridgeSetPadButton(Int32(pad), Int32(button), pressed)
    }

    private func setPadAxis(_ pad: Int, axis: Int, x: Float, y: Float) {
        bridgeSetPadAxis(Int32(pad), Int32(axis), x, y)
    }

    private func clearPadState(_ pad: Int) {
        bridgeClearPadState(Int32(pad))
    }
}

// C++ bridge functions
@_silgen_name("bridgeSetPadButton")
func bridgeSetPadButton(_ pad: Int32, _ button: Int32, _ pressed: Bool)

@_silgen_name("bridgeSetPadAxis")
func bridgeSetPadAxis(_ pad: Int32, _ axis: Int32, _ x: Float, _ y: Float)

@_silgen_name("bridgeClearPadState")
func bridgeClearPadState(_ pad: Int32)
