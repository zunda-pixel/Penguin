//
//  ActionViewController.swift
//

import UIKit
import UniformTypeIdentifiers

class ActionViewController: UIViewController {
  @objc func openURL(_ url: URL) {}
  
  func OpenURL(_ url: URL) {
    // magic
    // https://qiita.com/ensan_hcl/items/15ea4379bb184cd6f026
    // https://zenn.dev/kyome/articles/88876501b05f13
    
    let selector = #selector(openURL(_:))
    
    var responder: UIResponder? = self

    while let r = responder {
      if let application = r as? UIApplication {
        application.perform(selector, with: url)
        break
      }
      responder = r.next
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    guard let inputItems = extensionContext?.inputItems as? [NSExtensionItem] else { return }
    let providers = inputItems.compactMap(\.attachments).joined()
    
    let identifier = UTType.url.identifier
    
    Task {
      for provider in providers {
        guard provider.hasItemConformingToTypeIdentifier(identifier) else { return }
        
        let item = try await provider.loadItem(forTypeIdentifier: identifier)
        let url = item as! URL
                       
        guard url.host()?.contains("twitter.com") == true else { continue }
                
        let schemeURL = URL(string: "penguin://")!
        
        if let tweetID = url.pathComponents[safe: 3],
           url.pathComponents[safe: 2] == "status" {
          let url = schemeURL.appending(queryItems: [.init(name: "tweetID", value: tweetID)])
          OpenURL(url)
          break
        }
                
        if let userID = url.pathComponents[safe: 1] {
          let url = schemeURL.appending(queryItems: [.init(name: "screenID", value: userID)])
          OpenURL(url)
          break
        }
      }
      
      extensionContext?.completeRequest(returningItems: extensionContext?.inputItems)
    }
  }
}

extension Array {
  subscript(safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
