import Quick
import Nimble

@testable import Blueprint

import Domain

import RxSwift

final class ModelSpec: QuickSpec {
    override func spec() {
        describe("Model") {
            it("can create a new entity") {
                let disposeBag = DisposeBag()
                let persistence = InMemoryPersistence<TestEntity>()
                let model = Model(persistence: persistence)
                let entity = TestEntity(id: TestEntity.Id("test"), name: "Test")

                var current: TestEntity? = nil
                model
                    .update(id: entity.id) { $0 ?? entity }
                    .subscribe(onSuccess: { current = $0 })
                    .disposed(by: disposeBag)
                expect(current).toEventually(equal(entity))
                expect(current?.name).toEventually(equal(entity.name))

                var stored: TestEntity? = nil
                persistence
                    .restore(by: entity.id)
                    .subscribe(onSuccess: { stored = $0 })
                    .disposed(by: disposeBag)
                expect(stored).toEventually(equal(entity))
                expect(stored?.name).toEventually(equal(entity.name))
            }

            it("should publish transitions to subscribers") {
                let disposeBag = DisposeBag()
                let persistence = InMemoryPersistence<TestEntity>()
                let model = Model(persistence: persistence)
                let entity = TestEntity(id: TestEntity.Id("test"), name: "Test")

                var transition: Model<TestEntity>.Transition? = nil
                model
                    .transitions
                    .subscribe(onNext: { transition = $0 })
                    .disposed(by: disposeBag)
                model
                    .update(id: entity.id) { $0 ?? entity }
                    .subscribe()
                    .disposed(by: disposeBag)
                expect(transition?.target).toEventually(equal(entity.id))
                expect(transition?.entity).toEventually(equal(entity))
                expect(transition?.entity?.name).toEventually(equal(entity.name))
            }

            it("should process all received updates") {
                let disposeBag = DisposeBag()
                let persistence = InMemoryPersistence<TestEntity>()
                let model = Model(persistence: persistence)
                let iteration = 10
                let entity = TestEntity(id: TestEntity.Id("test"), name: String(repeating: ".", count: iteration))

                var transition: Model<TestEntity>.Transition? = nil
                model
                    .transitions
                    .subscribe(onNext: { transition = $0 })
                    .disposed(by: disposeBag)

                (0..<(iteration)).forEach { x in
                    model
                        .update(id: entity.id) { TestEntity(id: entity.id, name: ($0?.name ?? "") + ".") }
                        .subscribe()
                        .disposed(by: disposeBag)
                }
                expect(transition?.target).toEventually(equal(entity.id))
                expect(transition?.entity).toEventually(equal(entity))
                expect(transition?.entity?.name).toEventually(equal(entity.name))
            }
        }
    }

    struct TestEntity: Domain.Entity {
        let id: Id
        let name: String

        struct Id: Domain.Id, Domain.Box {
            let value: String

            init(_ value: String) {
                self.value = value
            }
        }
    }
}
