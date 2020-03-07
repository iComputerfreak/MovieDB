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
                    HStack {
                        ActivityIndicator()
                        Text("Updating media library...")
                    }
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
                        self.documentPicker = DocumentPicker(onSelect: { url in
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
                                        }),
                                        secondaryButton: .cancel(Text("No")))
                                }
                            } catch let exception {
                                print("Error reading imported csv file:")
                                print(exception)
                            }
                        }, onCancel: {
                            self.documentPicker = nil
                        })
                    }, label: {
                        Text("Import Media")
                    })
                        // TODO: Replace Binding with .init(get:), if fatalError never occurred.
                        .popover(isPresented: .init(get: {
                            self.documentPicker != nil
                        }, set: { newState in
                            fatalError("Seems this is called after all... Better uncomment that code below.")
                            /*print("Setting new state: \(newState)")
                            // If the new state is "hidden"
                            if newState == false {
                                self.documentPicker = nil
                            }*/
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
                        let url = JFUtils.documentsPath.appendingPathComponent("MovieDB_Export_\(formatter.string(from: Date())).csv")
                        do {
                            try csv.write(to: url, atomically: true, encoding: .utf8)
                        } catch let exception {
                            print(exception)
                            return
                        }
                        self.shareSheet.shareFile(url: url)
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
                            MediaLibrary.shared.mediaList.removeAll()
                            MediaLibrary.shared.save()
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
