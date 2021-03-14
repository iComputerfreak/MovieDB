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
    
    init() {
    }
    
    func save() {
    }
    
    // TODO: Reload all media objects when changing region / Language to use the correct localized title and information
    var sortedLanguages: [String] {
        Locale.isoLanguageCodes.sorted { (code1, code2) -> Bool in
            // Sort nil values to the end
            guard let language1 = JFUtils.languageString(for: code1) else {
                return false
            }
            guard let language2 = JFUtils.languageString(for: code2) else {
                return true
            }
            return language1.lexicographicallyPrecedes(language2)
        }
    }
    
    var sortedRegions: [String] {
        Locale.isoRegionCodes.sorted { (code1, code2) -> Bool in
            // Sort nil values to the end
            guard let region1 = JFUtils.regionString(for: code1) else {
                return false
            }
            guard let region2 = JFUtils.regionString(for: code2) else {
                return true
            }
            return region1.lexicographicallyPrecedes(region2)
        }
    }
    
    @State private var updateInProgress = false
    
    @State private var shareSheet = ShareSheet()
    @State private var documentPicker: DocumentPicker?
    
    @State private var isLoading: Bool = false
    
    var body: some View {
        LoadingView(isShowing: $isLoading) {
            NavigationView {
                Form {
                    Section {
                        Toggle(isOn: $config.showAdults, label: Text("Show Adult Content").closure())
                        Picker("Database Language", selection: $config.language) {
                            ForEach(self.sortedLanguages, id: \.self) { code in
                                Text(JFUtils.languageString(for: code) ?? code)
                                    .tag(code)
                            }
                        }
                        Picker("Region", selection: $config.region) {
                            ForEach(self.sortedRegions, id: \.self) { code in
                                Text(JFUtils.regionString(for: code) ?? code)
                                    .tag(code)
                            }
                        }
                    }
                    Section(footer: {
                        VStack {
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
                    }()) {
                        
                        // MARK: - Update Button
                        Button(action: {
                            self.updateInProgress = true
                            DispatchQueue.global().async {
                                // Update and show the result
                                self.library.update() { (updateCount: Int?, error: Error?) in
                                    
                                    if let error = error {
                                        print("Error updating media objects: \(error)")
                                        AlertHandler.showSimpleAlert(title: "Update error", message: "Error updating media objects: \(error.localizedDescription)")
                                        return
                                    }
                                    
                                    guard let updateCount = updateCount else {
                                        print("Error updating media objects.")
                                        return
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.updateInProgress = false
                                        let message = "\(updateCount == 0 ? "No" : "\(updateCount)") media \(updateCount == 1 ? "object has" : "objects have") been updated."
                                        AlertHandler.showSimpleAlert(title: "Update completed", message: message)
                                    }
                                }
                            }
                        }, label: Text("Update Media").closure())
                        .disabled(self.updateInProgress)
                                                
                        // MARK: - Import Button
                        Button(action: {
                            // Use iOS file picker
                            self.documentPicker = DocumentPicker(onSelect: { url in
                                print("Importing \(url.lastPathComponent).")
                                self.isLoading = true
                                // Document picker finished. Invalidate it.
                                self.documentPicker = nil
                                
                                // Perform the import into a separate context on a background thread
                                PersistenceController.shared.container.performBackgroundTask { (importContext: NSManagedObjectContext) in
                                    // Load the CSV data
                                    do {
                                        let csvString = try String(contentsOf: url)
                                        print("Read csv file. Trying to import into library.")
                                        let importer: CSVImporter<Media?> = CSVImporter<Media?>(contentString: csvString)
                                        importer.startImportingRecords { (headerValues: [String]) in
                                            // Check if the header contains the necessary values
                                            for header in CSVManager.requiredImportKeys {
                                                if !headerValues.contains(header.rawValue) {
                                                    // TODO: Show error
                                                }
                                            }
                                            for header in CSVManager.optionalImportKeys {
                                                if !headerValues.contains(header.rawValue) {
                                                    // TODO: Show warning that a key is missing, but that it was ignored.
                                                }
                                            }
                                        } recordMapper: { values in CSVManager.createMedia(from: values, context: importContext) }
                                        .onFail {
                                            // TODO: Show that something went wrong
                                        }
                                        .onFinish { (mediaObjects) in
                                            // Presenting will change UI
                                            DispatchQueue.main.async {
                                                // TODO: Tell the user how many duplicates were not added
                                                let controller = UIAlertController(title: "Import",
                                                                                   message: "Imported \(mediaObjects.count) media \(mediaObjects.count == 1 ? "object" : "objects")",
                                                                                   preferredStyle: .alert)
                                                controller.addAction(UIAlertAction(title: "Undo", style: .destructive, handler: { _ in
                                                    // Reset all the work we have just done
                                                    importContext.reset()
                                                }))
                                                controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                                                    // Make the changes to this context permanent by saving them to disk
                                                    // TODO: Should this context be a sub-context of the viewContext? This way we would push them into the viewContext and avoid having to merge the viewContext with the container.
                                                    PersistenceController.saveContext(context: importContext)
                                                }))
                                                self.isLoading = false
                                                AlertHandler.presentAlert(alert: controller)
                                            }
                                        }
                                        
                                        
                                    } catch {
                                        print("Error importing: \(error)")
                                        AlertHandler.showSimpleAlert(title: "Import Error", message: "Error importing the media objects: \(error.localizedDescription)")
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
                        }, label: {
                            Text("Import Media")
                        })
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
                        Button(action: {
                            // Prepare for export
                            print("Exporting...")
                            self.isLoading = true
                            
                            // Perform the export in a separate context on a background thread
                            PersistenceController.shared.container.performBackgroundTask { (exportContext: NSManagedObjectContext) in
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
                                self.shareSheet.shareFile(url: url)
                                #endif
                                
                                // Delete the file after sharing (this is only the local copy, that will be shared)
                                if FileManager.default.fileExists(atPath: url.path) {
                                    try? FileManager.default.removeItem(at: url)
                                }
                            }
                        }, label: {
                            // Attach the share sheet above the export button (will be displayed correctly anyways)
                            ZStack(alignment: .leading) {
                                Text("Export Media")
                                shareSheet
                            }
                        })
                        
                        // MARK: - Import Tags
                        Button(action: {
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
                                            let controller = UIAlertController(title: "Import",
                                                                               message: "Do you want to import \(count) tag\(count == 1 ? "" : "s")?",
                                                                               preferredStyle: .alert)
                                            controller.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                                                // Use a background context for importing the tags
                                                PersistenceController.shared.container.performBackgroundTask { (context) in
                                                    do {
                                                        try TagImporter.import(importData, context: context)
                                                        try context.save()
                                                    } catch {
                                                        print(error)
                                                        AlertHandler.showSimpleAlert(title: "Error Importing Tags", message: error.localizedDescription)
                                                    }
                                                }
                                            }))
                                            controller.addAction(UIAlertAction(title: "No", style: .cancel))
                                            self.isLoading = false
                                            AlertHandler.presentAlert(alert: controller)
                                        }
                                    } catch let error as LocalizedError {
                                        print("Error importing: \(error)")
                                        AlertHandler.showSimpleAlert(title: "Import Error", message: "Error importing the tags: \(error.localizedDescription)")
                                        DispatchQueue.main.async {
                                            self.isLoading = false
                                        }
                                    } catch let otherError {
                                        print("Unknown Error: \(otherError)")
                                        assertionFailure("This error should be captured specifically to give the user a more precise error message.")
                                        AlertHandler.showSimpleAlert(title: "Import Error", message: "There was an error importing the tags.")
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
                        }, label: {
                            Text("Import Tags")
                        })
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
                        
                        // MARK: - Export Tags
                        Button(action: {
                            var url: URL!
                            PersistenceController.shared.container.performBackgroundTask { (context) in
                                do {
                                    let exportData: String = try TagImporter.export(context: context)
                                    // Save as a file to share it
                                    url = JFUtils.documentsPath.appendingPathComponent("MovieDB_Tags_Export.txt")
                                    // Delete any old export, if it exists (this is only the local copy, that will be shared)
                                    if FileManager.default.fileExists(atPath: url.path) {
                                        try? FileManager.default.removeItem(at: url)
                                    }
                                    try exportData.write(to: url, atomically: true, encoding: .utf8)
                                } catch let exception {
                                    print("Error writing Tags Export file")
                                    print(exception)
                                    return
                                }
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
                            self.shareSheet.shareFile(url: url)
                            #endif
                        }, label: Text("Export Tags").closure())
                        
                        // MARK: - Reset Button
                        Button(action: {
                            let controller = UIAlertController(title: "Reset Library", message: "This will delete all media objects in your library. Do you want to continue?", preferredStyle: .alert)
                            controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                            controller.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                                // Don't reset the tags
                                do {
                                    try self.library.reset()
                                } catch let e {
                                    print("Error resetting media library")
                                    print(e)
                                    AlertHandler.showSimpleAlert(title: "Error resetting library", message: e.localizedDescription)
                                }
                            }))
                            AlertHandler.presentAlert(alert: controller)
                        }, label: Text("Reset Library").closure())
                    }
                    
                }
                .navigationBarTitle("Settings")
            }
            .onDisappear(perform: save)
        }
    }
    
    struct Keys {
        static let showAdults = "showAdults"
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
