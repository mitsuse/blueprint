import Domain

import RxSwift

extension Model {
    public func read<Session>(with session: Session) -> Observable<Entity<Id, Property>?> where Session: Blueprint.Session, Session.Id == Id {
        return session.user
            .flatMap { [unowned self] userId -> Observable<Entity<Id, Property>?> in
                let observable: Observable<Entity<Id, Property>?>
                switch userId {
                case let .success(.some(userId)):observable = self.read(by: userId).map { $0 }
                case .success(.none), .failure: observable = Observable.just(nil)
                }
                return observable
            }
    }
}
