# Project Blueprint: CodeNetra AI

## Overview
CodeNetra AI is an advanced assistive developer tool built with Flutter and powered by Google Gemini API. It bridges the gap between visual assets and executable code, featuring a unique "Dual Mode" interface.

## Key Features (Implemented)
* **🤖 AI-Powered Analysis:** Integration with Gemini API for code explanation and generation.
* **👁️ Live Vision:** "Netra Mode" to analyze real-world objects via camera.
* **💬 Repo Chat:** Context-aware chat interface for discussing repository code.
* **🎨 Cyberpunk UI:** Custom Neon Green & Black theme with smooth animations.
* **🔄 Dual Mode:** Seamless toggle between "Developer Mode" and "Netra Mode".

## Architecture & Tech Stack
* **Frontend:** Flutter (Dart)
* **AI Engine:** Google Gemini Pro & Gemini Pro Vision
* **State Management:** Provider / GetX (Confirm which one you used)
* **Backend:** Firebase (for auth/storage)

## Development Challenges & Solutions
During the development, we faced critical infrastructure constraints on Google IDX:
1.  **Build Failures:** Overcame "No space left on device" errors by optimizing Gradle caches and managing build artifacts efficiently.
2.  **Gradle Daemons:** Resolved plugin conflicts by manually resetting Gradle daemons.

## Future Roadmap
* Voice command integration for hands-free coding.
* Direct GitHub integration for pull requests.
