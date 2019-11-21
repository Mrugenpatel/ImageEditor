import UIKit

enum EditMode {
  case normal
  case drawing
  case texting
}

public final class PhotoEditorViewController: UIViewController {
  
  /** holding the 2 imageViews original image and drawing & stickers */
  @IBOutlet weak var canvasView: UIView!
  //To hold the image
  @IBOutlet var imageView: UIImageView!
  @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
  
  //To hold the drawings and stickers
  @IBOutlet weak var overlayImageView: UIImageView!
  
  @IBOutlet weak var topToolbar: UIView!
  @IBOutlet weak var bottomToolbar: UIView!
  
  @IBOutlet weak var topGradient: UIView!
  @IBOutlet weak var bottomGradient: UIView!
  
  @IBOutlet weak var doneButton: UIButton!
  @IBOutlet weak var colorsCollectionView: UICollectionView!
  @IBOutlet weak var colorPickerView: UIView!
  @IBOutlet weak var colorPickerViewBottomConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var actionsBar: UIStackView!
  //Controls
  @IBOutlet weak var drawButton: UIButton!
  @IBOutlet weak var textButton: UIButton!
  @IBOutlet weak var clearButton: UIButton!
  @IBOutlet weak var saveButton: UIButton!
  
  public var image: UIImage
  let dismissWhenSave: Bool
  let warningBeforeExit: Bool
  /**
   Array of Stickers -UIImage- that the user will choose from
   */
  public var stickers : [UIImage] = []
  /**
   Array of Colors that will show while drawing or typing
   */
  public var colors  : [UIColor] = []
  
  public var photoEditorDelegate: PhotoEditorDelegate?
  var colorsCollectionViewDelegate: ColorsCollectionViewDelegate!
  
  // list of controls to be hidden
  public var hiddenControls : [control] = []
  
  var drawColor: UIColor = UIColor.black
  var textColor: UIColor = UIColor.white
//  var isDrawing: Bool = false
//  var isTyping: Bool = false
  var lastPoint: CGPoint!
  var swiped = false
  var lastPanPoint: CGPoint?
  var lastTextViewTransform: CGAffineTransform?
  var lastTextViewTransCenter: CGPoint?
  var lastTextViewFont:UIFont?
  var activeTextView: UITextView?
  var imageViewToPan: UIImageView?
  
  var editMode: EditMode = .normal {
    didSet {
      switch editMode {
      case .normal:
        doneButton.isHidden = true
        colorPickerView.isHidden = true
        actionsBar.isHidden = false
        hideToolbar(hide: false)
        overlayImageView.isUserInteractionEnabled = true
        
        view.endEditing(true)
        toggleGestures(on: canvasView, enable: true) //TODO: check
      case .drawing, .texting:
        doneButton.isHidden = false
        colorPickerView.isHidden = false
        actionsBar.isHidden = true
        hideToolbar(hide: true)
        overlayImageView.isUserInteractionEnabled = false
        
        toggleGestures(on: canvasView, enable: false)
      }
    }
  }
  
  init(image: UIImage, dismissWhenSave: Bool = true, warningBeforeExit: Bool = true) {
    self.image = image
    self.dismissWhenSave = dismissWhenSave
    self.warningBeforeExit = warningBeforeExit
    super.init(nibName:"PhotoEditorViewController", bundle: Bundle(for: PhotoEditorViewController.self))
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    self.setImageView(image: image)
    
    clearButton.layer.cornerRadius = 20
    saveButton.layer.cornerRadius = 20
    saveButton.layer.borderColor = UIColor.white.cgColor
    saveButton.layer.borderWidth = 1
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow),
                                           name: UIResponder.keyboardDidShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                           name: UIResponder.keyboardWillHideNotification, object: nil)
    NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillChangeFrame(_:)),
                                           name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    
    
    configureCollectionView()
    hideControls()
    //        addGestures(view: canvasView)
  }
  
  func configureCollectionView() {
//    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//    layout.itemSize = CGSize(width: 45, height: 45)
//    layout.scrollDirection = .horizontal
//    layout.minimumInteritemSpacing = 0
//    layout.minimumLineSpacing = 0
//    colorsCollectionView.collectionViewLayout = layout
    colorsCollectionViewDelegate = ColorsCollectionViewDelegate()
    colorsCollectionViewDelegate.colorDelegate = self
    if !colors.isEmpty {
      colorsCollectionViewDelegate.colors = colors
    }
    colorsCollectionView.delegate = colorsCollectionViewDelegate
    colorsCollectionView.dataSource = colorsCollectionViewDelegate
    
    colorsCollectionView.register(
      UINib(nibName: "ColorCollectionViewCell", bundle: Bundle(for: ColorCollectionViewCell.self)),
      forCellWithReuseIdentifier: "ColorCollectionViewCell")
  }
  
  func setImageView(image: UIImage) {
    imageView.image = image
    let size = image.suitableSize(heightLimit: view.bounds.height, widthLimit: view.bounds.width)
    imageViewHeightConstraint.constant = (size?.height)!
  }
  
  func hideToolbar(hide: Bool) {
    topToolbar.isHidden = hide
    topGradient.isHidden = hide
    bottomToolbar.isHidden = hide
    bottomGradient.isHidden = hide
  }
}

extension PhotoEditorViewController: ColorDelegate {
  func didSelectColor(color: UIColor) {
    switch editMode {
    case .drawing:
      drawColor = color
    case .texting:
      activeTextView?.textColor = color
      textColor = color
    default:
      break
    }
  }
}


extension PhotoEditorViewController {
  func addGestures(view: UIView) {
    //Gestures
    view.isUserInteractionEnabled = true
    
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(PhotoEditorViewController.panGesture))
    panGesture.minimumNumberOfTouches = 1
    panGesture.maximumNumberOfTouches = 1
    panGesture.delegate = self
    view.addGestureRecognizer(panGesture)
    
    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(PhotoEditorViewController.pinchGesture))
    pinchGesture.delegate = self
    view.addGestureRecognizer(pinchGesture)
        
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PhotoEditorViewController.tapGesture))
    view.addGestureRecognizer(tapGesture)
    
  }
  
  func toggleGestures(on view: UIView, enable: Bool) {
    view.isUserInteractionEnabled = enable
  }
}

