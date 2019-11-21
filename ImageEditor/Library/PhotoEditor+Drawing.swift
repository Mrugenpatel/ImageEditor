import UIKit

extension PhotoEditorViewController {
  
  override public func touchesBegan(_ touches: Set<UITouch>,
                                    with event: UIEvent?){
    guard editMode == .drawing else { return }
    swiped = false
    if let touch = touches.first {
      lastPoint = touch.location(in: self.overlayImageView)
    }
  }
  
  override public func touchesMoved(_ touches: Set<UITouch>,
                                    with event: UIEvent?){
    guard editMode == .drawing else { return }
    swiped = true
    if let touch = touches.first {
      let currentPoint = touch.location(in: overlayImageView)
      drawLineFrom(lastPoint, toPoint: currentPoint)
      lastPoint = currentPoint
    }
  }
  
  override public func touchesEnded(_ touches: Set<UITouch>,
                                    with event: UIEvent?){
    guard editMode == .drawing else { return }
    if !swiped {
      // draw a single point
      drawLineFrom(lastPoint, toPoint: lastPoint)
    }
    
  }
  
  func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint) {
    // 1
    let canvasSize = overlayImageView.frame.integral.size
    UIGraphicsBeginImageContextWithOptions(canvasSize, false, 0)
    if let context = UIGraphicsGetCurrentContext() {
      overlayImageView.image?.draw(in: CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height))
      // 2
      context.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
      context.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
      // 3
      context.setLineCap( CGLineCap.round)
      context.setLineWidth(5.0)
      context.setStrokeColor(drawColor.cgColor)
      context.setBlendMode( CGBlendMode.normal)
      // 4
      context.strokePath()
      // 5
      overlayImageView.image = UIGraphicsGetImageFromCurrentImageContext()
    }
    UIGraphicsEndImageContext()
  }
  
}
