import Domain
import RxSwift

public protocol Session: class {
    associatedtype Id: Domain.Id

    var user: Observable<Id?> { get }
    var currentUser: Id? { get }

    func update(_ user: Id?)
}
