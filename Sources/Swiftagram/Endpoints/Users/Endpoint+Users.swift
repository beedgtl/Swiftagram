//
//  Endpoint+Users.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 26/03/21.
//

import Foundation

public extension Endpoint {
    /// A `struct` defining users-related endpoints.
    struct Users { }

    /// A wrapper for users endpoints.
    static let users: Users = .init()

    /// All user matching `query`.
    ///
    /// - parameter query: A `String` holding reference to a valid user query.
    /// - returns: A valid `Endpoint.Pagianted`.
    static func users(matching query: String) -> Endpoint.Paginated<Swiftagram.User.Collection,
                                                                    RankedOffset<String?, String?>,
                                                                    Error> {
        .init { secret, session, pages in
            // Persist the rank token.
            let rank = pages.rank ?? String(Int.random(in: 1_000..<10_000))
            // Prepare the actual pager.
            return Pager(pages) {
                Request.users
                    .search
                    .header(appending: secret.header)
                    .header(appending: rank, forKey: "rank_token")
                    .query(appending: ["q": query, "max_id": $0])
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Swiftagram.User.Collection.init)
                    .iterateFirst(stoppingAt: $0)
            }
            .eraseToAnyPublisher()
        }
    }
}

public extension Endpoint.Users {
    /// A list of all profiles blocked by the logged in user.
    var blocked: Endpoint.Disposable<Wrapper, Error> {
        .init { secret, session in
            Deferred {
                Request.users
                    .blocked_list
                    .header(secret.header)
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
            }
            .eraseToAnyPublisher()
        }
    }

    /// A list of users who requested to follow you.
    var requests: Endpoint.Paginated<Swiftagram.User.Collection, String?, Error> {
        .init { secret, session, pages in
            Pager(pages) {
                Request.friendships
                    .pending
                    .header(appending: secret.header)
                    .query(appending: $0, forKey: "max_id")
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Swiftagram.User.Collection.init)
                    .iterateFirst(stoppingAt: $0)
            }
            .eraseToAnyPublisher()
        }
    }
}
