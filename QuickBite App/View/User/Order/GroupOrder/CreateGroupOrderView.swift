//
//  CreateGroupOrderView.swift
//  QuickBite
//
//  Created by student on 26/11/25.
//

import SwiftUI

struct UserMember: Identifiable, Equatable {
    let id: String // Changed from UUID to String to match Firestore ID
    let name: String
    let username: String
    let initial: String
    let color: Color
    var isCurrentUser: Bool = false
    
    // Custom init to handle UUID generation if needed, or pass specific ID
    init(firestoreId: String = UUID().uuidString, name: String, username: String, initial: String, color: Color, isCurrentUser: Bool = false) {
        self.id = firestoreId
        self.name = name
        self.username = username
        self.initial = initial
        self.color = color
        self.isCurrentUser = isCurrentUser
    }
}

struct CreateGroupOrderView: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var members: [UserMember]
    
    @State private var searchText = ""
    
    @StateObject private var viewModel = CreateGroupOrderViewModel()
    
    
    var filteredSuggestions: [UserMember] {
        viewModel.suggestions.filter { user in
 
            let loggedInUser = members.first(where: { $0.isCurrentUser })

            let isTheCurrentUser = user.isCurrentUser ||
            (loggedInUser?.id == user.id) ||
            (loggedInUser?.username == user.username)
            
            let isAlreadyMember = members.contains(where: { $0.username == user.username })
            
            let matchesSearch = searchText.isEmpty ||
            user.name.localizedCaseInsensitiveContains(searchText) ||
            user.username.localizedCaseInsensitiveContains(searchText)
            
            return !isTheCurrentUser && !isAlreadyMember && matchesSearch
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            Divider()
            
            VStack(alignment: .leading, spacing: 20) {
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search by @username", text: $searchText)
                        .textInputAutocapitalization(.never)
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top)
                
                // In this group Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("In this group (\(members.count))")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(members) { member in
                                VStack {
                                    ZStack(alignment: .topTrailing) {
                                        // Avatar
                                        Text(member.initial)
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(member.isCurrentUser ? Color(red: 0.9, green: 0.4, blue: 0.1) : .white)
                                            .frame(width: 54, height: 54)
                                            .background(member.isCurrentUser ? Color.orange.opacity(0.2) : member.color.opacity(0.8))
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle().stroke(member.isCurrentUser ? Color.orange : Color.clear, lineWidth: 1)
                                            )
                                        
                                        // Badge (tombol silang merah untuk menghapus member, kecuali user sendiri)
                                        if member.isCurrentUser {
                                            Image(systemName: "asterisk")
                                                .font(.system(size: 10))
                                                .foregroundColor(.white)
                                                .frame(width: 18, height: 18)
                                                .background(Color.green)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                                .offset(x: 0, y: 0)
                                        } else {
                                            // Tambahan: Opsi menghapus member
                                            Button(action: {
                                                withAnimation {
                                                    if let index = members.firstIndex(where: { $0.id == member.id }) {
                                                        members.remove(at: index)
                                                    }
                                                }
                                            }) {
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.white)
                                                    .frame(width: 18, height: 18)
                                                    .background(Color.red)
                                                    .clipShape(Circle())
                                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                            }
                                            .offset(x: 0, y: 0)
                                        }
                                    }
                                    
                                    Text(member.isCurrentUser ? "You" : member.name.split(separator: " ").first ?? "")
                                        .font(.caption)
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Divider()
                            
    
                // Suggestion / Search Results Section
                VStack(alignment: .leading, spacing: 16) {
                    // Judul dinamis sesuai status pencarian
                    Text(searchText.isEmpty ? "Friends" : "Search results for \"\(searchText)\"")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    ScrollView {
                        // Menggunakan filteredSuggestions
                        ForEach(filteredSuggestions) { user in
                            HStack {
                                // Avatar
                                Text(user.initial)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 48, height: 48)
                                    .background(user.color.opacity(0.4))
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(user.name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text(user.username)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                // Button Add (+)
                                Button(action: {
                                    withAnimation {
                                        // Tambahkan ke list members
                                        members.append(user)
                                        // Kosongkan search text setelah menambah (opsional, biar UX lebih bersih)
                                        searchText = ""
                                    }
                                }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(red: 0.9, green: 0.4, blue: 0.1))
                                        .frame(width: 36, height: 36)
                                        .background(Color.orange.opacity(0.2))
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                        }
                        
                        if !searchText.isEmpty && filteredSuggestions.isEmpty {
                            Text("No users found")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                                .padding(.top, 10)
                        }
                    }
                }
            }
            
            Divider()
            // Footer Button
            VStack {
                Button(action: {
                    dismiss() // Kembali ke halaman sebelumnya
                }) {
                    Text(members.count > 1 ? "Done (\(members.count) Members)" : "Done (1 Member)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.orange)
                        .cornerRadius(30)
                }
            }
            .padding()
            .background(Color.white)
        }
        .background(Color.white)
        // Mengatur Judul Halaman (Native Navigation Bar)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text("Add Members")
                        .font(.headline)
                        .foregroundColor(.black)
                    Text("Angela's Group")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            viewModel.fetchAllUsers()
        }
    }
}

struct CreateGroupOrderView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CreateGroupOrderView(members: .constant([
                UserMember(name: "Angela", username: "@angela", initial: "A", color: .orange, isCurrentUser: true)
            ]))
        }
    }
}
