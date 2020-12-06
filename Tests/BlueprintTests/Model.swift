import Quick
import Nimble

@testable import Blueprint

import Dispatch

import Domain
import RxSwift

final class ModelSpec: QuickSpec {
    override func spec() {
        describe("Model") {
            it("can create a new entity") {
                let disposeBag = DisposeBag()
                let persistence = InMemoryPersistence<TestId, TestProperty>()
                let model = Model(persistence: persistence)
                let entity = Entity(id: TestId("test"), property: TestProperty(name: "Test"))

                var current: Entity<TestId, TestProperty> = Entity(id: entity.id, property: nil)
                model
                    .update(id: entity.id) { $0 ?? entity.property }
                    .subscribe(onSuccess: { current = $0 })
                    .disposed(by: disposeBag)
                expect(current).toEventually(equal(entity))
                expect(current.property).toEventually(equal(entity.property))

                var stored: Entity<TestId, TestProperty>? = nil
                persistence
                    .restore(by: entity.id)
                    .subscribe(onSuccess: { stored = $0 })
                    .disposed(by: disposeBag)
                expect(stored).toEventually(equal(entity))
                expect(stored?.property).toEventually(equal(entity.property))
            }

            it("should publish transitions to subscribers") {
                let disposeBag = DisposeBag()
                let persistence = InMemoryPersistence<TestId, TestProperty>()
                let model = Model(persistence: persistence)
                let entity = Entity(id: TestId("test"), property: TestProperty(name: "Test"))

                var transition: Entity<TestId, TestProperty>? = nil
                model
                    .transitions
                    .subscribe(onNext: { transition = $0 })
                    .disposed(by: disposeBag)
                model
                    .update(id: entity.id) { $0 ?? entity.property }
                    .subscribe()
                    .disposed(by: disposeBag)
                expect(transition?.id).toEventually(equal(entity.id))
                expect(transition).toEventually(equal(entity))
                expect(transition?.property).toEventually(equal(entity.property))
            }

            it("should process all received updates") {
                let disposeBag = DisposeBag()
                let persistence = InMemoryPersistence<TestId, TestProperty>()
                let model = Model(persistence: persistence)
                let iteration = 10
                let entity = Entity(id: TestId("test"), property: TestProperty(name: String(repeating: ".", count: iteration)))

                var transition: Entity<TestId, TestProperty>? = nil
                model
                    .transitions
                    .subscribe(onNext: { transition = $0 })
                    .disposed(by: disposeBag)

                (0..<(iteration)).forEach { x in
                    model
                        .update(id: entity.id) { TestProperty(name: ($0?.name ?? "") + ".") }
                        .subscribe()
                        .disposed(by: disposeBag)
                }
                expect(transition?.id).toEventually(equal(entity.id))
                expect(transition).toEventually(equal(entity))
                expect(transition?.property).toEventually(equal(entity.property))
            }

            it("should process asynchronous updates sequentially") {
                let disposeBag = DisposeBag()
                let persistence = InMemoryPersistence<TestId, TestProperty>()
                let model = Model(persistence: persistence)
                let id = TestId("test")

                var transition: Entity<TestId, TestProperty>? = nil
                model
                    .transitions
                    .subscribe(onNext: { transition = $0 })
                    .disposed(by: disposeBag)

                let expectation = "0123456789"
                (0..<10).forEach { x in
                    model
                        .update(id: id) { property in
                            Single.create { observe in
                                DispatchQueue(label: "\(x)").async {
                                    let updated = TestProperty(name: (property?.name ?? "") + "\(x)")
                                    observe(.success(.some(updated)))
                                }
                                return Disposables.create()
                            }
                        }
                        .subscribe()
                        .disposed(by: disposeBag)
                }

                expect(transition?.property?.name).toEventually(equal(expectation), timeout: .seconds(1))
            }
        }
    }

    struct TestProperty: Equatable {
        let name: String
    }

    struct TestId: Domain.Id {
        let value: String

        init(_ value: String) {
            self.value = value
        }
    }
}
