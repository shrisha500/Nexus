"""Todo App - Client-Side UI."""

import from "@jac/runtime" { jacSignup, jacLogin, jacLogout, jacIsLoggedIn }

#import from .components.TodoItem { TodoItem }
import from .components.AuthForm { AuthForm }
import from .components.SurveyModal { SurveyModal }

sv import from endpoints { AddTodo, ListTodos, ToggleTodo, DeleteTodo }

def:pub app -> JsxElement {
    has isLoggedIn: bool = False,
        checkingAuth: bool = True,
        isSignup: bool = False,
        username: str = "",
        password: str = "",
        error: str = "",
        loading: bool = False,
        todos: list = [],
        newRawText: str = "",
        newSourceUrl: str = "",
        newDepth: int,
        todosLoading: bool = True,
        surveyVisible: bool = False,
        surveyKnownTopics: str = "",
        surveyStyle: str = "",
        surveyDepth: int = 3,
        surveyRetention: bool = False,
        surveyResult: dict = {};

    can with entry {
        isLoggedIn = jacIsLoggedIn();
        checkingAuth = False;
    }

    can with [isLoggedIn] entry {
        if isLoggedIn {
            fetchTodos();
        }
    }

    can with [surveyResult] entry {
        if surveyResult is not None {
            print("Survey result:", surveyResult);
            # You can send this to backend later
        }
    }

    async def fetchTodos -> None;
    async def addTodo -> None;
    async def toggleTodo(todoId: str) -> None;
    async def deleteTodo(todoId: str) -> None;
    async def handleLogin -> None;
    async def handleSignup -> None;
    async def handleSurvey -> dict;
    def handleLogout -> None;
    async def handleSubmit(e: any) -> None;
    def handleTodoKeyPress(e: any) -> None;
    def submitSurvey -> None;
    def handleSurvey -> dict;

    # Loading screen
    if checkingAuth {
        return
            <div
                style={{
                    "display": "flex",
                    "justifyContent": "center",
                    "alignItems": "center",
                    "height": "100vh",
                    "fontFamily": "system-ui, -apple-system, sans-serif",
                    "color": "#666"
                }}
            >
                Loading...
            </div>;
    }

    # Logged in - Show Todo List
    if isLoggedIn {
        return
            <>
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
                    "background": "rgb(0, 0, 100)",
                    "padding": "2rem",
                    "borderRadius": "16px",
                    "boxShadow": "0 10px 30px rgba(0,0,0,0.2)",
                    "display": "flex",
                    "flexDirection": "column",
                    "alignItems": "center",
                    "gap": "1rem",
                    "width": "100vw",
                    "height": "100vh"
                }}>
                    
                    <div style={{
                        "marginBottom": "0.5rem",
                        "objectFit": "contain"
                    }}>
                    <img 
                    src="aghPX01.svg" alt="Logo" width="300" height="150"></img>
                    </div>

                    <input
                            type="text"
                            value={newRawText}
                            onChange={lambda e: any  -> None { newRawText = e.target.value;}}
                            onKeyPress={handleTodoKeyPress}
                            placeholder="What needs to be explained?"
                            style={{
                                "width": "50%",
                                "padding": "0.75rem 1rem",
                                "fontSize": "0.95rem",
                                "border": "1px solid #ddd",
                                "borderRadius": "8px",
                                "outline": "none",
                                "transition": "border 0.2s ease",
                                "backgroundColor": "#fafafa"
                            }}
                        />


                        <input
                            type="text"
                            value={newSourceUrl}
                            onChange={lambda e: any  -> None { newSourceUrl = e.target.value;}}
                            onKeyPress={handleTodoKeyPress}
                            placeholder="Enter a source URL"
                            style={{
                                "width": "50%",
                                "padding": "0.75rem 1rem",
                                "fontSize": "0.95rem",
                                "border": "1px solid #ddd",
                                "borderRadius": "8px",
                                "outline": "none",
                                "transition": "border 0.2s ease",
                                "backgroundColor": "#fafafa"
                            }}
                        />

                        <input
                            type="int"
                            value={newDepth}
                            onChange={lambda e: any  -> None { newDepth = e.target.value;}}
                            onKeyPress={handleTodoKeyPress}
                            placeholder="How in depth do you want to go?"
                            style={{
                                "width": "50%",
                                "padding": "0.75rem 1rem",
                                "fontSize": "0.95rem",
                                "border": "1px solid #ddd",
                                "borderRadius": "8px",
                                "outline": "none",
                                "transition": "border 0.2s ease",
                                "backgroundColor": "#fafafa"
                            }}
                        />
                        <button
                            onClick={lambda -> None { addTodo();}}
                            style={{
                                "width": "100%",
                                "marginTop": "0.5rem",
                                "padding": "0.8rem",
                                "fontSize": "1rem",
                                "fontWeight": "600",
                                "background": "linear-gradient(135deg, #4CAF50, #43a047)",
                                "color": "white",
                                "border": "none",
                                "borderRadius": "8px",
                                "cursor": "pointer",
                                "boxShadow": "0 4px 12px rgba(76,175,80,0.3)",
                                "transition": "transform 0.1s ease"
                            }}
                        >
                        Generate Explanation
                        </button>

                        <button style={{
                                "position": "absolute",
                                "top": "20px",
                                "right": "20px",
                                "padding": "0.5rem 1rem",
                                "fontSize": "0.85rem",
                                "backgroundColor": "rgba(255,255,255,0.9)",
                                "color": "#333",
                                "border": "none",
                                "borderRadius": "6px",
                                "cursor": "pointer",
                                "boxShadow": "0 2px 8px rgba(0,0,0,0.15)"
                            }}
                        onClick={handleLogout}

                    >
                        Log Out
                    </button>

                </div>
            </>;
    }

    # Not logged in - Show Auth Form
    return
        <AuthForm
            isSignup={isSignup}
            username={username}
            password={password}
            error={error}
            loading={loading}
            onUsernameChange={lambda e: any  -> None { username = e.target.value;}}
            onPasswordChange={lambda e: any  -> None { password = e.target.value;}}
            onSubmit={handleSubmit}
            onToggleMode={lambda -> None { isSignup = not isSignup;error = "";}}
        />;
}
