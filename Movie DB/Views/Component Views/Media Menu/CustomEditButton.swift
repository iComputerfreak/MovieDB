//
//  CustomEditButton.swift
//  Movie DB
//
//  Created by Jonas Frey on 27.05.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct CustomEditButton: View {
    @Binding var isEditing: Bool
    
    var body: some View {
        Button(isEditing ? Strings.Generic.editButtonLabelDone : Strings.Generic.editButtonLabelEdit) {
            withAnimation(.easeInOut) {
                isEditing.toggle()
            }
        }
    }
}

struct CustomEditButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CustomEditButton(isEditing: .constant(false))
            CustomEditButton(isEditing: .constant(true))
        }
    }
}
