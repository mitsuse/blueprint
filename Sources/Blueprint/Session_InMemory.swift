import Domain
import RxSwift

public final class InMemorySession<Id>: Session where Id: Domain.Id {
    private let userSubject = BehaviorSubject<Id?>(value: nil)

    public init() {
    }

    public var user: Observable<Id?> { return userSubject.asObservable() }
    public var currentUser: Id? { return try! userSubject.value() }

    public func update(_ user: Id?) {
        userSubject.onNext(user)
    }
}
