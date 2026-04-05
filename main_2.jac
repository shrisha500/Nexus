"""Adaptive Explanation Engine — Frontend Entry Point (full-page web app)."""

sv import from endpoints {
    Explain,
    SetupProfile,
    GetSessions,
    GetSessionDetail
}

cl {
    import from react { createContext, useContext }
    import from "./styles/globals.css" { globals_css }
    import from "./components/AuthForm.cl.jac" { AuthForm }
    import from "./components/App.cl.jac" { App }

    glob AppContext = createContext(None);

    def:pub AppProvider(props: dict) -> JsxElement {
        has is_authenticated: bool = False;

        value = {
            "is_authenticated": is_authenticated,
            "login":  lambda -> None { is_authenticated = True;  },
            "logout": lambda -> None { is_authenticated = False; }
        };

        return <AppContext.Provider value={value}>
            {props.children}
        </AppContext.Provider>;
    }

    def:pub app() -> JsxElement {
        return <AppProvider>
            <RootRouter />
        </AppProvider>;
    }

    def:pub RootRouter() -> JsxElement {
        ctx = useContext(AppContext);
        if ctx.is_authenticated {
            return <App />;
        }
        return <AuthGate />;
    }

    def:pub AuthGate() -> JsxElement {
        has username:  str  = "";
        has password:  str  = "";
        has is_signup: bool = False;
        has error:     str  = "";
        has loading:   bool = False;

        ctx = useContext(AppContext);

        async def handle_submit(e: any) -> None {
            e.preventDefault();
            loading = True;
            error   = "";
            try {
                endpoint = "/user/register" if is_signup else "/user/login";
                resp = await fetch(endpoint, {
                    "method":  "POST",
                    "headers": {"Content-Type": "application/json"},
                    "body":    JSON.stringify({"username": username, "password": password})
                });
                data = await resp.json();
                if data.token {
                    ctx.login();
                } else {
                    error = data.message if data.message else "Authentication failed";
                }
            } except Exception as ex {
                error = str(ex);
            }
            loading = False;
        }

        return <AuthForm
            isSignup={is_signup}
            username={username}
            password={password}
            error={error}
            loading={loading}
            onUsernameChange={lambda e: any -> None { username = e.target.value; }}
            onPasswordChange={lambda e: any -> None { password = e.target.value; }}
            onSubmit={lambda e: any -> None { handle_submit(e); }}
            onToggleMode={lambda -> None { is_signup = not is_signup; error = ""; }}
        />;
    }
}
