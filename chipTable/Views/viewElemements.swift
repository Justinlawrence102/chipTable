//
//  viewElemements.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/6/23.
//

import Foundation
import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.white)
            .font(Font.system(size: 20, weight: .medium))
            .frame(width: 350, height: 55)
            .background(Color("Light Blue"))
            .cornerRadius(12)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
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
struct PrimaryButtonView: View{
    var title: String
    var action : ((Bool) -> Void)

    var body: some View {
#if os(visionOS)
        Button(action: {
            print(title)
            action(true)
        }) {
            Text(title)
                .frame(width: 300, height: 55)
        }
        .background(Color("Light Blue"))
        .cornerRadius(28)
#else
        Button(action: {
            print(title)
            action(true)
        }) {
            Text(title)
                .foregroundColor(Color.white)
                .font(.body)
                .frame(maxWidth: 350)
                .frame(height: 55)
                .background(Color("Light Blue"))
                .cornerRadius(12)
        }
//        .buttonStyle(PrimaryButtonStyle())
#endif
    }
}

struct SecondaryButtonView: View{
    var title: String
    var action : ((Bool) -> Void)
    
    var body: some View {
#if os(visionOS)
        Button(action: {
            print(title)
            action(true)
        }) {
            Text(title)
                .frame(width: 300, height: 60)
        }
        .background(.thinMaterial)
        .cornerRadius(28)
#else
        Button(action: {
            print(title)
            action(true)
        }) {
            Text(title)
                .foregroundColor(Color("Light Blue"))
                .font(.body)
                .frame(maxWidth: 350)
                .frame(height: 55)
                .background(Color("Card"))
                .cornerRadius(12)
        }
//        .buttonStyle(SecondaryButtonStyle())
#endif
    }
}
struct buttonView: View {
    var title: String
    var backgroundColor = Color("Light Blue")
    var titleColor = Color.white
    var body: some View {
        Text(title)
            .foregroundColor(titleColor)
            .font(.body)
            .frame(width: 400, height: 70)
            .background(backgroundColor)
            .cornerRadius(12)
    }
}

struct xButton: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
#if os(visionOS)
            Button(action: {
                print("Exit")
                dismiss()
            }, label: {
                ZStack {
                    Image(systemName: "xmark")
                }
            })
            .padding()
            .frame(width: 33, height: 33)
            .cornerRadius(20)
#else
            Button(action: {
                print("Exit")
                dismiss()
            }, label: {
                ZStack {
                    Image(systemName: "xmark")
                }
                .font(Font.callout.weight(.semibold))
                .foregroundStyle(Color.gray)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(20)
            })
            .frame(width: 33, height: 33)
            .cornerRadius(20)
#endif
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
