import SceneKit
import UIBezierPath_Query

// 1024 in pixels is 1 in SceneKit
let sizeScale: CGFloat = 1024.0
let fontScale: CGFloat = 0.002

public class ARPopupLabel: SCNNode {
    private var bezierPathWidth: CGFloat = 1024.0
    private var bezierPathHeight: CGFloat = 512.0
    private var backPlaneWidth: CGFloat = 1.0
    private var backPlaneHeight: CGFloat = 1.0

    private var bezierPath: UIBezierPath = UIBezierPath()
    private var backPlane: SCNPlane = SCNPlane()
    private var backPlaneNode: SCNNode = SCNNode()
    private var borderLayerTop: CAShapeLayer?
    private var borderPlaneTop: SCNPlane = SCNPlane()
    private var borderNodeTop: SCNNode = SCNNode()
    private var borderLayerBottom: CAShapeLayer?
    private var borderPlaneBottom: SCNPlane = SCNPlane()
    private var borderNodeBottom: SCNNode = SCNNode()
    private var dotGeometry: SCNCylinder = SCNCylinder()
    private var dotTopNode: SCNNode = SCNNode()
    private var dotBottomNode: SCNNode = SCNNode()
    private var headerTextNode: SCNNode = SCNNode()
    private var detailsTextNode: SCNNode = SCNNode()

//MARK: Public variables
    private(set) public var width: CGFloat = 1024.0

    private(set) public var height: CGFloat = 1024.0

    private(set) public var isExpanded: Bool = false

    private(set) public var isAnimating: Bool = false

    public var updateQueue: DispatchQueue?
    
    public var backgrounColor: UIColor = UIColor.gray.withAlphaComponent(0.4) {
        didSet {
            backPlane.firstMaterial?.diffuse.contents = backgrounColor
        }
    }

    public var borderColor: UIColor = UIColor.darkGray {
        didSet {
            borderLayerTop?.strokeColor = borderColor.cgColor
            borderLayerBottom?.strokeColor = borderColor.cgColor
        }
    }
    
    public var dotColor: UIColor = UIColor.darkGray {
        didSet {
            dotGeometry.firstMaterial?.diffuse.contents = dotColor
        }
    }

    public var lineWidth: CGFloat = 8.0 {
        didSet {
            self.layoutGeometry()
        }
    }

    public var cornerRadius: CGFloat = 24.0 {
        didSet {
            self.layoutGeometry()
        }
    }

    public var headerText: String = "" {
        didSet {
            updateText(node: headerTextNode,
                       text: headerText,
                       font: headerFont,
                       color: headerColor)
        }
    }

    public var headerColor: UIColor = UIColor.black {
        didSet {
            if let text = headerTextNode.geometry as? SCNText {
                DispatchQueue.main.async {
                    text.firstMaterial?.diffuse.contents = self.headerColor
                }
            }
        }
    }
    
    public var headerFont: UIFont = UIFont(name: "Helvetica Neue", size: 20)! {
        didSet {
            updateText(node: headerTextNode,
                       text: headerText,
                       font: headerFont,
                       color: headerColor)
        }
    }
    
    public var detailsText: String = "" {
        didSet {
            updateText(node: detailsTextNode,
                       text: detailsText,
                       font: detailsFont,
                       color: detailsColor)
        }
    }

    public var detailsColor: UIColor = UIColor.white {
        didSet {
            if let text = detailsTextNode.geometry as? SCNText {
                text.firstMaterial?.diffuse.contents = detailsColor
            }
        }
    }

    public var detailsFont: UIFont = UIFont(name: "Helvetica Neue", size: 18)!{
        didSet {
            updateText(node: detailsTextNode,
                       text: detailsText,
                       font: detailsFont,
                       color: detailsColor)
        }
    }

    public var margin: CGFloat = 8.0 {
        didSet {
            fitSizeForContent()
        }
    }
    
