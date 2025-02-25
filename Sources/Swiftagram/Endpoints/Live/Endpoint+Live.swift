//
//  Endpoint+Live.swift
//  
//
//  Created by Dan on 18.02.2022.
//

import Foundation

public extension Endpoint.Group {
    /// A `class` defining location endpoints.
    final class Live {}
}

public extension Endpoint {
  static let live = Group.Live()
}

extension Request {
  /// The `live` base request.
  static let live = Request.version1.live.appendingDefaultHeader()
}

public extension Endpoint.Group.Live {
  /// The create live request.
  ///
  /// - parameters:
  ///     - secret: A valid `Secret`.
  ///     - offset: An optional `String`.
  ///     - rank: A valid `String`.
  /// - returns: A valid `Request`.
  func create(message: String?) -> Endpoint.Single<Swiftagram.Stream, Swift.Error> {
    .init { secret, session in
      Deferred {
        Request.live
          .path(appending: "create/")
          .header(appending: secret.header)
          .body([
            "_csrftoken": secret["csrftoken"],
            "_uuid": secret.client.device.identifier.uuidString,
            "_uid": secret.identifier,
            "preview_width": "720",
            "preview_height": "1184",
            "broadcast_message": message,
            "broadcast_type": "RTMP",
            "internal_only": "0"
          ].compactMapValues { $0 })
          .publish(with: session)
          .map(\.data)
          .wrap()
          .map(Swiftagram.Stream.init)
      }
      .replaceFailingWithError()
    }
  }
  
  func start(broadcastId: String) -> Endpoint.Single<Swiftagram.Stream, Swift.Error> {
    .init { secret, session in
      Deferred {
        Request.live
          .path(appending: broadcastId)
          .path(appending: "start/")
          .header(appending: secret.header)
          .body([
            "_csrftoken": secret["csrftoken"],
            "_uuid": secret.client.device.identifier.uuidString,
            "_uid": secret.identifier,
            "should_send_notifications": "0",
          ].compactMapValues { $0 })
          .publish(with: session)
          .map(\.data)
          .wrap()
          .map(Swiftagram.Stream.init)
      }
      .replaceFailingWithError()
    }
  }
}
