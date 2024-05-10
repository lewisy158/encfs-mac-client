//
//  ActionView.swift
//  mac_test
//
//  Created by 应璐暘 on 2024/5/10.
//

import SwiftUI

struct ActionView: View {
    let text: LocalizedStringKey
    let subtitle: String
    let actionName: LocalizedStringKey
    let action: () -> Void

    init(
        text: LocalizedStringKey,
        subtitle: String = "",
        actionName: LocalizedStringKey,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.subtitle = subtitle
        self.actionName = actionName
        self.action = action
    }

    var body: some View {
        HStack(alignment: subtitle.isEmpty ? .center : .top) {
            VStack(alignment: .leading) {
                Text(text)
                    .foregroundStyle(.primary)

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .truncationMode(.middle)
                        .lineLimit(2)
                        .help(subtitle)
                }
            }
            Spacer()
            Button(actionName) {
                action()
            }
        }
    }
}
