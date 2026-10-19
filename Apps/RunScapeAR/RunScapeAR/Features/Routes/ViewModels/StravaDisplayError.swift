import DataLayer
import Foundation

struct StravaDisplayError {
    let userMessage: String

    init(_ error: Error) {
        if let strava = error as? StravaError {
            switch strava {
            case .unauthorized:
                userMessage = "Your Strava session has expired. Please sign in again."
            case .forbidden:
                userMessage = "You don't have permission to access this data."
            case .notFound:
                userMessage = "The requested item could not be found."
            case .rateLimited:
                userMessage = "Too many requests. Please wait a moment and try again."
            case .serverError:
                userMessage = "Strava is temporarily unavailable. Please try again later."
            default:
                userMessage = "Something went wrong. Please try again."
            }
        } else if error is StravaOAuthError {
            userMessage = "Your Strava session has expired. Please sign in again."
        } else if (error as NSError).domain == NSURLErrorDomain {
            userMessage = "No internet connection. Check your network and try again."
        } else {
            userMessage = "Something went wrong. Please try again."
        }
    }
}
