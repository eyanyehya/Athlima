//
//  CountDownView.swift
//  Sportastic
//
//  Created by Eyan Yehya on 9/25/22.
//

import SwiftUI

struct CountDownView: View {
    var timeLeft: String
    var body: some View {
        HStack {
            // days left
            VStack {
                Text("\(String(timeLeft[0]))\(String(timeLeft[1]))")
                    .italic()
                    .padding()
                Text("Days")
            }
            // hours left
            VStack {
                Text("\(String(timeLeft[2]))\(String(timeLeft[3]))")
                    .italic()
                    .padding()
                Text("Hours")
            }
            // minutes left
            VStack {
                Text("\(String(timeLeft[4]))\(String(timeLeft[5]))")
                    .italic()
                    .padding()
                Text("Minutes")
            }

            // seconds left
            VStack {
                Text("\(String(timeLeft[6]))\(String(timeLeft[7]))")
                    .italic()
                    .padding()
                Text("Seconds")
            }

        }
    }
}

extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}

struct CountDownView_Previews: PreviewProvider {
    static var previews: some View {
        CountDownView(timeLeft: "123")
    }
}