    public var separatorHeight: CGFloat = 16.0 {
        didSet {
            fitSizeForContent()
        }
    }

//MARK: Private methods
    
    private func makeShapeLayer(path: UIBezierPath, flipped: Bool) -> CAShapeLayer{
        let displayLayer = CAShapeLayer()
        displayLayer.frame = CGRect(x: 0, y: 0, width: bezierPathWidth, height: bezierPathHeight)
        displayLayer.fillColor = UIColor.clear.cgColor
        displayLayer.strokeColor = borderColor.cgColor
        displayLayer.isGeometryFlipped = flipped
        displayLayer.lineWidth = lineWidth
        displayLayer.path = path.cgPath
        return displayLayer
    }
    
    private func layoutGeometry() {
        var posX: Float
        var posY: Float
        bezierPathWidth = width
        bezierPathHeight = height / 2.0
        backPlaneWidth = width / sizeScale
        backPlaneHeight = height / sizeScale;
        let lineOffset = lineWidth / 2.0
        let cornerOffset = cornerRadius + lineOffset

        backPlane.width = backPlaneWidth
        backPlane.height = backPlaneHeight
        backPlane.cornerRadius = cornerRadius / sizeScale
        backPlane.firstMaterial?.diffuse.contents = backgrounColor
        backPlaneNode.pivot = SCNMatrix4MakeTranslation(-Float((backPlaneWidth / 2.0)), 0.0, 0.0)
        backPlaneNode.position = SCNVector3Make(-Float((backPlaneWidth / 2.0)), 0.0, 0.0)
        backPlaneNode.scale = SCNVector3Make(0.0, 0.0, 0.0)
        backPlaneNode.opacity = 0.0

        // Bezier path
        bezierPath.removeAllPoints()
        bezierPath.move(to: CGPoint(x: lineOffset, y: 0))
        bezierPath.addLine(to: CGPoint(x: lineOffset, y: bezierPathHeight - cornerOffset))
        bezierPath.addArc(withCenter: CGPoint(x: cornerOffset, y: bezierPathHeight - cornerOffset),
                             radius: cornerRadius,
                             startAngle: CGFloat.pi,
                             endAngle: CGFloat.pi / 2.0,
                             clockwise: false)
        bezierPath.addLine(to: CGPoint(x: bezierPathWidth - cornerOffset, y: bezierPathHeight - lineOffset))
        bezierPath.addArc(withCenter: CGPoint(x: bezierPathWidth - cornerOffset, y: bezierPathHeight - cornerOffset),
                             radius: cornerRadius,
                             startAngle: CGFloat.pi / 2.0,
                             endAngle: 0,
                             clockwise: false)
        bezierPath.addLine(to: CGPoint(x: bezierPathWidth - lineOffset, y: lineWidth))

        borderLayerTop = makeShapeLayer(path: bezierPath, flipped: false)
        borderLayerTop?.strokeEnd = 0.0
        let materialTop = SCNMaterial()
        materialTop.diffuse.contents = borderLayerTop
        borderPlaneTop.width = backPlaneWidth
        borderPlaneTop.height = backPlaneHeight / 2.0
        borderPlaneTop.materials = [materialTop]
        borderNodeTop.position = SCNVector3Make(0.0, Float(backPlaneHeight / 4.0), 0.001)

        // Bottom path
        borderLayerBottom = makeShapeLayer(path: bezierPath, flipped: true)
        borderLayerBottom?.strokeEnd = 0.0
        let materialBottom = SCNMaterial()
        materialBottom.diffuse.contents = borderLayerBottom
        borderPlaneBottom.width = backPlaneWidth
        borderPlaneBottom.height = backPlaneHeight / 2.0
        borderPlaneBottom.materials = [materialBottom]
        borderNodeBottom.position = SCNVector3Make(0.0, Float(-backPlaneHeight / 4.0), 0.001)

        // Dots
        dotGeometry.radius = lineWidth / sizeScale
        dotGeometry.firstMaterial?.diffuse.contents = dotColor
        posX = Float((backPlaneWidth - lineOffset / sizeScale) / 2.0)
        posY = Float(backPlaneHeight / 4.0)
        dotTopNode.position = SCNVector3Make(-posX, -posY, 0.0)
        dotBottomNode.position = SCNVector3Make(-posX, posY, 0.0)
        
        // Text
        posX = Float(backPlaneWidth / 2.0 - (margin + lineWidth) / sizeScale)
        posY = Float(backPlaneHeight / 2.0 - (margin + lineWidth) / sizeScale)
        headerTextNode.position = SCNVector3Make(-posX, posY, 0.0)
        detailsTextNode.position = SCNVector3Make(-posX, -posY, 0.0)
        
        if (isExpanded) {
            isExpanded = false
            self.expand(duration: 0.0)
        }
    }
    
