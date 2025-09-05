////
////  LabelTapHelper.swift
////  Sicretta
////
////  Created by Deepak Jain on 27/06/22.
////
//
//import Foundation
//
//class AtMentionsLabel: UILabel {
//  private var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
//  weak var tapDelegate: AtMentionsLabelTapDelegate?
//
//  var mentions: [String] = [] // usernames to style
//
//  override init(frame: CGRect) {
//    super.init(frame: frame)
//    commonInit()
//  }
//
//  required init?(coder aDecoder: NSCoder) {
//    super.init(coder: aDecoder)
//    commonInit()
//  }
//
//  func commonInit() {
//    isUserInteractionEnabled = true
//
//    lineBreakMode = .byWordWrapping
//    tapGesture = UITapGestureRecognizer()
//    tapGesture.addTarget(self, action: #selector(handleLabelTap(recognizer:)))
//    tapGesture.numberOfTapsRequired = 1
//    tapGesture.isEnabled = true
//    addGestureRecognizer(tapGesture)
//  }
//
//
//  @objc func handleLabelTap(recognizer: UITapGestureRecognizer) {
//    let tapLocation = recognizer.location(in: self)
//    let tapIndex = indexOfAttributedTextCharacterAtPoint(point: tapLocation)
//
//    for username in mentions {
//      if let ranges = self.attributedText?.rangesOf(subString: username) {
//        for range in ranges {
//          if tapIndex > range.location && tapIndex < range.location + range.length {
//            tapDelegate?.labelWasTappedForUsername(username)
//            return
//          }
//        }
//      }
//    }
//  }
//
//  func indexOfAttributedTextCharacterAtPoint(point: CGPoint) -> Int {
//    guard let attributedString = self.attributedText else { return -1 }
//
//    let mutableAttribString = NSMutableAttributedString(attributedString: attributedString)
//    // Add font so the correct range is returned for multi-line labels
//    mutableAttribString.addAttributes([NSAttributedString.Key.font: font], range: NSRange(location: 0, length: attributedString.length))
//
//    let textStorage = NSTextStorage(attributedString: mutableAttribString)
//
//    let layoutManager = NSLayoutManager()
//    textStorage.addLayoutManager(layoutManager)
//
//    let textContainer = NSTextContainer(size: frame.size)
//    textContainer.lineFragmentPadding = 0
//    textContainer.maximumNumberOfLines = numberOfLines
//    textContainer.lineBreakMode = lineBreakMode
//    layoutManager.addTextContainer(textContainer)
//
//    let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
//    return index
//  }
//}
//
//extension NSAttributedString {
//  func rangesOf(subString: String) -> [NSRange] {
//    var nsRanges: [NSRange] = []
//    let ranges = string.ranges(of: subString, options: .caseInsensitive, locale: nil)
//
//    for range in ranges {
//      nsRanges.append(range.nsRange)
//    }
//
//    return nsRanges
//  }
//}
//
//extension String {
//  func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
//    var ranges: [Range<Index>] = []
//    while let range = self.range(of: substring, options: options, range: (ranges.last?.upperBound ?? self.startIndex) ..< self.endIndex, locale: locale) {
//      ranges.append(range)
//    }
//    return ranges
//  }
//}
