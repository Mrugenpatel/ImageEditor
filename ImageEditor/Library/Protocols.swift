
import UIKit

public protocol PhotoEditorDelegate {
  /**
   - Parameter image: edited Image
   */
  func doneEditing(image: UIImage)
  /**
   StickersViewController did Disappear
   */
  func canceledEditing()
}

protocol ColorDelegate {
  func didSelectColor(color: UIColor)
}
