import Domain

import RxSwift

public final class InMemoryPersistence<Entity>: Persistence where Entity: Domain.Entity {
    private var dictionary: [Entity.Id: Entity]

    public init() {
        self.dictionary = [:]
    }

    public func store(_ entity: Entity?, with id: Entity.Id) -> Single<Entity?> {
        return Single.create { [unowned self] subscribe in
            self.dictionary[id] = entity
            subscribe(.success(entity))
            return Disposables.create()
        }
    }

    public func restore(by id: Entity.Id) -> Single<Entity?> {
        return Single.create { [unowned self] subscribe in
            subscribe(.success(self.dictionary[id]))
            return Disposables.create()
        }
    }
}
