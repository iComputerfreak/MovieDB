// Copyright © 2023 Jonas Frey. All rights reserved.

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

#Preview {
    VStack {
        CustomEditButton(isEditing: .constant(false))
        CustomEditButton(isEditing: .constant(true))
    }
}
