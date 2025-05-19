//
//  FuriganaText.swift
//  FlickDojoGame
//
//  Created by 市川涼 on 2025/05/06.
//

// FuriganaText.swift
import SwiftUI

struct FuriganaText: View {
    let kanji: String
    let reading: String
    let correctCount: Int

    var body: some View {
        VStack(spacing: 2) {
            Text(kanji)
                .font(.largeTitle)
                .foregroundColor(.black)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)

            HStack(spacing: 0) {
                ForEach(Array(reading.enumerated()), id: \.offset) { index, char in
                    Text(String(char))
                        .foregroundColor(index < correctCount ? .pink : .black)
                        .font(.title2)
                        .fontWeight(.medium)

                }
            }
        }
    }
}
