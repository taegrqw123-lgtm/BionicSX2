// BionicSX2 Metal View Controller Implementation
// AUDIT REFERENCE: Section 4.3

#import "MetalViewController.h"
#include "iOSVMManager.h"

@interface MetalViewController ()
@end

@implementation MetalViewController

+ (Class)layerClass {
    return [CAMetalLayer class];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self setupMetal];
    [self setupDisplayLink];
}

- (void)setupMetal {
    self.metalLayer = (CAMetalLayer *)self.view.layer;
    self.metalDevice = MTLCreateSystemDefaultDevice();
    self.metalLayer.device = self.metalDevice;
    self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    self.metalLayer.framebufferOnly = YES;
    self.metalLayer.frame = self.view.bounds;

    self.commandQueue = [self.metalDevice newCommandQueue];
}

- (void)setupDisplayLink {
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(renderFrame)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)renderFrame {
    // C++ MetalRenderer handles actual rendering
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.metalLayer.frame = self.view.bounds;
    CGFloat scale = self.view.contentScaleFactor;
    self.metalLayer.drawableSize = CGSizeMake(
        self.view.bounds.size.width * scale,
        self.view.bounds.size.height * scale);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Start emulation
    iOSVMManager::StartVM(nullptr);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.displayLink invalidate];
    iOSVMManager::StopVM();
}

- (void)dealloc {
    [self.displayLink invalidate];
}

@end
