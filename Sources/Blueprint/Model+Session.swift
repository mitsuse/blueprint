import Domain

import RxSwift

extension Model {
    public func read<Session>(with session: Session) -> Observable<Entity?> where Session: Blueprint.Session, Session.Id == Entity.Id {
        return session.user
            .flatMap { [unowned self] userId -> Observable<Entity?> in
                let observable: Observable<Entity?>
                switch userId {
                case let .some(userId): observable = self.read(by: userId)
                case .none: observable = Observable.just(nil)
                }
                return observable
            }
    }
}