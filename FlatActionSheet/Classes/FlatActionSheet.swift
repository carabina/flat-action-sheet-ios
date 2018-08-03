//
//  FlatActionSheet.swift
//  FlatActionSheet
//
//  Created by Ampe on 7/31/18.
//

import Foundation

@IBDesignable
open class FlatActionSheet: UIView {
    
    // MARK: Views
    open weak var tableView: UITableView!
    
    // MARK: Properties
    open weak var tableViewHeightConstraint: NSLayoutConstraint!
    open weak var tableViewTopConstraint: NSLayoutConstraint!
    
    // MARK: Properties
    open var actions: [FlatActionSheetAction] = []
    
    // MARK: IBInspectables
    @IBInspectable
    open var cellHeight: CGFloat = FlatActionSheetConfig.default.cellHeight {
        didSet {
            animateTableView(tableViewHeightConstraint,
                             value: tableViewHeight(),
                             for: animationDuration,
                             with: .to)
        }
    }
    
    @IBInspectable
    open var backgroundViewColor: UIColor = FlatActionSheetConfig.default.backgroundColor {
        didSet {
            layer.backgroundColor = backgroundViewColor.cgColor
        }
    }
    
    @IBInspectable
    open var backgroundAlphaValue: CGFloat = FlatActionSheetConfig.default.backgroundAlphaValue {
        didSet {
            guard backgroundAlphaValue >= 0 && backgroundAlphaValue <= 1 else {
                
                assert(false, "select a value between 0 and 1")
                return
            }
            
            animateBackgroundAlpha(for: animationDuration, value: backgroundAlphaValue)
        }
    }
    
    @IBInspectable
    open var animationDuration: Double = FlatActionSheetConfig.default.animationDuration
    
    @IBInspectable
    open var shouldShowDropShadow: Bool = FlatActionSheetConfig.default.shouldShowDropShadow {
        didSet {
            guard shouldShowDropShadow else {
                return
            }
            
            tableView.layer.shadowColor = dropShadowColor.cgColor
            tableView.layer.shadowOffset = dropShadowOffset
            tableView.layer.shadowRadius = dropShadowRadius
            tableView.layer.shadowOpacity = dropShadowOpacity
            tableView.layer.masksToBounds = false
        }
    }
    
    @IBInspectable
    open var dropShadowColor: UIColor = FlatActionSheetConfig.default.dropShadowConfig.color {
        didSet {
            tableView.layer.shadowColor = UIColor.black.cgColor
        }
    }
    
    @IBInspectable
    open var dropShadowOffset: CGSize = FlatActionSheetConfig.default.dropShadowConfig.offset {
        didSet {
            tableView.layer.shadowOffset = dropShadowOffset
        }
    }
    
    @IBInspectable
    open var dropShadowRadius: CGFloat = FlatActionSheetConfig.default.dropShadowConfig.radius {
        didSet {
            tableView.layer.shadowRadius = dropShadowRadius
        }
    }
    
    @IBInspectable
    open var dropShadowOpacity: Float = FlatActionSheetConfig.default.dropShadowConfig.opacity {
        didSet {
            tableView.layer.shadowOpacity = dropShadowOpacity
        }
    }
    
    // MARK: Designable Initalizers
    public convenience init() {
        
        self.init(frame: CGRect.zero)
    }
    
    public override convenience init(frame: CGRect) {
        
        self.init(frame)
    }
    
    // MARK: Programmatic Initalizer
    public init(_ frame: CGRect,
                config: FlatActionSheetConfig = .default) {
        
        let tableView = UITableView()
        self.tableView = tableView
        
        super.init(frame: frame)
        
        addViews()
        addConstraints()
        
        setupTableView()
        
        initConfig(config)
    }
    
    // MARK: Storyboard Initalizer
    public required init?(coder aDecoder: NSCoder) {
        
        let tableView = UITableView()
        self.tableView = tableView
        
        super.init(coder: aDecoder)
        
        addViews()
        addConstraints()
        
        setupTableView()
    }
}

// MARK: - Setup Methods
private extension FlatActionSheet {
    func setupTableView() {
        
        tableView.register(FlatActionSheetCell.self,
                           forCellReuseIdentifier: FlatActionSheetCell.reuseIdentifier)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.isScrollEnabled = false
    }
    
