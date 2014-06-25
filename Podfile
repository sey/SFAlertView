platform :ios, '6.1'
inhibit_all_warnings!

xcodeproj	'SFAlertView.xcodeproj'

pod 'UIView+AutoLayout', '1.1.0'

pod 'Nimbus/AttributedLabel', '1.0.0'

post_install do |installer|
    print "Fixing Nimbus/AttributedLabel\n"
    system "sed -ie 's/CGContextSetTextPosition(ctx, lineOrigin.x, lineOrigin.y);/CGContextSetTextPosition(ctx, lineOrigin.x, lineOrigin.y - rect.origin.y);/g' ./Pods/Nimbus/src/attributedlabel/src/NIAttributedLabel.m"
end
