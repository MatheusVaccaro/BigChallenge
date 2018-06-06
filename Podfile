# Podfile
use_frameworks!

target 'BigChallenge' do
    pod 'RxSwift',    '~> 4.0'
    pod 'RxCocoa',    '~> 4.0'
    pod 'SwiftLint'
end

# RxTest and RxBlocking make the most sense in the context of unit/integration tests
# target 'YOUR_TESTING_TARGET' do
#     pod 'RxBlocking', '~> 4.0'
#     pod 'RxTest',     '~> 4.0'
# end

def testing_pods
    pod 'Quick'
    pod 'Nimble'
end

target 'BigChallengeTests' do
    testing_pods
end

target 'BigChallengeUITests' do
    testing_pods
end
