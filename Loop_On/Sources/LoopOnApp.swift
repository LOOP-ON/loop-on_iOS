import SwiftUI

@main
struct LOOPONApp: App {
    @State private var isFinishedSplash = false
    
    var body: some Scene {
        WindowGroup {
            if isFinishedSplash{
                ContentView()
            } else{
                SplashView(isFinishedSplash: $isFinishedSplash)
            }
            
        }
    }
}
