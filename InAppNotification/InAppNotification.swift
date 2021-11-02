//
//  InAppNotification.swift
//  InAppNotification
//
//  Created by Rajesh Thangaraj on 02/11/21.
//

import UIKit

class InAppNotification: UIView {
    
    let imageView = UIImageView()
    let textLabel = UILabel()
    let panView = UIView()


    var timer: Timer?
    var panGesture: UIPanGestureRecognizer?
    var initialLocation: CGPoint = .zero
    var initailShowValue: CGFloat = 0

    var hideConstraint: NSLayoutConstraint?
    var showConstraint: NSLayoutConstraint?
    
   fileprivate init(with message: String, image: UIImage) {
        super.init(frame: .zero)
        backgroundColor = .white
        layer.cornerRadius = 10
       
        imageView.image = image
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        textLabel.text = message
        textLabel.textColor = .black
        textLabel.numberOfLines = 0
        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
       
        panView.backgroundColor = .black.withAlphaComponent(0.2)
        addSubview(panView)
        panView.translatesAutoresizingMaskIntoConstraints = false
        panView.layer.cornerRadius = 2
       
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            textLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            textLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            trailingAnchor.constraint(equalToSystemSpacingAfter: textLabel.trailingAnchor, multiplier: 1),
            textLabel.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1),
            panView.centerXAnchor.constraint(equalTo: centerXAnchor),
            panView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3),
            panView.heightAnchor.constraint(equalToConstant: 4),
            panView.widthAnchor.constraint(equalToConstant: 40)
        ])
       let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction))
       addGestureRecognizer(panGesture)
       self.panGesture = panGesture
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func panGestureAction(panGesture: UIPanGestureRecognizer) {
        if let showConstraint = showConstraint, showConstraint.isActive {
            switch panGesture.state {
            case .began:
                timer?.invalidate()
                initialLocation = panGesture.location(in: self)
                initailShowValue = showConstraint.constant
            case .changed:
                showConstraint.constant = initailShowValue + (panGesture.location(in: self).y - initialLocation.y)
            case .ended:
                hideView()
            default: break
            }
        }
    }
    
    fileprivate func keyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes.filter({$0.activationState == .foregroundActive}).compactMap({$0 as? UIWindowScene}).first?.windows.filter({$0.isKeyWindow}).first
    }
    
    fileprivate func show(decayIn: TimeInterval) {
        if let window = keyWindow() {
            window.addSubview(self)
            translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: window.leadingAnchor, multiplier: 1),
                widthAnchor.constraint(greaterThanOrEqualToConstant: 300),
                heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
                centerXAnchor.constraint(equalTo: window.centerXAnchor)
            ])
            
            hideConstraint = bottomAnchor.constraint(equalTo: window.topAnchor)
            hideConstraint?.isActive = true
            window.layoutIfNeeded()
            hideConstraint?.isActive = false

            showConstraint = topAnchor.constraint(equalTo: window.topAnchor, constant: window.safeAreaInsets.top + 10)
            showConstraint?.isActive = true

            UIView.animate(withDuration: 0.2) {
                window.layoutIfNeeded()
            }
            
            timer = Timer.scheduledTimer(timeInterval: decayIn, target: self, selector: #selector(hideView), userInfo: nil, repeats: false)
        }
        
    }
    
    @objc func hideView() {
        showConstraint?.isActive = false
        hideConstraint?.isActive = true
        UIView.animate(withDuration: 0.2) {
            self.superview?.layoutIfNeeded()
        } completion: { status in
            self.removeFromSuperview()
        }
    }
    
    static func show(message: String, image: UIImage = UIImage(systemName: "r.joystick.tilt.right.fill")!, decayIn: TimeInterval = 2) {
        InAppNotification(with: message, image: image).show(decayIn: decayIn)
    }

}

