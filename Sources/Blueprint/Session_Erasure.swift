import Domain
import RxSwift

public final class AnySession<Id: Domain.Id>: Session {
    private let _user: () -> Observable<Id?>
    private let _currentUser: () -> Id?
    private let _update: (Id?) -> Void

    public init<Session>(_ session: Session) where Session: Blueprint.Session, Session.Id == Id {
        self._user = { session.user }
        self._currentUser = { session.currentUser }
        self._update = session.update
    }

    public var user: Observable<Id?> { return _user() }
    public var currentUser: Id? { return _currentUser() }

    public func update(_ user: Id?) { return _update(user) }
}
