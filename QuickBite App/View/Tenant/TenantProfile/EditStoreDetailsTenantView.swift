import SwiftUI
import PhotosUI

struct EditStoreDetailsTenantView: View {

    let storeId: String
    
    // MARK: - Initial Existing Values
    @State private var bannerPickedItem: PhotosPickerItem? = nil
    @State private var iconPickedItem: PhotosPickerItem? = nil
    
    @State private var bannerImage: UIImage? = nil
    @State private var iconImage: UIImage? = nil
    
    @State private var bannerFileName: String = ""
    @State private var iconFileName: String = ""
    
    @State private var open24Hours: Bool = false
    @State private var openingTime: Date =
        Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date())!
    @State private var closingTime: Date =
        Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date())!
    
    @State private var openDays: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday, .friday]
    
    @State private var showOpeningPicker = false
    @State private var showClosingPicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // UI UNCHANGED
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .navigationTitle("Edit Store Details")
            .navigationBarTitleDisplayMode(.inline)
            
            Button(action: {
                print("Save changes for storeId:", storeId)
            }) {
                Text("Save Changes")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .font(.headline)
                    .cornerRadius(24)
            }
            .padding(.horizontal)
        }
        .toolbar(.hidden, for: .tabBar)
        // rest unchanged
    }
}

#Preview {
    NavigationView {
        EditStoreDetailsTenantView(storeId: "preview_store_id")
    }
}
