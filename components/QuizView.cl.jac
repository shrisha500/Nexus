"""QuizView.cl.jac — Retention mode multiple-choice quiz."""

import from "../styles/quiz.css" { quiz_css }

def:pub QuizView(questions: list) -> JsxElement {
    has answered: list = [];  # [{"q_idx": int, "chosen": int, "correct": bool}]

    def answer(q_idx: int, chosen_display_idx: int, correct_display_idx: int) -> None {
        for a in answered {
            if a["q_idx"] == q_idx { return; }  # already answered
        }
        is_correct = (chosen_display_idx == correct_display_idx);
        answered = answered + [{"q_idx": q_idx, "chosen": chosen_display_idx, "correct": is_correct}];
    }

    def get_answer(q_idx: int) -> any {
        for a in answered { if a["q_idx"] == q_idx { return a; } }
        return None;
    }

    score    = len([a for a in answered if a["correct"]]);
    finished = len(answered) == len(questions);

    return <div className="quiz-view">
        <div className="quiz-header">
            <h2 className="quiz-title">Knowledge Check</h2>
            <span className="quiz-score">{score} / {len(questions)}</span>
        </div>

        {[
            <QuizQuestion
                key={qi}
                q_idx={qi}
                question_data={q}
                answer_state={get_answer(qi)}
                onAnswer={lambda ci: int, cdi: int -> None { answer(qi, ci, cdi); }}
            />
            for qi, q in enumerate(questions)
        ]}

        {finished and
            <div className="quiz-result">
                <span className="quiz-result__emoji">
                    {("🎉" if score == len(questions) else ("👍" if score * 2 >= len(questions) else "📖"))}
                </span>
                <p className="quiz-result__text">
                    {(
                        "Perfect! You nailed it." if score == len(questions) else
                        (f"Nice work — {score}/{len(questions)} correct." if score * 2 >= len(questions) else
                         f"{score}/{len(questions)} correct. Try reviewing the concepts above.")
                    )}
                </p>
            </div>
        }
    </div>;
}

def:pub QuizQuestion(
    q_idx:         int,
    question_data: dict,
    answer_state:  any,
    onAnswer:      any
) -> JsxElement {
    # question_data: {question_str: [correct_answer, wrong1, wrong2, wrong3]}
    # correct answer is always index 0 in the raw list.
    q_text   = list(question_data.keys())[0];
    raw      = question_data[q_text];  # 4 choices, [0] is correct

    # Deterministic shuffle per question index so correct isn't always first
    # Pattern: [1,2,0,3] rotates correct answer to pos 2 by default
    DISPLAY_ORDER = [1, 2, 0, 3];
    displayed     = [raw[DISPLAY_ORDER[i]] for i in range(4)];
    correct_di    = DISPLAY_ORDER.index(0);  # display-index of correct answer

    answered = answer_state is not None;

    def btn_class(di: int) -> str {
        if not answered { return "choice-btn"; }
        if di == correct_di  { return "choice-btn choice-btn--correct"; }
        if answered and answer_state["chosen"] == di and di != correct_di {
            return "choice-btn choice-btn--wrong";
        }
        return "choice-btn choice-btn--dimmed";
    }

    return <div className={("quiz-question" + (" quiz-question--answered" if answered else ""))}>
        <p className="quiz-question__text">
            <span className="quiz-question__num">{q_idx + 1}.</span>
            {q_text}
        </p>
        <div className="choices">
            {[
                <button
                    key={di}
                    type="button"
                    className={btn_class(di)}
                    disabled={answered}
                    onClick={lambda -> None { onAnswer(di, correct_di); }}
                >
                    <span className="choice-letter">{["A","B","C","D"][di]}</span>
                    <span className="choice-text">{displayed[di]}</span>
                </button>
                for di in range(4)
            ]}
        </div>
    </div>;
}
