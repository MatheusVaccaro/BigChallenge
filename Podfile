# Podfile
use_frameworks!

target 'BigChallenge' do
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

# RxTest and RxBlocking make the most sense in the context of unit/integration tests
# target 'YOUR_TESTING_TARGET' do
#     pod 'RxBlocking', '~> 4.0'
#     pod 'RxTest',     '~> 4.0'
# end

def testing_pods
    platform :ios, '11.0'
    pod 'Quick'
    pod 'Nimble'
    pod 'RxCocoa', '~> 4.0'
    pod 'RxSwift', '~> 4.0'
end

target 'BigChallengeTests' do
    testing_pods
end

target 'BigChallengeUITests' do
    testing_pods
end
