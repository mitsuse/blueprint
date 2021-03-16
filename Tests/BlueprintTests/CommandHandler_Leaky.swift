import Quick
import Nimble

import RxSwift

import Blueprint

final class LeakyCommandHandlerSpec: QuickSpec {
    override func spec() {
        describe("LeakyCommandHandler") {
            it("should return the result of processing command.") {
                let disposeBag = DisposeBag()
                let handler: LeakyCommandHandler<Int> = LeakyCommandHandler()

                let expectation = 1

                var result: Int?

                handler.handle({ () in Single.just(expectation) })
                    .subscribe(onSuccess: { value in result = value })
                    .disposed(by: disposeBag)

                expect(result).toEventually(equal(expectation))
            }

            context("if it is processing a command") {
                it("should be busy") {
                    let disposeBag = DisposeBag()
                    let scheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "jp.mitsuse.BlueprintTests.LeakyCommandHandler")
                    let handler: LeakyCommandHandler<Int> = LeakyCommandHandler()

                    var result: Bool? = nil
                    handler.isBusy
                        .subscribe(onNext: { isBusy in result = isBusy })
                        .disposed(by: disposeBag)
                    handler.handle({ () in Single.timer(.seconds(1), scheduler: scheduler) })
                        .subscribe()
                        .disposed(by: disposeBag)
                    expect(result).toEventually(beTrue())
                }
            }
        }
    }
}
