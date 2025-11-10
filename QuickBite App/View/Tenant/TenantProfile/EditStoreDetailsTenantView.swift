//
//  EditStoreDetailsTenantView.swift
//  QuickBite App
//
//  Created by jessica tedja on 10/11/25.
//

import SwiftUI
import PhotosUI

struct EditStoreDetailsTenantView: View {
    @Environment(\.dismiss) private var dismiss

    // Track perubahan
    @State private var isDirty = false
    private func markDirty() { isDirty = true }

    // Banner & Search Icon
    @State private var bannerImage: UIImage? = nil
    @State private var iconImage: UIImage? = nil
    @State private var bannerPickedItem: PhotosPickerItem?
    @State private var iconPickedItem: PhotosPickerItem?
    @State private var bannerFileName: String = ""
    @State private var iconFileName: String = ""

    // Operational Hours
    @State private var open24Hours = false
    @State private var openingTime: Date = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date())!
    @State private var closingTime: Date = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date())!

    // Weekly open days (disimpan di parent layar ini)
    @State private var openDays: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday]

    @State private var showOpeningPicker = false
    @State private var showClosingPicker = false

    var body: some View {
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
                        } else { Text(" ") }
                    }
                    .frame(height: 120)

                    HStack(spacing: 10) {
                        PhotosPicker(selection: $bannerPickedItem, matching: .images) {
                            pillButton("Choose File")
                        }
                        Text(bannerFileName.isEmpty ? " " : bannerFileName)
                            .font(.subheadline).foregroundColor(.secondary)
                            .lineLimit(1).truncationMode(.middle)
                        Spacer()
                    }
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
                            }
                        }
                        .frame(width: 64, height: 64)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 10) {
                                PhotosPicker(selection: $iconPickedItem, matching: .images) {
                                    pillButton("Choose File")
                                }
                                Text(iconFileName.isEmpty ? " " : iconFileName)
                                    .font(.subheadline).foregroundColor(.secondary)
                                    .lineLimit(1).truncationMode(.middle)
                            }

                            Text("A clear, square image for search results")
                                .font(.footnote).foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }

                VStack(spacing: 0) {
                    GroupBoxRow {
                        Toggle(isOn: $open24Hours) { Text("Open 24 Hours") }
                            .onChange(of: open24Hours) { _,_ in markDirty() }
                    }

                    if !open24Hours {
                        GroupBoxRow {
                            HStack {
                                Text("Opening Time")
                                Spacer()
                                Button(formatTime(openingTime)) { showOpeningPicker = true }
                                    .font(.callout.weight(.semibold))
                                    .foregroundColor(.orange)
                            }
                        }
                        GroupBoxRow {
                            HStack {
                                Text("Closing Time")
                                Spacer()
                                Button(formatTime(closingTime)) { showClosingPicker = true }
                                    .font(.callout.weight(.semibold))
                                    .foregroundColor(.orange)
                            }
                        }
                    }

                    NavigationLink {
                        // Pass binding agar perubahan balik ke parent
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
            .padding(16)
            .padding(.bottom, 16)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle("Edit Store Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    dismiss() // ⬅️ langsung balik
                }
                .foregroundColor(isDirty ? .orange : .secondary)
                .disabled(!isDirty)
            }
        }
        .toolbar(.hidden, for: .tabBar)

        // PhotosPicker handlers → tandai dirty
        .onChange(of: bannerPickedItem) { _, newValue in
            guard let newValue else { return }
            Task {
                if let data = try? await newValue.loadTransferable(type: Data.self),
                   let uiimg = UIImage(data: data) {
                    bannerImage = uiimg
                    bannerFileName = await fileName(from: newValue) ?? "selected_banner.png"
                    markDirty()
                }
            }
        }
        .onChange(of: iconPickedItem) { _, newValue in
            guard let newValue else { return }
            Task {
                if let data = try? await newValue.loadTransferable(type: Data.self),
                   let uiimg = UIImage(data: data) {
                    iconImage = uiimg
                    iconFileName = await fileName(from: newValue) ?? "selected_icon.png"
                    markDirty()
                }
            }
        }
        .onChange(of: openingTime) { _,_ in markDirty() }
        .onChange(of: closingTime) { _,_ in markDirty() }
        .onChange(of: openDays) { _,_ in markDirty() } // perubahan dari WeeklySchedule
        // Time pickers
        .sheet(isPresented: $showOpeningPicker) {
            TimePickerSheet(title: "Opening Time", date: $openingTime)
                .presentationDetents([.height(320)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showClosingPicker) {
            TimePickerSheet(title: "Closing Time", date: $closingTime)
                .presentationDetents([.height(320)])
                .presentationDragIndicator(.visible)
        }
    }

    // Helpers
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

    private func fileName(from item: PhotosPickerItem) async -> String? {
        await item.itemIdentifier
    }
}

// Row container ala list card
private struct GroupBoxRow<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        VStack(spacing: 0) {
            content
                .padding(.horizontal, 16)
                .frame(height: 48)
            Divider().padding(.leading, 16)
        }
        .background(Color(.systemBackground))
    }
}

// Bottom time picker sheet
private struct TimePickerSheet: View {
    let title: String
    @Binding var date: Date
    var body: some View {
        VStack {
            Capsule().fill(Color.secondary.opacity(0.35))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
            Text(title).font(.headline).padding(.top, 6)
            DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel).labelsHidden()
                .frame(height: 200).padding(.top, 8)
            Spacer(minLength: 0)
        }
        .padding(.bottom, 10)
        .background(Color(.systemBackground))
        .toolbar(.hidden, for: .tabBar)
    }
}

enum Weekday: String, CaseIterable, Identifiable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    var id: String { rawValue }
    var label: String {
        switch self {
        case .monday: "Monday"
        case .tuesday: "Tuesday"
        case .wednesday: "Wednesday"
        case .thursday: "Thursday"
        case .friday: "Friday"
        case .saturday: "Saturday"
        case .sunday: "Sunday"
        }
    }
}

struct OrangeCheckSquareStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .strokeBorder(Color.orange.opacity(configuration.isOn ? 0 : 0.5), lineWidth: 1)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(configuration.isOn ? Color.orange : Color.clear)
                        )
                        .frame(width: 22, height: 22)
                    if configuration.isOn {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                configuration.label
                    .font(.body)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
    }
}

struct WeeklyOpeningDaysView: View {
    @Binding var openDays: Set<Weekday>

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose Store Opening Days")
                .font(.headline)
                .padding(.bottom, 4)

            ForEach(Weekday.allCases) { day in
                Toggle(isOn: Binding(
                    get: { openDays.contains(day) },
                    set: { isOn in
                        if isOn { openDays.insert(day) } else { openDays.remove(day) }
                    }
                )) {
                    Text(day.label)
                }
                .toggleStyle(OrangeCheckSquareStyle())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct WeeklyScheduleView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var openDays: Set<Weekday>

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                WeeklyOpeningDaysView(openDays: $openDays)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .navigationTitle("Weekly Schedule")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    // perubahan sudah tersalur ke parent via binding
                    dismiss() // ⬅️ langsung balik
                }
                .foregroundColor(.orange)
                .font(.headline)
            }
        }
    }
}

//#Preview {
//    NavigationStack { EditStoreDetailsTenantView() }
//}
