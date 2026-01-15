Private Marketplace Tester extension

This small extension helps testing a local Private Marketplace deployment.
# Private Marketplace VS Code Extension

This extension provides a simple command to test the local Private Marketplace deployment and open the marketplace URL.

Commands:
- `privateMarketplace.testDeployment` - checks docker-compose status and attempts an HTTP GET to the marketplace URL defined in `local.env` or `http://localhost`.

Packaging:

1. Install `vsce` if you don't have it: `npm install -g @vscode/vsce`.
2. From the `extension1` folder run: `vsce package` to produce a `.vsix` file.
3. Install in VS Code: `Extensions: Install from VSIX...` and select the generated file.
