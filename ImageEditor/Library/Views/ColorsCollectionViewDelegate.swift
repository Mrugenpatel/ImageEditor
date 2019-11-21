import UIKit

class ColorsCollectionViewDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  let cellWidth = 45
  let cellSpacing = 0
  
  var colorDelegate : ColorDelegate?
  
  /**
   Array of Colors that will show while drawing or typing
   */
  var colors = [UIColor.black,
                UIColor.gray,
                UIColor.white,
                UIColor.blue,
                UIColor.green,
                UIColor.red,
                UIColor.yellow,
                UIColor.orange,
                UIColor.purple]
  
  override init() {
    super.init()
  }
  
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return colors.count
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.visibleCells.forEach { cell in
      cell.isSelected = false
    }
    collectionView.cellForItem(at: indexPath)?.isSelected = true
    colorDelegate?.didSelectColor(color: colors[indexPath.item])
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCollectionViewCell", for: indexPath) as! ColorCollectionViewCell
    cell.colorView.backgroundColor = colors[indexPath.item]
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    
    let totalCellWidth = cellWidth * collectionView.numberOfItems(inSection: section)
    let totalSpacingWidth = cellSpacing * (collectionView.numberOfItems(inSection: section) - 1)
    
    let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
    let rightInset = leftInset
    
    return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: cellWidth, height: cellWidth)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return CGFloat(cellSpacing)
  }
}
