# TipsyPal mobile Application

Ever wanted to post something on social media after a night out — but didn’t want it to look like you typed with your elbows?  
TipsyPal is your AI-powered wingman.  

With just a tap of a button, you can choose different response styles — humorous, philosophical, or even dramatic — and let TipsyPal craft a polished, funny, and typo-free post for you.  

Think of TipsyPal as a smart filter between your tipsy thoughts and the online world:  
✨ No more embarrassing typos  
😂 Add a witty twist  
🧠 Sound deep when you want to  
😭 Or drop some beautifully sad vibe

Built with Flutter, powered by AI. 

# TipsyPal mobile Application

## Running the project in VS Code

This project includes a `.vscode/launch.json` with multiple run configurations.  
You can select them via the **Run and Debug (F5)** menu in VS Code.

### Available configs
- **TipsyPal PROD (Android)** → Runs the app on an Android emulator or device, connected to the production backend.  
- **TipsyPal PROD (Windows)** → Runs the app as a Windows desktop build, connected to the production backend.  
- **TipsyPal PROD (Web/Chrome)** → Runs the app in Chrome, connected to the production backend.  
- **TipsyPal DEV (Local Emulator)** → Runs the app against your local Firebase emulator (`http://127.0.0.1:5001/...`).  

### Notes
- PROD configs use:  
BACKEND_URL=https://europe-north1-tipsypal-app.cloudfunctions.net/chat

- DEV config assumes you have started Firebase locally with:  
firebase emulators:start --only functions