    func addViews() {
        
        addSubview(tableView)
    }
    
    func addConstraints() {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        let tableViewTopAnchor = tableView.topAnchor.constraint(equalTo: bottomAnchor)
        tableViewTopAnchor.isActive = true
        
        tableViewTopConstraint = tableViewTopAnchor
        
        let tableViewHeightAnchor = tableView.heightAnchor.constraint(equalToConstant: tableViewHeight())
        tableViewHeightAnchor.isActive = true
        
        tableViewHeightConstraint = tableViewHeightAnchor
    }
    
    func initConfig(_ config: FlatActionSheetConfig = .default) {
        
        cellHeight = config.cellHeight
        backgroundAlphaValue = config.backgroundAlphaValue
        shouldShowDropShadow = config.shouldShowDropShadow
        animationDuration = config.animationDuration
        
        dropShadowColor = config.dropShadowConfig.color
        dropShadowOffset = config.dropShadowConfig.offset
        dropShadowRadius = config.dropShadowConfig.radius
        dropShadowOpacity = config.dropShadowConfig.opacity
    }
}

// MARK: - Public Methods
public extension FlatActionSheet {
    func show() {
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(animationDuration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn))
        
        animateTableView(tableViewTopConstraint, value: -tableViewHeight(), for: animationDuration, with: .to)
        animateBackgroundAlpha(for: animationDuration, value: backgroundAlphaValue)
        
        CATransaction.commit()
    }
    
    func hide(_ animationDuration: TimeInterval) {
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(animationDuration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut))
        
        CATransaction.setCompletionBlock {
            self.removeFromSuperview()
        }
        
        animateTableView(tableViewTopConstraint, value: 0, for: animationDuration, with: .to)
        animateBackgroundAlpha(for: animationDuration, value: 0)
        
        CATransaction.commit()
    }
}

// MARK: - Animation Methods
private extension FlatActionSheet {
    enum AnimationType {
        case add
        case to
    }
    
    func animateTableView(_ constraint: NSLayoutConstraint,
                          value: CGFloat,
                          for duration: TimeInterval,
                          with type: AnimationType) {
        
        switch type {
        case .add:
            constraint.constant += value
        case .to:
            constraint.constant = value
        }
        
        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
        }
    }
    
    func animateBackgroundAlpha(for duration: TimeInterval,
                                value: CGFloat) {
        
        layer.backgroundColor = UIColor.black.withAlphaComponent(0).cgColor
        
        UIView.animate(withDuration: duration) {
            self.layer.backgroundColor = UIColor.black.withAlphaComponent(value).cgColor
        }
    }
}

// MARK: - Flat Action Sheet Data Source Conformance
extension FlatActionSheet: FlatActionSheetDataSource {
    public func addAction(_ action: FlatActionSheetAction) {
        
        actions.append(action)
        tableViewHeightConstraint.constant = tableViewHeight()
        
        tableView.reloadData()
    } 
}

// MARK: - Table View Delegate Conformance
extension FlatActionSheet: UITableViewDelegate {
    public func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {
        
        guard let action = action(for: indexPath) else {
            
            assert(false, "internal inconsistency  - file a bug")
            return
        }
        
        guard let handler = action.handler else {
            
            assert(false, "internal inconsistency  - file a bug")
            return
        }
        
        switch action.style {
        case .dismiss:
            
            hide(animationDuration)
        }
        
        handler(action)
    }
    
    public func tableView(_ tableView: UITableView,
                          heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return cellHeight
    }
}

// MARK: - Table View Data Source Conformance
extension FlatActionSheet: UITableViewDataSource {
    public func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
        
        return actions.count
    }
    
    public func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FlatActionSheetCell.reuseIdentifier,
                                                       for: indexPath) as? FlatActionSheetCell else {
                                                        
            assert(false, "table view cell registration inconsistency")
            return UITableViewCell()
        }
        
        guard let title = action(for: indexPath)?.title else {
            
            assert(false, "internal inconsistency  - file a bug")
            return UITableViewCell()
        }
        
        cell.update(title)
        
        return cell
    }
}
