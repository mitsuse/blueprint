import Domain
import RxSwift

public protocol Session: class {
    associatedtype Id: Domain.Id

    var user: Observable<Result<Id?, Error>> { get }
    var currentUser: Id? { get }

    func update(_ update: Result<Id?, Error>)
}
