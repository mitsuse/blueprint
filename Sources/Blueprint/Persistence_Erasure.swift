import Domain

import RxSwift

public final class AnyPersistence<Entity>: Persistence where Entity: Domain.Entity {
    private let _store: (Entity?, Entity.Id) -> Single<Entity?>
    private let _restore: (Entity.Id) -> Single<Entity?>

    public init<Persistence>(_ persistence: Persistence) where Persistence: Blueprint.Persistence, Persistence.Entity == Entity {
        self._store = persistence.store
        self._restore = persistence.restore
    }

    public func store(_ entity: Entity?, with id: Entity.Id) -> Single<Entity?> { return _store(entity, id) }
    public func restore(by id: Entity.Id) -> Single<Entity?> { return _restore(id) }
}
