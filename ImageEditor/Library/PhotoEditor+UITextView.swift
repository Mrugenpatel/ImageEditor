import Foundation
import UIKit

extension PhotoEditorViewController: UITextViewDelegate {
  
  public func textViewDidChange(_ textView: UITextView) {
    let rotation = atan2(textView.transform.b, textView.transform.a)
    if rotation == 0 {
      let oldFrame = textView.frame
      let sizeToFit = textView.sizeThatFits(CGSize(width: oldFrame.width, height:CGFloat.greatestFiniteMagnitude))
      textView.frame.size = CGSize(width: oldFrame.width, height: sizeToFit.height)
    }
  }
  public func textViewDidBeginEditing(_ textView: UITextView) {
    lastTextViewTransform =  textView.transform
    lastTextViewTransCenter = textView.center
    lastTextViewFont = textView.font!
    activeTextView = textView
    textView.superview?.bringSubviewToFront(textView)
  }
  
  public func textViewDidEndEditing(_ textView: UITextView) {
    guard lastTextViewTransform != nil && lastTextViewTransCenter != nil && lastTextViewFont != nil
      else {
        return
    }
    activeTextView = nil
    textView.isEditable = false
    textView.font = self.lastTextViewFont!
    textView.backgroundColor = .clear
  }
  
}
