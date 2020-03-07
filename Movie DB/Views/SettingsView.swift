//
//  SettingsView.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI
import JFSwiftUI
import CSV

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
    
    @State private var isShowingUpdateResult = false
    @State private var updateResult: (successes: Int, failures: Int) = (0, 0)
    @State private var updateInProgress = false
    @State private var isShowingResetAlert = false
    
    @State private var shareSheet = ShareSheet()
    @State private var documentPicker: DocumentPicker?
    
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
                                self.updateResult = MediaLibrary.shared.update()
                                self.isShowingUpdateResult = true
                                DispatchQueue.main.sync {
                                    self.updateInProgress = false
                                }
                            }
                        }, label: Text("Update Media").closure())
                            .disabled(self.updateInProgress)
                        // MARK: - Import Button
                        Button(action: {
                            self.documentPicker = DocumentPicker(callback: { url in
                                do {
                                    let csv = try String(contentsOf: url)
                                    print("Imported csv file. Trying to import into library.")
                                    let mediaObjects = CSVDecoder().decode(csv)
                                    // TODO: Ask if the import number is correct
                                    MediaLibrary.shared.mediaList.append(contentsOf: mediaObjects)
                                } catch let exception {
                                    print("Error reading imported csv file:")
                                    print(exception)
                                }
                            })
                        }, label: {
                            Text("Import Media")
                        })
                            .popover(isPresented: .init(get: {
                                self.documentPicker != nil
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
                            self.isShowingResetAlert = true
                        }, label: Text("Reset Library").closure())
                            .alert(isPresented: $isShowingResetAlert) {
                                Alert(title: Text("Reset Library"), message: Text("This will delete all media objects in your library. Do you want to continue?"), primaryButton: .default(Text("Cancel")), secondaryButton: .destructive(Text("Delete"), action: {
                                    // Delete all objects
                                    MediaLibrary.shared.mediaList.removeAll()
                                    MediaLibrary.shared.save()
                                }))
                        }
                    }
            }
            .navigationBarTitle("Settings")
        }
        .onDisappear(perform: save)
            
        .alert(isPresented: $isShowingUpdateResult) {
            let s = self.updateResult.successes
            let f = self.updateResult.failures
            var message = "\(s == 0 ? "No" : "\(s)") media \(s == 1 ? "object has" : "objects have") been updated."
            if f != 0 {
                message += " \(f) media \(f == 1 ? "object" : "objects") could not be updated."
            }
            return Alert(title: Text("Update completed"), message: Text(message), dismissButton: .default(Text("Okay")))
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
