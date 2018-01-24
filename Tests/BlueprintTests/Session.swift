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
                    .subscribe(onNext: { currentId = $0 })
                    .disposed(by: disposeBag)
                session.update(id)
                expect(currentId).toEventually(equal(id))
            }
        }
    }

    struct TestId: Domain.Id, Domain.Box {
        let value: String

        init(_ value: String) {
            self.value = value
        }
    }
}
