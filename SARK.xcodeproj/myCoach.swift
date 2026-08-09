//
//  myCoach.swift
//  firstapp
//
//  Created by hajer almejel on 21/02/1448 AH.
//
import SwiftUI

struct myCoach: View {
    var body: some View {
        ZStack(alignment: .top){
            Color("Background")
                .ignoresSafeArea()
            
            VStack(spacing: 50) {
                Text("My Coaches")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Color("priemary texts"))
                    
                    
                
                Text("Your projects")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color("priemary texts"))
                
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Home Bakery project")
                        .font(.system(size: 13))
                        .foregroundStyle(Color("faded text"))
                    
                    HStack(spacing: 14) {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color("Green"))
                            .frame(width: 70, height: 70)
                            .overlay(
                                Image("bakery")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(12)
                            )
                        
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("F&B AI Coach")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color("priemary texts"))
                            
                            Text("0%")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color("priemary texts"))
                            
                            ProgressView(value: 0.0)
                                .tint(Color("Green"))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color("faded text"))
                    }
                    .padding(16)
                    .frame(width: 365, height: 220)
                    .frame(height: 120)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color("boxes"))
                    )
                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)                 }
                
                
                .padding(.horizontal, 20)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Coffee Shop project")
                        .font(.system(size: 13))
                        .foregroundStyle(Color("faded text"))
                    
                    HStack(spacing: 14) {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color("boxes"))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image("coffee")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(12)
                            )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("F&B AI Coach")
                                .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color("priemary texts"))
                            
                            Text("70%")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color("priemary texts"))
                            
                            ProgressView(value: 0.7)
                                .tint(Color("Green"))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color("faded text"))
                    }
                    .padding(16)
                    .frame(width: 365, height: 220)
                    .frame(height: 120)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color("boxes"))
                    )
                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
                }
            }
        }
        
    }
}
    
    #Preview {
        myCoach()
    }
    

