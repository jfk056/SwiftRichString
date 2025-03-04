//
//  SwiftRichString
//  Elegant Strings & Attributed Strings Toolkit for Swift
//
//  Created by Daniele Margutti.
//  Copyright © 2018 Daniele Margutti. All rights reserved.
//
//	Web: http://www.danielemargutti.com
//	Email: hello@danielemargutti.com
//	Twitter: @danielemargutti
//
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

import Foundation

public protocol StyleProtocol: AnyObject {
	
	/// Return the attributes of the style in form of dictionary `NSAttributedStringKey`/`Any`.
	var attributes: [NSAttributedString.Key : Any] { get }
	
	/// Font unique attributes dictionary.
	var fontData: FontData? { get }
    
    var textTransforms: [TextTransform]? { get }
	
	func set(to source: String, range: NSRange?) -> NSMutableAttributedString
	
	func add(to source: NSMutableAttributedString, range: NSRange?) -> NSMutableAttributedString
	
	@discardableResult
	func set(to source: NSMutableAttributedString, range: NSRange?) -> NSMutableAttributedString
	
	@discardableResult
	func remove(from source: NSMutableAttributedString, range: NSRange?) -> NSMutableAttributedString
}

public extension StyleProtocol {
	
	func set(to source: String, range: NSRange?) -> NSMutableAttributedString {
		let attributedText = NSMutableAttributedString(string: source)
		self.fontData?.addAttributes(to: attributedText, range: nil)
		attributedText.addAttributes(self.attributes, range: (range ?? NSMakeRange(0, attributedText.length)))
        return applyTextTransform(self.textTransforms, to: attributedText)
	}
	
	func add(to source: NSMutableAttributedString, range: NSRange?) -> NSMutableAttributedString {
		self.fontData?.addAttributes(to: source, range: range)
		source.addAttributes(self.attributes, range: (range ?? NSMakeRange(0, source.length)))
        return applyTextTransform(self.textTransforms, to: source)
	}
	
	@discardableResult
	func set(to source: NSMutableAttributedString, range: NSRange?) -> NSMutableAttributedString {
		self.fontData?.addAttributes(to: source, range: range)
		source.addAttributes(self.attributes, range: (range ?? NSMakeRange(0, source.length)))
        return applyTextTransform(self.textTransforms, to: source)
	}
	
	@discardableResult
	func remove(from source: NSMutableAttributedString, range: NSRange?) -> NSMutableAttributedString {
		self.attributes.keys.forEach({
			source.removeAttribute($0, range: (range ?? NSMakeRange(0, source.length)))
		})
        return applyTextTransform(self.textTransforms, to: source)
	}
    
    private func applyTextTransform(_ transforms: [TextTransform]?, to string: NSMutableAttributedString) -> NSMutableAttributedString {
        guard let transforms = self.textTransforms else {
            return string
        }
        
        let mutable: NSMutableAttributedString = string.mutableStringCopy()
        let fullRange: NSRange = NSRange(location: 0, length: mutable.length)
        mutable.enumerateAttributes(in: fullRange, options: [], using: { (_, range, _) in
            var substring = mutable.attributedSubstring(from: range).string
            transforms.forEach {
                substring = $0.transformer(substring)
            }
            mutable.replaceCharacters(in: range, with: substring)
        })
        
        return mutable
    }
	
}
