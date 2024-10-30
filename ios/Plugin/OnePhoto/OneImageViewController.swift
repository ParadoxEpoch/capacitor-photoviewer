//
//  OneImageViewController.swift
//  Capacitor
//
//  Originally created by Quéau Jean Pierre on 30/09/2021.
//  Additions by Tristan Gauci (ParadoxEpoch) on 30/10/2024.
//

import UIKit

import SDWebImage
import ISVImageScrollView

class OneImageViewController: UIViewController, UIScrollViewDelegate {
    private var _url: String = ""
    private var _maxZoomScale: CGFloat = 3.0
    private var _minZoomScale: CGFloat = 1.0
    private var _compressionQuality: Double = 0.8
    private var _options: [String: Any] = [:]
    private var _isShare: Bool = true
    private var _startFrom: Int = 0
    private var _backgroundColor: String = "black"
    private var _backColor: BackgroundColor = BackgroundColor()
    private var _colorRange: [String] = ["white", "ivory", "lightgrey"]
    private var _btColor: UIColor = UIColor.white

    // MARK: - Set-up url

    var url: String {
        get {
            return self._url
        }
        set {
            self._url = newValue
        }
    }

    var startFrom: Int {
        get {
            return self._startFrom
        }
        set {
            self._startFrom = newValue
        }
    }

    // MARK: - Set-up options

    var options: [String: Any] {
        get {
            return self._options
        }
        set {
            self._options = newValue

            if self._options.keys.contains("share") {
                if let isShare = self._options["share"] as? Bool {
                    self._isShare = isShare
                }
            }
            if self._options.keys.contains("maxzoomscale") {
                if let maxZoomScale = self._options["maxzoomscale"] as? Double {
                    self._maxZoomScale = CGFloat(maxZoomScale)
                }
            }
            if self._options.keys.contains("compressionquality") {
                if let compressionQuality = self._options["compressionquality"]
                    as? Double {
                    self._compressionQuality = compressionQuality
                }
            }
            if self._options.keys.contains("backgroundcolor") {
                if let backgroundColor = self._options["backgroundcolor"]
                    as? String {
                    self._backgroundColor = backgroundColor
                    if _colorRange.contains(_backgroundColor) {
                        _btColor = UIColor.black
                    }
                    self.mBlurEffectView.isHidden = _backgroundColor != "blur"
                }
            }
        }
    }
    
