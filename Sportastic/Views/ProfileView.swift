import SwiftUI
struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    
    @StateObject var currentUserViewModel = CurrentUserViewModel()
    
    @State var actionSheetShowing = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                ProfileImage(url: viewModel.imageURL)
                    .frame(width: 200, height: 200)
                if viewModel.isWorking {
                    HStack {
                        Text ("Setting Profile Photo ")
                            .foregroundColor(.secondary)
                        ProgressView()
                    }
                }
                else {
                    ImagePickerButton(imageURL: $viewModel.imageURL) {
                        Label("Choose Image", systemImage: "photo.fill")
                    }
                }
                Spacer()
                Grid() {
                    GridRow {
                        Text("Name")
                        Spacer()
                        Text(currentUserViewModel.currentUser?.name ?? "Unknown")
                    }
                    Divider()
                    GridRow {
                        Text("Email")
                        Spacer()
                        Text("\(currentUserViewModel.currentUser?.email ?? "")")
                    }
                    Divider()
                    GridRow {
                        Text("Phone Number")
                        Spacer()
                        Text("\(currentUserViewModel.currentUser?.phoneNumber ?? "")")
                    }
                    Divider()
                    GridRow {
                        Text("Age")
                        Spacer()
                        Text("\(getAgeFromBirthday(birthday: currentUserViewModel.currentUser?.birthday ?? Date()))")
                    }
                    Divider()
                }
                
                
                Spacer()
            }
            .navigationTitle("Profile")
            .toolbar {
                HStack {
                    Button("Delete Account", action: {
                        actionSheetShowing = true
                    })
                    .actionSheet(isPresented: $actionSheetShowing) {
                        ActionSheet(title: Text("Delete Account"), message: Text("Are you sure you want to delete your account? You will not be able to access it again."), buttons: [
                            .default(Text("Yes, delete my account."), action: {
                                currentUserViewModel.deleteUser()
                                viewModel.signOut()
                            }),.cancel()
                        ])
                    }
                    Button("Sign Out", action: {
                        viewModel.signOut()
                    })
                }
            }
        }
        .onAppear(perform: { currentUserViewModel.getUser() })
        .alert("Error", error: $viewModel.error)
        .disabled(viewModel.isWorking)
    }
    
    func getAgeFromBirthday(birthday: Date) -> Int {
        return Calendar.current.dateComponents([.year, .month, .day], from: birthday, to: Date()).year ?? 0
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: ProfileViewModel(user: User.testUser, authService: AuthService()))
    }
}