    private func fitSizeForContent() {
        // Total height =
        //   border width * 2
        // + height of title label if not empty
        // + height of details label if not empty
        // + size of spacer if title and details not empty
        // Total width =
        //   border width * 2
        // + max(header width, details width) if header or details not empty
        
        width = lineWidth * 2 + margin * 2.0
        height = lineWidth * 2 + margin * 2.0
        var headerWidth: CGFloat = 0.0
        var headerHeight: CGFloat = 0.0
        var detailsWidth: CGFloat = 0.0
        var detailsHeight: CGFloat = 0.0
        if (headerText != "") {
            if let text = headerTextNode.geometry as? SCNText {
                let (min, max) = text.boundingBox
                headerWidth = CGFloat(max.x - min.x) * fontScale * sizeScale
                headerHeight = CGFloat(max.y - min.y) * fontScale * sizeScale
                headerTextNode.pivot = SCNMatrix4MakeTranslation(0.0, max.y, 0.0)
            }
        }
        if (detailsText != "") {
            if let text = detailsTextNode.geometry as? SCNText {
                let (min, max) = text.boundingBox
                detailsWidth = CGFloat(max.x - min.x) * sizeScale * fontScale
                detailsHeight = CGFloat(max.y - min.y) * sizeScale * fontScale
            }
        }
        width = width + max(headerWidth, detailsWidth)
        height = height + headerHeight + detailsHeight
        height = height + ((headerText == "" || detailsText == "") ? 0.0 : separatorHeight)
        layoutGeometry()
    }

    private func updateText(node: SCNNode, text: String, font: UIFont, color: UIColor) {
        if (text == "") {
            node.geometry = nil
        }
        else {
            let scnText = SCNText(string: text, extrusionDepth: 0.5)
            scnText.font = font
            scnText.alignmentMode = CATextLayerAlignmentMode.left.rawValue
            scnText.truncationMode = CATextLayerTruncationMode.end.rawValue
            scnText.flatness = 0.01
            scnText.firstMaterial?.isDoubleSided = true
            scnText.firstMaterial?.diffuse.contents = color
            node.geometry = scnText
        }
        fitSizeForContent()
    }
    
    private func animationFrame(progress: CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        borderLayerTop?.strokeEnd = progress
        borderLayerBottom?.strokeEnd = progress
        CATransaction.commit()
        let point = bezierPath.mx_point(atFractionOfLength: progress)
        let x: CGFloat = point.x / sizeScale - backPlaneWidth / 2.0
        let y: CGFloat = point.y / sizeScale - backPlaneHeight / 4.0
        dotTopNode.position = SCNVector3(x, y, CGFloat(dotTopNode.position.z))
        dotBottomNode.position = SCNVector3(x, -y, CGFloat(dotBottomNode.position.z))
        let lineOffset = lineWidth / 2.0
        if (point.y <= (bezierPathHeight - lineOffset)) {
            if (progress < 0.5) {
                let ratio = (point.y / (bezierPathHeight - lineOffset))
                backPlaneNode.scale = SCNVector3Make(Float(ratio), Float(ratio), Float(ratio))
            }
            else {
                backPlaneNode.scale = SCNVector3Make(1.0, 1.0, 1.0)
            }
        }
        self.backPlaneNode.opacity = progress
    }

//MARK: Public methods
    
