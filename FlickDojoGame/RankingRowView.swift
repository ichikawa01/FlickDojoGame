//
//  RankingRowView.swift
//  FlickDojoGame
//
//  Created by 市川涼 on 2025/05/11.
//

import SwiftUI

struct RankingRowView: View {
    let index: Int
    let entry: RankingEntry
    let currentUserId: String?

    var body: some View {
        HStack {
            if index == 0 {
                Image(.medal1)
                    .resizable()
                    .frame(width: 35, height: 35)
                    .padding(.trailing, 6)
            } else if index == 1 {
                Image(.medal2)
                    .resizable()
                    .frame(width: 35, height: 35)
                    .padding(.trailing, 6)
            } else if index == 2 {
                Image(.medal3)
                    .resizable()
                    .frame(width: 35, height: 35)
                    .padding(.trailing, 6)
            } else {
                Text("\(index + 1)")
                    .bold()
                    .frame(width: 24, alignment: .trailing)
                    .padding(.trailing, 17)
            }

            Text(entry.userName)
            Spacer()
            Text("\(entry.score)")
                .bold()
        }
        .padding(.vertical, 4)
        .background(entry.userId == currentUserId ? Color.yellow.opacity(0.3) : Color.clear)
        .cornerRadius(8)

    }
}
