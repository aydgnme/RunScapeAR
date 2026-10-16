//
//  StravaAthleteDTO.swift
//  DataLayer
//
//  Created by Mert Ioan Aydogan on 15/10/2026.
//

struct StravaAthleteDTO: Decodable, Sendable {
    let id: Int64
    let username: String?
    let firstName: String?
    let lastName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case firstName = "firstname"
        case lastName = "lastname"
    }
}
