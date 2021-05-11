//
//  ParentResolver.swift
//  Movie DB
//
//  Created by Geri Borbás on 27.04.2020
//  Copyright © 2020. Geri Borbás
//  Source: https://github.com/Geri-Borbas/iOS.Blog.SwiftUI_Search_Bar_in_Navigation_Bar/blob/main/SwiftUI_Search_Bar_in_Navigation_Bar/SearchBar/ViewControllerResolver.swift
//  License: MIT License
//

import SwiftUI

final class ViewControllerResolver: UIViewControllerRepresentable {
    
    let onResolve: (UIViewController) -> Void
    
    init(onResolve: @escaping (UIViewController) -> Void) {
        self.onResolve = onResolve
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return ParentResolverViewController(onResolve: onResolve)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

class ParentResolverViewController: UIViewController {
    
    let onResolve: (UIViewController) -> Void
    
    init(onResolve: @escaping (UIViewController) -> Void) {
        self.onResolve = onResolve
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Use init(onResolve:) to instantiate ParentResolverViewController.")
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        if let parent = parent {
            onResolve(parent)
        }
    }
    
}
