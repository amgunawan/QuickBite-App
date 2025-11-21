import SwiftUI
import PhotosUI

struct EditStoreDetailsTenantView: View {
    
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
                    
                    // MARK: Store Banner
                    Group {
                        Text("Store Banner").font(.headline)
                        Text("This will appear on the top of your store profile")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                            
                            if let img = bannerImage {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                VStack {
                                    Image(systemName: "photo.fill.on.rectangle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 30)
                                        .foregroundColor(.secondary)
                                    Text("Upload Banner (16:9)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .frame(height: 130)
                        
                        HStack {
                            PhotosPicker(selection: $bannerPickedItem, matching: .images) {
                                pillButton("Choose File")
                            }
                            Text(bannerFileName.isEmpty ? "No file chosen" : bannerFileName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Spacer()
                        }
                    }
                    
                    // MARK: Search Menu Icon
                    Group {
                        Text("Search Menu Icon").font(.headline)
                        
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.secondarySystemBackground))
                                
                                if let img = iconImage {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                } else {
                                    Image(systemName: "photo.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(width: 64, height: 64)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    PhotosPicker(selection: $iconPickedItem, matching: .images) {
                                        pillButton("Choose File")
                                    }
                                    
                                    Text(iconFileName.isEmpty ? "No file chosen" : iconFileName)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                
                                Text("A clear, square image for search results")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                    
                    // MARK: Operational Hours
                    Text("Operational Hours").font(.headline)
                    
                    VStack(spacing: 0) {
                        GroupBoxRow {
                            Toggle("Open 24 Hours", isOn: $open24Hours)
                        }
                        
                        GroupBoxRow {
                            HStack {
                                Text("Opening Time")
                                    .foregroundColor(open24Hours ? .secondary : .primary)
                                Spacer()
                                Button(formatTime(openingTime)) {
                                    showOpeningPicker = true
                                }
                                .font(.callout.weight(.semibold))
                                .foregroundColor(open24Hours ? .gray : .orange)
                                .disabled(open24Hours)
                            }
                        }
                        
                        GroupBoxRow {
                            HStack {
                                Text("Closing Time")
                                    .foregroundColor(open24Hours ? .secondary : .primary)
                                Spacer()
                                Button(formatTime(closingTime)) {
                                    showClosingPicker = true
                                }
                                .font(.callout.weight(.semibold))
                                .foregroundColor(open24Hours ? .gray : .orange)
                                .disabled(open24Hours)
                            }
                        }
                        
                        NavigationLink {
                            WeeklyScheduleView(openDays: $openDays)
                        } label: {
                            HStack {
                                Text("Weekly Schedule")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 48)
                        }
                        .background(Color(.systemBackground))
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                    
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .navigationTitle("Edit Store Details")
            .navigationBarTitleDisplayMode(.inline)
            
            // MARK: Save button
            Button(action: {
                print("Save changes tapped")
            }) {
                Text("Save Changes")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .font(.headline)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .onChange(of: bannerPickedItem) { _, newValue in
            handlePhotoPicker(item: newValue,
                              image: $bannerImage,
                              fileName: $bannerFileName)
        }
        .onChange(of: iconPickedItem) { _, newValue in
            handlePhotoPicker(item: newValue,
                              image: $iconImage,
                              fileName: $iconFileName)
        }
        .sheet(isPresented: $showOpeningPicker) {
            TimePickerSheet(title: "Opening Time", date: $openingTime)
                .presentationDetents([.height(320)])
        }
        .sheet(isPresented: $showClosingPicker) {
            TimePickerSheet(title: "Closing Time", date: $closingTime)
                .presentationDetents([.height(320)])
        }
    }
    
    // MARK: Helpers
    private func pillButton(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color.orange.opacity(0.15)))
            .foregroundColor(.orange)
    }
    
    private func formatTime(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: d)
    }
    
    private func handlePhotoPicker(
        item: PhotosPickerItem?,
        image: Binding<UIImage?>,
        fileName: Binding<String>
    ) {
        guard let item else { return }
        
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiimg = UIImage(data: data) {
                image.wrappedValue = uiimg
                fileName.wrappedValue = await item.itemIdentifier ?? "selected_file.png"
            }
        }
    }
}

#Preview {
    NavigationView {
        EditStoreDetailsTenantView()
    }
}
