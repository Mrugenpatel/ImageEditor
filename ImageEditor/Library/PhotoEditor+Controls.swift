import Foundation
import UIKit

// MARK: - Control
public enum control {
  case draw
  case text
  case save
  case clear
}

extension PhotoEditorViewController {
  
  //MARK: Top Toolbar
  
  @IBAction func drawButtonTapped(_ sender: Any) {
    editMode = .drawing
  }
  
  @IBAction func textButtonTapped(_ sender: Any) {
    editMode = .texting
    
    let textView = UITextView(frame: CGRect(x: view.bounds.width * 0.15, y: overlayImageView.center.y,
                                            width: view.bounds.width * 0.7, height: 40))
    
    textView.textAlignment = .center
    textView.font = UIFont(name: "Helvetica", size: 28)
    textView.textColor = textColor
    textView.layer.shadowColor = UIColor.black.cgColor
    textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
    textView.layer.shadowOpacity = 0.2
    textView.layer.shadowRadius = 1.0
    textView.layer.backgroundColor = UIColor.white.withAlphaComponent(0.4).cgColor
    textView.autocorrectionType = .no
    textView.isScrollEnabled = false
    textView.delegate = self
    overlayImageView.addSubview(textView)
    addGestures(view: textView)
    DispatchQueue.main.async {    
      textView.becomeFirstResponder()
    }
    actionsBar.isHidden = true
//    toggleGestures(on: canvasView, enable: false)
  }    
  
  @IBAction func doneButtonTapped(_ sender: Any) {
    editMode = .normal
  }
  
  
  @IBAction func clearButtonTapped(_ sender: AnyObject) {
    //clear drawing
    overlayImageView.image = nil
    //clear stickers and textviews
    for subview in overlayImageView.subviews {
      subview.removeFromSuperview()
    }
  }
  
  @IBAction func continueButtonPressed(_ sender: Any) {
    let img = canvasView.toImage()
    photoEditorDelegate?.doneEditing(image: img)
    if dismissWhenSave {
      dismiss(animated: true)
    }
  }
  
  @IBAction func cancelButtonTapped(_ sender: Any) {
    let dismiss = {
      self.photoEditorDelegate?.canceledEditing()
      self.dismiss(animated: true)
    }
    if warningBeforeExit {
      let alert = UIAlertController(title: "Close without saving?", message: "You sure you want to exit? You changes won't be saved.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Yes, exit", style: .destructive, handler: { _ in
        dismiss()
      }))
      alert.addAction(UIAlertAction(title: "No, stay here", style: .cancel, handler: nil))
      present(alert, animated: true)
    } else {
      dismiss()
    }
  }
  
  func hideControls() {
    for control in hiddenControls {
      switch control {
      case .clear:
        clearButton.isHidden = true
      case .draw:
        drawButton.isHidden = true
      case .save:
        saveButton.isHidden = true
      case .text:
        textButton.isHidden = true
      }
    }
  }
  
}
