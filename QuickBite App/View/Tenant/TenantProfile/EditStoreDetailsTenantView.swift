import SwiftUI
import PhotosUI

private struct StoreSnapshot: Equatable {
    let bannerImage: UIImage?
    let iconImage: UIImage?
    let open24Hours: Bool
    let openingTime: Date
    let closingTime: Date
    let openDays: Set<Weekday>
}

struct EditStoreDetailsTenantView: View {

    let storeId: String
    
    @State private var originalSnapshot: StoreSnapshot?
    @State private var hasChanges = false

    @StateObject private var vm = EditStoreDetailsViewModel()
    
    @State private var didLoadFromFirestore = false

    // MARK: - UI STATE
    @State private var bannerPickedItem: PhotosPickerItem?
    @State private var iconPickedItem: PhotosPickerItem?

    @State private var bannerImage: UIImage?
    @State private var iconImage: UIImage?

    @State private var open24Hours = false
    @State private var openingTime: Date = .now
    @State private var closingTime: Date = .now
    @State private var openDays: Set<Weekday> = []

    @State private var showOpeningPicker = false
    @State private var showClosingPicker = false
    
    var body: some View {
        ZStack {

            VStack(spacing: 20) {

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        storeBannerSection
                        searchIconSection

                        Text("Operational Hours")
                            .font(.headline)
                            .padding(.top, 10)

                        operationalHoursSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }

                Button {
                    Task {
                        await vm.saveChanges(
                            storeId: storeId,
                            bannerImage: bannerImage,
                            iconImage: iconImage,
                            openDays: openDays,
                            openingTime: openingTime,
                            closingTime: closingTime,
                            open24Hours: open24Hours
                        )

                        // Reset baseline after successful save
                        originalSnapshot = StoreSnapshot(
                            bannerImage: bannerImage,
                            iconImage: iconImage,
                            open24Hours: open24Hours,
                            openingTime: openingTime,
                            closingTime: closingTime,
                            openDays: openDays
                        )
                        hasChanges = false
                    }
                } label: {
                    Text("Save Changes")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(hasChanges ? Color.orange : Color.gray.opacity(0.4))
                        .foregroundColor(.white)
                        .font(.headline)
                        .cornerRadius(24)
                }
                .disabled(!hasChanges)
                .padding()
            }
            .disabled(!didLoadFromFirestore)
            .opacity(didLoadFromFirestore ? 1 : 0)

            if !didLoadFromFirestore {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading store details...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            }
        }
        .navigationTitle("Edit Store Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadExistingStore() }
        .sheet(isPresented: $showOpeningPicker) {
            TimePickerSheet(title: "Opening Time", date: $openingTime)
        }
        .sheet(isPresented: $showClosingPicker) {
            TimePickerSheet(title: "Closing Time", date: $closingTime)
        }
        .onChange(of: open24Hours) { _, isOn in
            guard didLoadFromFirestore else { return }

            let calendar = Calendar.current
            if isOn {
                openingTime = calendar.startOfDay(for: Date())
                closingTime = calendar.date(
                    bySettingHour: 23,
                    minute: 59,
                    second: 0,
                    of: Date()
                ) ?? closingTime
            }
        }
        .onChange(of: bannerImage) { _, _ in recomputeHasChanges() }
        .onChange(of: iconImage) { _, _ in recomputeHasChanges() }
        .onChange(of: open24Hours) { _, _ in recomputeHasChanges() }
        .onChange(of: openingTime) { _, _ in recomputeHasChanges() }
        .onChange(of: closingTime) { _, _ in recomputeHasChanges() }
        .onChange(of: openDays) { _, _ in recomputeHasChanges() }
    }
    
    private func loadExistingStore() {
        vm.loadStore(storeId: storeId) { data in

            bannerImage = data.banner
            iconImage = data.icon

            let parsed = parseSchedule(data.rawSchedule)

            openDays = parsed.openDays
            open24Hours = parsed.open24Hours
            openingTime = parsed.openingTime
            closingTime = parsed.closingTime

            originalSnapshot = StoreSnapshot(
                bannerImage: bannerImage,
                iconImage: iconImage,
                open24Hours: open24Hours,
                openingTime: openingTime,
                closingTime: closingTime,
                openDays: openDays
            )

            didLoadFromFirestore = true
        }
    }
    
