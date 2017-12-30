import RxSwift

public protocol Service: class {
    var isBusy: Observable<Bool> { get }
}
