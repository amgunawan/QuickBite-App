import SwiftUI
import PhotosUI

struct StoreBrandingView: View {
    @State private var bannerPickedItem: PhotosPickerItem? = nil
    @State private var iconPickedItem: PhotosPickerItem? = nil
    @State private var bannerImage: UIImage? = nil
    @State private var iconImage: UIImage? = nil
    @State private var bannerFileName: String = ""
    @State private var iconFileName: String = ""

    @State private var open24Hours = true
    @State private var openingTime: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var closingTime: Date = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()

    @State private var openDays: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    
    @State private var showOpeningPicker = false
    @State private var showClosingPicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            RegistrationHeader(step: 1,
                               title: "Build your Quickbite Store",
                               subtitle: "Configure your store's menu and branding")
            
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    
                    Group {
                        Text("Store Banner").font(.headline)
                        Text("This will appear on the top of your store profile")
                            .font(.footnote).foregroundColor(.secondary)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                            if let img = bannerImage {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
                        .frame(height: 120)
                        
                        HStack(spacing: 10) {
                            PhotosPicker(selection: $bannerPickedItem, matching: .images) {
                                pillButton("Choose File")
                            }
                            Text(bannerFileName.isEmpty ? "No file chosen" : bannerFileName)
                                .font(.subheadline).foregroundColor(.secondary)
                                .lineLimit(1).truncationMode(.middle)
                            Spacer()
                        }
                        .padding(.bottom, 8)
                    }
                    
                    Group {
                        Text("Search Menu Icon").font(.headline)
                        
                        HStack(alignment: .top, spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(.secondarySystemBackground))
                                if let img = iconImage {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                } else {
                                    Image(systemName: "photo.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(width: 64, height: 64)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 10) {
                                    PhotosPicker(selection: $iconPickedItem, matching: .images) {
                                        pillButton("Choose File")
                                    }
                                    Text(iconFileName.isEmpty ? "No file chosen" : iconFileName)
                                        .font(.subheadline).foregroundColor(.secondary)
                                        .lineLimit(1).truncationMode(.middle)
                                }
                                
                                Text("A clear, square image for search results")
                                    .font(.footnote).foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                    
                    Text("Operational Hours").font(.headline)
                        .padding(.top, 10)
                    
                    VStack(spacing: 0) {
                        GroupBoxRow {
                            Toggle(isOn: $open24Hours) { Text("Open 24 Hours") }
                        }
                        
                        GroupBoxRow {
                            HStack {
                                Text("Opening Time")
                                    .foregroundColor(open24Hours ? .secondary : .primary)
                                Spacer()
                                Button(formatTime(openingTime)) { showOpeningPicker = true }
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
                                Button(formatTime(closingTime)) { showClosingPicker = true }
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
                                Image(systemName: "chevron.right").foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 48)
                        }
                        .background(Color(.systemBackground))
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .scrollIndicators(.hidden)
            
            NavigationLink(destination: MenuSetupView(),
                           label: {
                OrangeButton(title: "Continue to Menu Setup", action: {}, enabled: canContinue)
            })
            .padding()
        }
        .sheet(isPresented: $showOpeningPicker) {
            TimePickerSheet(title: "Opening Time", date: $openingTime)
                .presentationDetents([.height(320)])
        }
        .sheet(isPresented: $showClosingPicker) {
            TimePickerSheet(title: "Closing Time", date: $closingTime)
                .presentationDetents([.height(320)])
        }
        .onChange(of: bannerPickedItem) { _, newValue in
            handlePhotoPicker(item: newValue, image: $bannerImage, fileName: $bannerFileName)
        }
        .onChange(of: iconPickedItem) { _, newValue in
            handlePhotoPicker(item: newValue, image: $iconImage, fileName: $iconFileName)
        }
    }
    
    private func pillButton(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(Capsule().fill(Color.orange.opacity(0.15)))
            .foregroundColor(.orange)
    }

    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "h:mm a"; return f.string(from: date)
    }
    
    private var canContinue: Bool {
        bannerImage != nil && iconImage != nil
    }
    
    private func handlePhotoPicker(item: PhotosPickerItem?, image: Binding<UIImage?>, fileName: Binding<String>) {
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
        StoreBrandingView()
    }
}
