/*
interfaces
*/

@interface MTMaterialView : UIView {

}
@end
@interface CCUIModularControlCenterOverlayViewController : UIViewController {
  MTMaterialView* _backgroundView;
}
@property (nonatomic,retain) MTMaterialView * overlayBackgroundView;
@end

@interface SBControlCenterController: NSObject
+(id)sharedInstance;
-(void)presentAnimated:(BOOL)arg1;
@end

@interface SBMainSwitcherViewController: NSObject
+(id)sharedInstance;
-(BOOL)dismissSwitcherNoninteractively;
-(BOOL)toggleSwitcherNoninteractivelyWithSource:(long long)arg1 ;
@end

@interface CCUIControlCenterSystemAgent: NSObject
+(id)sharedInstance;
-(void)lockOrientation;
@end


@interface CCUIScrollView : UIScrollView
@end
CCUIScrollView* ccs;

unsigned long long cols;
bool first = false;
//double speed = 1;
/**

Begin stuff


**/
%hook SBControlCenterController
//remove default cc gesture
-(BOOL)_shouldAllowControlCenterGesture{
  return NO;
}
//if home button is pressed or swipe up, close switcher
-(BOOL)isPresentedOrDismissing{
    [[%c(SBMainSwitcherViewController) sharedInstance] dismissSwitcherNoninteractively];
    return %orig;
}
%end
//show cc when opening app switcher
%hook SBAppSwitcherPageView
-(void)setVisible:(BOOL)arg1{
  if(arg1){
    [[%c(SBControlCenterController) sharedInstance] presentAnimated:YES];
  }
}
%end

//hide status bar on CC
%hook CCUIOverlayStatusBarPresentationProvider
- (void)_addHeaderContentTransformAnimationToBatch:(id)arg1 transitionState:(id)arg2 {
  return;
}
%end

//remove cc blur
%hook CCUIModularControlCenterOverlayViewController
-(void)viewDidLoad {
  %orig;
  MTMaterialView* backgroundView = [self valueForKey:@"_backgroundView"];
  [backgroundView removeFromSuperview];
}
%end

//remove annoying blur in landscape and leaving the switcher
%hook CCUIHeaderPocketView
-(void)setBackgroundAlpha:(double)arg1{
  return;
}
-(void)setContentAlpha:(double)arg1{
  return;
}
-(void)_updateAlpha{
  return;
}
%end
/*
%hook SBFluidSwitcherViewController
-(void)_handleDismissTapGesture:(id)arg1{
  [[%c(SBControlCenterController) sharedInstance] dismissAnimated:NO];
  %orig;
}
%end
*/
%hook SBGridSwitcherPersonality
-(unsigned long long)_numberOfCols{
  cols = %orig;
  return %orig;
}
-(BOOL)shouldInterruptPresentationAndDismiss{
  if(cols == 0){
    [[%c(SBControlCenterController) sharedInstance] presentAnimated:YES];
    //[ccs setContentOffset:CGPointMake(-37,-91) animated:YES];
    return NO;
  }
  return %orig;
}
//render switcher cards a bit to the left, update their positions and CC
-(CGRect)frameForIndex:(unsigned long long)arg1 mode:(long long)arg2{
  if(arg1 == 0){
    //if the first card gets moved, move the CC accordingly, without animation so its instant
     if(UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)){
      [ccs setContentOffset:CGPointMake(310-%orig.origin.x,%orig.origin.y+185) animated:NO];
    }
    else{
      [ccs setContentOffset:CGPointMake(210-%orig.origin.x,%orig.origin.y+180) animated:NO];
    }
  }
  //[ccs setBounces:NO];
  if(arg2 == 2){ //mode 2 - loading card in CC
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
      return CGRectMake(%orig.origin.x-290,%orig.origin.y,1112,834);
    }
    return CGRectMake(%orig.origin.x-290,%orig.origin.y,834,1112);
  }
  return %orig;//mode 3 - loading app
}
//don't make the card disappear if it's still visible, rip memory
-(BOOL)isIndexVisible:(unsigned long long)arg1 ignoreInsertionsAndRemovals:(BOOL)arg2{
  if (arg2 == YES){
    return NO;
  }
  return YES;
}

//fix switcher size
-(CGSize)contentSize{
  return CGSizeMake(%orig.width+290,%orig.height);
}
%end

%hook CCUIModularControlCenterOverlayViewController
-(BOOL)_scrollViewCanAcceptDownwardsPan{
  return YES;//YES makes it so that you can't swipe up cc wtf
}
%end

//move cc pos when cc is alone
%hook CCUIScrollView
-(void)setContentInset:(UIEdgeInsets)arg1 {
  ccs = self;
  %orig;

  if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)){
    arg1 = UIEdgeInsetsMake(47,25,0,0);
    %orig;
  }
  else if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
    arg1 = UIEdgeInsetsMake(114,35,0,0);
    %orig;
  }
}
%end

%hook CCUIAnimation
-(double)speed{
  return 1000;
}
/*
-(double)delay{
  return 0;
}
*/
%end
