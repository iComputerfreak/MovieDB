//
//  SettingsView.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI
import JFSwiftUI

struct SettingsView: View {
    
    // Reference to the config instance
    @ObservedObject private var config: JFConfig = JFConfig.shared
    
    init() {
    }
    
    func save() {
    }
    
    // TODO: Reload all media objects when changing region / Language?
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
    
    // Alerts
    @ObservedObject private var alertController = AlertController()
    
    @State private var shareSheet = ShareSheet()
    @State private var documentPicker: DocumentPicker?
    @State private var alert: Alert? = nil
    
    var body: some View {
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
                    AnyView(
                        HStack {
                            ActivityIndicator()
                            Text("Updating media library...")
                        }
                    )
                    .hidden(condition: !self.updateInProgress)
                }()) {
                    
                    // MARK: - Update Button
                    Button(action: {
                        DispatchQueue.global().async {
                            DispatchQueue.main.sync {
                                self.updateInProgress = true
                            }
                            // Update and show the result
                            let updateResult = MediaLibrary.shared.update()
                            DispatchQueue.main.sync {
                                self.updateInProgress = false
                                let s = updateResult.successes
                                let f = updateResult.failures
                                var message = "\(s == 0 ? "No" : "\(s)") media \(s == 1 ? "object has" : "objects have") been updated."
                                if f != 0 {
                                    message += " \(f) media \(f == 1 ? "object" : "objects") could not be updated."
                                }
                                self.alertController.present(title: "Update completed", message: message)
                            }
                        }
                    }, label: Text("Update Media").closure())
                        .disabled(self.updateInProgress)
                    
                    // MARK: - Import Button
                    Button(action: {
                        // Use iOS file picker
                        self.documentPicker = DocumentPicker(onSelect: { url in
                            print("Importing \(url.lastPathComponent).")
                            // Document picker finished. Invalidate it.
                            self.documentPicker = nil
                            do {
                                let csv = try String(contentsOf: url)
                                print("Imported csv file. Trying to import into library.")
                                let mediaObjects = CSVDecoder().decode(csv)
                                // Presenting will change UI
                                DispatchQueue.main.async {
                                    self.alertController.present(
                                        title: "Import",
                                        message: "Do you want to import \(mediaObjects.count) media \(mediaObjects.count == 1 ? "object" : "objects")?",
                                        primaryButton: .default(Text("Yes"), action: {
                                            MediaLibrary.shared.mediaList.append(contentsOf: mediaObjects)
                                            MediaLibrary.shared.save()
                                        }),
                                        secondaryButton: .cancel(Text("No")))
                                }
                            } catch let exception {
                                print("Error reading imported csv file:")
                                print(exception)
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
                        let encoder = CSVEncoder()
                        let csv = encoder.encode(MediaLibrary.shared.mediaList)
                        // Save the csv as a file to share it
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        let url: URL!
                        url = JFUtils.documentsPath.appendingPathComponent("MovieDB_Export.csv")
                        // Delete any old export, if it exists
                        if FileManager.default.fileExists(atPath: url.path) {
                            try? FileManager.default.removeItem(at: url)
                        }
                        do {
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
                    }, label: {
                        // Attach the share sheet above the export button (will be displayed correctly anyways)
                        ZStack(alignment: .leading) {
                            Text("Export Media")
                            shareSheet
                        }
                    })
                    // MARK: - Reset Button
                    Button(action: {
                        self.alertController.present(title: "Reset Library", message: "This will delete all media objects in your library. Do you want to continue?", primaryButton: .default(Text("Cancel")), secondaryButton: .destructive(Text("Delete"), action: {
                            // Delete all objects
                            MediaLibrary.shared.reset()
                        }))
                    }, label: Text("Reset Library").closure())
                }
                
                .alert(isPresented: $alertController.isShown, content: alertController.buildAlert)
            }
            .navigationBarTitle("Settings")
        }
        .onDisappear(perform: save)
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
