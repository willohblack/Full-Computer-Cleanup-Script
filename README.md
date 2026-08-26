# Clean-Restart

A fully silent PowerShell script that resets key personal data on Windows:

- Empties the **Downloads** folder
- Empties the **Recycle Bin**
- Force-closes major browsers
- Clears **history**, **cookies**, **cache**, **sessions**, **local storage**, and **saved passwords** for:
  - Google Chrome
  - Microsoft Edge
  - Brave
  - Opera / Opera GX
  - Mozilla Firefox

After running, you are logged out of virtually all websites and the browser starts in a clean state.

> **Warning**: This is irreversible. All files in Downloads are permanently deleted. Saved browser passwords and most autofill data are removed.

## Usage

### Manual run
```powershell
powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\Path\To\Clean-Computer.ps1"
