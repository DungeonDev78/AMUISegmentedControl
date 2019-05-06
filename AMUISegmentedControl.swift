//
//  AMUISegmentedControl.swift
//
//  Created with 💪 by Alessandro Manilii on 12/11/2018.
//  Copyright © 2018 Alessandro Manilii. All rights reserved.
//

import UIKit

@IBDesignable
public class AMUISegmentedControl: UIControl {

    // MARK: - IBInspectables
    @IBInspectable var isUnderlined: Bool = false {
        didSet { configureStyle(isUnderlined: isUnderlined) }
    }

    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet { layer.borderWidth = borderWidth }
    }

    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet { layer.borderColor = borderColor.cgColor}
    }

    @IBInspectable var commaSeparatedButtonTitles: String = "" {
        didSet { updateView() }
    }

    @IBInspectable var fontName: String = "" {
        didSet { updateFontsWith(name: fontName, size: fontSize) }
    }

    @IBInspectable var fontSize: Double = 12.0 {
        didSet { updateFontsWith(name: fontName, size: fontSize) }
    }

    @IBInspectable var textColor: UIColor = .lightGray {
        didSet { updateView() }
    }

    @IBInspectable var selectorColor: UIColor = .darkGray {
        didSet { updateView() }
    }

    @IBInspectable var selectorTextColor: UIColor = .white {
        didSet { updateView() }
    }

    // MARK: - Properties
    var buttons = [UIButton]()
    var selector: UIView!
    var topAncorConstraint: NSLayoutConstraint?
    var selectedIndex = 0

    // MARK: - Lifecycle & Public Setup
    override public func draw(_ rect: CGRect) {
        layer.cornerRadius = frame.height/2
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(UIDevice.orientationDidChangeNotification)
    }

    /// Changes the fonts of the selector buttons
    ///
    /// - Parameters:
    ///   - fonts: the chosen fonts
    ///   - size: the size of the fonts themselves
    public func setup(fonts: UIFont, size: CGFloat) {
        updateButton(fonts: fonts, size: size)
    }
}

// MARK: - Configurations
private extension AMUISegmentedControl {
    /// Setup the style of the selector, rounded or underlined
    ///
    /// - Parameter isUnderlined: the setup bool
    func configureStyle(isUnderlined: Bool) {
        animateUI(for: buttons[selectedIndex])
        if isUnderlined {
            layer.borderWidth = 0
            topAncorConstraint?.constant = frame.height - 3
            selector.layer.cornerRadius = 0
        } else {
            layer.borderWidth = borderWidth
            topAncorConstraint?.constant = 0
            selector.layer.cornerRadius = frame.height/2
        }
    }
}

// MARK: - Updates and Animations
private extension AMUISegmentedControl {

    /// Update the view itself
    func updateView() {
        buttons.removeAll()
        subviews.forEach{ $0.removeFromSuperview() }

        let buttonTitles = commaSeparatedButtonTitles.components(separatedBy: ",")

        setupButtons(with: buttonTitles)
        setupSelector(for: buttonTitles)
        setupButtonsStackView()
    }

    /// Configure the buttons
    ///
    /// - Parameter buttonTitles: the array of titles
    func setupButtons(with buttonTitles: [String]) {
        buttonTitles.forEach {
            let button = UIButton.init(type: .system)
            button.setTitle($0, for: .normal)
            button.setTitleColor(textColor, for: .normal)
            button.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
            buttons.append(button)
        }

        buttons.first?.setTitleColor(selectorTextColor, for: .normal)
    }

    /// Configure the dynamic selector
    ///
    /// - Parameter buttonTitles: the array of titles
    func setupSelector(for buttonTitles: [String]) {
        let selectorWidth = frame.width / CGFloat(buttonTitles.count)
        let selectorStartPosition = frame.width/CGFloat(buttons.count) * CGFloat(selectedIndex)
        if selector == nil {
            selector = UIView(frame: CGRect(x: selectorStartPosition, y: 10, width: selectorWidth, height: 5))
        }

        selector.layer.cornerRadius = frame.height/2
        selector.backgroundColor = selectorColor
        addSubview(selector)

        setupConstraintsForSelector()
    }

    /// Configure the geometric constraints of the dynamic selector
    func setupConstraintsForSelector() {
        selector.translatesAutoresizingMaskIntoConstraints = false
        topAncorConstraint = selector.topAnchor.constraint(equalTo: self.topAnchor)
        if let topAncorConstraint = topAncorConstraint { topAncorConstraint.isActive = true }
        selector.bottomAnchor.constraint(equalTo:  self.bottomAnchor).isActive = true
        selector.leftAnchor.constraint(equalTo: self.leftAnchor).isActive =  true
        let multiplier = 1 / CGFloat(buttons.count)
        selector.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: multiplier).isActive = true
    }

    /// Configure the buttons area
    func setupButtonsStackView() {
        let buttonsStackView = UIStackView.init(arrangedSubviews: buttons)
        buttonsStackView.axis = .horizontal
        buttonsStackView.alignment = .fill
        buttonsStackView.distribution = .fillEqually
        addSubview(buttonsStackView)

        setupConstraints(for: buttonsStackView)
    }

    /// Configure the geometric constraints of the buttons area
    ///
    /// - Parameter buttonsStackView: the stackView holding the buttons
    func setupConstraints(for buttonsStackView: UIStackView) {
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        buttonsStackView.bottomAnchor.constraint(equalTo:  self.bottomAnchor).isActive = true
        buttonsStackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        buttonsStackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }

    /// Update the fonts of the buttons
    ///
    /// - Parameters:
    ///   - fontName: the string with the name of the font
    ///   - size: the size of the fonts
    func updateFontsWith(name fontName:String, size: Double) {
        buttons.forEach{
            let fonts = UIFont(name: fontName, size: CGFloat(size)) ?? UIFont.systemFont(ofSize: CGFloat(size))
            $0.titleLabel?.font = fonts
        }
    }

    /// Update the fonts of the buttons
    ///
    /// - Parameters:
    ///   - fonts: the chosen fonts
    ///   - size: the size of the fonts
    func updateButton(fonts: UIFont, size: CGFloat) {
        buttons.forEach{
            $0.titleLabel?.font = fonts
            $0.titleLabel?.font = $0.titleLabel?.font.withSize(size)
        }
    }

    /// Animate the selector
    ///
    /// - Parameter button: the button tapped
    func animateUI(for button: UIButton) {
        for (buttonIndex, btn) in buttons.enumerated() {
            btn.setTitleColor(textColor, for: .normal)
            if btn == button {
                selectedIndex = buttonIndex
                let selectorStartPosition = frame.width/CGFloat(buttons.count) * CGFloat(buttonIndex)
                UIView.animate(withDuration: 0.25) {
                    self.selector.frame.origin.x = selectorStartPosition
                }
                if !isUnderlined {
                    btn.setTitleColor(selectorTextColor, for: .normal)
                }
            }
        }
    }

    /// Fired then the device changes the orientation
    @objc func orientationDidChange() {
        animateUI(for: buttons[selectedIndex])
    }
}

// MARK: - Updates and Animations
extension AMUISegmentedControl {

    /// Fired then a button is tapped
    ///
    /// - Parameter button: the tapped button
    @objc public func buttonTapped(button: UIButton) {
        animateUI(for: button)
        sendActions(for: .valueChanged)
    }
}
