//
//  CTLabel.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 08.01.17.
//  Copyright © 2017 Kilograpp. All rights reserved.
//

import Foundation
import CoreGraphics
import CoreText

final class AttributedTextLayoutData {
    var attributedText: NSAttributedString
    var size: CGSize
    var lines : [AttributedLineLayoutData] = []
    
    init(text: NSAttributedString, maxWidth: CGFloat) {
        let stringRef = text as! CFAttributedString
        let typeSetter = CTTypesetterCreateWithAttributedString(stringRef);
        
        var lines: Array<AttributedLineLayoutData> = []
        
        var startIdx: CFIndex = 0
        var lineIdx: CFIndex = 0
        
        let len: CFIndex = CFAttributedStringGetLength(stringRef);
        
        var size = CGSize.zero;
        
        while (startIdx < len) {
            let lineCharactersCount: CFIndex = CTTypesetterSuggestLineBreak(typeSetter, startIdx, Double(maxWidth))
            let line = CTTypesetterCreateLine(typeSetter, CFRangeMake(startIdx, lineCharactersCount))
            var ascent: CGFloat = 0
            var descent: CGFloat = 0
            var leading: CGFloat = 0
            let lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
            
            size.width = max(size.width, CGFloat(lineWidth));
            size.height += ascent + descent + leading;
            
            let renderedLine = AttributedLineLayoutData(line:line, origin:CGPoint(x:0, y:size.height-descent-leading))
            lines.append(renderedLine)
            
            startIdx+=lineCharactersCount
            lineIdx += 1
        }
        
        self.lines = lines
        self.size = size
        self.attributedText = text
    }
    
    func drawTextInContext(ctx:CGContext) {
        for line in lines {
            var origin = line.origin
            origin.y = self.size.height - origin.y
            ctx.textPosition = origin;
            CTLineDraw(line.line, ctx);
        }
    }
}

final class AttributedLineLayoutData {
    var line: CTLine
    var origin: CGPoint
    
    init(line: CTLine, origin: CGPoint) {
        self.line = line
        self.origin = origin
    }
}

final class CTLabel : UIView {
    let width: CGFloat = UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings - Constants.UI.PostStatusViewSize
    
    var layoutData: AttributedTextLayoutData? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var highlightedLayoutData: AttributedTextLayoutData?
    var highlighted: Bool = false
    
    var onMentionTap: ((_ username: String) -> Void)?
    var onUrlTap: ((_ url: URL) -> Void)?
    var onHashTagTap: ((_ hashTag: String) -> Void)?
    var onPhoneTap: ((_ phone: String) -> Void)?
    var onEmailTap: ((_ email: String) -> Void)?
    
    override func draw(_ rect: CGRect) {
        defer {
            self.transform = CGAffineTransform(scaleX: 1.0, y: -1.0);
        }
        
        guard let dataToDisplay = highlighted ? highlightedLayoutData : layoutData else {return}
        dataToDisplay.drawTextInContext(ctx: UIGraphicsGetCurrentContext()!)
    }
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let point = touches.first?.location(in: self) else {return}
//        let charIdx = charachterIndexAtPoint(point: point)
//        
//        if charIdx != NSNotFound {
//            var range = NSRange()
//            guard let ld = layoutData else {
//                return
//            }
//
//            let text = ld.attributedText
//            let username = text.mentionAtIndex(charIdx, effectiveRange: &range)
//            let hashTag = text.hashTagAtIndex(charIdx, effectiveRange: &range)
//            let email = text.emailAtIndex(charIdx, effectiveRange: &range)
//            let url = text.URLAtIndex(charIdx, effectiveRange: &range)
//            let phone = text.phoneAtIndex(charIdx, effectiveRange: &range)
//            
//            if (username != nil) || (hashTag != nil) || (email != nil) || (url != nil) || (phone != nil) {
//                let mutableString = text.mutableCopy() as! NSMutableAttributedString
//                mutableString.addAttribute(NSBackgroundColorAttributeName, value: UIColor.blue, range: range)
//                let highlightedText = (mutableString.copy() as! NSAttributedString)
//                highlightedLayoutData = AttributedTextLayoutData(text: highlightedText, maxWidth: width)
//                setNeedsDisplay()
//            }
//        }
//    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else {return}
        let charIdx = charachterIndexAtPoint(point: point)
        
        if charIdx == NSNotFound {
            return
        }
        
        defer {
            cancelHighlight()
        }
        
        guard let ld = layoutData else {
            return
        }
        
        if let username = ld.attributedText.mentionAtIndex(charIdx) {
            self.onMentionTap?(username)
            return
        }
        
        if let hashTag = ld.attributedText.hashTagAtIndex(charIdx) {
            self.onHashTagTap?(hashTag)
            return
        }
        
        if let email = ld.attributedText.emailAtIndex(charIdx) {
            self.onEmailTap?(email)
            return
        }
        
        if let url = ld.attributedText.URLAtIndex(charIdx) {
            self.onUrlTap?(url)
            return
        }
        
        if let phone = ld.attributedText.phoneAtIndex(charIdx) {
            self.onPhoneTap?(phone)
            return
        }
        
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        cancelHighlight()
    }
    
    fileprivate func cancelHighlight() {
        highlighted = false
        highlightedLayoutData = nil
        setNeedsDisplay()
    }
    
    fileprivate func charachterIndexAtPoint(point: CGPoint) -> CFIndex {
        guard let lines = layoutData?.lines else {
            return NSNotFound
        }
        
        for line in lines {
            var ascent: CGFloat = 0
            var descent: CGFloat = 0
            var leading: CGFloat = 0
            let lineWidth = CTLineGetTypographicBounds(line.line, &ascent, &descent, &leading)
            var origin = line.origin
            origin.y = self.bounds.size.height - origin.y
            let size = CGSize(width: CGFloat(lineWidth), height: ascent+descent+leading)
            var lineRect = CGRect(origin: origin, size: size)
//            lineRect = lineRect.offsetBy(dx: 0, dy: -ascent)

            if lineRect.contains(point) {
                let linePoint = CGPoint(x: point.x - origin.x, y: origin.y - point.y)
                return max(0, CTLineGetStringIndexForPosition(line.line, linePoint) - 1)
            }
        }
        
        return NSNotFound;
    }
    
    func prepareForReuse() {
        self.layoutData = nil
        self.highlightedLayoutData = nil
    }
}
