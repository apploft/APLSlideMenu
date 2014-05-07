//  Created by Tobias Conradi on 18.12.12.
//  Copyright (c) 2012 apploft GmbH. All rights reserved.
//

#import "APLSlideMenuViewController.h"

NSString *APLSlideMenuWillShowNotification = @"APLSlideMenuWillShowNotificationInternal";
NSString *APLSlideMenuDidShowNotification = @"APLSlideMenuDidShowNotificationInternal";
NSString *APLSlideMenuWillHideNotification = @"APLSlideMenuWillHideNotificationInternal";
NSString *APLSlideMenuDidHideNotification = @"APLSlideMenuDidHideNotificationInternal";


static NSTimeInterval kAPLSlideMenuDefaultAnimationDuration = 0.25;
static CGFloat kAPLSlideMenuDefaultMenuWidth = 260.0;
static NSTimeInterval kAPLSlideMenuDefaultBounceDuration = 0.2;
static CGFloat kAPLSlideMenuFirstOffset = 4.0;


@interface APLSlideMenuViewController() <UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIGestureRecognizer *dragGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *hideTapGestureRecognizer;
@property (nonatomic, assign) CGFloat dragContentStartX;
@property (nonatomic, assign) BOOL keyboardVisible;
@property (nonatomic, assign, getter = isMenuViewVisible) BOOL menuViewVisible;
@property (nonatomic, assign) UIView *contentContainerView;
@property (nonatomic, assign, getter = isDisplayMenuSideBySide) BOOL displayMenuSideBySide;
@property (nonatomic, strong, readwrite) UIViewController *activeMenuViewController;

@end


@implementation APLSlideMenuViewController

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void) commonInit {
    _animationDuration  = kAPLSlideMenuDefaultAnimationDuration;
    _menuWidth          = kAPLSlideMenuDefaultMenuWidth;
    self.gestureSupport = APLSlideMenuGestureSupportBasic;
    
    _useShadow          = YES;
    _keyboardVisible    = NO;
    _bouncing           = NO;
    _tapOnContentViewToHideMenu = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (id) init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)viewDidLoad {    
    [super viewDidLoad];
    
    //Create GestureRecognizers for NavigationView
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragGestureRecognizerDrag:)];
    panGR.delegate = self;
    panGR.minimumNumberOfTouches = 1;
    panGR.maximumNumberOfTouches = 1;
    self.dragGestureRecognizer = panGR;
    [self.view addGestureRecognizer:panGR];
    
    UIView *contentContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    contentContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.contentContainerView = contentContainer;
    [self.view addSubview:contentContainer];
    
    if (self.useShadow) {
        [self addShadowToView:contentContainer];    
    }
}

- (void)viewWillAppear:(BOOL)animated  {
    [super viewWillAppear:animated];
    
    // Correct shadow size
    if (self.useShadow) {
        UIView *currentView = self.contentViewController.view;
        currentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:currentView.bounds].CGPath;
    }
    
    if (!self.presentedViewController) {
        [self displayMenuSideBySideIfNeededForOrientation:[UIApplication sharedApplication].statusBarOrientation];
    }

}

#pragma mark - Interface rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (self.contentViewController != nil) ? [[self getTopContentViewController] shouldAutorotateToInterfaceOrientation:toInterfaceOrientation] : YES;
}

- (BOOL)shouldAutorotate {
    return (self.contentViewController != nil) ? [[self getTopContentViewController] shouldAutorotate] : YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return (self.contentViewController != nil) ? [[self getTopContentViewController] supportedInterfaceOrientations] : UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [UIView animateWithDuration:duration animations:^{
        [self displayMenuSideBySideIfNeededForOrientation:toInterfaceOrientation];
    }];
}

- (void)displayMenuSideBySideIfNeededForOrientation:(UIInterfaceOrientation)orientation {
    BOOL displayMenuSideBySide = self.isShowMenuInLandscape && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) && UIInterfaceOrientationIsLandscape(orientation);
    
    CGFloat offsetX = displayMenuSideBySide? [self menuAbsoluteWidth] : 0.;
    CGRect frame = self.contentContainerView.frame;
    frame.origin.x = offsetX;
    frame.size.width = self.view.bounds.size.width - offsetX;
    self.contentContainerView.frame = frame;
    
    self.contentContainerView.clipsToBounds = displayMenuSideBySide;
    self.displayMenuSideBySide = displayMenuSideBySide;
}

