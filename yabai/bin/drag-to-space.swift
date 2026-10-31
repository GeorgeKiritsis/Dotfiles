// Moves the window under (x, y) to desktop N without SIP/scripting-addition:
// holds the window by its title bar and triggers the native ctrl+N "Switch to Desktop N".
import CoreGraphics
import Foundation

let args = CommandLine.arguments
guard args.count == 4, let space = Int(args[1]), let x = Double(args[2]), let y = Double(args[3]) else {
    FileHandle.standardError.write("usage: drag-to-space <space> <x> <y>\n".data(using: .utf8)!)
    exit(1)
}
let keycodes: [Int: CGKeyCode] = [1: 18, 2: 19, 3: 20, 4: 21, 5: 23, 6: 22, 7: 26, 8: 28, 9: 25]
guard let key = keycodes[space] else { exit(1) }

let src = CGEventSource(stateID: .combinedSessionState)
func post(_ e: CGEvent?, _ flags: CGEventFlags = []) {
    guard let e = e else { return }
    e.flags = flags
    e.post(tap: .cghidEventTap)
}
func ms(_ n: UInt32) { usleep(n * 1000) }

let p = CGPoint(x: x, y: y)
let p2 = CGPoint(x: x + 1, y: y)
post(CGEvent(mouseEventSource: src, mouseType: .mouseMoved, mouseCursorPosition: p, mouseButton: .left))
ms(30)
post(CGEvent(mouseEventSource: src, mouseType: .leftMouseDown, mouseCursorPosition: p, mouseButton: .left))
ms(60)
post(CGEvent(mouseEventSource: src, mouseType: .leftMouseDragged, mouseCursorPosition: p2, mouseButton: .left))
ms(60)
post(CGEvent(keyboardEventSource: src, virtualKey: key, keyDown: true), .maskControl)
post(CGEvent(keyboardEventSource: src, virtualKey: key, keyDown: false), .maskControl)
ms(450)
post(CGEvent(mouseEventSource: src, mouseType: .leftMouseUp, mouseCursorPosition: p2, mouseButton: .left))
