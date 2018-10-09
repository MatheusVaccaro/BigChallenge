# Podfile
use_frameworks!

target 'Reef' do
    platform :ios, '11.0'

    pod 'RxSwift',    '~> 4.0'
    pod 'RxCocoa',    '~> 4.0'
    pod 'SwiftLint', '~> 0.25.0'
    pod 'RxDataSources', '~> 3.0'
    pod 'UITextView+Placeholder', '~> 1.2'
    pod 'JTAppleCalendar', '~> 7.0'
    pod 'Fabric'
    pod 'Crashlytics'
end

target 'ReefKit' do
    platform :ios, '11.0'
    pod 'RxSwift',    '~>4.0'
end

target 'ReefToday' do
    platform :ios, '11.0'
    pod 'RxSwift',    '~>4.0'
end

def testing_pods
    pod 'Quick'
    pod 'Nimble'
    pod 'RxCocoa', '~> 4.0'
    pod 'RxSwift', '~> 4.0'
end

target 'ReefTests' do
    platform :ios, '11.0'
    testing_pods
end
