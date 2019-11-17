source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!

def prod_pods
    pod 'Moya/RxSwift', '~> 11.0'
    pod 'Moya-ObjectMapper/RxSwift'
    pod 'RxSwift'
    pod 'RxCocoa'
    pod 'SwiftyUserDefaults'
    pod 'AlamofireImage'
    pod 'Agrume'
    pod 'RxDataSources'
end

target 'FlickrViewerTests' do
    inherit! :search_paths
    prod_pods
end

target 'FlickrViewer' do
    prod_pods
end
