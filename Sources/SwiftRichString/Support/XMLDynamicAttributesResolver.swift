//
//  SwiftRichString
//  Elegant Strings & Attributed Strings Toolkit for Swift
//
//  Created by Daniele Margutti.
//  Copyright © 2018 Daniele Margutti. All rights reserved.
//
//    Web: http://www.danielemargutti.com
//    Email: hello@danielemargutti.com
//    Twitter: @danielemargutti
//
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in
//    all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//    THE SOFTWARE.

import Foundation
import UIKit

// MARK: - XMLDynamicAttributesResolver

public protocol XMLDynamicAttributesResolver {
        
    /// When an `img` tag is found this function is called to return requested image.
    /// Default implementation of this method receive the `name` attribute of the `img` tag along with any mapping
    /// provided by calling `StyleXML`, if `mapping` does not contains requested image for given name
    /// the `UIImage(named:)` is called and image is searching inside any bundled `xcasset` file.
    ///
    /// - Parameters:
    ///   - name: name of the image to get.
    ///   - fromStyle: caller instance of `StyleXML.
    func image(name: String, attributes: [String: String]?, fromStyle style: StyleXML) -> UIImage?
    
    /// You are receiving this event when SwiftRichString correctly render an existing tag but the tag
    /// contains extra attributes you may want to handle.
    /// For example you can pass a specific tag `<bold color="#db13f2">text/<bold>` and you want to override
    /// the color with passed value in tags.
    ///
    /// - Parameters:
    ///   - attributedString: attributed string. You will receive it after the style is applied.
    ///   - xmlStyle: xml style information with tag, applied style and the dictionary with extra attributes.
    ///   - fromStyle: caller instance of `StyleXML.
    func applyDynamicAttributes(to attributedString: inout NSMutableAttributedString, xmlStyle: XMLDynamicStyle, fromStyle: StyleXML)
    
    /// You will receive this event when SwiftRichString can't found a received style name into provided group tags.
    /// You can decide to handle it. The default receiver for example uses the `a` tag to render passed url if `href`
    /// attribute is alo present.
    ///
    /// - Parameters:
    ///   - tag: tag name received.
    ///   - attributedString: attributed string received.
    ///   - attributes: attributes of the tag received.
    ///   - fromStyle: caller instance of `StyleXML.
    func styleForUnknownXMLTag(_ tag: String, to attributedString: inout NSMutableAttributedString, attributes: [String: String]?, fromStyle: StyleXML)

}

extension XMLDynamicAttributesResolver {
    
    public func image(name: String, attributes: [String: String]?, fromStyle style: StyleXML) -> UIImage? {
        guard let mappedImage = style.imageProvider?(name, attributes) else {
            return UIImage(named: name) // xcassets fallback
        }

        // origin xml style contains mapped image.
        return mappedImage
    }
    
}

// MARK: - StandardXMLAttributesResolver

open class StandardXMLAttributesResolver: XMLDynamicAttributesResolver {
    
    public init() {}
    
    open func applyDynamicAttributes(to attributedString: inout NSMutableAttributedString, xmlStyle: XMLDynamicStyle, fromStyle: StyleXML) {
        let finalStyleToApply = Style()
        xmlStyle.enumerateAttributes { key, value  in
            switch key {
            case "color": // color support
                finalStyleToApply.color = UIColor(hexString: value)
                
            default: break
            }
        }
        self.styleForUnknownXMLTag(xmlStyle.tag, to: &attributedString, attributes: xmlStyle.xmlAttributes, fromStyle: fromStyle)
        attributedString.add(style: finalStyleToApply)
    }
    
    open func styleForUnknownXMLTag(_ tag: String, to attributedString: inout NSMutableAttributedString, attributes: [String: String]?, fromStyle: StyleXML) {
        let finalStyleToApply = Style()
        switch tag {
            case "a": // href support
            if let href: String = attributes?["href"] {
                finalStyleToApply.linkURL = URL(string: href)
            }
            case "img":
            /// Remote image
            if let url: String = attributes?["url"] {
                if let image: NSMutableAttributedString = NSMutableAttributedString(imageURL: url, bounds: attributes?["rect"]) {
                    attributedString.append(image)
                }
            }
                
            /// Local image
            if let imageName: String = attributes?["named"] {
                if let image: UIImage = image(name: imageName, attributes: attributes, fromStyle: fromStyle),
                   let imageString: NSMutableAttributedString = NSMutableAttributedString(image: image, bounds: attributes?["rect"]) {
                    attributedString.append(imageString)
                }
            }
            
            default:
                break
        }
        attributedString.add(style: finalStyleToApply)
    }
    
}
