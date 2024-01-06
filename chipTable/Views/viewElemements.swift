//
//  viewElemements.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/6/23.
//

import Foundation
import SwiftUI

struct buttonView: View {
    var title: String
    var backgroundColor = Color("Light Blue")
    var titleColor = Color("Card")
    var body: some View {
        Text(title)
            .foregroundColor(titleColor)
            .font(Font.system(size: 20, weight: .medium))
            .frame(width: 350, height: 55)
//            .frame(minWidth: 350, maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(12)
    }
}

struct bottomCardView: View {
    var body: some View {
        HStack(spacing: 8.0) {
            Image(systemName: "suit.club.fill")
                .font(Font.system(size: 90))
                .foregroundColor(Color("Blue"))
                .padding(.bottom, 120.0)
                .padding(.top, 50.0)
                .frame(width: 200)
                .background(Color("Card"))
                .cornerRadius(20)
            Spacer()
            VStack {
                Spacer()
                    .frame(height: 90)
                Image(systemName: "suit.heart.fill")
                    .font(Font.system(size: 90))
                    .foregroundColor(Color("Red"))
                    .padding(.bottom, 120.0)
                    .padding(.top, 50.0)
                    .frame(width: 200)
                    .background(Color("Card"))
                    .cornerRadius(20)
            }
            Spacer()
            Image(systemName: "suit.spade.fill")
                .font(Font.system(size: 90))
                .foregroundColor(Color("Blue"))
                .padding(.bottom, 120.0)
                .padding(.top, 50.0)
                .frame(width: 200)
                .background(Color("Card"))
                .cornerRadius(20)
            Spacer()
            VStack {
                Spacer()
                    .frame(height: 90)
                Image(systemName: "suit.diamond.fill")
                    .font(Font.system(size: 90))
                    .foregroundColor(Color("Red"))
                    .padding(.bottom, 120.0)
                    .padding(.top, 50.0)
                    .frame(width: 200)
                    .background(Color("Card"))
                    .cornerRadius(20)
            }
        }
        .padding(.horizontal, 25.0)
        .padding(.bottom, -70)
    }
}
