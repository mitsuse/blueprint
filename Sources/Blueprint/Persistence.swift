import Domain

import RxSwift

public protocol Persistence {
    associatedtype Entity: Domain.Entity

    func store(_ entity: Entity?, with id: Entity.Id) -> Single<Entity?>
    func restore(by id: Entity.Id) -> Single<Entity?>
}
