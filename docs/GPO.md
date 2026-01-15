# Configure VS Code via Group Policy / ADMX (private marketplace)

This document explains how to deploy the `extensionsGallery` configuration to Windows clients using Group Policy (ADMX) or a registry deployment for testing. For authoritative policy names and the official guidance, see:

- https://github.com/microsoft/vsmarketplace/blob/main/privatemarketplace/latest/README.md#5-connect-vs-code-to-the-private-marketplace

Summary
- Recommended: import the official VS Code ADMX/ADML templates into your Group Policy Central Store and configure the `Extensions Gallery`/`extensionsGallery` policy using the Group Policy Management Editor.
- Alternative (testing or lightweight): deploy the equivalent registry value via Group Policy Preferences (Registry) or a script.

1) Using ADMX (recommended)

- Download the VS Code ADMX/ADML files from the official VS Code documentation or from the link above.
- Copy the ADMX file(s) to your domain Central Store (`%SYSVOL%\domain\Policies\PolicyDefinitions`) and the matching ADML files to the language folder (for example `en-US`).
- Open the Group Policy Management Console (GPMC) and create a new GPO (or edit an existing one) scoped to the OU containing your Windows clients.
- In the GPO editor, go to `Computer Configuration` → `Policies` → `Administrative Templates` and find the Visual Studio Code policy group. Locate the policy for configuring the Extensions Gallery (the ADMX will expose a policy that accepts the JSON/value for `extensionsGallery`).
- Edit the policy and paste the JSON object that configures your private marketplace. Example JSON (replace placeholders with your actual endpoints):

```
{
  "serviceUrl": "https://localhost/api/v1",
  "itemUrl": "https://localhost/item",
  "controlUrl": "https://localhost/api/v1",
  "recommendationsUrl": "https://localhost/recommendations"
}
```

- Apply the GPO; clients will pick up the policy at the next policy refresh (or force with `gpupdate /force`).

2) Using Registry / Group Policy Preferences (for testing)

- If you prefer to deploy the policy as a registry value, use Group Policy Preferences (GPP) → `Preferences` → `Windows Settings` → `Registry` to create a new registry item.
- The exact registry key name and value type are defined by the ADMX shipped with VS Code — consult the ADMX or the official link above for the authoritative path and value name. If you need a quick test and understand the risk, you can deploy a string value that matches the policy's expected JSON payload.

Example (illustrative only — verify the key name from the ADMX before applying to production):

PowerShell (example to run locally for testing):

```powershell
$json = '{"serviceUrl":"https://localhost/api/v1","itemUrl":"https://localhost/item","controlUrl":"https://localhost/api/v1"}'
New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft -Name "VisualStudioCode" -Force | Out-Null
Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\VisualStudioCode -Name "extensionsGallery" -Value $json -Type String
```

Important notes
- Always validate the ADMX names and registry paths from the official ADMX/ADML files or the linked Microsoft guidance before deploying widely.
- After applying the policy, restart VS Code or wait for the policy to take effect; you can use `gpupdate /force` on clients to speed this up.
- For internal/private marketplaces using self-signed certificates, ensure the certificate is installed in the appropriate trust store (machine `Trusted Root Certification Authorities`) so VS Code can establish HTTPS connections to your private gallery.

References
- Official guidance and examples: https://github.com/microsoft/vsmarketplace/blob/main/privatemarketplace/latest/README.md#5-connect-vs-code-to-the-private-marketplace
