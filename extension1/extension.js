const vscode = require('vscode');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');
const http = require('http');

function activate(context) {
  const disposable = vscode.commands.registerCommand('privateMarketplace.testDeployment', async function () {
    const workspaceRoot = vscode.workspace.workspaceFolders && vscode.workspace.workspaceFolders[0].uri.fsPath;
    if (!workspaceRoot) {
      vscode.window.showErrorMessage('Open the workspace containing the Private Marketplace project first.');
      return;
    }

    const localEnv = path.join(workspaceRoot, 'local.env');
    let url = 'http://localhost';
    try {
      if (fs.existsSync(localEnv)) {
        const content = fs.readFileSync(localEnv, 'utf8');
        const match = content.match(/MARKETPLACE_URL=(.*)/);
        if (match) url = match[1].trim();
      }
    } catch (err) {}

    const composeFile = path.join(workspaceRoot, 'docker-compose.yml');
    let dockerOk = false;
    if (fs.existsSync(composeFile)) {
      try {
        await new Promise((resolve) => {
          exec('docker compose ps', { cwd: workspaceRoot }, (error, stdout, stderr) => {
            if (error) {
              vscode.window.showWarningMessage('docker compose check failed: ' + error.message);
              resolve();
              return;
            }
            const isUp = stdout && stdout.toLowerCase().includes('up');
            dockerOk = Boolean(isUp);
            resolve();
          });
        });
      } catch (e) {}
    }

    const result = await new Promise((resolve) => {
      const req = http.get(url, (res) => {
        resolve({ status: res.statusCode, ok: res.statusCode >= 200 && res.statusCode < 400 });
      });
      req.on('error', (err) => resolve({ error: err.message }));
      req.setTimeout(5000, () => {
        req.abort();
        resolve({ error: 'timeout' });
      });
    });

    if (result.error) {
      const msg = `Marketplace URL ${url} unreachable: ${result.error}`;
      vscode.window.showErrorMessage(msg);
      return;
    }

    const statusMsg = `Marketplace ${url} responded ${result.status}` + (dockerOk ? ' (docker compose shows services up)' : '');
    const open = 'Open in browser';
    const choice = await vscode.window.showInformationMessage(statusMsg, open);
    if (choice === open) {
      vscode.env.openExternal(vscode.Uri.parse(url));
    }
  });
  context.subscriptions.push(disposable);
}

function deactivate() {}

module.exports = { activate, deactivate };