#pragma mark - status bar style

- (UIViewController*)childViewControllerForStatusBarStyle {
    return self.isMenuViewVisible ? self.activeMenuViewController : self.contentViewController;
}

#pragma mark - Properties

-(void)setMenuViewVisible:(BOOL)menuViewVisible {
    _menuViewVisible = menuViewVisible;
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (CGFloat)menuAbsoluteWidth {
    return (self.menuWidth >= 0.0 && self.menuWidth <= 1.0) ? roundf(self.menuWidth * self.view.bounds.size.width) : self.menuWidth;
}

- (UITapGestureRecognizer*)hideTapGestureRecognizer {
    if (_hideTapGestureRecognizer == nil) {
        _hideTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeTapGestureRecognizerFired:)];
        _hideTapGestureRecognizer.delegate = self;
        _hideTapGestureRecognizer.delaysTouchesBegan = YES;
        _hideTapGestureRecognizer.delaysTouchesEnded = YES;
    }
    return _hideTapGestureRecognizer;
}

- (void)setContentViewController:(UIViewController *)contentViewController {
    [self setContentViewController:contentViewController animated:NO];
}

- (void)setLeftMenuViewController:(UIViewController *)menuViewController {
    
    if (_leftMenuViewController) {
        [_leftMenuViewController willMoveToParentViewController:nil];
        [_leftMenuViewController.view removeFromSuperview];
        [_leftMenuViewController removeFromParentViewController];
    }
    
    _leftMenuViewController = menuViewController;
    if (menuViewController) {
        UIView *menuView    = menuViewController.view;
        CGRect menuFrame = self.view.bounds;
        menuFrame.size.width = self.menuAbsoluteWidth + kAPLSlideMenuFirstOffset;
        
        menuView.frame = menuFrame;
        
        [self addChildViewController:menuViewController];
        [self.view insertSubview:menuView atIndex:0];
        
        [menuViewController didMoveToParentViewController:self];
    }
}

- (void)setRightMenuViewController:(UIViewController *)menuViewController {
    
    if (_rightMenuViewController) {
        [_rightMenuViewController willMoveToParentViewController:nil];
        [_rightMenuViewController.view removeFromSuperview];
        [_rightMenuViewController removeFromParentViewController];
    }
    
    _rightMenuViewController = menuViewController;
    if (menuViewController) {
        UIView *menuView    = menuViewController.view;
        CGRect menuFrame = self.view.bounds;
        menuFrame.size.width = self.menuAbsoluteWidth + kAPLSlideMenuFirstOffset;
        menuFrame.origin.x = self.view.bounds.size.width - menuFrame.size.width;
        
        menuView.frame = menuFrame;
        
        [self addChildViewController:menuViewController];
        [self.view insertSubview:menuView atIndex:0];
        
        [menuViewController didMoveToParentViewController:self];
    }
}

- (void)setGestureSupport:(APLSlideMenuGestureSupportType)gestureSupport {
    _gestureSupport = gestureSupport;
    self.dragGestureRecognizer.enabled = gestureSupport != APLSlideMenuGestureSupportNone;
}

#pragma mark - Menu view



- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated {
    
    if (_contentViewController) {
        [_contentViewController willMoveToParentViewController:nil];
        [_contentViewController.view removeFromSuperview];
        [_contentViewController removeFromParentViewController];
    }
    _contentViewController = contentViewController;
     
    if ([contentViewController isKindOfClass:[UINavigationController class]]) {
        ((UINavigationController*)contentViewController).delegate = self;
    }
    
    if (!contentViewController) {
        return;
    }

    [self addChildViewController:contentViewController];
    contentViewController.view.frame = self.contentContainerView.bounds;
    contentViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    CGRect currentFrame     = self.view.bounds;
    currentFrame.origin.x   = currentFrame.size.width;
    self.contentContainerView.frame = currentFrame;
    [self.contentContainerView addSubview:contentViewController.view];
    
    if (self.isMenuViewVisible) {
        currentFrame.origin.x = [self menuAbsoluteWidth];
    }
    else {
        currentFrame.origin.x = 0;
    }
    
    void (^animationBlock)()   = ^(){
        self.contentContainerView.frame = currentFrame;
    };
    void (^completionBlock)(BOOL) = ^(BOOL finished){
        [contentViewController didMoveToParentViewController:self];
    };
    
    if (animated) {
        [UIView animateWithDuration:kAPLSlideMenuDefaultAnimationDuration animations:animationBlock
                         completion:completionBlock];
    } else {
        animationBlock();
        completionBlock(YES);
    }

}

