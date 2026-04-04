"""
Adaptive Explanation Engine entry point.
"""

import from services.appService { generate_explanation }
import from services.appService { load_preferences, save_preferences }

cl import ".styles.global.css";
cl import from .index { ClientApp }

cl {
    def:pub app() -> JsxElement {
        return <ClientApp />;
    }
}
