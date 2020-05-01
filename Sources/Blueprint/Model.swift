import Domain

import RxSwift

public final class Model<Entity> where Entity: Domain.Entity {
    private let disposeBag = DisposeBag()

    private let persistence: AnyPersistence<Entity>

    private let semaphore = PublishSubject<Void>()
    private let subscribeQueue = PublishSubject<Subscribe>()
    private let requestQueue = PublishSubject<Request>()
    private let transitionStream = PublishSubject<Transition>()

    public init<Persistence>(persistence: Persistence) where Persistence: Blueprint.Persistence, Persistence.Entity == Entity {
        self.persistence = AnyPersistence(persistence)

        Observable.zip(semaphore, requestQueue)
            .flatMap { [unowned self] (_, request) -> Single<(Entity.Id, Entity?)> in
                let target = Single.just(request.target)
                let entity =
                    self.persistence.restore(by: request.target)
                        .flatMap(request.update)
                return Single.zip(target, entity)
            }
            .flatMap { [unowned self] target, entity in
                self.persistence.store(entity, with: target).map { entity in
                    Transition(target: target, entity: entity)
                }
            }
            .subscribe(onNext: { [unowned self] transition in self.transitionStream.onNext(transition) })
            .disposed(by: disposeBag)

        Observable.zip(transitionStream, subscribeQueue)
            .subscribe(onNext: { [unowned self] (transition, subscribe) in
                subscribe(.success(transition.entity))
                self.semaphore.onNext(())
            })
            .disposed(by: disposeBag)

        semaphore.onNext(())
    }

    public var transitions: Observable<Transition> {
        return transitionStream.asObserver()
    }

    public func update(id: Entity.Id, _ block: @escaping (Entity?) -> Entity?) -> Single<Entity?> {
        update(id: id) { entity in Single.just(block(entity)) }
    }

    public func update(id: Entity.Id, _ block: @escaping (Entity?) -> Single<Entity?>) -> Single<Entity?> {
        return Single.create { [unowned self] subscribe in
            self.requestQueue.onNext(Request(target: id, update: block))
            self.subscribeQueue.onNext(subscribe)
            return Disposables.create()
        }
    }

    public func read(by id: Entity.Id) -> Observable<Entity?> {
        return Observable.concat(
            readLatest(by: id).asObservable(),
            transitions.filter({ $0.target == id }).map({ $0.entity })
        )
    }

    public func readLatest(by id: Entity.Id) -> Single<Entity?> {
        return persistence.restore(by: id)
    }

    public struct Transition {
        public let target: Entity.Id
        public let entity: Entity?
    }

    private typealias Subscribe = (SingleEvent<Entity?>) -> Void

    private struct Request {
        public let target: Entity.Id
        public let update: (Entity?) -> Single<Entity?>
    }

    private struct Process {
        public let target: Entity.Id
        public let entity: Entity?
    }
}
