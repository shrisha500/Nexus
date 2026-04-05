"""Adaptive Explanation Engine — Main App Component."""

import from "@jac/runtime" { jacSignup, jacLogin, jacLogout, jacIsLoggedIn }

import from .components.AuthForm { AuthForm }
import from .components.SurveyModal { SurveyModal }
import from .components.ExplanationResult { ExplanationResult }
import from .components.SessionHistory { SessionHistory }

sv import from endpoints { Explain, SetupProfile, GetSessions, GetSessionDetail }

def:pub app -> JsxElement {
    has isLoggedIn: bool = False,
        checkingAuth: bool = True,
        isSignup: bool = False,
        username: str = "",
        password: str = "",
        error: str = "",
        loading: bool = False;

    has surveyVisible: bool = False,
        surveyKnownTopics: str = "",
        surveyStyle: str = "",
        surveyDepth: int = 2,
        surveyRetention: bool = False;

    has newRawText: str = "",
        newSourceUrl: str = "",
        newDepth: int = 2;

    has explanationResult: list = [],
        quizResult: list = [],
        explanationLoading: bool = False,
        explanationError: str = "";

    has sessions: list = [],
        selectedSessionId: str = "",
        sessionDetail: dict = {},
        historyLoading: bool = False,
        showHistory: bool = False;

    can with entry {
        isLoggedIn = jacIsLoggedIn();
        checkingAuth = False;
    }

    can with [isLoggedIn] entry {
        if isLoggedIn {
            fetchSessions();
        }
    }

    async def fetchSessions -> None;
    async def fetchSessionDetail(sessionId: str) -> None;
    async def submitExplanation -> None;
    async def handleLogin -> None;
    async def handleSignup -> None;
    async def handleSubmit(e: any) -> None;
    async def handleLogout -> None;
    async def submitSurvey -> None;
    def handleDepthChange(val: int) -> None;
    async def handleKeyPress(e: any) -> None;

    # ================================================================
    # LOADING SCREEN
    # ================================================================
    if checkingAuth {
        return
            <div style={{
                "display": "flex",
                "justifyContent": "center",
                "alignItems": "center",
                "height": "100vh",
                "fontFamily": "system-ui, -apple-system, sans-serif",
                "background": "#0a0a1a",
                "color": "#888"
            }}>
                Loading...
            </div>;
    }

    # ================================================================
    # AUTH SCREEN
    # ================================================================
    if not isLoggedIn {
        return
            <div style={{
                "minHeight": "100vh",
                "background": "linear-gradient(135deg, #0a0a1a 0%, #1a1a3e 100%)",
                "display": "flex",
                "alignItems": "center",
                "justifyContent": "center"
            }}>
                <AuthForm
                    isSignup={isSignup}
                    username={username}
                    password={password}
                    error={error}
                    loading={loading}
                    onUsernameChange={lambda e: any -> None { username = e.target.value; }}
                    onPasswordChange={lambda e: any -> None { password = e.target.value; }}
                    onSubmit={handleSubmit}
                    onToggleMode={lambda -> None { isSignup = not isSignup; error = ""; }}
                />
            </div>;
    }

    # ================================================================
    # MAIN APP (logged in)
    # ================================================================
    return
        <div style={{
            "display": "flex",
            "height": "100vh",
            "fontFamily": "system-ui, -apple-system, sans-serif",
            "background": "#0a0a1a",
            "color": "#e8e8f0",
            "overflow": "hidden"
        }}>

            {(
                <SurveyModal
                    knownTopics={surveyKnownTopics}
                    style={surveyStyle}
                    depth={surveyDepth}
                    retention={surveyRetention}
                    onTopicsChange={lambda e: any -> None { surveyKnownTopics = e.target.value; }}
                    onStyleChange={lambda e: any -> None { surveyStyle = e.target.value; }}
                    onDepthChange={lambda d: int -> None { surveyDepth = d; }}
                    onRetentionChange={lambda r: bool -> None { surveyRetention = r; }}
                    onSubmit={lambda -> None { submitSurvey(); }}
                />
            )
            if surveyVisible
            else None}

            <div style={{
                "width": ("280px" if showHistory else "0px"),
                "minWidth": ("280px" if showHistory else "0px"),
                "overflow": "hidden",
                "background": "#111128",
                "borderRight": "1px solid #2a2a4a",
                "transition": "width 0.3s ease, min-width 0.3s ease",
                "display": "flex",
                "flexDirection": "column"
            }}>
                {(
                    <SessionHistory
                        sessions={sessions}
                        selectedSessionId={selectedSessionId}
                        loading={historyLoading}
                        onSelect={lambda sid: str -> None { fetchSessionDetail(sid); selectedSessionId = sid; }}
                    />
                )
                if showHistory
                else None}
            </div>

            <div style={{
                "flex": "1",
                "display": "flex",
                "flexDirection": "column",
                "overflow": "hidden"
            }}>

                <div style={{
                    "display": "flex",
                    "alignItems": "center",
                    "justifyContent": "space-between",
                    "padding": "0.75rem 1.5rem",
                    "background": "#111128",
                    "borderBottom": "1px solid #2a2a4a",
                    "flexShrink": "0"
                }}>
                    <div style={{"display": "flex", "alignItems": "center", "gap": "1rem"}}>
                        <button
                            onClick={lambda -> None { showHistory = not showHistory; }}
                            style={{
                                "background": "none",
                                "border": "1px solid #3a3a6a",
                                "color": "#aaa",
                                "padding": "0.4rem 0.8rem",
                                "borderRadius": "6px",
                                "cursor": "pointer",
                                "fontSize": "0.85rem"
                            }}
                        >
                            {("Hide History" if showHistory else "History")}
                        </button>
                        <span style={{
                            "fontSize": "1.2rem",
                            "fontWeight": "700",
                            "color": "#c084fc",
                            "letterSpacing": "-0.5px"
                        }}>
                            Nexus
                        </span>
                    </div>
                    <button
                        onClick={handleLogout}
                        style={{
                            "background": "none",
                            "border": "1px solid #3a3a6a",
                            "color": "#aaa",
                            "padding": "0.4rem 0.8rem",
                            "borderRadius": "6px",
                            "cursor": "pointer",
                            "fontSize": "0.85rem"
                        }}
                    >
                        Log Out
                    </button>
                </div>

                <div style={{
                    "flex": "1",
                    "overflowY": "auto",
                    "padding": "2rem",
                    "display": "flex",
                    "flexDirection": "column",
                    "gap": "1.5rem",
                    "alignItems": "center"
                }}>

                    <div style={{
                        "width": "100%",
                        "maxWidth": "720px",
                        "background": "#16162a",
                        "borderRadius": "14px",
                        "padding": "1.5rem",
                        "border": "1px solid #2a2a4a",
                        "boxShadow": "0 4px 24px rgba(0,0,0,0.4)"
                    }}>
                        <h2 style={{
                            "margin": "0 0 1.25rem 0",
                            "fontSize": "1.1rem",
                            "fontWeight": "600",
                            "color": "#c084fc"
                        }}>
                            What do you want explained?
                        </h2>

                        <textarea
                            value={newRawText}
                            onChange={lambda e: any -> None { newRawText = e.target.value; }}
                            placeholder="Paste the text or concept you want explained..."
                            rows="4"
                            style={{
                                "width": "100%",
                                "padding": "0.75rem",
                                "fontSize": "0.95rem",
                                "border": "1px solid #3a3a5a",
                                "borderRadius": "8px",
                                "background": "#0d0d20",
                                "color": "#e8e8f0",
                                "resize": "vertical",
                                "outline": "none",
                                "boxSizing": "border-box",
                                "fontFamily": "inherit",
                                "lineHeight": "1.5"
                            }}
                        />

                        <input
                            type="text"
                            value={newSourceUrl}
                            onChange={lambda e: any -> None { newSourceUrl = e.target.value; }}
                            placeholder="Source URL (optional)"
                            style={{
                                "width": "100%",
                                "padding": "0.65rem 0.75rem",
                                "marginTop": "0.75rem",
                                "fontSize": "0.9rem",
                                "border": "1px solid #3a3a5a",
                                "borderRadius": "8px",
                                "background": "#0d0d20",
                                "color": "#e8e8f0",
                                "outline": "none",
                                "boxSizing": "border-box"
                            }}
                        />

                        <div style={{"marginTop": "1rem"}}>
                            <div style={{
                                "display": "flex",
                                "justifyContent": "space-between",
                                "marginBottom": "0.4rem",
                                "fontSize": "0.85rem",
                                "color": "#aaa"
                            }}>
                                <span>Depth</span>
                                <span style={{"color": "#c084fc", "fontWeight": "600"}}>
                                    {(
                                        "Level 1 — High-level intuition" if newDepth == 1
                                        else ("Level 2 — Practical understanding" if newDepth == 2
                                        else ("Level 3 — Technical details" if newDepth == 3
                                        else "Level 4 — Deep internals"))
                                    )}
                                </span>
                            </div>
                            <input
                                type="range"
                                min="1"
                                max="4"
                                value={newDepth}
                                onChange={lambda e: any -> None { newDepth = int(e.target.value); }}
                                style={{
                                    "width": "100%",
                                    "accentColor": "#c084fc"
                                }}
                            />
                            <div style={{
                                "display": "flex",
                                "justifyContent": "space-between",
                                "fontSize": "0.75rem",
                                "color": "#555",
                                "marginTop": "0.2rem"
                            }}>
                                <span>Surface</span>
                                <span>Deep</span>
                            </div>
                        </div>

                        {(
                            <div style={{
                                "marginTop": "0.75rem",
                                "padding": "0.6rem 0.75rem",
                                "background": "rgba(220,50,50,0.15)",
                                "border": "1px solid rgba(220,50,50,0.3)",
                                "borderRadius": "6px",
                                "color": "#f87171",
                                "fontSize": "0.85rem"
                            }}>
                                {explanationError}
                            </div>
                        )
                        if explanationError
                        else None}

                        <button
                            onClick={lambda -> None { submitExplanation(); }}
                            disabled={explanationLoading}
                            style={{
                                "width": "100%",
                                "marginTop": "1rem",
                                "padding": "0.8rem",
                                "fontSize": "1rem",
                                "fontWeight": "600",
                                "background": ("#444" if explanationLoading else "linear-gradient(135deg, #7c3aed, #a855f7)"),
                                "color": "white",
                                "border": "none",
                                "borderRadius": "8px",
                                "cursor": ("not-allowed" if explanationLoading else "pointer"),
                                "transition": "opacity 0.2s"
                            }}
                        >
                            {("Generating..." if explanationLoading else "Generate Explanation")}
                        </button>
                    </div>

                    {(
                        <ExplanationResult
                            concepts={explanationResult}
                            quiz={quizResult}
                        />
                    )
                    if explanationResult
                    else None}

                    {(
                        <ExplanationResult
                            concepts={sessionDetail["concepts"]}
                            quiz={[]}
                        />
                    )
                    if (selectedSessionId and sessionDetail and not explanationResult)
                    else None}

                </div>
            </div>
        </div>;
}
