// Copyright © 2023 Jonas Frey. All rights reserved.

import SwiftUI

/// Displays the runtime of a movie
struct RuntimeInfoView: View {
    // The formatter used to display the runtime of the movie in minutes (e.g. "130 minutes")
    private static let minutesFormatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.minute]
        f.unitsStyle = .full
        return f
    }()
    
    // The formatter used to display the runtime of the movie in hours and minutes (e.g. "2h 10m")
    private static let hoursFormatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.hour, .minute]
        f.unitsStyle = .abbreviated
        return f
    }()
    
    @EnvironmentObject private var mediaObject: Media
    
    var body: some View {
        if let runtime = (mediaObject as? Movie)?.runtime {
            Group {
                if runtime > 60 {
                    let components = DateComponents(calendar: .current, timeZone: .current, minute: runtime)
                    let minutesString = Self.minutesFormatter.string(from: components)!
                    let hoursString = Self.hoursFormatter.string(from: components)!
                    Text(Strings.Detail.runtimeValueLabel(minutesString, hoursString))
                } else {
                    let components = DateComponents(calendar: .current, timeZone: .current, minute: runtime)
                    Text(Self.minutesFormatter.string(from: components)!)
                }
            }
            .headline(Text("\(Image(systemName: "stopwatch")) \(Strings.Detail.runtimeHeadline)"))
        } else {
            EmptyView()
        }
    }
}

#Preview {
    RuntimeInfoView()
        .previewEnvironment()
}
