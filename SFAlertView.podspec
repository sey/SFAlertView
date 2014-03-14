Pod::Spec.new do |s|

  s.name         = "SFAlertView"
  s.version      = "1.0.11"
  s.summary      = "A highly configurable content hugging alert view."

  s.description  = <<-DESC
                   This pod is the result of merging SIAlertView and a custom 
                   popup component which resize to fit its content.
                   DESC

  s.homepage     = "https://github.com/sey/SFAlertView"

  s.license      = { :type => 'MIT', :file => 'LICENSE.md' }

  s.author             = { "Florian Sey" => "florian.sey@gmail.com" }
  s.social_media_url = "http://twitter.com/floriansey"

  s.platform     = :ios, '6.1'

  s.source       = { :git => "https://github.com/sey/SFAlertView.git", :tag => "1.0.11" }

  s.source_files  = 'SFAlertView/SFAlertView.{h,m}', 'SFAlertView/UIWindow+SIUtils.{h,m}'

  s.requires_arc = true

  s.dependency 'UIView+AutoLayout', '1.1.0'

end
