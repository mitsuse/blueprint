import Domain

import RxSwift

public final class Model<Id, Property> where Id: Domain.Id {
    private let disposeBag = DisposeBag()

    private let persistence: AnyPersistence<Id, Property>

    private let semaphore = PublishSubject<Void>()
    private let subscribeQueue = PublishSubject<Subscribe>()
    private let requestQueue = PublishSubject<Request>()
    private let transitionStream = PublishSubject<Entity<Id, Property>>()

    public init<Persistence>(persistence: Persistence) where Persistence: Blueprint.Persistence, Persistence.Id == Id, Persistence.Property == Property {
        self.persistence = AnyPersistence(persistence)

        Observable.zip(semaphore, requestQueue)
            .flatMap { [unowned self] (_, request) -> Single<Entity<Id, Property>> in
                self.persistence.restore(by: request.target)
                    .flatMap { request.update($0.property) }
                    .map { Entity(id: request.target, property: $0) }
            }
            .flatMap { [unowned self] entity in
                self.persistence.store(entity)
            }
            .subscribe(onNext: { [unowned self] entity in self.transitionStream.onNext(entity) })
            .disposed(by: disposeBag)

        Observable.zip(transitionStream, subscribeQueue)
            .subscribe(onNext: { [unowned self] (entity, subscribe) in
                subscribe(.success(entity))
                self.semaphore.onNext(())
            })
            .disposed(by: disposeBag)

        semaphore.onNext(())
    }

    public var transitions: Observable<Entity<Id, Property>> {
        return transitionStream.asObserver()
    }

    public func update(id: Id, _ block: @escaping (Property?) -> Property?) -> Single<Entity<Id, Property>> {
        update(id: id) { entity in Single.just(block(entity)) }
    }

    public func update(id: Id, _ block: @escaping (Property?) -> Single<Property?>) -> Single<Entity<Id, Property>> {
        return Single.create { [unowned self] subscribe in
            self.requestQueue.onNext(Request(target: id, update: block))
            self.subscribeQueue.onNext(subscribe)
            return Disposables.create()
        }
    }

    public func read(by id: Id) -> Observable<Entity<Id, Property>> {
        return Observable.concat(
            readLatest(by: id).asObservable(),
            transitions.filter({ $0.id == id })
        )
    }

    public func readLatest(by id: Id) -> Single<Entity<Id, Property>> {
        return persistence.restore(by: id)
    }

    private typealias Subscribe = (SingleEvent<Entity<Id, Property>>) -> Void

    private struct Request {
        public let target: Id
        public let update: (Property?) -> Single<Property?>
    }
}
