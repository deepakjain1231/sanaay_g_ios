//
//  PDFEditorViewController.swift
//  DocSign
//
//  Created by Deepak Jain on 03/09/25.
//

import UIKit
import PDFKit

class PDFEditorViewController: UIViewController, PDFDocumentDelegate {
    
    var documentURL: URL!
    var strFileName = ""
    private let pdfView = PDFView()
    var searchController = UISearchController(searchResultsController: nil)
    
    // Keep a reference to bottom constraint
        private var pdfViewBottomConstraint: NSLayoutConstraint?
    
    // Keep search state
        private var searchResults: [PDFSelection] = []
        private var currentSearchIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupPDFView()
        setupToolbar()
        enterEditMode()
    }
    
    private func setupPDFView() {
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(true, withViewOptions: nil)
        
        view.addSubview(pdfView)
        pdfViewBottomConstraint = pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        
        NSLayoutConstraint.activate([
            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            pdfViewBottomConstraint!
        ])
        
        pdfView.document = PDFDocument(url: documentURL)
        
        if let doc = PDFDocument(url: documentURL) {
                    doc.delegate = self
                    pdfView.document = doc
                }
    }
    
    
    // MARK: - Toolbar
    private func setupToolbar() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeEditor)),
            UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchPDF)),
            UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharePDF))
        ]
        
        // Create a label
        let titleLabel = UILabel()
        titleLabel.text = strFileName
        titleLabel.font = UIFont.init(name: "Itim-Regular", size: 27)
        titleLabel.textColor = .black
        titleLabel.sizeToFit()
        
        // Put the label into a UIBarButtonItem
        let leftTitleItem = UIBarButtonItem(customView: titleLabel)
        
        // Assign to navigationItem
        navigationItem.leftBarButtonItem = leftTitleItem
        //navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeEditor))
    }
    
    // MARK: - Actions
    @objc private func sharePDF() {
        guard let url = documentURL else { return }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    @objc private func searchPDF() {
        guard let document = pdfView.document else { return }
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search in PDF"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Force search bar to show + keyboard
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.searchController.isActive = true
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    @objc private func closeEditor() {
        // Save before dismiss
        savePDF()
        dismiss(animated: true)
    }
    
    // MARK: - Auto Save
    private func savePDF() {
        guard let document = pdfView.document else { return }
        document.write(to: documentURL) // overwrites existing file
        print("✅ PDF saved at: \(documentURL.path)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        savePDF()
    }
    
    // MARK: - Direct Edit Mode
    private func enterEditMode() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let doc = self.pdfView.document else { return }
            
            for i in 0..<doc.pageCount {
                if let page = doc.page(at: i) {
                    for annotation in page.annotations {
                        // PDFKit AcroForm: "Tx" = text field
                        if annotation.widgetFieldType == .text {
                            self.pdfView.go(to: page)
                            annotation.isHighlighted = true
                            return
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Search Support
extension PDFEditorViewController: UISearchResultsUpdating, UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.isHidden = true
    }
       
       private func highlightSearchResult(_ selection: PDFSelection) {
           selection.color = UIColor.yellow.withAlphaComponent(0.5)
           pdfView.setCurrentSelection(selection, animate: true)
           pdfView.go(to: selection)
       }
    
    func didMatchString(_ instance: PDFSelection) {
            searchResults.append(instance)
            highlightSearchResult(instance)
        }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else { return }
        if !text.isEmpty {
            self.searchResults.removeAll()
            self.currentSearchIndex = 0
            self.pdfView.document?.beginFindString(text, withOptions: .caseInsensitive)
        }
        //pdfView.document?.beginFindString(text, withOptions: .caseInsensitive)
    }
}
