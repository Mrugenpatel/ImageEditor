import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var colorView: UIView!
  
  private var previouTransform: CGAffineTransform?
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    colorView.layer.cornerRadius = colorView.frame.width / 2
    colorView.clipsToBounds = true
    colorView.layer.borderWidth = 1.0
    colorView.layer.borderColor = UIColor.white.cgColor
  }
  
  override var isSelected: Bool {
    didSet {
      if isSelected {
        self.previouTransform = colorView.transform
        UIView.animate(withDuration: 0.2,
                       animations: {
                        self.colorView.transform = self.colorView.transform.scaledBy(x: 1.3, y: 1.3)
                        self.colorView.layer.borderWidth = 2.0
        })
      } else {
        UIView.animate(withDuration: 0.2,
                       animations: {
                        self.colorView.transform = self.previouTransform ?? self.colorView.transform
                        self.colorView.layer.borderWidth = 1.0
        })
      }
    }
  }
}
