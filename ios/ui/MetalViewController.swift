// PORTED FROM: PCSX2 macOS GSDeviceMTL surface — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 4.3
// STATUS: NEW — UIViewController hosting CAMetalLayer

// Audit Sec 4.3: UIView/CAMetalLayer replaces NSView/CAMetalLayer
// Audit Sec 4.3: Handles view lifecycle, resize, display link

import UIKit
import Metal
import QuartzCore

class MetalViewController: UIViewController {
    var metalLayer: CAMetalLayer!
    var metalDevice: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var displayLink: CADisplayLink!
    let gameURL: URL

    init(gameURL: URL) {
        self.gameURL = gameURL
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Audit Sec 4.3: UIView layer is CAMetalLayer
    override class var layerClass: AnyClass {
        return CAMetalLayer.self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        setupMetal()
        setupDisplayLink()
        startEmulation()
    }

    func setupMetal() {
        metalLayer = view.layer as? CAMetalLayer
        metalDevice = MTLCreateSystemDefaultDevice()
        metalLayer.device = metalDevice
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.bounds

        commandQueue = metalDevice.makeCommandQueue()

        // Link CAMetalLayer to C++ MetalRenderer via Obj-C bridge
        let viewPtr = Unmanaged.passUnretained(view).toOpaque()
        let layerPtr = Unmanaged.passUnretained(metalLayer as AnyObject).toOpaque()
        setMetalSurface(viewPtr, layerPtr)
    }

    func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(renderFrame))
        displayLink.add(to: .main, forMode: .common)
    }

    @objc func renderFrame() {
        // Called by display link each frame
        // C++ MetalRenderer handles actual rendering
        drawMetalFrame()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        metalLayer.frame = view.bounds
        metalLayer.drawableSize = CGSize(
            width: view.bounds.width * view.contentScaleFactor,
            height: view.bounds.height * view.contentScaleFactor)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        displayLink?.invalidate()
        stopEmulation()
    }

    func startEmulation() {
        let isoPath = gameURL.path
        // Bridge to C++ iOSVMManager::StartVM
        startVM(isoPath)
    }

    func stopEmulation() {
        stopVM()
    }

    deinit {
        displayLink?.invalidate()
    }
}

// C++ bridge functions declared in Obj-C bridge header
@_silgen_name("setMetalSurface")
func setMetalSurface(_ viewPtr: UnsafeMutableRawPointer, _ layerPtr: UnsafeMutableRawPointer)

@_silgen_name("startVM")
func startVM(_ isoPath: UnsafePointer<CChar>?)

@_silgen_name("stopVM")
func stopVM()

@_silgen_name("drawMetalFrame")
func drawMetalFrame()
