//
//  LESSFormatter.swift
//  DevUtils2
//
//  Created by Tony Dinh on 10/12/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Foundation

class LESSFormatterTool: PrettydiffFormatterTool {
  override func getSampleString() -> String? {
    return """
    @import "fruits";

    @rhythm: 1.5em;

    @media screen and (min-resolution: 2dppx) {
    body {font-size: 125%}
    }

    section > .foo + #bar:hover [href*="less"] {
    margin:     @rhythm 0 0 @rhythm;
    padding:    calc(5% + 20px);
    background: #f00ba7 url(http://placehold.alpha-centauri/42.png) no-repeat;
    background-image: linear-gradient(-135deg, wheat, fuchsia) !important ;
    background-blend-mode: multiply;
    }

    @font-face {
    font-family: /* ? */ 'Omega';
    src: url('../fonts/omega-webfont.woff?v=2.0.2');
    }

    .icon-baz::before {
    display:     inline-block;
    font-family: "Omega", Alpha, sans-serif;
    content:     "\\f085";
    color:       rgba(98, 76 /* or 54 */, 231, .75);
    }
    """
  }
  
  override func getHighlighterLanguage() -> String {
    return "less"
  }

  override func format(input: String, options: FormatToolOptions) throws -> String {
    return try formatLanguage(input: input, options: options, language: "less")
  }
}