    override public init() {
        super.init()
        // Background plane
        backPlane.firstMaterial?.isDoubleSided = true
        backPlaneNode.geometry = backPlane
        self.addChildNode(backPlaneNode)

        // Top path
        borderNodeTop.geometry = borderPlaneTop
        self.addChildNode(borderNodeTop)

        // Bottom path
        borderNodeBottom.geometry = borderPlaneBottom
        self.addChildNode(borderNodeBottom)

        // Dots
        dotGeometry.height = 0.001
        dotTopNode.geometry = dotGeometry
        dotTopNode.eulerAngles = SCNVector3(x: -.pi / 2, y: 0.0, z: 0.0)
        borderNodeTop.addChildNode(dotTopNode)
        dotBottomNode.geometry = dotGeometry
        dotBottomNode.eulerAngles = SCNVector3(x: -.pi / 2, y: 0.0, z: 0.0)
        borderNodeBottom.addChildNode(dotBottomNode)

        headerTextNode.scale = SCNVector3Make(Float(fontScale), Float(fontScale), Float(fontScale))
        backPlaneNode.addChildNode(headerTextNode)
        detailsTextNode.scale = SCNVector3Make(Float(fontScale), Float(fontScale), Float(fontScale))
        backPlaneNode.addChildNode(detailsTextNode)

        self.layoutGeometry()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func expand(duration: TimeInterval, completionHandler block: (() -> Void)? = nil) {
        guard !isAnimating && !isExpanded else {
            return
        }
        self.isAnimating = true
        let borderAnimation = SCNAction.customAction(duration: duration) { (node, time) in
            let progress = duration == 0 ? 1.0 : time / CGFloat(duration)
            self.animationFrame(progress: progress)
        }
        borderAnimation.timingMode = SCNActionTimingMode.easeInEaseOut

        func performAnimation(_ animation: SCNAction, completionHandler block: (() -> Void)? = nil) {
            self.runAction(animation, forKey: "borderAnimation") {
                self.removeAction(forKey: "borderAnimation")
                self.animationFrame(progress: 1.0)
                self.isAnimating = false
                self.isExpanded = true
                DispatchQueue.main.async {
                    block?()
                }
            }
        }
        if (updateQueue == nil && Thread.isMainThread) {
            performAnimation(borderAnimation, completionHandler: block)
        }
        else {
            let queue = updateQueue ?? DispatchQueue.main
            queue.async {
                performAnimation(borderAnimation, completionHandler: block)
            }
        }
    }

    public func collapse(duration: TimeInterval, completionHandler block: (() -> Void)? = nil) {
        guard !isAnimating && isExpanded else {
            return
        }
        self.isAnimating = true
        let borderAnimation = SCNAction.customAction(duration: duration) { (node, time) in
            let progress = 1.0 - time / CGFloat(duration)
            self.animationFrame(progress: progress)
        }
        
        borderAnimation.timingMode = SCNActionTimingMode.linear
        func performAnimation(_ animation: SCNAction, completionHandler block: (() -> Void)? = nil) {
            self.runAction(animation, forKey: "borderAnimation") {
                self.removeAction(forKey: "borderAnimation")
                self.animationFrame(progress: 0.0)
                self.isAnimating = false
                self.isExpanded = false
                DispatchQueue.main.async {
                    block?()
                }
            }
        }
        if (updateQueue == nil && Thread.isMainThread) {
            performAnimation(borderAnimation, completionHandler: block)
        }
        else {
            let queue = updateQueue ?? DispatchQueue.main
            queue.async {
                performAnimation(borderAnimation, completionHandler: block)
            }
        }
    }
}

