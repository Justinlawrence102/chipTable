//
//  viewElemements.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/6/23.
//

import Foundation
import SwiftUI

struct PrimaryButton: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.white)
            .font(Font.system(size: 20, weight: .medium))
            .frame(width: 350, height: 55)
            .background(Color("Light Blue"))
            .cornerRadius(12)
    }
}

struct SecondaryButton: ButtonStyle {
    var backgroundColor = Color("Card")
    var titleColor = Color("Light Blue")
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(titleColor)
            .font(Font.system(size: 20, weight: .medium))
            .frame(width: 350, height: 55)
            .background(backgroundColor)
            .cornerRadius(12)
    }
}
struct buttonView: View {
    var title: String
    var backgroundColor = Color("Light Blue")
    var titleColor = Color.white
    var body: some View {
//        if UIDevice.current.userInterfaceIdiom != .tv {
            Text(title)
                .foregroundColor(titleColor)
//                .font(Font.system(size: 20, weight: .medium))
                .font(.body)
                .frame(width: 400, height: 70)
                .background(backgroundColor)
                .cornerRadius(12)
//        }else {
//            Text(title)
////                .buttonStyle(.card)
//        }
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
