//
//  PDFViewerVC.swift
//  ClubAfib
//
//  Created by mac on 10/2/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import PDFKit

class PDFViewerVC: UIViewController {

    @IBOutlet var vwContent: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dst = URL(fileURLWithPath: NSTemporaryDirectory().appending("ECG.pdf"))
        let pdfView = PDFView(frame: vwContent.bounds)
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        vwContent.addSubview(pdfView)
                
        pdfView.autoScales = true
        pdfView.document = PDFDocument(url: dst)
    }
    
    @IBAction func onBack(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onShare(){
        let dst = URL(fileURLWithPath: NSTemporaryDirectory().appending("ECG.pdf"))
        let activityViewController = UIActivityViewController(activityItems: [dst], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
}
