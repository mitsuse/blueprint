import RxSwift

public final class LeakyCommandHandler<Result>: CommandHandler {
    public typealias Command = () -> Single<Result>
    public typealias Subscribe = (SingleEvent<Result>) -> Void

    private let scheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "jp.mitsuse.Blueprint.LeakyCommandHandler")
    private let disposeBag = DisposeBag()
    private let busySubject = BehaviorSubject<Bool>(value: false)
    private let requestQueue = PublishSubject<(command: Command, subscribe: Subscribe)>()

    public var isBusy: Observable<Bool> { return busySubject.asObservable() }

    public init() {
        requestQueue
            .withLatestFrom(isBusy) { request, isBusy in (request, isBusy) }
            .observe(on: scheduler)
            .subscribe(onNext: { [weak self] request, isBusy in
                guard let scheduler = self?.scheduler, let disposeBag = self?.disposeBag, let busyVariable = self?.busySubject else { return }
                if isBusy {
                    request.subscribe(.failure(CommandHandlerBusy()))
                } else {
                    busyVariable.onNext(true)
                    request.command()
                        .observe(on: scheduler)
                        .subscribe { [weak busyVariable] event in request.subscribe(event); busyVariable?.onNext(false) }
                        .disposed(by: disposeBag)
                }
            })
            .disposed(by: disposeBag)
    }

    public func handle(_ command: @escaping Command) -> Single<Result> {
        return Single<Result>.create { [weak requestQueue] subscribe in
            requestQueue?.on(.next((command: command, subscribe: subscribe)))
            return Disposables.create()
        }
    }
}

