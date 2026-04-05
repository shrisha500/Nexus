"""Implementations for the Adaptive Explanation Engine frontend."""

impl app.fetchSessions -> None {
    historyLoading = True;
    result = root() spawn GetSessions();
    sessions = result.reports[0]["sessions"] if result.reports else [];
    historyLoading = False;
}

impl app.fetchSessionDetail(sessionId: str) -> None {
    # Clear fresh results so the session detail renders instead
    explanationResult = [];
    quizResult = [];
    result = root() spawn GetSessionDetail(session_id=sessionId);
    sessionDetail = result.reports[0] if result.reports else {};
}

impl app.submitExplanation -> None {
    if not newRawText.trim() {
        explanationError = "Please enter some text to explain.";
        return;
    }
    explanationError = "";
    explanationLoading = True;
    explanationResult = [];
    quizResult = [];
    selectedSessionId = "";
    sessionDetail = {};

    response = root() spawn Explain(
        raw_text=newRawText,
        source_url=newSourceUrl,
        depth=newDepth
    );

    if response.reports {
        data = response.reports[0];
        explanationResult = data["explanation"] if "explanation" in data else [];

        # Backend returns quiz as list[dict[str, list[str]]] where each dict is
        # {question_text: [answer1, answer2, ...]} — normalize to
        # list[dict] with keys "question" and "answers" for the component.
        raw_quiz = data["quiz"] if "quiz" in data else [];
        normalized_quiz = [];
        for q_dict in raw_quiz {
            for q_text in q_dict {
                normalized_quiz.append({
                    "question": q_text,
                    "answers": q_dict[q_text]
                });
            }
        }
        quizResult = normalized_quiz;
    } else {
        explanationError = "Something went wrong. Please try again.";
    }

    explanationLoading = False;

    # Refresh history sidebar so the new session appears
    fetchSessions();
}

impl app.handleLogin -> None {
    error = "";
    if not username.trim() or not password {
        error = "Please fill in all fields.";
        return;
    }
    loading = True;
    success = await jacLogin(username, password);
    loading = False;
    if success {
        isLoggedIn = True;
        username = "";
        password = "";
    } else {
        error = "Invalid username or password.";
    }
}

impl app.handleSignup -> None {
    error = "";
    if not username.trim() or not password {
        error = "Please fill in all fields.";
        return;
    }
    if password.length < 4 {
        error = "Password must be at least 4 characters.";
        return;
    }
    loading = True;
    result = await jacSignup(username, password);
    loading = False;
    if result["success"] {
        isLoggedIn = True;
        username = "";
        password = "";
        # Show the onboarding survey right after signup
        surveyVisible = True;
    } else {
        error = result["error"] if result["error"] else "Signup failed.";
    }
}

impl app.submitSurvey -> None {
    topics = [t.strip() for t in surveyKnownTopics.split(",") if t.strip()];
    root() spawn SetupProfile(
        known_topics=topics,
        style_example=surveyStyle,
        depth_pref=surveyDepth,
        retention_mode=surveyRetention
    );
    surveyVisible = False;
}

impl app.handleLogout -> None {
    jacLogout();
    isLoggedIn = False;
    sessions = [];
    selectedSessionId = "";
    sessionDetail = {};
    explanationResult = [];
    quizResult = [];
    newRawText = "";
    newSourceUrl = "";
    newDepth = 2;
    username = "";
    password = "";
    error = "";
}

impl app.handleSubmit(e: any) -> None {
    e.preventDefault();
    if isSignup {
        await handleSignup();
    } else {
        await handleLogin();
    }
}

impl app.handleKeyPress(e: any) -> None {
    if e.key == "Enter" and not e.shiftKey {
        submitExplanation();
    }
}

impl app.handleDepthChange(val: int) -> None {
    newDepth = val;
}
