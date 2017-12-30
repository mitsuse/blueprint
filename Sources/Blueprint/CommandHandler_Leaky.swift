import RxSwift

public final class LeakyCommandHandler<Result>: CommandHandler {
    public typealias Command = () -> Single<Result>
    public typealias Subscribe = (SingleEvent<Result>) -> Void

    private let scheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "jp.mitsuse.Blueprint.LeakyCommandHandler")
    private let disposeBag = DisposeBag()
    private let busyVariable = Variable<Bool>(false)
    private let requestQueue = PublishSubject<(command: Command, subscribe: Subscribe)>()

    public var isBusy: Observable<Bool> { return busyVariable.asObservable() }

    public init() {
        requestQueue
            .withLatestFrom(isBusy) { request, isBusy in (request, isBusy) }
            .observeOn(scheduler)
            .subscribe(onNext: { [weak self] request, isBusy in
                guard let scheduler = self?.scheduler, let disposeBag = self?.disposeBag, let busyVariable = self?.busyVariable else { return }
                if isBusy {
                    request.subscribe(.error(CommandHandlerBusy()))
                } else {
                    busyVariable.value = true
                    request.command()
                        .observeOn(scheduler)
                        .subscribe { [weak busyVariable] event in request.subscribe(event); busyVariable?.value = false }
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

