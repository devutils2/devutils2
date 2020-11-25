//
//  SCSSFormatter.swift
//  DevUtils2
//
//  Created by Tony Dinh on 10/12/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Foundation

class SCSSFormatterTool: PrettydiffFormatterTool {
  override func getSampleString() -> String? {
    return """
    @import "compass/reset";

    // variables
    $colorGreen: #008000;
    $colorGreenDark: darken($colorGreen, 10);

    @mixin container {
      max-width: 980px;
    }

    // mixins with parameters
    @mixin button($color:green) {
    @if ($color == green) {
    background-color: #008000;
    }
    @else if ($color == red) {
     background-color: #B22222;
    }
    }

    button {
    @include button(red);
    }

    div,
    .navbar, #header,
    input[type="input"] {
     font-family: "Helvetica Neue", Arial, sans-serif;
      width: auto;
     margin: 0 auto;
      display: block;
    }
    """
  }
  
  override func getHighlighterLanguage() -> String {
    return "scss"
  }

  override func format(input: String, options: FormatToolOptions) throws -> String {
    return try formatLanguage(input: input, options: options, language: "scss")
  }
}
