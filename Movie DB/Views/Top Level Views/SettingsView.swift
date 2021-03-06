//
//  SettingsView.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI
import JFSwiftUI
import CoreData
import CSVImporter

struct SettingsView: View {
    
    // Reference to the config instance
    @ObservedObject private var config = JFConfig.shared
    @ObservedObject private var library = MediaLibrary.shared
    
    @Environment(\.managedObjectContext) private var managedObjectContext: NSManagedObjectContext
            
    @State private var updateInProgress = false
    @State private var reloadInProgress = false
    @State private var documentPicker: DocumentPicker?
    @State private var isLoading: Bool = false
    @State private var loadingText: String? = nil
    @State private var importLog: [String]? = nil
    @State private var languageChanged: Bool = false
    @State private var isShowingProInfo: Bool = false
    
    func loadLanguages() {
        if config.availableLanguages.isEmpty {
            // Load the TMDB Languages
            JFUtils.updateTMDBLanguages()
        }
    }
    
    var body: some View {
        LoadingView(isShowing: $isLoading, text: self.loadingText ?? NSLocalizedString("Loading...")) {
            NavigationView {
                Form {
                    Section {
                        Toggle(isOn: $config.showAdults, label: Text("Show Adult Content").closure())
                        Picker("Language", selection: $config.language) {
                            if config.availableLanguages.isEmpty {
                                Text("Loading...")
                                    .onAppear(perform: loadLanguages)
                            } else {
                                ForEach(config.availableLanguages, id: \.self) { code in
                                    Text(Locale.current.localizedString(forIdentifier: code) ?? code)
                                        .tag(code)
                                }
                            }
                        }
                        .onChange(of: config.language) { languageCode in
                            print("Language changed to \(languageCode)")
                            self.languageChanged = true
                        }
                    }
                    // MARK: - Buy Pro
                    Section {
                        Button("Buy Pro", action: { self.isShowingProInfo = true })
                            .popover(isPresented: $isShowingProInfo) {
                                ProInfoView()
                            }
                    }
                    Section {
                        // MARK: - Import Button
                        Button("Import Media", action: self.importMedia)
                            // MARK: Document Picker
                            .popover(isPresented: .init(get: {
                                #if targetEnvironment(macCatalyst)
                                return false
                                #else
                                return self.documentPicker != nil
                                #endif
                            }, set: { newState in
                                // If the new state is "hidden"
                                if newState == false {
                                    self.documentPicker = nil
                                }
                            })) {
                                self.documentPicker!
                            }
                        
                        // MARK: - Export Button
                        Button(action: self.exportMedia) {
                            Text("Export Media")
                        }
                        
                        // MARK: - Import Tags
                        Button("Import Tags", action: self.importTags)
                            // MARK: Import Log Popover
                            .popover(isPresented: .init(get: {
                                self.importLog != nil
                            }, set: { (enabled) in
                                if enabled {
                                    if self.importLog == nil {
                                        self.importLog = []
                                    }
                                } else {
                                    self.importLog = nil
                                }
                            })) {
                                ImportLogViewer(log: self.$importLog)
                            }
                        
                        // MARK: - Export Tags
                        Button("Export Tags", action: self.exportTags)
                    }
                    Section(footer: self.footer()) {
                        
                        // MARK: - Reload Button
                        Button("Reload Media", action: self.reloadMedia)
                        
                        // MARK: - Update Button
                        Button("Update Media", action: self.updateMedia)
                        .disabled(self.updateInProgress)
                        
                        // MARK: - Reset Button
                        Button("Reset Library", action: self.resetLibrary)
                    }
                    
                }
                .navigationTitle("Settings")
                // TODO: Localize
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink("Legal", destination: LegalView())
                    }
                }
            }
            
            
            
            
            