- (void) dismissContentViewController {
    [_contentViewController willMoveToParentViewController:nil];
    [_contentViewController.view removeFromSuperview];
    [_contentViewController removeFromParentViewController];
    _contentViewController = nil;
    
    // Reset visibility because the content view controller should be moved if setContentViewController is called.
    self.menuViewVisible = NO;
}


- (UIViewController*)getTopContentViewController {
    if ([self.contentViewController isKindOfClass:[UINavigationController class]]) {
        return ((UINavigationController*)self.contentViewController).topViewController;
    }
    return self.contentViewController;
}

- (void)setUseShadow:(BOOL)useIt {
    _useShadow = useIt;
    if (_useShadow) {
        [self addShadowToView:self.contentContainerView];
    } else {
        [self removeShadowFromView:self.contentContainerView];
    }
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // hack to trigger rotation to supported orientation in case this is not the topViewController
    if ([[navigationController viewControllers] count] < 2)
        return;
    
    UIViewController *vanillaViewController = [UIViewController new];
    [self presentViewController:vanillaViewController animated:NO completion:nil];
    [vanillaViewController dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Screen setup

- (void)addShadowToView:(UIView*)aView {
    aView.clipsToBounds = NO;
    aView.layer.shadowPath = [UIBezierPath bezierPathWithRect:aView.bounds].CGPath;
    aView.layer.shadowRadius = 10;
    aView.layer.shadowOpacity = 0.75;
    aView.layer.shadowOffset = CGSizeMake(0., 0.);
    aView.layer.shadowColor = [UIColor blackColor].CGColor;
}

- (void)removeShadowFromView:(UIView*)aView {
    aView.clipsToBounds = YES;
}

#pragma mark - MenuHandling

- (void) dragGestureRecognizerDrag:(UIPanGestureRecognizer*)sender {
    if (self.keyboardVisible || self.isDisplayMenuSideBySide)
        return;
    
    CGPoint translation = [sender translationInView:self.view];
    CGFloat xTranslation = translation.x;
    CGFloat flickVelocitiy = 3.0;
    
    UIGestureRecognizerState state = sender.state;
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            self.dragContentStartX = self.contentContainerView.frame.origin.x;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (self.gestureSupport == APLSlideMenuGestureSupportDrag) {
                UIView *aView       = self.contentContainerView;
                CGRect contentFrame = aView.frame;
                
                // Correct position
                CGFloat newStartX  = self.dragContentStartX;
                newStartX += xTranslation;
                
                CGFloat endX = (self.menuWidth >= 0.0 && self.menuWidth <= 1.0) ? roundf(self.menuWidth*contentFrame.size.width) : self.menuWidth;
                
                newStartX = MIN(MAX(self.rightMenuViewController ? -endX : 0., newStartX), self.leftMenuViewController ? endX : 0.);
                if (newStartX < 0) {
                    [self.view sendSubviewToBack:self.leftMenuViewController.view];
                } else {
                    [self.view sendSubviewToBack:self.rightMenuViewController.view];
                }
                
                contentFrame.origin.x = newStartX;                
                aView.frame = contentFrame;
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {            
            if (self.gestureSupport == APLSlideMenuGestureSupportBasic) {
                if (xTranslation > 0.0) {
                    if (self.leftMenuViewController && !self.isMenuViewVisible) {
                        [self showLeftMenu:YES];
                    } else {
                        [self hideMenu:YES];
                    }
                } else if (xTranslation < 0.0) {
                    if (self.rightMenuViewController && !self.isMenuViewVisible) {
                        [self showRightMenu:YES];
                    } else {
                        [self hideMenu:YES];
                    }
                }
            } else if (self.gestureSupport == APLSlideMenuGestureSupportDrag) {
                UIView *aView = self.contentContainerView;
                CGRect contentFrame = [aView frame];
                CGFloat currentX    = contentFrame.origin.x;
                
                if (((0. < currentX) && (flickVelocitiy < [sender velocityInView:self.contentContainerView].x)) ||
                    ((currentX < 0.) && ([sender velocityInView:self.contentContainerView].x < -flickVelocitiy))) {
                    if (xTranslation > 0.0) {
                        if (self.leftMenuViewController && !self.isMenuViewVisible) {
                            [self showLeftMenu:YES];
                        } else {
                            [self hideMenu:YES];
                        }
                    } else if (xTranslation < 0.0) {
                        if (self.rightMenuViewController && !self.isMenuViewVisible) {
                            [self showRightMenu:YES];
                        } else {
                            [self hideMenu:YES];
                        }
                    }
                } else {
                    CGFloat endX = (self.menuWidth >= 0.0 && self.menuWidth <= 1.0) ? roundf(self.menuWidth*contentFrame.size.width) : self.menuWidth;
                    
                    if (self.rightMenuViewController && !self.isMenuViewVisible && (currentX < -endX)) {
                        [self showRightMenu:YES];
                    } else if (self.leftMenuViewController && !self.isMenuViewVisible && (endX < currentX)) {
                        [self showLeftMenu:YES];
                    } else {
                        [self hideMenu:YES];
                    }
                }
            }
            // Reset drag content start x
            self.dragContentStartX = 0.0;
            break;
        }            
        default:
            break;
    }
}

#pragma mark - Helper methods

-(void)notifyWillShowMenu {
    [[NSNotificationCenter defaultCenter] postNotificationName:APLSlideMenuWillShowNotification object:self];
}

-(void)notifyDidShowMenu {
    [[NSNotificationCenter defaultCenter] postNotificationName:APLSlideMenuDidShowNotification object:self];
}

-(void)notifyWillHideMenu {
     [[NSNotificationCenter defaultCenter] postNotificationName:APLSlideMenuWillHideNotification object:self];
}

-(void)notifyDidHideMenu {
     [[NSNotificationCenter defaultCenter] postNotificationName:APLSlideMenuDidHideNotification object:self];
}

- (void)showLeftMenu:(BOOL)animated {
    [self.view sendSubviewToBack:self.rightMenuViewController.view];
    [self showMenu:self.leftMenuViewController animated:animated];
}

- (void)showRightMenu:(BOOL)animated {
    [self.view sendSubviewToBack:self.leftMenuViewController.view];
    [self showMenu:self.rightMenuViewController animated:animated];
}

- (void)showMenu:(UIViewController*)viewController animated:(BOOL)animated {
    if (self.isDisplayMenuSideBySide) return;
    
    CGFloat direction = (viewController == self.leftMenuViewController) ? 1. : -1.;
    
    void(^showMenuCompletionBlock)(BOOL) = ^(BOOL finished) {
        self.menuViewVisible = YES;
        self.activeMenuViewController = viewController;
        if (self.tapOnContentViewToHideMenu) {
            [self.contentContainerView addGestureRecognizer:self.hideTapGestureRecognizer];
            self.contentViewController.view.userInteractionEnabled = NO;
        }
        if (self.slideDelegate && [self.slideDelegate respondsToSelector:@selector(didShowMenu:)]) {
            [self.slideDelegate didShowMenu:self];
        }
        [self notifyDidShowMenu];
    };
    
    void(^showBouncingBlock)() = ^{
        __block CGRect contentFrame = [self.contentContainerView frame];
        __block CGFloat endx = direction * ((self.menuWidth >= 0.0 && self.menuWidth <= 1.0) ? roundf(self.menuWidth*contentFrame.size.width) : self.menuWidth);
        
        contentFrame.origin.x = endx + direction * kAPLSlideMenuFirstOffset;
        
        [UIView animateWithDuration:kAPLSlideMenuDefaultBounceDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.contentContainerView.frame = contentFrame;
                         }
                         completion:^(BOOL finished) {
                             contentFrame.origin.x = endx;
                             [UIView  animateWithDuration:kAPLSlideMenuDefaultBounceDuration
                                                    delay:0.0
                                                  options:UIViewAnimationOptionCurveEaseInOut
                                               animations:^{
                                                   self.contentContainerView.frame = contentFrame;
                                               }
                                               completion:showMenuCompletionBlock];
                         }];
    };
    
    void(^showMenuBlock)() = ^{
        CGRect contentFrame = [self.contentContainerView frame];
        contentFrame.origin.x = direction * ((self.menuWidth >= 0.0 && self.menuWidth <= 1.0) ? roundf(self.menuWidth*contentFrame.size.width) : self.menuWidth);
        self.contentContainerView.frame = contentFrame;
    };
    
    if (self.slideDelegate && [self.slideDelegate respondsToSelector:@selector(willShowMenu:)]) {
        [self.slideDelegate willShowMenu:self];
    }
    [self notifyWillShowMenu];
    
    if (animated) {
        if (self.isBouncing) {
            showBouncingBlock();
        } else {
            [UIView animateWithDuration:self.animationDuration animations:showMenuBlock completion:showMenuCompletionBlock];
        }
    } else {
        showMenuBlock();
        showMenuCompletionBlock(YES);
    }
}

- (void)hideMenu:(BOOL)animated {
    if (self.isDisplayMenuSideBySide) return;
    
    CGFloat direction = (self.activeMenuViewController == self.leftMenuViewController) ? 1. : -1.;
        
    void (^hideMenuCompletionBlock)(BOOL) = ^(BOOL finished) {
        self.menuViewVisible = NO;
        if (self.tapOnContentViewToHideMenu) {
            [self.contentContainerView removeGestureRecognizer:self.hideTapGestureRecognizer];
            self.contentViewController.view.userInteractionEnabled = YES;
        }
        
        if (self.slideDelegate && [self.slideDelegate respondsToSelector:@selector(didHideMenu:)]) {
            [self.slideDelegate didHideMenu:self];
        }
        [self notifyDidHideMenu];
    };
    
    void(^hideBouncingBlock)() = ^{
        __block CGRect contentFrame = [self.contentContainerView frame];
        
        contentFrame.origin.x = -1. * direction * kAPLSlideMenuFirstOffset;
        [UIView animateWithDuration:kAPLSlideMenuDefaultBounceDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.contentContainerView.frame = contentFrame;
                         }
                         completion:^(BOOL finished) {
                             contentFrame.origin.x = 0.0;
                             [UIView  animateWithDuration:kAPLSlideMenuDefaultBounceDuration
                                                    delay:0.0
                                                  options:UIViewAnimationOptionCurveEaseInOut
                                               animations:^{
                                                   self.contentContainerView.frame = contentFrame;
                                               }
                                               completion:hideMenuCompletionBlock];
                         }];
    };
    
    void(^hideMenuBlock)() = ^{
        CGRect contentFrame = [self.contentContainerView frame];
        contentFrame.origin.x = 0.0;
        self.contentContainerView.frame = contentFrame;
    };
    
    if (self.slideDelegate && [self.slideDelegate respondsToSelector:@selector(willHideMenu:)]) {
        [self.slideDelegate willHideMenu:self];
    }
    [self notifyWillHideMenu];
    
    if (animated) {
        if (self.isBouncing) {
            hideBouncingBlock();
        } else {
            [UIView animateWithDuration:self.animationDuration animations:hideMenuBlock completion:hideMenuCompletionBlock];
        }
    } else {
        hideMenuBlock();
        hideMenuCompletionBlock(YES);
    }
}

