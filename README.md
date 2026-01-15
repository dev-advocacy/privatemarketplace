
# Private Marketplace — Local Quickstart

This repository provides a local Private Marketplace for VS Code (marketplace service + nginx TLS reverse proxy). The reverse proxy terminates TLS and forwards requests to the marketplace service running in a container.

## Table of Contents
- [1. Requirements (including Windows version)](#1-requirements-including-windows-version)
- [2. Install certificate](#2-install-certificate)
- [3. Build the sample and deploy to the right folder](#3-build-the-sample-and-deploy-to-the-right-folder)
- [4. Build / start Docker containers](#4-build--start-docker-containers)
- [5. Install test Group Policy / VS Code settings](#5-install-test-group-policy--vs-code-settings)
- [6. Verify everything is OK](#6-verify-everything-is-ok)
- [7. Troubleshooting](#7-troubleshooting)

---

## 1) Requirements (including Windows version)

- Supported OS: Windows 11 (fully updated). WSL2 must be enabled for Docker Desktop.
- Docker Desktop for Windows with WSL2 backend.
- VS Code 1.104.2 or later (the marketplace image enforces client versions).
- PowerShell (built-in) or PowerShell 7 for running scripts.
- OpenSSL available if you want the `.key` output for nginx. The scripts will try `C:\Program Files\Git\mingw64\bin` (Git for Windows) if `openssl` is not on `PATH`.
- Optional: admin rights to bind host port `443` and to install certificates machine-wide.

---

## 2) Install certificate

### 2.1 Generate certificate files

Run the helper script to generate certs (PFX, CRT and optionally KEY):

```powershell
cd .
powershell -ExecutionPolicy Bypass -File .\scripts\make-cert.ps1
```

Notes:
- Files produced: `certs/privatemarketplace.pfx`, `certs/privatemarketplace.crt`. If OpenSSL is available the script also produces `certs/privatemarketplace.key`.
- The PFX is exported with password `privatemarketplace` (change the script if you need a different password).

### 2.2 Verify OpenSSL (Git for Windows)

If you use OpenSSL bundled with Git for Windows (common), the script will try `C:\Program Files\Git\mingw64\bin` automatically. To verify:

```powershell
Get-Command openssl -ErrorAction SilentlyContinue
openssl version
```

If `openssl` is missing, install Git for Windows or add your OpenSSL binary to `PATH` and re-run `make-cert.ps1` to generate `privatemarketplace.key`.

### 2.3 Install the certificate into Windows Trust

- Install for current user (no elevation required):

```powershell
.\scripts\install-cert.ps1
```

- Install machine-wide (requires elevated PowerShell):

```powershell
# Run PowerShell as Administrator
Start-Process powershell -Verb runAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File .\scripts\install-cert.ps1'
```

Manual install (explicit commands):

```powershell
# Current user
Import-Certificate -FilePath .\certs\privatemarketplace.crt -CertStoreLocation Cert:\CurrentUser\Root

# Machine-wide (elevated)
Import-Certificate -FilePath .\certs\privatemarketplace.crt -CertStoreLocation Cert:\LocalMachine\Root
```

After installing the certificate, restart your browser and VS Code so the changes take effect.

---

## 3) Build the sample and deploy to the right folder

### 3.1 Package your VS Code extension (sample provided)

This repo includes a sample extension in `extension1/` and a packaging helper script `extension1/package-extension.ps1`.

Run the packager from the extension folder (outputs to `artifacts/` by default):

```powershell
cd ./extension1
powershell -ExecutionPolicy Bypass -File .\package-extension.ps1 -OutDir "..\artifacts"
```

This produces `artifacts/gillesg-test.vsix`.
# Private Marketplace — Local Quickstart

This repository provides a local Private Marketplace for VS Code (marketplace service + nginx TLS reverse proxy). The reverse proxy terminates TLS and forwards requests to the marketplace service running in a container.

## Table of Contents
- [1. Requirements (including Windows version)](#1-requirements-including-windows-version)
- [2. Install certificate](#2-install-certificate)
- [3. Build the sample and deploy to the right folder](#3-build-the-sample-and-deploy-to-the-right-folder)
- [4. Build / start Docker containers](#4-build--start-docker-containers)
- [5. Install test Group Policy / VS Code settings](#5-install-test-group-policy--vs-code-settings)
- [6. Verify everything is OK](#6-verify-everything-is-ok)
- [7. Troubleshooting](#7-troubleshooting)

---

## 1) Requirements (including Windows version)

- Supported OS: Windows 10 22H2 or later, or Windows 11 (fully updated). WSL2 must be enabled for Docker Desktop.
- Docker Desktop for Windows with WSL2 backend.
- VS Code 1.104.2 or later (the marketplace image enforces client versions).
- PowerShell (built-in) or PowerShell 7 for running scripts.
- OpenSSL available if you want the `.key` output for nginx. The scripts will try `C:\Program Files\Git\mingw64\bin` (Git for Windows) if `openssl` is not on `PATH`.
- Optional: admin rights to bind host port `443` and to install certificates machine-wide.

---

## 2) Install certificate

### 2.1 Generate certificate files

Run the helper script to generate certs (PFX, CRT and optionally KEY):

```powershell
cd .
powershell -ExecutionPolicy Bypass -File .\scripts\make-cert.ps1
```

Notes:
- Files produced: `certs/privatemarketplace.pfx`, `certs/privatemarketplace.crt`. If OpenSSL is available the script also produces `certs/privatemarketplace.key`.
- The PFX is exported with password `privatemarketplace` (change the script if you need a different password).

### 2.2 Verify OpenSSL (Git for Windows)

If you use OpenSSL bundled with Git for Windows (common), the script will try `C:\Program Files\Git\mingw64\bin` automatically. To verify:

```powershell
Get-Command openssl -ErrorAction SilentlyContinue
openssl version
```

If `openssl` is missing, install Git for Windows or add your OpenSSL binary to `PATH` and re-run `make-cert.ps1` to generate `privatemarketplace.key`.

### 2.3 Install the certificate into Windows Trust

- Install for current user (no elevation required):

```powershell
.\scripts\install-cert.ps1
```

- Install machine-wide (requires elevated PowerShell):

```powershell
# Run PowerShell as Administrator
Start-Process powershell -Verb runAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File .\scripts\install-cert.ps1'
```

Manual install (explicit commands):

```powershell
# Current user
Import-Certificate -FilePath .\certs\privatemarketplace.crt -CertStoreLocation Cert:\CurrentUser\Root

# Machine-wide (elevated)
Import-Certificate -FilePath .\certs\privatemarketplace.crt -CertStoreLocation Cert:\LocalMachine\Root
```

After installing the certificate, restart your browser and VS Code so the changes take effect.

---

## 3) Build the sample and deploy to the right folder

### 3.1 Package your VS Code extension (sample provided)

This repo includes a sample extension in `extension1/` and a packaging helper script `extension1/package-extension.ps1`.

Run the packager from the extension folder (outputs to `artifacts/` by default):

```powershell
cd ./extension1
powershell -ExecutionPolicy Bypass -File .\package-extension.ps1 -OutDir "..\artifacts"
```

This produces `artifacts/gillesg-test.vsix`.

### 3.2 Deploy to the marketplace container

Copy the generated `.vsix` to the `extensions/` folder (the compose mounts `./extensions` into the container):

```powershell
copy .\artifacts\gillesg-test.vsix .\extensions\
```

The `privatemarketplace` container monitors that directory and will load new extensions automatically (check logs).

---

## 4) Build / start Docker containers

### 4.1 Verify `docker-compose.yml` mappings

Default configuration maps host port `443` to nginx container port `443`. If you cannot bind host 443, change mapping to a non-privileged host port (for example `8443:443`).

### 4.2 Start the stack

```powershell
cd .
docker compose up -d
```

### 4.3 Inspect containers and logs

```powershell
docker compose ps
docker compose logs privatemarketplace --tail 200
docker compose logs nginx-proxy --tail 200
```

OpenSSL note: OpenSSL is only required to extract a `.key` file from the generated PFX. The `make-cert.ps1` script attempts to locate OpenSSL under the Git for Windows path `C:\Program Files\Git\mingw64\bin` if it is not already on `PATH`.

---

## 5) Configure via Group Policy (domain)

This deployment assumes you manage VS Code clients centrally via Group Policy or MDM. The `extensionsGallery` configuration must be set via the registry or ADMX policies for your domain so clients pick up the gallery URL and item URLs.

Detailed step-by-step instructions are available in `docs/GPO.md` and the official guide:

- [GPO guidance](docs/GPO.md)
- https://github.com/microsoft/vsmarketplace/blob/main/privatemarketplace/latest/README.md#5-connect-vs-code-to-the-private-marketplace


## 6) Verify everything is OK

```powershell
cd .
curl -vk -H "User-Agent: VSCode/1.104.2" https://localhost/api/v1
```

Expected: HTTP 200 and a JSON capabilities document.

- In VS Code: open Extensions view, perform a search. The local gallery should return results and show your deployed `.vsix` packages.

- If extensions fail to appear, check `docker compose logs privatemarketplace` for messages about loading extensions.

---

## 7) Troubleshooting

### 7.1 Connection closed / ERR_CONNECTION_CLOSED

- Check which process uses host port 443:

```powershell
Get-NetTCPConnection -LocalPort 443 -ErrorAction SilentlyContinue | Select-Object LocalAddress, LocalPort, State, OwningProcess
Get-Process -Id (Get-NetTCPConnection -LocalPort 443 -ErrorAction SilentlyContinue).OwningProcess -ErrorAction SilentlyContinue
```

Or:

```powershell
netstat -ano | Select-String ":443"
# then Get-Process -Id <PID>
```

If a system service (IIS, Apache) uses port 443, stop or reconfigure it, or change `docker-compose.yml` to use a different host port (e.g. `8443:443`).

### 7.2 Docker cannot bind host port 443

- Free the port or run the process with proper privileges. On Windows, ensure Docker Desktop can bind the port; consider using a non-privileged host port.

### 7.3 Certificate errors in browser or VS Code

- Confirm certificate imported into the correct store (`CurrentUser\\Root` or `LocalMachine\\Root`). Restart apps.

### 7.4 "Access denied: Only VS Code clients version 1.104.2 or later are allowed."

- Ensure the client sends a recent `User-Agent`. For scripts use `-H "User-Agent: VSCode/1.104.2"`. For VS Code, update to a supported version.

### 7.5 Extensions not visible

- Confirm `.vsix` files exist in `extensions/` and that the container mounted path is correct. Look for extension-loading logs in `privatemarketplace` container logs.

### 7.6 Generate `.key` if missing

- If `make-cert.ps1` did not create `certs/privatemarketplace.key` because OpenSSL was not available, install Git for Windows or OpenSSL and run:

```powershell
openssl pkcs12 -in .\\certs\\privatemarketplace.pfx -nodes -passin pass:privatemarketplace -out .\\certs\\temp.pem
openssl pkey -in .\\certs\\temp.pem -out .\\certs\\privatemarketplace.key
Remove-Item .\\certs\\temp.pem
```

### 7.7 Useful quick commands

```powershell
# Start/stop stack
cd .
docker compose up -d
docker compose down --remove-orphans

# Check containers
docker compose ps

# View logs
docker compose logs privatemarketplace --tail 200
docker compose logs nginx-proxy --tail 200

# Test endpoint
curl -vk -H "User-Agent: VSCode/1.104.2" https://localhost/api/v1
```

---

If you want, I can:
- Run a check now to see if port 443 is in use on your machine and paste the output.
- Re-run `make-cert.ps1` so it picks up OpenSSL from Git for Windows and creates `privatemarketplace.key`.
- Modify `docker-compose.yml` to use a non-443 host port and update docs accordingly.

Tell me which action you want me to take next.
Get-NetTCPConnection -LocalPort 443 -ErrorAction SilentlyContinue | Select-Object LocalAddress, LocalPort, State, OwningProcess
Get-Process -Id (Get-NetTCPConnection -LocalPort 443 -ErrorAction SilentlyContinue).OwningProcess -ErrorAction SilentlyContinue
```

Or:

```powershell
netstat -ano | Select-String ":443"
# then Get-Process -Id <PID>
```

- If a system service (IIS, Apache) uses port 443, stop or reconfigure it, or change `docker-compose.yml` to use a different host port (e.g. `8443:443`).

7.2 Docker cannot bind host port 443

- Free the port or run the process with proper privileges. On Windows, ensure Docker Desktop can bind the port; consider using a non-privileged host port.

7.3 Certificate errors in browser or VS Code

- Confirm certificate imported into the correct store (`CurrentUser\Root` or `LocalMachine\Root`). Restart apps.

7.4 "Access denied: Only VS Code clients version 1.104.2 or later are allowed."

- Ensure the client sends a recent `User-Agent`. For scripts use `-H "User-Agent: VSCode/1.104.2"`. For VS Code, update to a supported version.

7.5 Extensions not visible

- Confirm `.vsix` files exist in `extensions/` and that the container mounted path is correct. Look for extension-loading logs in `privatemarketplace` container logs.

7.6 Generate `.key` if missing

- If `make-cert.ps1` did not create `certs/privatemarketplace.key` because OpenSSL was not available, install Git for Windows or OpenSSL and run:

```powershell
openssl pkcs12 -in .\certs\privatemarketplace.pfx -nodes -passin pass:privatemarketplace -out .\certs\temp.pem
openssl pkey -in .\certs\temp.pem -out .\certs\privatemarketplace.key
Remove-Item .\certs\temp.pem
```

7.7 Useful quick commands

```powershell
# Start/stop stack
cd D:\DEV\DE.VS\privatemarketplace
docker compose up -d
docker compose down --remove-orphans

# Check containers
4. Get the API service URL: https://localhost/api/v1

# View logs
5. Configure VS Code via Group Policy or local `settings.json` to use `extensionsGallery` (see sections below)


# Test endpoint
curl -vk -H "User-Agent: VSCode/1.104.2" https://localhost/api/v1
```

---

If you want, I can:
- Run a check now to see if port 443 is in use on your machine and paste the output.
- Re-run `make-cert.ps1` so it picks up OpenSSL from Git for Windows and creates `privatemarketplace.key`.
- Modify `docker-compose.yml` to use a non-443 host port and update docs accordingly.

Tell me which action you want me to take next.
Useful commands:

```powershell
cd .
curl -v https://localhost/api/v1
```

Note: VS Code requires HTTPS for galleries; the supplied nginx reverse proxy listens on port `443` and forwards requests to the container. For simple local use, install the self-signed certificate into Windows/Edge so VS Code trusts it.

Automatic certificate generation
--------------------------------

A PowerShell script `scripts/make-cert.ps1` is provided to generate a self-signed certificate and extract PEM files. Run:

```powershell
cd .
powershell -ExecutionPolicy Bypass -File .\scripts\make-cert.ps1
```

This creates `certs/privatemarketplace.pfx`, `certs/privatemarketplace.crt` and `certs/privatemarketplace.key`. The `make-cert.ps1` script uses the password `privatemarketplace` when exporting the PFX.

Install the certificate as a trusted root
----------------------------------------

To avoid prompts from VS Code when connecting to the local gallery, install the certificate into the Windows Trusted Root store:

1. For the current user (no elevation required):

```powershell
cd d:\DEV\DE.VS\privatemarketplace
powershell -ExecutionPolicy Bypass -File .\scripts\install-cert.ps1
```

2. To install machine-wide for all users, run the same script from an elevated PowerShell prompt.

After installation, restart VS Code for it to pick up the trust change.

Testing
-------

Verify that the API and reverse proxy are working correctly:

- From the host, test the public API endpoint:

```powershell
cd d:\DEV\DE.VS\privatemarketplace
curl -v https://localhost/api/v1
```

If you are using a self-signed certificate and you haven't installed `privatemarketplace.crt` into the Windows trust store, add `-k` to ignore TLS verification:

```powershell
curl -vk https://localhost/api/v1
```

Important note: the Private Marketplace image enforces a client check based on the VS Code version. If the request does not include a `User-Agent` header that matches a recent VS Code version, the server may return "Access denied: Only VS Code clients version 1.104.2 or later are allowed." To test the API manually without VS Code, simulate a compatible User-Agent:

```powershell
curl -vk -H "User-Agent: VSCode/1.104.2" https://localhost/api/v1
```

This should return HTTP 200 and a JSON description of the API resources.

If you still see 4xx/5xx errors, check the Docker Compose logs to diagnose:

```powershell
docker compose logs privatemarketplace --tail 200
docker compose logs nginx-proxy --tail 200
```

Host port 443 notes
--------------------

- Binding host port `443` requires that no other process on the host is listening on that port (for example IIS, Apache, or other services). If `docker compose up` fails with address-in-use or your browser shows "connection closed", check which process is using port 443 and stop it or choose a different host port.

- To list the process using port 443 on Windows (PowerShell):

```powershell
Get-NetTCPConnection -LocalPort 443 -ErrorAction SilentlyContinue | Select-Object LocalAddress, LocalPort, State, OwningProcess
Get-Process -Id (Get-NetTCPConnection -LocalPort 443 -ErrorAction SilentlyContinue).OwningProcess -ErrorAction SilentlyContinue
```

- If you prefer not to use host port 443, change the nginx mapping in `docker-compose.yml` (for example `8443:443`) and keep README curl examples using the explicit port.

- After changing certificates or adding the certificate to the Windows trust store, restart your browser or VS Code so the new trust is taken into account.

Additional testing steps
------------------------

- Start the stack and check both containers are running:

```powershell
cd d:\DEV\DE.VS\privatemarketplace
docker compose ps
```

- Test the API and simulate a VS Code client:

```powershell
curl -vk -H "User-Agent: VSCode/1.104.2" https://localhost/api/v1
```

If you want, I can:
- Check which host process is using port 443 on your machine now and paste the output here.
- Provide commands to install the certificate into the Windows trust store (or run them for you).
- Reconfigure the stack to use a different host port (e.g., 8443) and update the docs accordingly.
curl -vk -H "User-Agent: VSCode/1.104.2" https://localhost/api/v1
```