    private let mBlurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = UIScreen.main.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurEffectView
    }()
    private let mBackdropView: UIView = {
        let backdropView = UIView(frame: UIScreen.main.bounds)
        backdropView.backgroundColor = .clear
        return backdropView
    }()
    private let mContentView: UIView = {
        let contentView = UIView(frame: UIScreen.main.bounds)
        contentView.backgroundColor = .clear
        return contentView
    }()
    private let mImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let mScrollView: ISVImageScrollView = {
        let scrollView = ISVImageScrollView()
        return scrollView
    }()
    private let mNavBar: UINavigationBar = { () -> UINavigationBar in
        let navigationBar = UINavigationBar()
        navigationBar.isTranslucent = true
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        return navigationBar
    }()
    lazy var mClose: UIBarButtonItem = {
        let bClose = UIBarButtonItem()
        let image: UIImage?
        if #available(iOS 13, *) {
            let configuration = UIImage.SymbolConfiguration(scale: .large)
            image = UIImage(systemName: "multiply",
                            withConfiguration: configuration)
            bClose.image = image?.withTintColor(_btColor, renderingMode: .alwaysOriginal)
        } else {

            bClose.title = "Close"
            let fontSize: CGFloat = 18
            let font: UIFont = UIFont.boldSystemFont(ofSize: fontSize)
            bClose.setTitleTextAttributes(
                [NSAttributedString.Key.foregroundColor: _btColor,
                 NSAttributedString.Key.font: font], for: .normal)
        }
        bClose.tintColor = _btColor
        bClose.action = #selector(closeButtonTapped)
        return bClose
    }()
    lazy var mShare: UIBarButtonItem = {
        let bShare = UIBarButtonItem()
        let image: UIImage?
        if #available(iOS 13, *) {
            let configuration = UIImage.SymbolConfiguration(scale: .large)
            image = UIImage(systemName: "square.and.arrow.up",
                            withConfiguration: configuration)
            bShare.image = image?.withTintColor(_btColor, renderingMode: .alwaysOriginal)
        } else {
            bShare.title = "Share"
            let fontSize: CGFloat = 18
            let font: UIFont = UIFont.boldSystemFont(ofSize: fontSize)
            bShare.setTitleTextAttributes(
                [NSAttributedString.Key.foregroundColor: _btColor,
                 NSAttributedString.Key.font: font], for: .normal)
        }
        bShare.tintColor = _btColor
        bShare.action = #selector(shareButtonTapped)
        return bShare

    }()

    func addSubviewsToParentView(size: CGSize) {
        // Add the backdrop subview to the main view
        view.addSubview(mBackdropView)
        
        // Add the blur effect subview to the backdrop view
        mBackdropView.addSubview(mBlurEffectView)
        
        // Add the content container subview to the main view
        view.addSubview(mContentView)
        
        mContentView.addSubview(mScrollView)
        mScrollView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width, height: size.height))
        self.mScrollView.maximumZoomScale = self._maxZoomScale
        self.mScrollView.delegate = self

        if url.prefix(4) == "http" || url.contains("base64") {
            let imgPlaceHolder: UIImage?
            if #available(iOS 13, *) {
                imgPlaceHolder = UIImage(systemName: "livephoto.slash")
            } else {
                imgPlaceHolder = nil
            }
            mImageView.sd_setImage(with: URL(string: url), placeholderImage: imgPlaceHolder, completed: {image, error, _, url in
                if let err = error {
                    print("Error: \(err)")
                    return
                }
                guard let imgUrl = url else {
                    print("Error: image url not correct")
                    return
                }
                guard let img = image else {
                    print("Error: image url \(imgUrl) not loaded")
                    return
                }
                self.mImageView.image = img
                self.mScrollView.imageView = self.mImageView

            })
        }

        if url.prefix(38) ==
            "file:///var/mobile/Media/DCIM/100APPLE" ||
            url.prefix(38) ==
            "capacitor://localhost/_capacitor_file_" {
            let image: UIImage = UIImage()
            self.mImageView.image = image.getImage(path: url,
                                                   placeHolder: "livephoto.slash")
            self.mScrollView.imageView = self.mImageView
        }

        let navigationItem = UINavigationItem()
        navigationItem.rightBarButtonItem = mClose
        if self._isShare {
            navigationItem.leftBarButtonItem = mShare
        }
        mNavBar.setItems([navigationItem], animated: false)
        
        let screenHeight = UIScreen.main.bounds.height
        let navBarHeight: CGFloat = 64 // Height of your navigation bar
        let safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        // Calculate the y position for the navigation bar to be at the bottom
        let navBarYPosition = screenHeight - navBarHeight - safeAreaInsets
        mNavBar.frame = CGRect(x: 0, y: navBarYPosition, width: size.width, height: navBarHeight)
        view.addSubview(mNavBar)
        
        // Set up the pan gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        mContentView.addGestureRecognizer(panGesture)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the backdrop view background.
        // If this is "blur" the background will be clear to not impede on mBlurEffectView
        mBackdropView.backgroundColor = _backColor.setBackColor(color: _backgroundColor)
        
        // Capture a screenshot for the view background
        if let capturedImage = captureScreenshot() {
            // Create an UIImageView with the captured image
            let imageView = UIImageView(frame: view.bounds)
            imageView.image = capturedImage
            imageView.contentMode = .scaleAspectFill
            
            // Add the image view as a subview directly to the view controller's view
            view.addSubview(imageView)
        }
        
        addSubviewsToParentView(size: CGSize(width: view.frame.width, height: view.frame.height))
    }
    
    func captureScreenshot() -> UIImage? {
        // Use scenes and windows for iOS 13 and later
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            
            // Render the window's layer into an image
            UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, UIScreen.main.scale)
            defer { UIGraphicsEndImageContext() }
            
            if let context = UIGraphicsGetCurrentContext() {
                window.layer.render(in: context)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                return image
            }
        }
        
        return nil
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let progress = abs(translation.y) / view.bounds.height

        switch gesture.state {
        case .changed:
            // Move the content container with the finger
            mContentView.transform = CGAffineTransform(translationX: 0, y: translation.y)
            // Fade out the content container progressively
            mBackdropView.alpha = 1.0 - progress
            
            // Fade out the navigation bar
            UIView.animate(withDuration: 0.15) {
                self.mNavBar.transform = CGAffineTransform(translationX: 0, y: 50)
                self.mNavBar.alpha = 0.0
            }

        case .ended, .cancelled:
            let velocity = gesture.velocity(in: view).y

            // Determine if the view should be dismissed
            let dismissThreshold: CGFloat = 500  // Fast enough swipe
            let isFastSwipe = abs(velocity) > dismissThreshold
            let isSignificantDrag = progress > 0.5  // Dragged more than halfway
            let isDismissing = isFastSwipe || isSignificantDrag

            if isDismissing {
                // Determine the direction of the dismissal based on transform position
                let finalY: CGFloat = mContentView.transform.ty > 0 ? view.bounds.height : -view.bounds.height

                UIView.animate(withDuration: 0.20, animations: {
                    // Continue moving the content container off screen
                    self.mContentView.transform = CGAffineTransform(translationX: 0, y: finalY)
                    // Fully fade out the content container
                    self.mBackdropView.alpha = 0.0
                }, completion: { _ in
                    // Dismiss the view controller after animation completes
                    self.dismiss(animated: false, completion: nil)
                })
            } else {
                // Reset if neither fast swipe nor significant drag for dismissal
                UIView.animate(withDuration: 0.20, animations: {
                    self.mContentView.transform = .identity
                    self.mBackdropView.alpha = 1.0
                    self.mNavBar.transform = .identity
                    self.mNavBar.alpha = 1.0
                })
            }

        default:
            break
        }
    }

    // MARK: - viewDidDisappear

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        destroyAllGestures()
    }

    // MARK: - closeButtonTapped

    @objc func closeButtonTapped() {
        let vId: [String: Any] =
            ["result": true,
             "imageIndex": startFrom
            ]
        NotificationCenter.default.post(name: .photoviewerExit,
                                        object: nil,
                                        userInfo: vId)
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
        //self.dismissWithTransition(swipeDirection: "no")
    }

    // MARK: - shareButtonTapped

    @objc func shareButtonTapped() {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.sd_setImage(with: URL(string: url),
                              placeholderImage: nil)
        if let image = imageView.image {
            if let data = image.jpegData(compressionQuality:
                                            CGFloat(_compressionQuality)) {
                let avc = UIActivityViewController(activityItems: [data],
                                                   applicationActivities: [])
                present(avc, animated: true)
            }
        } else {
            print("No image available")
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - UIScrollViewDelegate

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.mImageView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale <= self._minZoomScale {
            scrollView.zoomScale = self._minZoomScale
            UIView.animate(withDuration: 0.15) {
                self.mNavBar.alpha = 1.0
            }
        } else if scrollView.zoomScale > self._maxZoomScale {
            scrollView.zoomScale = self._maxZoomScale
        } else {
            UIView.animate(withDuration: 0.15) {
                self.mNavBar.alpha = 0.0
            }
        }
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scrollView.zoomScale <= self._minZoomScale {
            scrollView.zoomScale = self._minZoomScale
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        mImageView.removeFromSuperview()
        mScrollView.removeFromSuperview()
        mNavBar.removeFromSuperview()
        mContentView.removeFromSuperview()
        mBackdropView.removeFromSuperview()

        addSubviewsToParentView(size: size)
    }

    // MARK: - destroyAllGestures

    func destroyAllGestures() {
        view.gestureRecognizers?.removeAll()
    }
}
