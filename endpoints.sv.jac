"""Jac Hackathon Project - Server-Side Data Layer.

Each user gets their own todo list automatically!
When authenticated, `root spawn` uses the user's personal root node.
"""

# ========================================
# Nodes
# ========================================
node UserProfile {
    has known_topics: list[str],
        style_example: str,
        depth_pref: int,
        retention_mode: bool = False; # does the user want quizzes
}

# Created every time a user highlights text and wants a concept explained
node ExplanationSession {
    has raw_text: str,
        source_url: str, # url of the page the user is currently on
        depth: int, # depth for this specific request
        session_created_at: str; # timestamp
} 

# There are multiple concepts in an explanation session
# Some concepts are created by the AI as prereqs for the
# current topic (prereq=True)
node ConceptNode {
    has concept_name: str, # name of the concept
        detail_level: int,
        explanation: str = "",
        is_prereq: bool = False; # user directly selected this concept
}

# Vocab
node TermNode {
    has word: str,
        plain_meaning: str,
        real_name: str, # proper technical term
        usage_context: str; # when and where this term is used
}

# ========================================
# Edges
# ========================================

# Created every time a user makes a new explain request
# [UserProfile]--HasSession->[ExplanationSession]
edge HasSession {
    has created_at: str, # timestamp
        explanation_depth: int; # depth for explanation request
}

# [ExplanationSession]--HasConcept->[ConceptNode]
edge HasConcept {
    has order: int,
        is_entry_point: bool;
}

# [ConceptNode A]--DependsOn->[ConceptNode B]
edge DependsOn {
    has priority: int, 
        relationship: str,
        auto_discovered: bool;
}

# [ConceptNode]--UsesTerm->[TermNode]
edge UsesTerm {
    has position_in_text: int,
        is_defined_before_use: bool;
}


# ========================================
# Walkers (API Operations)
# ========================================

# ExplainWalker is the entry point and orchestrator. 
# It's spawned when the user hits "Explain." It carries 
# the raw selected text and the requested depth. 
# It visits root first to find (or create) the UserProfile, 
# then creates a new ExplanationSession node and attaches it. 
# Once the session exists, it spawns the other walkers in sequence — 
# first TermExtractorWalker, then DependencyWalker, then ExplanationBuilderWalker. 
# It doesn't do any AI work itself; its job is to set up the graph and hand off to specialists. 
# Think of it as the project manager.
walker:priv ExplainWalker {
    has known_topics: list[str] = [],
        style_example: str = "",
        depth_pref: int = -1,
        created_at: str = "",
        explanation_depth: int = -1,
        raw_text: str = "",
        source_url: str = "",
        depth: int = -1,
        session_created_at: str = "";
    
    can create with Root entry {
        user_profile_node = [root()-->][?:UserProfile];
        if not user_profile_node {
            root() ++> UserProfile(known_topics=known_topics, style_example=style_example, depth_pref=depth_pref);
            # should we add a survey here to set these values?
        }
        
        user_profile_node[0] +>: HasSession(created_at=created_at, explanation_depth=explanation_depth) :+> ExplanationSession(
            # HasSession is an edge, ExplanationSession is a node
            # +>: EdgeType :+>
            raw_text=raw_text,
            source_url=source_url,
            depth=depth,
            session_created_at=session_created_at
        );

        #Calling the other walkers
        #...
    }
}

def extract_unknown_terms(raw_text: str, known_topics: list[str]) -> list[str] by llm();
    
sem extract_unknown_terms = "Given a string of text called raw_text and a list of strings called known_topics, extract jargon wods from the raw_text not in the known_topics and return these terms as a list of strings"; 

# TermExtractorWalker, then DependencyWalker, then ExplanationBuilderWalker

# TermExtractorWalker visits the ExplanationSession, reads raw_text, and identifies the unknown terms — 
#but it doesn't create TermNodes immediately. It stores the term list in its own walker state and passes 
# that list to the ExplanationBuilderWalker. The builder then creates TermNodes and attaches them to whichever 
# ConceptNode's explanation the term actually appears in. TermExtractorWalker's only real job is early detection — 
# flagging words so the builder knows what to watch for, not structuring the graph itself.
walker:priv TermExtractorWalker {
    has raw_text: str = "",
        known_topics: list[str] = [];

    extract_unknown_terms(raw_text=raw_text, known_topics=known_topics);
}

walker:priv DependencyWalker {

}

walker:priv ExplanationBuilderWalker {

}

walker:priv RetentionWalker {
    
}

# walker:priv AddTodo {
#     """Add a new todo item to the user's list."""
#     has title: str;

#     can create with Root entry {
#         global todo_counter;
#         todo_counter += 1;
#         new_id = "todo_" + str(todo_counter);
#         new_todo = here ++> Todo(id=new_id, title=self.title, completed=False);
#         if new_todo {
#             report new_todo[0] ;
#         }
#     }
# }

# walker:priv ListTodos {
#     """List all todo items for the current user."""
#     has todos: list = [];

#     can collect with Root entry {
#         visit [-->];
#     }

#     can gather with Todo entry {
#         self.todos.append(
#             {"id": here.id, "title": here.title, "completed": here.completed}
#         );
#     }

#     can report_all with Root exit {
#         report self.todos ;
#     }
# }

# walker:priv ToggleTodo {
#     """Toggle a todo's completed status."""
#     has todo_id: str;

#     can search with Root entry {
#         visit [-->];
#     }

#     can toggle with Todo entry {
#         if here.id == self.todo_id {
#             here.completed = not here.completed;
#             report {"id": here.id, "completed": here.completed} ;
#         }
#     }
# }

# walker:priv DeleteTodo {
#     """Delete a todo item."""
#     has todo_id: str;

#     can search with Root entry {
#         visit [-->];
#     }

#     can delete with Todo entry {
#         if here.id == self.todo_id {
#             del here ;
#             report {"deleted": self.todo_id} ;
#         }
#     }
# }
