//
//  StoreBrandingView.swift
//  QuickBite
//
//  Created by student on 13/11/25.
//

import SwiftUI
import PhotosUI

struct StoreBrandingView: View {
    @EnvironmentObject var storeVM: StoreRegistrationViewModel
    
    @EnvironmentObject var authVM: AuthenticationViewModel
    
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
            
            MenuHeader(step: 1,
                               title: "Build your Quickbite Store",
                               subtitle: "Configure your store's menu and branding")
            
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    
                    storeBannerSection
                    
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
                                        .frame(width: 64, height: 64)
                                        .clipped()
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
                    
                    operationalHoursSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .scrollIndicators(.hidden)
            
            NavigationLink(destination: MenuSetupView(),
                           label: {
                OrangeButton(title: "Continue to Menu Setup", enabled: canContinue)
            })
            .simultaneousGesture(TapGesture().onEnded {
                storeVM.saveDraft()
                Task {
                    do {
                        try await authVM.updateOnboardingStep(6)
                    } catch {
                        print("Failed to update onboarding step: \(error)")
                    }
                }
            })
            .padding()
        }
        .onAppear {
            if storeVM.openDays.isEmpty {
                storeVM.openDays = openDays
                storeVM.openingTime = openingTime
                storeVM.closingTime = closingTime
            }
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
            handlePhotoPicker(item: newValue) { image, filename in
                let resized = ImageResizeHelper.resize(image, mode: .ratio16x9)
                Task { @MainActor in
                    bannerImage = resized
                    bannerFileName = filename
                    storeVM.bannerImage = resized   // ✅ SAVE TO VIEWMODEL
                    print("[Branding] stored banner -> storeVM OK")
                }
            }
        }

        .onChange(of: iconPickedItem) { _, newValue in
            handlePhotoPicker(item: newValue) { image, filename in
                let resized = ImageResizeHelper.resize(image, mode: .square)
                Task { @MainActor in
                    iconImage = image
                    iconFileName = filename
                    storeVM.searchIcon = image   // ✅ SAVE TO VIEWMODEL
                    print("[Branding] stored icon -> storeVM OK")
                }
            }
        }
        
        .onChange(of: open24Hours) { _, isOn in
            storeVM.open24Hours = isOn

            let calendar = Calendar.current   // ✅ shared scope

            if isOn {
                // 24-hour operation
                openingTime = calendar.startOfDay(for: Date())
                closingTime = calendar.date(
                    bySettingHour: 23,
                    minute: 59,
                    second: 0,
                    of: Date()
                ) ?? Date()
            } else {
                // Restore reasonable defaults
                openingTime = calendar.date(
                    bySettingHour: 8,
                    minute: 0,
                    second: 0,
                    of: Date()
                ) ?? Date()

                closingTime = calendar.date(
                    bySettingHour: 20,
                    minute: 0,
                    second: 0,
                    of: Date()
                ) ?? Date()
            }

            storeVM.openingTime = openingTime
            storeVM.closingTime = closingTime
        }

        .onChange(of: openingTime) { _, new in
            storeVM.openingTime = new
        }
        
        .onChange(of: closingTime) { _, new in
            storeVM.closingTime = new
        }
        
        .onChange(of: openDays) { _, new in
            storeVM.openDays = new   // ✅ REQUIRED
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
    
    private func handlePhotoPicker(
        item: PhotosPickerItem?,
        completion: @escaping (UIImage, String) -> Void
    ) {
        guard let item else { return }

        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiimg = UIImage(data: data) {
                let filename = await item.itemIdentifier ?? "selected_file.png"

                // Ensure completion and any ViewModel writes happen on the main actor
                await MainActor.run {
                    completion(uiimg, filename)
                }
            }
        }
    }
    
    private var operationalHoursSection: some View {
        VStack(spacing: 0) {

            GroupBoxRow {
                Toggle(isOn: $open24Hours) {
                    Text("Open 24 Hours")
                }
            }

            if !open24Hours {
                GroupBoxRow {
                    HStack {
                        Text("Opening Time")
                        Spacer()
                        Button(formatTime(openingTime)) {
                            showOpeningPicker = true
                        }
                        .font(.callout.weight(.semibold))
                        .foregroundColor(.orange)
                    }
                }

                GroupBoxRow {
                    HStack {
                        Text("Closing Time")
                        Spacer()
                        Button(formatTime(closingTime)) {
                            showClosingPicker = true
                        }
                        .font(.callout.weight(.semibold))
                        .foregroundColor(.orange)
                    }
                }
            }

            NavigationLink {
                WeeklyScheduleView(openDays: $openDays)
            } label: {
                HStack {
                    Text("Weekly Schedule")
                        .foregroundColor(open24Hours ? .orange : .primary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(open24Hours ? .orange : .secondary)
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
    
    private var storeBannerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Store Banner")
                .font(.headline)

            Text("This will appear on the top of your store profile")
                .font(.footnote)
                .foregroundColor(.secondary)

            ZStack {
                if let img = bannerImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .aspectRatio(16/9, contentMode: .fill)
                } else {
                    VStack(spacing: 6) {
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
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .clipped()

            HStack(spacing: 10) {
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
            .padding(.bottom, 8)
        }
    }
}

#Preview {
    NavigationView {
        StoreBrandingView()
            .environmentObject(StoreRegistrationViewModel())
    }
}
