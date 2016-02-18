//
//  NewMessageDetail.swift
//  NewTaipei
//
//  Created by Cloud on 11/30/15.
//  Copyright © 2015 ischool. All rights reserved.
//

import UIKit

class NewMessageDetail: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var Subject: UILabel!
    @IBOutlet weak var Sender: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var Body: UITextView!
    
    @IBOutlet weak var IconLabel: UILabel!
    
    @IBOutlet weak var FrameView: UIView!
    
    var MessageData : MessageItem!
    
    var IconColor : UIColor?
    var IconText : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IconLabel.layer.masksToBounds = true
        IconLabel.layer.cornerRadius = IconLabel.frame.width / 2
        
        IconLabel.backgroundColor = IconColor
        IconLabel.text = IconText
        
        Subject.text = MessageData.Subject
        
        Sender.text = MessageData.Sender.isEmpty ? " \u{200c}" : MessageData.Sender
        Date.text = MessageData.Date.stringValue
        
        Body.attributedText = GetAttributedText(MessageData.Body)
        
        FrameView.layer.shadowColor = UIColor.darkGrayColor().CGColor
        FrameView.layer.shadowOpacity = 0.5
        FrameView.layer.shadowOffset = CGSizeMake(3.0, 2.0)
        FrameView.layer.shadowRadius = 3
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func GetAttributedText(text:String) -> NSMutableAttributedString{
        
//        let replaceStr = text.stringByReplacingOccurrencesOfString("\n", withString: "<br>")
//        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        
        let attrStr = try? NSAttributedString(
            data: text.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil)
        
        if let str = attrStr{
            
            let attrString = NSMutableAttributedString(attributedString: str)
            
            attrString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
            
            attrString.addAttributes([NSFontAttributeName : UIFont.systemFontOfSize(15.0)], range: NSMakeRange(0, attrString.length))
            
            return attrString
            
        }

        return NSMutableAttributedString(string: "格式解析失敗 X﹏X")
        
    }
    
    
}
