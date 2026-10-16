//
//  RoutesViewModel.swift
//  RunScapeAR
//
//  Created by Mert Ioan Aydogan on 16/10/2026.
//

import Domain
import Observation

@MainActor
@Observable
final class RoutesViewModel {
    private let getRoutes: GetRoutesUseCase

    private(set) var routes: [RouteSummary] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    init(
        getRoutes: GetRoutesUseCase
    ) {
        self.getRoutes = getRoutes
    }

    func load() async {
        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            routes = try await getRoutes.execute()
        } catch {
            errorMessage = String(
                describing: error
            )
        }
    }
}
