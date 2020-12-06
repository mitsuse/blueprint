import Domain

import RxSwift

public final class InMemoryPersistence<Id, Property>: Persistence where Id: Domain.Id {
    private var dictionary: [Id: Property]

    public init() {
        self.dictionary = [:]
    }

    public func store(_ entity: Entity<Id, Property>) -> Single<Entity<Id, Property>> {
        return Single.create { [unowned self] subscribe in
            switch entity.property {
            case .some: self.dictionary[entity.id] = entity.property
            case .none: self.dictionary.removeValue(forKey: entity.id)
            }
            subscribe(.success(entity))
            return Disposables.create()
        }
    }

    public func restore(by id: Id) -> Single<Entity<Id, Property>> {
        return Single.create { [unowned self] subscribe in
            subscribe(.success(Entity(id: id, property: self.dictionary[id])))
            return Disposables.create()
        }
    }
}
