
import UIKit

extension PhotoEditorViewController : UIGestureRecognizerDelegate  {
  @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
    if let view = recognizer.view {
      if view is UIImageView {
        //Tap only on visible parts on the image
        if recognizer.state == .began {
          for imageView in subImageViews(view: overlayImageView) {
            let location = recognizer.location(in: imageView)
            let alpha = imageView.alphaAtPoint(location)
            if alpha > 0 {
              imageViewToPan = imageView
              break
            }
          }
        }
        if imageViewToPan != nil {
          moveView(view: imageViewToPan!, recognizer: recognizer)
        }
      } else {
        moveView(view: view, recognizer: recognizer)
      }
    }
  }
  
  /**
   UIPinchGestureRecognizer - Pinching Objects
   If it's a UITextView will make the font bigger so it doen't look pixlated
   */
  @objc func pinchGesture(_ recognizer: UIPinchGestureRecognizer) {
    if let view = recognizer.view {
      if view is UITextView {
        let textView = view as! UITextView
        
        if textView.font!.pointSize * recognizer.scale < 90 {
          let font = UIFont(name: textView.font!.fontName, size: textView.font!.pointSize * recognizer.scale)
          textView.font = font
          let sizeToFit = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width,
                                                       height:CGFloat.greatestFiniteMagnitude))
          textView.bounds.size = CGSize(width: textView.intrinsicContentSize.width,
                                        height: sizeToFit.height)
        } else {
          let sizeToFit = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width,
                                                       height:CGFloat.greatestFiniteMagnitude))
          textView.bounds.size = CGSize(width: textView.intrinsicContentSize.width,
                                        height: sizeToFit.height)
        }
        
        
        textView.setNeedsDisplay()
      } else {
        view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
      }
      recognizer.scale = 1
    }
  }
  
  /**
   UIRotationGestureRecognizer - Rotating Objects
   */
  @objc func rotationGesture(_ recognizer: UIRotationGestureRecognizer) {
    if let view = recognizer.view {
      view.transform = view.transform.rotated(by: recognizer.rotation)
      recognizer.rotation = 0
    }
  }

  @objc func tapGesture(_ recognizer: UITapGestureRecognizer) {
    if let view = recognizer.view {
      if view is UIImageView {
        //Tap only on visible parts on the image
        for imageView in subImageViews(view: overlayImageView) {
          let location = recognizer.location(in: imageView)
          let alpha = imageView.alphaAtPoint(location)
          if alpha > 0 {
            scaleEffect(view: imageView)
            break
          }
        }
      } else {
        scaleEffect(view: view)
      }
    }
    if recognizer.view != activeTextView {
      _ = resignFirstResponder()
    }
  }
  
  /*
   Support Multiple Gesture at the same time
   */
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return false
  }
  
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return false
  }
  
  // to Override Control Center screen edge pan from bottom
  override public var prefersStatusBarHidden: Bool {
    return true
  }
  
  /**
   Scale Effect
   */
  func scaleEffect(view: UIView) {
    view.superview?.bringSubviewToFront(view)
    
    if #available(iOS 10.0, *) {
      let generator = UIImpactFeedbackGenerator(style: .heavy)
      generator.impactOccurred()
    }
    let previouTransform =  view.transform
    UIView.animate(withDuration: 0.2,
                   animations: {
                    view.transform = view.transform.scaledBy(x: 1.2, y: 1.2)
    },
                   completion: { _ in
                    UIView.animate(withDuration: 0.2) {
                      view.transform  = previouTransform
                    }
    })
  }
  
  func moveView(view: UIView, recognizer: UIPanGestureRecognizer)  {
    view.superview?.bringSubviewToFront(view)
    let pointToSuperView = recognizer.location(in: self.view)
    
    view.center = CGPoint(x: view.center.x + recognizer.translation(in: overlayImageView).x,
                          y: view.center.y + recognizer.translation(in: overlayImageView).y)
    
    recognizer.setTranslation(CGPoint.zero, in: overlayImageView)
    
    lastPanPoint = pointToSuperView
    
    if recognizer.state == .ended {
      imageViewToPan = nil
      lastPanPoint = nil
      if !overlayImageView.bounds.contains(view.center) { //Snap the view back to overlayImageView
        UIView.animate(withDuration: 0.3, animations: {
          view.center = self.overlayImageView.center
        })
        
      }
    }
  }
  
  func subImageViews(view: UIView) -> [UIImageView] {
    var imageviews: [UIImageView] = []
    for imageView in view.subviews {
      if imageView is UIImageView {
        imageviews.append(imageView as! UIImageView)
      }
    }
    return imageviews
  }
}
