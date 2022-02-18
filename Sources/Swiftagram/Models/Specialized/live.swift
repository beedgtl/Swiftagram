//
//  File.swift
//  
//
//  Created by Dan on 18.02.2022.
//

import Foundation

/// A `struct` representing a `Comment`.
public struct Stream: Wrapped, Specialized {
    /// The underlying `Response`.
    public var wrapper: () -> Wrapper
  
  public var  broadcastId: String! { self["broadcast_id"].string(converting: true) }
  public var  uploadUrl: String! { self["upload_url"].string() }

  /// Init.
  /// - parameter wrapper: A valid `Wrapper`.
  public init(wrapper: @escaping () -> Wrapper) {
      self.wrapper = wrapper
  }
}
