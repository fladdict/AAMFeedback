Pod::Spec.new do |s|
  s.name         = 'AAMFeedback'
  s.version      = '0.0.1'
  s.platform    = :ios, '5.0'
  s.license      = { :type => 'Modified BSD' }
  s.homepage     = 'https://github.com/fladdict/AAMFeedback'
  s.summary      = 'Library that you can add User feedback form in you app on the fly. :-)'
  s.author       = 'Takayuki Fukatsu'
  s.source       = { :git => 'https://github.com/fladdict/AAMFeedback.git' }
  s.source_files = 'AAMFeedback/AAMFeedback/*.{h,m}'
  # s.resources    = 'AAMFeedback/*.{lproj}'
  s.requires_arc = false
  s.frameworks   = 'UIKit', 'MessageUI', 'CoreGraphics'
end
