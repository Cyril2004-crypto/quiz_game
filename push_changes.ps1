Set-Location "c:\Users\HP\quiz_game"
Write-Host "Current directory: $(Get-Location)"
Write-Host "Git status:"
git status
Write-Host "Adding changes..."
git add .
Write-Host "Committing changes..."
git commit -m "Update to version 3.1.0: Added dynamic question refresh system with expanded question pool"
Write-Host "Pushing to GitHub..."
git push origin master
Write-Host "Done!"
