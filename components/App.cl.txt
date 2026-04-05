"""App.cl.jac — Full-page shell: sidebar + main explanation panel."""

import from "./HistorySidebar.cl.jac"  { HistorySidebar  }
import from "./ExplainPanel.cl.jac"    { ExplainPanel    }
import from "./OnboardingModal.cl.jac" { OnboardingModal }
import from "../styles/app.css" { app_css }
sv import from endpoints { GetSessions }

def:pub App() -> JsxElement {
    has active_session_id:  str  = "";
    has show_onboarding:    bool = False;
    has sessions:           list[dict] = [];
    has loading_sessions:   bool = True;

    async can with entry {
        await refresh_sessions();
    }

    async def refresh_sessions() {
        loading_sessions = True;
        try {
            result = root() spawn GetSessions();
            if result["sessions"] and len(list[dict]((result["sessions"])))> 0 {
                sessions = list[dict](result["sessions"]);
            }
        } except Exception as e {
            print(f"Sessions load error: {e}");
        }
        loading_sessions = False;
    }

    def select_session(sid: str) -> None {
        active_session_id = sid;
    }

    def new_explain() -> None {
        active_session_id = "";
    }

    def on_explain_done(sid: str) -> None {
        active_session_id = sid;
        refresh_sessions();
    }

    return <div className="app-shell">
        {show_onboarding and
            <OnboardingModal onClose={lambda -> None { show_onboarding = False; }} />
        }
        <HistorySidebar
            sessions={sessions}
            loading={loading_sessions}
            activeSessionId={active_session_id}
            onSelectSession={select_session}
            onNewExplain={new_explain}
            onOpenSettings={lambda -> None { show_onboarding = True; }}
        />
        <main className="main-content">
            <ExplainPanel
                activeSessionId={active_session_id}
                onExplainDone={on_explain_done}
            />
        </main>
    </div>;
}
