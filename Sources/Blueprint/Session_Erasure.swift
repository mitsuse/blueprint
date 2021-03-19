import Domain
import RxSwift

public final class AnySession<Id: Domain.Id>: Session {
    private let _user: () -> Observable<Result<Id?, Error>>
    private let _currentUser: () -> Id?
    private let _update: (Result<Id?, Error>) -> Void

    public init<Session>(_ session: Session) where Session: Blueprint.Session, Session.Id == Id {
        self._user = { session.user }
        self._currentUser = { session.currentUser }
        self._update = session.update
    }

    public var user: Observable<Result<Id?, Error>> { return _user() }
    public var currentUser: Id? { return _currentUser() }

    public func update(_ result: Result<Id?, Error>) { return _update(result) }
}
