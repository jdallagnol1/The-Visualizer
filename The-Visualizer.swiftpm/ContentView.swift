//
//  TriangleScene.swift
//  Triangle
//
//  Created by João Vitor Dall Agnol Fernandes on 13/04/22.
//

import Foundation
import SwiftUI

enum intro {
    case first, second, third, fourth, fifth, triangle
}

struct FirstPage: View {
    @Binding var currentView: intro
    var body: some View {
        ZStack{
            Image("FIrstPage")
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

            Button("toSecond")
            {
                currentView = .second
            }
            .foregroundColor(.clear)
            .frame(width:  UIScreen.main.bounds.width/12, height:  UIScreen.main.bounds.height/22)
            .position(x: UIScreen.main.bounds.width/1.170, y: UIScreen.main.bounds.height/1.264)
        }
    }
}

struct SecondPage: View {
    @Binding var currentView: intro
    var body: some View {
        ZStack{
            Image("SecondPage")
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

            Button("previousPage")
            {
                currentView = .first
            }
            .foregroundColor(.clear)
            .frame(height:  UIScreen.main.bounds.height/22)
            .position(x: UIScreen.main.bounds.width/5.5, y: UIScreen.main.bounds.height/1.264)
            Button("toThirdPage")
            {
                currentView = .third
            }
            .foregroundColor(.clear)
            .frame(height:  UIScreen.main.bounds.height/22)
            .position(x: UIScreen.main.bounds.width/1.170, y: UIScreen.main.bounds.height/1.264)
        }
    }
}

struct ThirdPage: View {
    @Binding var currentView: intro
    var body: some View {
        ZStack{
            Image("ThirdPage")
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

            Button("previousPage")
            {
                currentView = .second
            }
            .foregroundColor(.clear)
            .frame(height:  UIScreen.main.bounds.height/22)
            .position(x: UIScreen.main.bounds.width/5.5, y: UIScreen.main.bounds.height/1.264)
            Button("toFourthPage")
            {
                currentView = .fourth
            }
            .foregroundColor(.clear)
            .frame(height:  UIScreen.main.bounds.height/22)
            .position(x: UIScreen.main.bounds.width/1.170, y: UIScreen.main.bounds.height/1.264)
        }
    }
}

struct FourthPage: View {
    @Binding var currentView: intro
    var body: some View {
        ZStack{
            Image("FourthPage")
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

            Button("previousPage")
            {
                currentView = .third
            }
            .foregroundColor(.clear)
            .frame(height:  UIScreen.main.bounds.height/22)
            .position(x: UIScreen.main.bounds.width/5.5, y: UIScreen.main.bounds.height/1.264)
            Button("ToFifth")
            {
                currentView = .fifth
            }
            .foregroundColor(.clear)
            .frame(height:  UIScreen.main.bounds.height/22)
            .position(x: UIScreen.main.bounds.width/1.170, y: UIScreen.main.bounds.height/1.264)
        }
    }
}

struct FifthPage: View {
    @Binding var currentView: intro
    var body: some View {
        ZStack{
            Image("FifthPage")
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

            Button("previousPage")
            {
                currentView = .fourth
            }
            .foregroundColor(.clear)
            .frame(height:  UIScreen.main.bounds.height/22)
            .position(x: UIScreen.main.bounds.width/5.5, y: UIScreen.main.bounds.height/1.264)
            Button("toTriangle")
            {
                currentView = .triangle
            }
            .foregroundColor(.clear)
            .frame(height:  UIScreen.main.bounds.height/22)
            .position(x: UIScreen.main.bounds.width/1.170, y: UIScreen.main.bounds.height/1.264)
        }
    }
}

struct ContenView: View {
    @State var showingTriangle = false
    @State var currentView: intro = .first
    
    var body: some View {
        switch currentView {
        case .first:
            FirstPage(currentView: $currentView)
                .ignoresSafeArea()
        case .second:
            SecondPage(currentView: $currentView)
                .ignoresSafeArea()
        case .third:
            ThirdPage(currentView: $currentView)
                .ignoresSafeArea()
        case .fourth:
            FourthPage(currentView: $currentView)
                .ignoresSafeArea()
        case .fifth:
            FifthPage(currentView: $currentView)
                .ignoresSafeArea()
        case .triangle:
            SpriteKitContainer(scene: SpriteKitScene())
                .ignoresSafeArea()
        }
    }
}
