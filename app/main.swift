// Coquille Mac : lance le serveur local et l'affiche dans une fenêtre.
import Cocoa
import WebKit

let bun = "__BUN__", root = "__ROOT__", port = "4117"

final class AppDelegate: NSObject, NSApplicationDelegate, WKNavigationDelegate {
  var window: NSWindow!
  var web: WKWebView!
  let server = Process()

  func applicationDidFinishLaunching(_ note: Notification) {
    server.executableURL = URL(fileURLWithPath: bun)
    server.arguments = ["run", root + "/server.ts"]
    var env = ProcessInfo.processInfo.environment
    env["PORT"] = port
    env["PATH"] = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin" // pour trouver `aws` et `security`
    server.environment = env
    try? server.run() // si le port est déjà pris par une copie en cours, on affiche celle-là

    window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1280, height: 860),
                      styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
    window.title = "Vigie"
    window.titleVisibility = .hidden
    window.titlebarAppearsTransparent = true
    window.backgroundColor = NSColor(red: 0.788, green: 0.875, blue: 0.929, alpha: 1) // le haut du ciel de la page : la barre de titre s'y fond
    window.minSize = NSSize(width: 720, height: 480)
    window.center()
    window.setFrameAutosaveName("Kaoly")
    web = WKWebView(frame: .zero)
    web.navigationDelegate = self
    window.contentView = web
    window.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
    open()
  }

  func open() { web.load(URLRequest(url: URL(string: "http://127.0.0.1:\(port)/")!)) }

  // le serveur met un instant à démarrer : on réessaie tant qu'il ne répond pas
  func webView(_ w: WKWebView, didFailProvisionalNavigation n: WKNavigation!, withError e: Error) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { self.open() }
  }
  func applicationShouldTerminateAfterLastWindowClosed(_ s: NSApplication) -> Bool { true }
  func applicationWillTerminate(_ note: Notification) { if server.isRunning { server.terminate() } }
}

let app = NSApplication.shared
let menu = NSMenu()
let appItem = NSMenuItem(); menu.addItem(appItem)
appItem.submenu = NSMenu()
appItem.submenu!.addItem(withTitle: "Quitter Vigie", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
let editItem = NSMenuItem(); menu.addItem(editItem)
editItem.submenu = NSMenu(title: "Édition") // sans ce menu, impossible de coller la clé Qonto
editItem.submenu!.addItem(withTitle: "Couper", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
editItem.submenu!.addItem(withTitle: "Copier", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
editItem.submenu!.addItem(withTitle: "Coller", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
editItem.submenu!.addItem(withTitle: "Tout sélectionner", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
let viewItem = NSMenuItem(); menu.addItem(viewItem)
viewItem.submenu = NSMenu(title: "Présentation")
viewItem.submenu!.addItem(withTitle: "Recharger", action: #selector(WKWebView.reload(_:)), keyEquivalent: "r")
app.mainMenu = menu
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
