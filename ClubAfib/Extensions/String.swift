//
//  String.swift
//  Extentions
//
//  Created by Rener on 7/20/20.
//  Copyright © 2020 ExtremeMobile. All rights reserved.
//

import UIKit

extension String {
    
    /*!
     @brief It converts hex string into UIColor.
     @discussion It converts hex string into UIColor.
     @param hex The value of hex
     @return UIColor
     */
    func hexStringToUIColor () -> UIColor {
        var cString:String = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func localized() -> String {

        let path = Bundle.main.path(forResource: UserInfo.sharedInstance.currentLanguage, ofType: "lproj")
        let bundle = Bundle(path: path!)

        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
    
    func interpretAsHTML(font: String, size: CGFloat) -> NSAttributedString? {
        
        var style = ""
        style += "<style>* { "
        style += "font-family: \"\(font)\" !important;"
        style += "font-size: \(size) !important;"
        style += "}</style>"
        
        let styledHTML = self.trimmingCharacters(in: CharacterSet.newlines).appending(style)
        let htmlData   = styledHTML.data(using: .utf8)!
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            NSAttributedString.DocumentReadingOptionKey.documentType      : NSAttributedString.DocumentType.html,
            NSAttributedString.DocumentReadingOptionKey.characterEncoding : String.Encoding.utf8.rawValue,
        ]
        
        return try? NSAttributedString(data: htmlData, options: options, documentAttributes: nil)
    }
    
    private var convertHtmlToNSAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        do {
            return try NSAttributedString(data: data,options: [.documentType: NSAttributedString.DocumentType.html,.characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }

}