            .onDisappear {
                if self.languageChanged {
                    AlertHandler.showYesNoAlert(title: NSLocalizedString("Reload library?"), message: NSLocalizedString("Do you want to reload all media objects using the new language?"), yesAction: { _ in self.reloadMedia() })
                    self.languageChanged = false
                }
            }
        }
    }
    
    // MARK: - Button Functions
    
    func reloadMedia() {
        self.reloadInProgress = true
        DispatchQueue.global().async {
            print("Starting reload...")
            // Reload and show the result
            self.library.reloadAll { (error: Error?) in
                if let error = error {
                    print("Error reloading media objects: \(error)")
                    AlertHandler.showError(title: NSLocalizedString("Error reloading library"), error: error)
                    self.reloadInProgress = false
                    return
                }
                
                DispatchQueue.main.async {
                    self.reloadInProgress = false
                    AlertHandler.showSimpleAlert(title: NSLocalizedString("Reload Completed"), message: NSLocalizedString("All media objects have been reloaded."))
                }
            }
        }
    }
    
    func updateMedia() {
        self.updateInProgress = true
        DispatchQueue.global().async {
            print("Starting update...")
            // Update the available TMDB Languages
            JFUtils.updateTMDBLanguages()
            // Update and show the result
            self.library.update() { (updateCount: Int?, error: Error?) in
                
                if let error = error {
                    print("Error updating media objects: \(error)")
                    AlertHandler.showSimpleAlert(title: NSLocalizedString("Update Error"), message: NSLocalizedString("Error updating media objects: \(error.localizedDescription)"))
                    self.updateInProgress = false
                    return
                }
                
                guard let updateCount = updateCount else {
                    print("Error updating media objects.")
                    self.updateInProgress = false
                    return
                }
                
                DispatchQueue.main.async {
                    self.updateInProgress = false
                    let format = NSLocalizedString("%lld media objects have been updated.", tableName: "Plurals")
                    AlertHandler.showSimpleAlert(title: NSLocalizedString("Update Completed"), message: String.localizedStringWithFormat(format, updateCount))
                }
            }
        }
    }
    
    func importMedia() {
        if !JFUtils.purchasedPro() {
            if let mediaCount = MediaLibrary.shared.mediaCount() {
                if mediaCount >= JFLiterals.nonProMediaLimit {
                    self.isShowingProInfo = true
                    return
                }
            } else {
                print("Error retrieving media count")
                // continue with import
            }
        }
        // Use iOS file picker
        self.documentPicker = DocumentPicker(onSelect: { url in
            print("Importing \(url.lastPathComponent).")
            self.isLoading = true
            // Document picker finished. Invalidate it.
            self.documentPicker = nil
            
            // Perform the import into a separate context on a background thread
            PersistenceController.shared.container.performBackgroundTask { (importContext: NSManagedObjectContext) in
                // Set the merge policy to not override existing data
                importContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
                importContext.name = "Import Context"
                // The log containing all errors and information about the import
                var importLog: [String] = []
                // Load the CSV data
                do {
                    let csvString = try String(contentsOf: url)
                    print("Read csv file. Trying to import into library.")
                    let importer: CSVImporter<Media?> = CSVImporter<Media?>(contentString: csvString, delimiter: String(CSVManager.separator))
                    var csvHeader: [String] = []
                    importer.startImportingRecords { (headerValues: [String]) in
                        // Check if the header contains the necessary values
                        for header in CSVManager.requiredImportKeys {
                            if !headerValues.contains(header.rawValue) {
                                importLog.append("[Error] The CSV file does not contain the required header '\(header)'.")
                            }
                        }
                        for header in CSVManager.optionalImportKeys {
                            if !headerValues.contains(header.rawValue) {
                                importLog.append("[Warning] The CSV file does not contain the optional header '\(header)'.")
                            }
                        }
                        importLog.append("[Info] Importing CSV with header \(headerValues.joined(separator: String(CSVManager.separator)))")
                        csvHeader = headerValues
                    } recordMapper: { values in
                        do {
                            return try CSVManager.createMedia(from: values, context: importContext)
                        } catch let error as CSVManager.CSVError {
                            let line = csvHeader.map({ values[$0] ?? "" }).joined(separator: String(CSVManager.separator))
                            switch error {
                                case .noTMDBID:
                                    importLog.append("[Error] The following line is missing a TMDB ID:\n\(line)")
                                case .noMediaType:
                                    importLog.append("[Error] The following line is missing a media type:\n\(line)")
                                case .mediaAlreadyExists:
                                    importLog.append("[Warning] The following line already exists in the library. Skipping...\n\(line)")
                            }
                        } catch {
                            // Other errors, e.g., error while fetching the TMDBData
                            importLog.append("[Error] \(error.localizedDescription)")
                        }
                        return nil
                    }
                    .onProgress { (progress: Int) in
                        // Update the loading view
                        self.loadingText = "Loading \(progress) media objects..."
                    }
                    .onFail {
                        importLog.append("[FATAL] Importing failed!")
                        self.showImportLog(importLog)
                    }
                    .onFinish { (mediaObjects) in
                        // Presenting will change UI
                        DispatchQueue.main.async {
                            // TODO: Tell the user how many duplicates were not added
                            let format = NSLocalizedString("Imported %lld media objects.", tableName: "Plurals")
                            let controller = UIAlertController(
                                title: NSLocalizedString("Import"),
                                message: String.localizedStringWithFormat(format, mediaObjects.count),
                                preferredStyle: .alert)
                            controller.addAction(UIAlertAction(title: NSLocalizedString("Undo"), style: .destructive, handler: { _ in
                                // Reset all the work we have just done
                                importContext.reset()
                                importLog.append("[Info] Undoing import. All imported objects removed.")
                                self.showImportLog(importLog)
                            }))
                            controller.addAction(UIAlertAction(title: NSLocalizedString("Ok"), style: .default, handler: { _ in
                                // Make the changes to this context permanent by saving them to disk
                                PersistenceController.saveContext(context: importContext)
                                importLog.append("[Info] Import complete.")
                                self.showImportLog(importLog)
                            }))
                            self.isLoading = false
                            // Reset the loading text
                            self.loadingText = nil
                            AlertHandler.presentAlert(alert: controller)
                        }
                    }
                    
                    
                } catch {
                    print("Error importing: \(error)")
                    AlertHandler.showSimpleAlert(title: NSLocalizedString("Import Error"), message: NSLocalizedString("Error importing the media objects: \(error.localizedDescription)"))
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
                
            }
        }, onCancel: {
            print("Canceling...")
            self.documentPicker = nil
        })
        #if targetEnvironment(macCatalyst)
        // On macOS present the file picker manually
        UIApplication.shared.windows[0].rootViewController!.present(self.documentPicker!.viewController, animated: true)
        #endif
        
    }
    
    func showImportLog(_ log: [String]) {
        // Present the import Log as a separate view controller
        self.importLog = log
    }
    
    func exportMedia() {
        // Prepare for export
        print("Exporting...")
        self.isLoading = true
        
        // Perform the export in a separate context on a background thread
        PersistenceController.shared.container.performBackgroundTask { (exportContext: NSManagedObjectContext) in
            exportContext.name = "Export Context"
            let url: URL!
            do {
                let medias = JFUtils.allMedias()
                let csv = CSVManager.createCSV(from: medias)
                // Save the csv as a file to share it
                url = JFUtils.documentsPath.appendingPathComponent("MovieDB_Export_\(JFUtils.isoDateString()).csv")
                try csv.write(to: url, atomically: true, encoding: .utf8)
            } catch let exception {
                print("Error writing CSV file")
                print(exception)
                return
            }
            #if targetEnvironment(macCatalyst)
            // Show save file dialog
            self.documentPicker = DocumentPicker(urlToExport: url, onSelect: { url in
                print("Exporting \(url.lastPathComponent).")
                // Document picker finished. Invalidate it.
                self.documentPicker = nil
                do {
                    // Export the csv to the file
                    try csv.write(to: url, atomically: true, encoding: .utf8)
                } catch let exception {
                    print("Error exporting csv file:")
                    print(exception)
                }
            }, onCancel: {
                print("Canceling...")
                self.documentPicker = nil
            })
            // On macOS present the file picker manually
            UIApplication.shared.windows[0].rootViewController!.present(self.documentPicker!.viewController, animated: true)
            #else
            JFUtils.share(items: [url!])
            #endif
            self.isLoading = false
        }
    }
    
    func importTags() {
        // Use iOS file picker
        self.documentPicker = DocumentPicker(onSelect: { url in
            print("Importing \(url.lastPathComponent).")
            self.isLoading = true
            // Document picker finished. Invalidate it.
            self.documentPicker = nil
            DispatchQueue.global().async {
                // Load the CSV data and decode it
                do {
                    let importData = try String(contentsOf: url)
                    print("Imported Tag Export file. Trying to import into library.")
                    // Count the non-empty tags
                    let count = importData.components(separatedBy: "\n").filter({ !$0.isEmpty }).count
                    // Presenting will change UI
                    DispatchQueue.main.async {
                        let format = NSLocalizedString("Do you want to import %lld tags?", tableName: "Plurals")
                        let controller = UIAlertController(
                            title: NSLocalizedString("Import"),
                            message: String.localizedStringWithFormat(format, count),
                            preferredStyle: .alert)
                        controller.addAction(UIAlertAction(title: NSLocalizedString("Yes"), style: .default, handler: { _ in
                            // Use a background context for importing the tags
                            PersistenceController.shared.container.performBackgroundTask { (context) in
                                context.name = "Tag Import Context"
                                do {
                                    try TagImporter.import(importData, context: context)
                                    try context.save()
                                } catch {
                                    print(error)
                                    AlertHandler.showSimpleAlert(title: NSLocalizedString("Error Importing Tags"), message: error.localizedDescription)
                                }
                            }
                        }))
                        controller.addAction(UIAlertAction(title: NSLocalizedString("No"), style: .cancel))
                        AlertHandler.presentAlert(alert: controller)
                        self.isLoading = false
                    }
                } catch let error as LocalizedError {
                    print("Error importing: \(error)")
                    AlertHandler.showSimpleAlert(title: NSLocalizedString("Import Error"), message: NSLocalizedString("Error Importing the Tags: \(error.localizedDescription)"))
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                } catch let otherError {
                    print("Unknown Error: \(otherError)")
                    assertionFailure("This error should be captured specifically to give the user a more precise error message.")
                    AlertHandler.showSimpleAlert(title: NSLocalizedString("Import Error"), message: NSLocalizedString("There was an error importing the tags."))
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            }
        }, onCancel: {
            print("Canceling...")
            self.documentPicker = nil
        })
        #if targetEnvironment(macCatalyst)
        // On macOS present the file picker manually
        UIApplication.shared.windows[0].rootViewController!.present(self.documentPicker!.viewController, animated: true)
        #endif
    }
    
    func exportTags() {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.name = "Tag Export Context"
            var url: URL!
            do {
                let exportData: String = try TagImporter.export(context: context)
                // Save as a file to share it
                url = JFUtils.documentsPath.appendingPathComponent("MovieDB_Tags_Export_\(JFUtils.isoDateString()).txt")
                try exportData.write(to: url, atomically: true, encoding: .utf8)
            } catch let exception {
                print("Error writing Tags Export file")
                print(exception)
                return
            }
            #if targetEnvironment(macCatalyst)
            // Show save file dialog
            self.documentPicker = DocumentPicker(urlToExport: url, onSelect: { url in
                print("Exporting \(url.lastPathComponent).")
                // Document picker finished. Invalidate it.
                self.documentPicker = nil
                do {
                    // Export the csv to the file
                    try exportData.write(to: url, atomically: true, encoding: .utf8)
                } catch let exception {
                    print("Error exporting Tag Export file:")
                    print(exception)
                }
            }, onCancel: {
                print("Canceling...")
                self.documentPicker = nil
            })
            // On macOS present the file picker manually
            UIApplication.shared.windows[0].rootViewController!.present(self.documentPicker!.viewController, animated: true)
            #else
            JFUtils.share(items: [url!])
            #endif
        }
    }
    
    func resetLibrary() {
        let controller = UIAlertController(title: NSLocalizedString("Reset Library"), message: NSLocalizedString("This will delete all media objects in your library. Do you want to continue?"), preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: NSLocalizedString("Cancel"), style: .cancel))
        controller.addAction(UIAlertAction(title: NSLocalizedString("Delete"), style: .destructive, handler: { _ in
            // Don't reset the tags, only the media objects
            do {
                try self.library.reset()
            } catch let e {
                print("Error resetting media library")
                print(e)
                AlertHandler.showSimpleAlert(title: NSLocalizedString("Error resetting library"), message: e.localizedDescription)
            }
        }))
        AlertHandler.presentAlert(alert: controller)
    }
    
    func footer() -> some View {
        HStack {
            Spacer()
            VStack(alignment: .center) {
                ZStack {
                    // Update Progress
                    AnyView(
                        HStack {
                            ActivityIndicator()
                            Text("Updating media library...")
                        }
                    )
                    .hidden(condition: !self.updateInProgress)
                }.frame(height: self.updateInProgress ? nil : 0)
                let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                Text("Version \(appVersion ?? "unknown")")
            }
            Spacer()
        }
    }
    
    struct Keys {
        static let showAdults = "showAdults"
    }
    
    struct ImportLogViewer: View {
        
        let log: Binding<[String]?>
        
        var logText: String {
            log.wrappedValue?.joined(separator: "\n") ?? ""
        }
        
        var body: some View {
            NavigationView {
                ScrollView {
                    Text(logText)
                        .lineLimit(nil)
                        .padding()
                        .font(.footnote)
                    Spacer()
                }
                .navigationTitle("Import Log")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            self.log.wrappedValue = nil
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Copy") {
                            UIPasteboard.general.string = logText
                        }
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
