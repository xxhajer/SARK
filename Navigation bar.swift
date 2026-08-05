//
//  Navigation bar.swift
//  firstApp
//
//  Created by Danah yousef Almansour on 20/02/1448 AH.
//

import SwiftUI

struct Navigation_bar: View {
    var body: some View {
        ZStack{
            VStack{
             Spacer()
                
                HStack{
                    VStack{
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    Spacer()
                    VStack{
                        Image(systemName: "briefcase.fill")
                        Text("Business")
                    }
                    Spacer()
                    VStack{
                        Image(systemName: "sparkles")
                        Text("AI Coach")
                        
                    }
                    Spacer()
                    VStack{
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                    
                }
                .padding(.horizontal,25)
                .padding(.vertical, 15)
                .background(Color.white)
                .cornerRadius(35)
                .shadow(radius: 5)
                .padding()
            }
        }
    }
}

#Preview {
    Navigation_bar()
}
