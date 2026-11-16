@echo off
cd /d "%~dp0"
if not exist .env copy .env.example .env >nul
where node >nul 2>nul || (echo Instale Node.js 20+ & pause & exit /b 1)
start "" "http://127.0.0.1:4178"
node server.mjs
pause
