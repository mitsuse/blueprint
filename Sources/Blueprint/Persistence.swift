import Domain

import RxSwift

public protocol Persistence {
    associatedtype Id: Domain.Id
    associatedtype Property

    func store(_ entity: Entity<Id, Property>) -> Single<Entity<Id, Property>>
    func restore(by id: Id) -> Single<Entity<Id, Property>>
}