    private func recomputeHasChanges() {
        guard let original = originalSnapshot else { return }

        hasChanges = StoreSnapshot(
            bannerImage: bannerImage,
            iconImage: iconImage,
            open24Hours: open24Hours,
            openingTime: openingTime,
            closingTime: closingTime,
            openDays: openDays
        ) != original
    }
    
    private var storeBannerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Store Banner").font(.headline)

            ZStack {
                if let img = bannerImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    VStack {
                        Image(systemName: "photo.fill.on.rectangle.fill")
                            .foregroundColor(.secondary)
                        Text("Upload Banner (16:9)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 120)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .clipped()

            HStack {
                PhotosPicker(selection: $bannerPickedItem, matching: .images) {
                    pillButton("Choose File")
                }
            }
            .onChange(of: bannerPickedItem) { _, item in
                handlePhotoPicker(item: item) { image in
                    bannerImage = centerCrop16x9(image)
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }

    private var searchIconSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Search Menu Icon")
                .font(.headline)

            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.secondarySystemBackground))

                    if let img = iconImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 64, height: 64)   // ✅ FIX: frame on IMAGE
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        Image(systemName: "photo.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                PhotosPicker(selection: $iconPickedItem, matching: .images) {
                    pillButton("Choose File")
                }

                Spacer()
            }
            .onChange(of: iconPickedItem) { _, item in
                handlePhotoPicker(item: item) { image in
                    iconImage = ImageResizeHelper.resize(image, mode: .square)
                }
            }
        }
    }

    private var operationalHoursSection: some View {
        VStack(spacing: 0) {

            GroupBoxRow {
                Toggle("Open 24 Hours", isOn: $open24Hours)
            }

            if !open24Hours {
                GroupBoxRow {
                    HStack {
                        Text("Opening Time")
                        Spacer()
                        Button(formatTime(openingTime)) {
                            showOpeningPicker = true
                        }
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
                        .foregroundColor(.orange)
                    }
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
                .tint(.orange)
                .padding(.horizontal, 16)
                .frame(height: 48)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8)
        )
    }

    private func pillButton(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color.orange.opacity(0.15)))
            .foregroundColor(.orange)
    }

    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }

    private func handlePhotoPicker(
        item: PhotosPickerItem?,
        completion: @escaping (UIImage) -> Void
    ) {
        guard let item else { return }

        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    completion(image)
                }
            }
        }
    }

    // MARK: - CENTER CROP 16:9
    private func centerCrop16x9(_ image: UIImage) -> UIImage {
        let targetRatio: CGFloat = 16 / 9
        let size = image.size
        let currentRatio = size.width / size.height

        var cropRect: CGRect

        if currentRatio > targetRatio {
            let newWidth = size.height * targetRatio
            let xOffset = (size.width - newWidth) / 2
            cropRect = CGRect(x: xOffset, y: 0, width: newWidth, height: size.height)
        } else {
            let newHeight = size.width / targetRatio
            let yOffset = (size.height - newHeight) / 2
            cropRect = CGRect(x: 0, y: yOffset, width: size.width, height: newHeight)
        }

        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return image
        }

        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }

    // MARK: - PARSE FIRESTORE SCHEDULE (SINGLE SOURCE OF TRUTH)
    private func parseSchedule(
        _ raw: [String: Any]?
    ) -> (
        openDays: Set<Weekday>,
        openingTime: Date,
        closingTime: Date,
        open24Hours: Bool
    ) {

        guard let raw, !raw.isEmpty else {
            return ([], .now, .now, false)
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        var days: Set<Weekday> = []
        var opening: Date?
        var closing: Date?
        var detected24h = true

        for (key, value) in raw {

            guard
                let dict = value as? [String: String],
                let open = dict["open_time"],
                let close = dict["close_time"],
                let day = Weekday(rawValue: key)
            else {
                continue
            }

            days.insert(day)

            if open != "00:00" || close != "23:59" {
                detected24h = false
            }

            if opening == nil {
                opening = formatter.date(from: open)
            }

            if closing == nil {
                closing = formatter.date(from: close)
            }
        }

        let is24h = detected24h && !days.isEmpty

        return (
            days,
            opening ?? .now,
            closing ?? .now,
            is24h
        )
    }
}

#Preview {
    NavigationView {
        EditStoreDetailsTenantView(storeId: "L6fI11B54V0HHh7y0jFa")
    }
}
