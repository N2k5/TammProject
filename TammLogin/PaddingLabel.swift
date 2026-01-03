//
//  PaddingLabel.swift
//  TammLogin
//
//  Created by BP-36-213-12 on 03/01/2026.
//

import Foundation
import UIKit

final class PaddingLabel: UILabel {

    var textInsets = UIEdgeInsets(
        top: 10,
        left: 14,
        bottom: 10,
        right: 14
    )

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + textInsets.left + textInsets.right,
            height: size.height + textInsets.top + textInsets.bottom
        )
    }
}
