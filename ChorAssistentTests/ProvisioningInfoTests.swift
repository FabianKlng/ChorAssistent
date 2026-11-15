import Foundation
import Testing

@testable import ChorAssistent

struct ProvisioningInfoTests {
    private let plist = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>ExpirationDate</key>
            <date>2026-12-01T12:00:00Z</date>
            <key>Name</key>
            <string>iOS Team Provisioning Profile</string>
        </dict>
        </plist>
        """

    @Test func readsExpirationFromSignedWrapper() throws {
        var data = Data([0x30, 0x82, 0xFF, 0x00, 0x06, 0x09])
        data.append(Data(plist.utf8))
        data.append(Data([0xA0, 0x00, 0xFF, 0x31]))

        let expected = try #require(ISO8601DateFormatter().date(from: "2026-12-01T12:00:00Z"))
        #expect(ProvisioningInfo.expirationDate(fromProfileData: data) == expected)
    }

    @Test func missingPlistReturnsNil() {
        #expect(ProvisioningInfo.expirationDate(fromProfileData: Data([0x00, 0x01, 0xFF])) == nil)
    }

    @Test func brokenPlistReturnsNil() {
        let broken = Data("<?xml version=\"1.0\"?><plist><dict><key>ExpirationDate</key></plist>".utf8)
        #expect(ProvisioningInfo.expirationDate(fromProfileData: broken) == nil)
    }

    @Test func daysRemaining() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        #expect(ProvisioningInfo.daysRemaining(until: now.addingTimeInterval(47 * 3600), now: now) == 1)
        #expect(ProvisioningInfo.daysRemaining(until: now.addingTimeInterval(48 * 3600), now: now) == 2)
        #expect(ProvisioningInfo.daysRemaining(until: now.addingTimeInterval(-3600), now: now) == 0)
    }
}
