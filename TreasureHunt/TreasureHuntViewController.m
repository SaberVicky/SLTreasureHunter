#import "TreasureHuntViewController.h"

#import "TreasureHuntRenderLoop.h"
#import "TreasureHuntRenderer.h"
#import "Masonry.h"

@interface TreasureHuntViewController ()<TreasureHuntRendererDelegate> {
  GVRCardboardView *_cardboardView;
  TreasureHuntRenderer *_treasureHuntRenderer;
  TreasureHuntRenderLoop *_renderLoop;
}

@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, assign) NSInteger count;
@end

@implementation TreasureHuntViewController

- (void)loadView {
    __weak typeof(self) weakself = self;
  _treasureHuntRenderer = [[TreasureHuntRenderer alloc] init];
    _treasureHuntRenderer.successBlock = ^{
        weakself.count++;
        weakself.scoreLabel.text = [NSString stringWithFormat:@"已找到宝藏  %zd个", weakself.count];
    };
  _treasureHuntRenderer.delegate = self;

  _cardboardView = [[GVRCardboardView alloc] initWithFrame:CGRectZero];
  _cardboardView.delegate = _treasureHuntRenderer;
  _cardboardView.autoresizingMask =
      UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    

 // _cardboardView.vrModeEnabled = YES;
    
  // Use double-tap gesture to toggle between VR and magic window mode.
  //UITapGestureRecognizer *doubleTapGesture =
   //   [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTapView:)];
  //doubleTapGesture.numberOfTapsRequired = 2;
  //[_cardboardView addGestureRecognizer:doubleTapGesture];

  self.view = _cardboardView;
    
    self.scoreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.scoreLabel.textColor = [UIColor redColor];
    self.scoreLabel.text = @"已找到宝藏  0个";
    self.scoreLabel.font = [UIFont systemFontOfSize:40];
    [_cardboardView addSubview:self.scoreLabel];
    [self.scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(20);
    }];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Tips" message:@"移动屏幕找到宝藏，将屏幕中心对准宝藏，宝藏颜色变黄后点击获得！" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  _renderLoop = [[TreasureHuntRenderLoop alloc] initWithRenderTarget:_cardboardView
                                                            selector:@selector(render)];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];

  // Invalidate the render loop so that it removes the strong reference to cardboardView.
  [_renderLoop invalidate];
  _renderLoop = nil;
}

- (GVRCardboardView *)getCardboardView {
  return _cardboardView;
}

#pragma mark - TreasureHuntRendererDelegate

- (void)shouldPauseRenderLoop:(BOOL)pause {
  _renderLoop.paused = pause;
}

#pragma mark - Implementation

- (void)didDoubleTapView:(id)sender {
  _cardboardView.vrModeEnabled = !_cardboardView.vrModeEnabled;
}

@end
