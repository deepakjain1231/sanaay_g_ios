//
//  ReportVC.swift
//  SaNaay Wellness
//
//  Created by DEEPAK JAIN on 25/10/23.
//

import UIKit
import WebKit
import SafariServices

class ReportVC: UIViewController, WKNavigationDelegate, SFSafariViewControllerDelegate, WKUIDelegate {
    
    var is_loaded = false
    var str_reportLink = ""
    var str_pdf_name = ""
    var documentURL: URL!
    var screenFrom = ScreenType.none
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var webView_iPad: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //self.str_reportLink = "https://dev.ayurythm.com/SanaayGreport/ViewResult/227"
        
        
        let arr_pdfname = self.str_reportLink.components(separatedBy: "/")
        self.str_pdf_name = "sanaay_report_\(arr_pdfname.last ?? "1").pdf"

        ShowProgressHud(message: AppMessage.plzWait)
        self.webView.uiDelegate = self
        self.webView_iPad.uiDelegate = self
        self.webView.navigationDelegate = self
        self.webView_iPad.navigationDelegate = self
//        if let url = URL(string: self.str_reportLink) {
//            let request = URLRequest(url: url)
//            self.webView.load(request)
//            self.webView_iPad.load(request)
//        }
//        else {
//            DismissProgressHud()
//        }
        
        if let url = documentURL {
            let request = URLRequest(url: url)
            self.webView.load(request)
            self.webView_iPad.load(request)
        }
        else {
            DismissProgressHud()
        }
        
        
    }
    
    //MARK: - UIButton Action
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        if self.screenFrom == .direct_back {
            if let stackVCs = self.navigationController?.viewControllers {
                if let activeSubVC = stackVCs.first(where: { type(of: $0) == HomeVC.self }) {
                    (activeSubVC as? HomeVC)?.APICall()
                    self.navigationController?.popToViewController(activeSubVC, animated: true)
                }
            }
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btn_Share_Action(_ sender: UIButton) {
        if self.is_loaded {
            ShowProgressHud(message: AppMessage.plzWait)
            //saveAsPDF()
            //self.createPDFfromWebView()
            //self.createPDF()
            self.sharePdf(path: self.documentURL)
        }
    }
    
    //MARK: - WEB VIEW DELEGATE
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        DismissProgressHud()
//        //self.injectCSS()
//        self.is_loaded  = true
//    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("✅ HTML loaded, but wait for JS rendering...")
        self.is_loaded  = true
        DismissProgressHud()
        // Poll until content height stabilizes
        //checkPageReady()
    }

//    private func checkPageReady() {
//        webView.evaluateJavaScript("document.readyState") { (result, error) in
//            if let state = result as? String {
//                if state == "complete" {
//                    // Extra check: wait until height stops changing
//                    self.waitUntilHeightStable()
//                } else {
//                    // Try again after 0.5 sec
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                        self.checkPageReady()
//                    }
//                }
//            }
//        }
//    }

//    private func waitUntilHeightStable(previousHeight: CGFloat = 0) {
//        webView.evaluateJavaScript("document.body.scrollHeight") { (result, error) in
//            guard let height = result as? CGFloat else { return }
//
//            if abs(height - previousHeight) < 2 { // Height stable
//                print("✅ Page fully rendered, safe to use")
//                DismissProgressHud()
//                //self.exportToPDF()
//            } else {
//                // Keep checking until content stops changing
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    self.waitUntilHeightStable(previousHeight: height)
//                }
//            }
//        }
//    }

    
    
