import Domain

import RxSwift

public final class AnyPersistence<Id, Property>: Persistence where Id: Domain.Id {
    private let _store: (Entity<Id, Property>) -> Single<Entity<Id, Property>>
    private let _restore: (Id) -> Single<Entity<Id, Property>>

    public init<Persistence>(_ persistence: Persistence) where Persistence: Blueprint.Persistence, Persistence.Id == Id, Persistence.Property == Property {
        self._store = persistence.store
        self._restore = persistence.restore
    }

    public func store(_ entity: Entity<Id, Property>) -> Single<Entity<Id, Property>> { return _store(entity) }
    public func restore(by id: Id) -> Single<Entity<Id, Property>> { return _restore(id) }
}
