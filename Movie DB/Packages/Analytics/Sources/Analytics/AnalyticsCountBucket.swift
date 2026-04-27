//
//  AnalyticsCountBucket.swift
//  Analytics
//
//  Created by OpenCode on 27.04.26.
//

public enum AnalyticsCountBucket: String, Sendable {
    case oneToNinetyNine = "1_99"
    case oneHundredToOneNinetyNine = "100_199"
    case twoHundredToTwoNinetyNine = "200_299"
    case threeHundredToThreeNinetyNine = "300_399"
    case fourHundredToFourNinetyNine = "400_499"
    case fiveHundredToNineNinetyNine = "500_999"
    case oneThousandToOneThousandNineHundredNinetyNine = "1000_1999"
    case twoThousandToFourThousandNineHundredNinetyNine = "2000_4999"
    case fiveThousandToNineThousandNineHundredNinetyNine = "5000_9999"
    case tenThousandPlus = "10000_plus"

    public static func bucket(for count: Int) -> AnalyticsCountBucket {
        switch count {
        case ..<100:
            .oneToNinetyNine
        case ..<200:
            .oneHundredToOneNinetyNine
        case ..<300:
            .twoHundredToTwoNinetyNine
        case ..<400:
            .threeHundredToThreeNinetyNine
        case ..<500:
            .fourHundredToFourNinetyNine
        case ..<1000:
            .fiveHundredToNineNinetyNine
        case ..<2000:
            .oneThousandToOneThousandNineHundredNinetyNine
        case ..<5000:
            .twoThousandToFourThousandNineHundredNinetyNine
        case ..<10000:
            .fiveThousandToNineThousandNineHundredNinetyNine
        default:
            .tenThousandPlus
        }
    }
}
