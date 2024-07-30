# RecoveryX

### Uploading tests:
 1. Save the test (.htm and .gif files) in the folder backtests
 2. make sure that all the RecoveryX code is commited into git (`git status` does not show untracked or uncommited changes), as the test will be associated to the last commit in git.
 3. get the AWS SSO profile logged in: `aws sso configure` to create the profile or `aws sso login --profile PROFILE_NAME` if already created. If you are not registered as a contributor in the IBTQuant AWS organization, ask Manuel to add you.
 4. execute the script upload_tests.py with the command: `python upload_tests.py --profile=PROFILE_NAME`