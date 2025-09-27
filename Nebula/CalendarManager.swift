import Foundation
import EventKit
import SwiftUI

class CalendarManager: ObservableObject {
    private let eventStore = EKEventStore()
    @Published var events: [EKEvent] = []
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        checkAuthorizationStatus()
    }
    
    func checkAuthorizationStatus() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
    }
    
    func requestAccess() async {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            await MainActor.run {
                self.authorizationStatus = granted ? .fullAccess : .denied
                if granted {
                    self.fetchEvents()
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to request calendar access: \(error.localizedDescription)"
            }
        }
    }
    
    func fetchEvents() {
        guard authorizationStatus == .fullAccess else { return }
        
        isLoading = true
        errorMessage = nil
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 30, to: startOfDay) ?? now
        
        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
        
        DispatchQueue.global(qos: .userInitiated).async {
            let fetchedEvents = self.eventStore.events(matching: predicate)
            
            DispatchQueue.main.async {
                self.events = fetchedEvents.sorted { $0.startDate < $1.startDate }
                self.isLoading = false
            }
        }
    }
    
    func eventsForDate(_ date: Date) -> [EKEvent] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        return events.filter { event in
            event.startDate < endOfDay && event.endDate > startOfDay
        }
    }
    
    func eventsForDateRange(_ startDate: Date, _ endDate: Date) -> [EKEvent] {
        return events.filter { event in
            event.startDate < endDate && event.endDate > startDate
        }
    }
    
    func refreshEvents() {
        fetchEvents()
    }
}

// MARK: - Calendar Event Extensions
extension EKEvent {
    var eventColor: Color {
        guard let calendar = self.calendar else { return Color.blue }
        
        // Convert CGColor to SwiftUI Color
        if let cgColor = calendar.cgColor {
            return Color(cgColor: cgColor)
        }
        
        // Fallback colors based on calendar title
        let title = calendar.title.lowercased()
        if title.contains("work") || title.contains("business") {
            return Color.blue
        } else if title.contains("personal") || title.contains("home") {
            return Color.green
        } else if title.contains("health") || title.contains("fitness") {
            return Color.red
        } else if title.contains("travel") || title.contains("vacation") {
            return Color.orange
        } else {
            return Color.purple
        }
    }
    
    var duration: TimeInterval {
        return endDate.timeIntervalSince(startDate)
    }
    
    var formattedTimeRange: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        if isAllDay {
            return "All Day"
        } else {
            return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        }
    }
}

// MARK: - Calendar Event View Model
struct CalendarEventViewModel: Identifiable {
    let id = UUID()
    let event: EKEvent
    
    var title: String { event.title }
    var startDate: Date { event.startDate }
    var endDate: Date { event.endDate }
    var location: String? { event.location }
    var notes: String? { event.notes }
    var isAllDay: Bool { event.isAllDay }
    var color: Color { event.eventColor }
    var formattedTimeRange: String { event.formattedTimeRange }
    var calendarTitle: String { event.calendar?.title ?? "Unknown Calendar" }
}
