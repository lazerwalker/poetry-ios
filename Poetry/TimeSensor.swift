import Foundation

enum TimeOfDay {
    case EarlyMorning,
    LateMorning,
    Lunch,
    EarlyAfternoon,
    EarlyEvening,
    Evening,
    Night,
    Unknown
}

struct TimeSensor {
    let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)

    //- Calendar things
    func isWeekend() -> Bool {
        if let components = calendar?.components(.Weekday, fromDate: NSDate()) {
            return components.weekday == 1 || components.weekday == 7
        }
        return false
    }

    func isWeekday() -> Bool {
        return !isWeekend()
    }

    //- Time things
    func timeOfDay() -> TimeOfDay {
        if let components = calendar?.components(.Hour, fromDate: NSDate()) {
            let hour = components.hour
            if hour > 6 && hour < 10 {
                return .EarlyMorning
            }
        }
        return .Unknown
    }
}