-(void) switchLeftMenu:(BOOL) animated {
    if (self.isMenuViewVisible) {
        [self hideMenu:animated];
    } else {
        [self showLeftMenu:animated];
    }
}

-(void) switchRightMenu:(BOOL) animated {
    if (self.isMenuViewVisible) {
        [self hideMenu:animated];
    } else {
        [self showRightMenu:animated];
    }
}

- (void) keyboardWillShow:(NSNotification*)notification {
    self.keyboardVisible = YES;
}

- (void) keyboardDidHide:(NSNotification*)notification {
    self.keyboardVisible = NO;
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    // prevent recognizing touches on the slider
    if ([touch.view isKindOfClass:[UISlider class]]) {
        return NO;
    }
    return YES;
}

- (IBAction)closeTapGestureRecognizerFired:(UIGestureRecognizer*)sender {
    [self hideMenu:YES];
}

@end

//----------------------------------------------

@implementation UIViewController (APLSlideMenuViewController)

- (APLSlideMenuViewController*) slideMenuController {
    UIViewController *currentViewController = self;
    while ((currentViewController = currentViewController.parentViewController)) {
        if ([currentViewController isKindOfClass:[APLSlideMenuViewController class]]) {
            return (APLSlideMenuViewController*) currentViewController;
        }
    }
    return nil;
}

@end
