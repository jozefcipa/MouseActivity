import Cocoa
import ApplicationServices

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem!
    var jiggleTimer: Timer?
    let screenWidth: CGFloat = NSScreen.main?.frame.width ?? 1440
    let screenHeight: CGFloat = NSScreen.main?.frame.height ?? 900
    let moveDuration: TimeInterval = 1.0
    let stepInterval: TimeInterval = 0.01
    let jiggleInterval: TimeInterval = 5.0
    var isJiggling = false

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupMenuBar()
    }

    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "🖱️"

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Start moving", action: #selector(startJiggling), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Stop moving", action: #selector(stopJiggling), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApp.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    @objc func startJiggling() {
        if isJiggling { return }

        isJiggling = true
        statusItem.button?.title = "🖱️✅"

        jiggleTimer = Timer.scheduledTimer(withTimeInterval: jiggleInterval, repeats: true) { _ in
            self.jiggleOnce()
        }
    }

    @objc func stopJiggling() {
        jiggleTimer?.invalidate()
        jiggleTimer = nil
        isJiggling = false
        statusItem.button?.title = "🖱️"

    }

    func jiggleOnce() {
        let current = getCurrentMouseLocation()
        let target = getRandomPoint()
        smoothMove(from: current, to: target, duration: moveDuration)
    }

    func getCurrentMouseLocation() -> CGPoint {
        let event = CGEvent(source: nil)
        return event?.location ?? .zero
    }

    func getRandomPoint() -> CGPoint {
        let x = CGFloat.random(in: 0..<screenWidth)
        let y = CGFloat.random(in: 0..<screenHeight)
        return CGPoint(x: x, y: y)
    }

    func smoothMove(from start: CGPoint, to end: CGPoint, duration: TimeInterval) {
        let steps = Int(duration / stepInterval)
        for i in 0...steps {
            let t = Double(i) / Double(steps)
            let x = start.x + (end.x - start.x) * t
            let y = start.y + (end.y - start.y) * t
            CGWarpMouseCursorPosition(CGPoint(x: x, y: y))
            usleep(useconds_t(stepInterval * 1_000_000))
        }
    }
}
