import Domain
import RxSwift

public final class InMemorySession<Id>: Session where Id: Domain.Id {
    private let userVariable = Variable<Id?>(nil)

    public init() {
    }

    public var user: Observable<Id?> { return userVariable.asObservable() }
    public var currentUser: Id? { return userVariable.value }

    public func update(_ user: Id?) {
        userVariable.value = user
    }
}
