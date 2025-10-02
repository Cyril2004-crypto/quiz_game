@echo off
echo Pushing changes to GitHub...
cd /d "c:\Users\HP\quiz_game"
git add .
git commit -m "Update to version 3.1.0: Added dynamic question refresh system - Expanded question pool to 33+ questions across 8 categories - Added Organic Chemistry, Inorganic Chemistry, Mathematics, and Physics questions - Implemented getRandomQuestions() for balanced category distribution - Added Fresh badge in quiz UI - Updated welcome screen with question pool statistics"
git push origin master
echo Done!
pause
