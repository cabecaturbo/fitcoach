import XCTest
@testable import ConversationalMacroCoach

final class OnboardingFlowTests: XCTestCase {
    func testRequiredQuestionsMustBeAnswered() {
        var finished = false
        let viewModel = OnboardingFlowViewModel { _ in
            finished = true
        }

        let requiredIds: [Int] = [20, 23, 27]
        requiredIds.forEach { id in
            let question = question(withId: id, from: viewModel.groups)
            viewModel.recordAnswer("Test", for: question)
        }

        XCTAssertTrue(viewModel.canFinish)
        viewModel.finish()
        XCTAssertTrue(finished)
    }

    func testFinishBlockedWhenRequiredMissing() {
        var finished = false
        let viewModel = OnboardingFlowViewModel { _ in
            finished = true
        }

        let question20 = question(withId: 20, from: viewModel.groups)
        viewModel.recordAnswer("DEXA 15%", for: question20)
        // Intentionally skip Q23 and Q27

        XCTAssertFalse(viewModel.canFinish)
        viewModel.finish()
        XCTAssertFalse(finished)
    }

    func testSkipOptionalQuestion() {
        let viewModel = OnboardingFlowViewModel { _ in }
        let question = question(withId: 5, from: viewModel.groups)

        viewModel.recordAnswer("Shellfish", for: question)
        XCTAssertEqual(viewModel.answers[5], "Shellfish")

        viewModel.skip(question: question)
        XCTAssertNil(viewModel.answers[5])
    }

    private func question(withId id: Int, from groups: [QuestionGroup]) -> Question {
        guard let question = groups.flatMap(\.questions).first(where: { $0.id == id }) else {
            fatalError("Missing question \(id)")
        }
        return question
    }
}

