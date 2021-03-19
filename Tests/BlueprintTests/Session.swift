import Quick
import Nimble

@testable import Blueprint

import Domain

import RxSwift

final class SessionSpec: QuickSpec {
    override func spec() {
        describe("InMemorySession") {
            it("should publish the current user Id to subscribers") {
                let disposeBag = DisposeBag()
                let session = InMemorySession<TestId>()
                let id = TestId("test")

                var currentId: TestId? = nil
                session.user
                    .subscribe(onNext: { user in
                        switch user {
                        case let .success(id): currentId = id
                        case .failure: currentId = nil
                        }
                    })
                    .disposed(by: disposeBag)
                session.update(.success(id))
                expect(currentId).toEventually(equal(id))
            }

            context("on receiving error") {
                it("should publish nil id to subscribers") {
                    let disposeBag = DisposeBag()
                    let session = InMemorySession<TestId>()
                    let id = TestId("test")

                    var currentId: TestId? = nil
                    session.user
                        .subscribe(onNext: { user in
                            switch user {
                            case let .success(id): currentId = id
                            case .failure: currentId = nil
                            }
                        })
                        .disposed(by: disposeBag)

                    session.update(.success(id))
                    expect(currentId).toEventually(equal(id))

                    session.update(.failure(TestError()))
                    expect(currentId).toEventually(beNil())
                }
            }

            context("after receiving errors") {
                it("can update the current user") {
                    let disposeBag = DisposeBag()
                    let session = InMemorySession<TestId>()
                    let id = TestId("test")

                    var currentId: TestId? = nil
                    session.user
                        .subscribe(onNext: { user in
                            switch user {
                            case let .success(id): currentId = id
                            case .failure: currentId = nil
                            }
                        })
                        .disposed(by: disposeBag)

                    session.update(.failure(TestError()))
                    session.update(.success(id))
                    expect(currentId).toEventually(equal(id))
                }
            }
        }
    }

    struct TestId: Domain.Id {
        let value: String

        init(_ value: String) {
            self.value = value
        }
    }

    struct TestError: Error {
    }
}
