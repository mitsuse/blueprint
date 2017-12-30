import RxSwift

public protocol CommandHandler {
    associatedtype Result

    var isBusy: Observable<Bool> { get }

    func handle(_ command: @escaping () -> Single<Result>) -> Single<Result>
}

public struct CommandHandlerBusy: Swift.Error {
    public init() {
    }
}
