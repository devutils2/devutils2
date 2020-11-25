//
//  ERBFormatter.swift
//  DevUtils2
//
//  Created by Tony Dinh on 10/12/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Foundation

class ERBFormatterTool: PrettydiffFormatterTool {
  override func getSampleString() -> String? {
    return """
    <%# this is a comment %>  <% @posts.each do |post| %>
      <p>
      <%= link_to post.title, post %></p>
            <% end %>

    <%- available_things = things.select(&:available?) -%> <%%- x = 1 + 2 -%%> <%% value = 'real string #{@value}' %%> <%%= available_things.inspect %%>
    """
  }
  
  override func getHighlighterLanguage() -> String {
    return "erb"
  }

  override func format(input: String, options: FormatToolOptions) throws -> String {
    return try formatLanguage(input: input, options: options, language: "erb")
  }
}
