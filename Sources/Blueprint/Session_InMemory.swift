import Domain
import RxSwift

public final class InMemorySession<Id>: Session where Id: Domain.Id {
    private let userSubject = BehaviorSubject<Result<Id?, Error>>(value: .success(nil))

    public init() {
    }

    public var user: Observable<Result<Id?, Error>> {
        userSubject.asObservable()
    }

    public var currentUser: Id? {
        switch try! userSubject.value() {
        case let .success(id): return id
        case .failure: return nil
        }
    }

    public func update(_ update: Result<Id?, Error>) {
        switch update {
        case let .success(id): userSubject.on(.next(.success(id)))
        case let .failure(error): userSubject.on(.next(.failure(error)))
        }
    }
}