//    private func saveAsPDF() {
//        let pdfConfiguration = WKPDFConfiguration()
//
//        /// Using `webView.scrollView.frame` allows us to capture the
//        // entire page, not just the visible portion
//        pdfConfiguration.rect = CGRect(x: 0, y: 0, width: webView_iPad.scrollView.contentSize.width, height: webView_iPad.scrollView.contentSize.height)
//        
//        webView_iPad.createPDF(configuration: pdfConfiguration) { result in
//            switch result {
//            case .success(let data):
//                // Creates a path to the downloads directory
//                
//                DispatchQueue.main.async {
//                    let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
//                    let actualPath = resourceDocPath.appendingPathComponent(self.str_pdf_name)
//                    do {
//                        try data.write(to: actualPath, options: .atomic)
//                        DismissProgressHud()
//                        self.sharePdf(path: actualPath)
//                        print("pdf successfully saved!")
//                    } catch {
//                        print("Pdf could not be saved")
//                        DismissProgressHud()
//                    }
//                }
//
//            case .failure(let failure):
//                print(failure.localizedDescription)
//                DismissProgressHud()
//            }
//        }
//        
//    }
    
    
    func sharePdf(path:URL) {
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: path.path) {
            DismissProgressHud()
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [path], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        } else {
            print("document was not found")
            DismissProgressHud()
            let alertController = UIAlertController(title: "Error", message: "Document was not found!", preferredStyle: .alert)
            let defaultAction = UIAlertAction.init(title: "ok", style: UIAlertAction.Style.default, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
//    func createPDFfromWebView() {
//        let pdfData = NSMutableData()
//        let pageRenderer = UIPrintPageRenderer()
//        
//        DispatchQueue.main.async {
//            pageRenderer.addPrintFormatter(self.webView_iPad.viewPrintFormatter(), startingAtPageAt: 0)
//            
//            let page = CGRect(x: 0, y: 0, width: 612, height: 792) // Standard US Letter size
//            let printable = page.insetBy(dx: 0, dy: 0)
//            
//            pageRenderer.setValue(NSValue(cgRect: page), forKey: "paperRect")
//            pageRenderer.setValue(NSValue(cgRect: printable), forKey: "printableRect")
//            
//            UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, nil)
//            
//            for i in 0..<pageRenderer.numberOfPages {
//                UIGraphicsBeginPDFPage()
//                let bounds = UIGraphicsGetPDFContextBounds()
//                pageRenderer.drawPage(at: i, in: bounds)
//            }
//            
//            UIGraphicsEndPDFContext()
//            
//            // Save pdfData to a file or present it with UIActivityViewController
//            self.savePDF(data: pdfData)
//        }
//    }
        
//    func savePDF(data: NSData) {
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        let docDirectory = paths[0]
//        let pdfPath = docDirectory.appendingPathComponent("webview.pdf")
//        
//        data.write(to: pdfPath, atomically: true)
//        print("PDF saved to: \(pdfPath)")
//        DismissProgressHud()
//        self.sharePdf(path: pdfPath)
//    }


//    func injectCSS() {
//        let css = """
//        body { font-family: Arial, sans-serif; margin: 20px; }
//        h1 { color: blue; }
//        p { margin-bottom: 20px; }
//        """
//        
//        let javascript = """
//        var style = document.createElement('style');
//        style.innerHTML = `\(css)`;
//        document.head.appendChild(style);
//        """
//        
//        webView.evaluateJavaScript(javascript) { (result, error) in
//            if let error = error {
//                print("Error injecting CSS: \(error)")
//            } else {
//                self.createPDF()
//            }
//        }
//    }
    
//    func createPDF() {
//        let printFormatter = webView.viewPrintFormatter()
//        let printPageRenderer = UIPrintPageRenderer()
//        
//        printPageRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
//        
//        let pdfData = drawPDFUsingPrintPageRenderer(printPageRenderer: printPageRenderer)
//        
//        // Save or share the PDF data as needed
//        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//        let pdfPath = docDir.appendingPathComponent("document.pdf")
//        
//        try! pdfData.write(to: pdfPath)
//        print("PDF saved to: \(pdfPath)")
//        DismissProgressHud()
//        self.sharePdf(path: pdfPath)
//    }
    
//    func drawPDFUsingPrintPageRenderer(printPageRenderer: UIPrintPageRenderer) -> NSData {
//        let data = NSMutableData()
//        UIGraphicsBeginPDFContextToData(data, CGRect.zero, nil)
//        UIGraphicsBeginPDFPage()
//        printPageRenderer.drawPage(at: 0, in: UIGraphicsGetPDFContextBounds())
//        UIGraphicsEndPDFContext()
//        return data
//    }
}



