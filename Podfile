workspace 'ApolloUnitTestingDemo.xcworkspace'
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'ApolloUnitTestingDemo' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'Apollo'
  pod 'Result'

  # Pods for ApolloUnitTestingDemo

  target 'ApolloUnitTestingDemoTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ApolloUnitTestingDemoUITests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  target 'WorldAPI' do
      project './WorldAPI/WorldAPI.xcodeproj'
      pod 'Apollo'
      pod 'Result'
  end

end
