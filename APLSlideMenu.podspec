Pod::Spec.new do |s|
  s.name         = "APLSlideMenu"
  s.version      = "0.1.3"
  s.summary      = "Sliding Hamburger Menu like the one in the Facebook App"

  s.description  = <<-DESC
                   Sliding Hamburger Menu like the one in the Facebook App

                   * supports left and right slide menus
                   * supports optional swipe gesture support
                   * supports device orientations
                   * supports optional permanent display of slidemenu in landscape on iPad like an UISplitViewController
                   * supports iOS 7 view controller-based status bar appearance
                   * supports storyboard setup
                   * basic accessibility support
                   DESC

  s.homepage     = "https://github.com/apploft/APLSlideMenu"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  
  s.author       = 'Christopher Groß', 'Tobias Conradi', 'Tino Rachui', 'Michael Kamphausen', 'Thorsten Siebenborn'

  s.platform     = :ios, '5.0'

  s.source       = { :git => "https://github.com/apploft/APLSlideMenu.git", :tag => s.version.to_s }

  s.source_files  = 'APLSlideMenu', 'APLSlideMenu/**/*.{h,m}'
  s.exclude_files = 'Classes/Exclude'

  s.framework  = 'QuartzCore'
  s.requires_arc = true

end
